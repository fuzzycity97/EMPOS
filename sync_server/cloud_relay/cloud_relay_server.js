// OmniSys Cloud Relay Service (Node.js)
// Minimal, zero-dependency, standalone cloud relay for syncing subscription & capability
// toggles from the Super-Admin panel to remote clinic application instances.

const http = require('http');
const crypto = require('crypto');

const PORT = parseInt(process.env.CLOUD_RELAY_PORT || '4040', 10);
const HOST = process.env.CLOUD_RELAY_HOST || '0.0.0.0';

// In-Memory State
const clinicSockets = new Map(); // accountId -> Set<WebSocketConnection>
const adminSockets = new Set();  // Set<WebSocketConnection>
const offlineQueues = new Map(); // accountId -> Array<SubscriptionEvent>
const accountPresence = new Map(); // accountId -> { isOnline, lastSeen, connectedTerminals }

// -----------------------------------------------------------------------------
// RFC 6455 WebSocket Implementation (Zero External Dependencies)
// -----------------------------------------------------------------------------
class WebSocketConnection {
  constructor(socket) {
    this.socket = socket;
    this.isClosed = false;
    this.role = null;
    this.accountId = null;
    this.instanceId = null;
    this.adminId = null;
    this.buffer = Buffer.alloc(0);

    socket.on('data', (chunk) => this._handleData(chunk));
    socket.on('close', () => this._handleClose());
    socket.on('error', (err) => {
      console.error('[RelaySocket Error]', err.message);
      this._handleClose();
    });
  }

  send(data) {
    if (this.isClosed || !this.socket.writable) return;
    const payload = Buffer.from(typeof data === 'string' ? data : JSON.stringify(data), 'utf8');
    const length = payload.length;

    let header;
    if (length <= 125) {
      header = Buffer.from([0x81, length]);
    } else if (length <= 65535) {
      header = Buffer.alloc(4);
      header[0] = 0x81;
      header[1] = 126;
      header.writeUInt16BE(length, 2);
    } else {
      header = Buffer.alloc(10);
      header[0] = 0x81;
      header[1] = 127;
      header.writeBigUInt64BE(BigInt(length), 2);
    }

    try {
      this.socket.write(Buffer.concat([header, payload]));
    } catch (e) {
      console.error('[Send Error]', e.message);
    }
  }

  close() {
    if (this.isClosed) return;
    this.isClosed = true;
    try {
      // Send close frame
      this.socket.write(Buffer.from([0x88, 0x00]));
      this.socket.end();
    } catch (_) {}
  }

  _handleData(chunk) {
    this.buffer = Buffer.concat([this.buffer, chunk]);
    while (this.buffer.length >= 2) {
      const firstByte = this.buffer[0];
      const secondByte = this.buffer[1];

      const opcode = firstByte & 0x0f;
      const isMasked = (secondByte & 0x80) !== 0;
      let payloadLength = secondByte & 0x7f;
      let offset = 2;

      if (payloadLength === 126) {
        if (this.buffer.length < 4) return;
        payloadLength = this.buffer.readUInt16BE(2);
        offset = 4;
      } else if (payloadLength === 127) {
        if (this.buffer.length < 10) return;
        payloadLength = Number(this.buffer.readBigUInt64BE(2));
        offset = 10;
      }

      let maskingKey = null;
      if (isMasked) {
        if (this.buffer.length < offset + 4) return;
        maskingKey = this.buffer.subarray(offset, offset + 4);
        offset += 4;
      }

      if (this.buffer.length < offset + payloadLength) return;

      let payload = this.buffer.subarray(offset, offset + payloadLength);
      this.buffer = this.buffer.subarray(offset + payloadLength);

      if (isMasked && maskingKey) {
        const unmasked = Buffer.alloc(payload.length);
        for (let i = 0; i < payload.length; i++) {
          unmasked[i] = payload[i] ^ maskingKey[i % 4];
        }
        payload = unmasked;
      }

      if (opcode === 0x08) {
        // Connection Close
        this.close();
        return;
      } else if (opcode === 0x09) {
        // Ping -> respond with Pong (opcode 0x0A)
        if (this.socket.writable) {
          this.socket.write(Buffer.concat([Buffer.from([0x8A, payload.length]), payload]));
        }
      } else if (opcode === 0x01) {
        // Text Frame
        const text = payload.toString('utf8');
        try {
          const message = JSON.parse(text);
          this._dispatchMessage(message);
        } catch (err) {
          console.warn('[Relay Warning] Received non-JSON payload:', text.substring(0, 100));
        }
      }
    }
  }

  _handleClose() {
    if (this.isClosed) return;
    this.isClosed = true;

    if (this.role === 'clinic' && this.accountId) {
      const set = clinicSockets.get(this.accountId);
      if (set) {
        set.delete(this);
        const count = set.size;
        if (count === 0) {
          clinicSockets.delete(this.accountId);
          accountPresence.set(this.accountId, {
            isOnline: false,
            lastSeen: new Date().toISOString(),
            connectedTerminals: 0,
          });
          broadcastPresence(this.accountId, false, 0);
        } else {
          accountPresence.set(this.accountId, {
            isOnline: true,
            lastSeen: new Date().toISOString(),
            connectedTerminals: count,
          });
          broadcastPresence(this.accountId, true, count);
        }
      }
    } else if (this.role === 'admin') {
      adminSockets.delete(this);
    }
  }

  _dispatchMessage(msg) {
    if (!msg || !msg.type) return;

    switch (msg.type) {
      case 'register':
        this._handleRegister(msg);
        break;

      case 'subscription_toggle':
        this._handleSubscriptionToggle(msg);
        break;

      case 'ack_batch':
      case 'ack_update':
        this._handleClinicAck(msg);
        break;

      case 'get_presence':
        this._handleGetPresence(msg);
        break;

      case 'ping':
        this.send({ type: 'pong', timestamp: new Date().toISOString() });
        break;

      default:
        console.log('[Relay] Unrecognized message type:', msg.type);
    }
  }

  _handleRegister(msg) {
    this.role = msg.role;

    if (msg.role === 'clinic') {
      const accountId = msg.accountId || 'acc_default';
      this.accountId = accountId;
      this.instanceId = msg.instanceId || '1';

      if (!clinicSockets.has(accountId)) {
        clinicSockets.set(accountId, new Set());
      }
      clinicSockets.get(accountId).add(this);

      const count = clinicSockets.get(accountId).size;
      accountPresence.set(accountId, {
        isOnline: true,
        lastSeen: new Date().toISOString(),
        connectedTerminals: count,
      });

      console.log(`[Relay] Clinic connected: ${accountId} (Terminal ${this.instanceId}, Total: ${count})`);
      broadcastPresence(accountId, true, count);

      // Check for queued offline events
      const queue = offlineQueues.get(accountId) || [];
      this.send({
        type: 'registered',
        role: 'clinic',
        accountId: accountId,
        pendingCount: queue.length,
        timestamp: new Date().toISOString(),
      });

      if (queue.length > 0) {
        console.log(`[Relay] Flushing ${queue.length} queued events to ${accountId}`);
        this.send({
          type: 'subscription_batch_update',
          accountId: accountId,
          events: queue,
        });
      }
    } else if (msg.role === 'admin') {
      this.adminId = msg.adminId || 'superadmin';
      adminSockets.add(this);
      console.log(`[Relay] Super-Admin connected: ${this.adminId}`);

      // Return presence map to admin
      const presenceList = [];
      for (const [accId, pres] of accountPresence.entries()) {
        presenceList.push({ accountId: accId, ...pres });
      }

      this.send({
        type: 'registered',
        role: 'admin',
        adminId: this.adminId,
        activeClinics: presenceList,
        timestamp: new Date().toISOString(),
      });
    }
  }

  _handleSubscriptionToggle(msg) {
    const { accountId, action, targetKey, newValue, adminId, timestamp, eventId } = msg;
    if (!accountId) {
      this.send({ type: 'error', message: 'Missing accountId in subscription_toggle' });
      return;
    }

    const event = {
      eventId: eventId || `evt_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
      accountId,
      action,
      targetKey,
      newValue,
      adminId: adminId || this.adminId || 'superadmin',
      timestamp: timestamp || new Date().toISOString(),
    };

    const activeClinicSet = clinicSockets.get(accountId);
    const isClinicOnline = activeClinicSet && activeClinicSet.size > 0;

    if (isClinicOnline) {
      // Deliver live to all connected clinic instances
      for (const conn of activeClinicSet) {
        conn.send({
          type: 'subscription_update',
          ...event,
        });
      }
      console.log(`[Relay] Live delivered toggle to online clinic ${accountId}: ${targetKey} -> ${newValue}`);

      this.send({
        type: 'ack',
        eventId: event.eventId,
        accountId: accountId,
        deliveryStatus: 'delivered',
        timestamp: new Date().toISOString(),
      });
    } else {
      // Clinic is offline: Queue the change server-side
      if (!offlineQueues.has(accountId)) {
        offlineQueues.set(accountId, []);
      }
      offlineQueues.get(accountId).push(event);
      console.log(`[Relay] Clinic ${accountId} is OFFLINE. Queued toggle: ${targetKey} -> ${newValue} (Queue size: ${offlineQueues.get(accountId).length})`);

      this.send({
        type: 'ack',
        eventId: event.eventId,
        accountId: accountId,
        deliveryStatus: 'queued',
        queueSize: offlineQueues.get(accountId).length,
        timestamp: new Date().toISOString(),
      });
    }
  }

  _handleClinicAck(msg) {
    const accountId = this.accountId;
    if (!accountId || !offlineQueues.has(accountId)) return;

    if (msg.eventIds && Array.isArray(msg.eventIds)) {
      const ackedSet = new Set(msg.eventIds);
      const remaining = offlineQueues.get(accountId).filter(e => !ackedSet.has(e.eventId));
      offlineQueues.set(accountId, remaining);
      console.log(`[Relay] Acknowledged batch for ${accountId}. Remaining queue: ${remaining.length}`);
    } else if (msg.eventId) {
      const remaining = offlineQueues.get(accountId).filter(e => e.eventId !== msg.eventId);
      offlineQueues.set(accountId, remaining);
    }
  }

  _handleGetPresence(msg) {
    const presenceList = [];
    for (const [accId, pres] of accountPresence.entries()) {
      const queue = offlineQueues.get(accId) || [];
      presenceList.push({
        accountId: accId,
        ...pres,
        queuedCount: queue.length,
      });
    }
    this.send({
      type: 'presence_list',
      accounts: presenceList,
    });
  }
}

function broadcastPresence(accountId, isOnline, terminalCount) {
  const msg = {
    type: 'presence_update',
    accountId,
    isOnline,
    connectedTerminals: terminalCount,
    timestamp: new Date().toISOString(),
  };
  for (const admin of adminSockets) {
    admin.send(msg);
  }
}

// -----------------------------------------------------------------------------
// HTTP REST Server & WebSocket Upgrade Dispatcher
// -----------------------------------------------------------------------------
const server = http.createServer((req, res) => {
  const url = req.url || '/';

  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (url === '/health' || url === '/') {
    let totalClinics = 0;
    for (const set of clinicSockets.values()) {
      totalClinics += set.size;
    }
    let totalQueued = 0;
    for (const q of offlineQueues.values()) {
      totalQueued += q.length;
    }

    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      service: 'omnisys-cloud-relay',
      status: 'healthy',
      uptimeSeconds: Math.floor(process.uptime()),
      connectedClinics: totalClinics,
      connectedAdmins: adminSockets.size,
      totalQueuedEvents: totalQueued,
      timestamp: new Date().toISOString(),
    }));
    return;
  }

  if (url.startsWith('/presence/')) {
    const accountId = url.replace('/presence/', '').trim();
    const pres = accountPresence.get(accountId) || { isOnline: false, lastSeen: null, connectedTerminals: 0 };
    const queue = offlineQueues.get(accountId) || [];
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      accountId,
      ...pres,
      queuedCount: queue.length,
    }));
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'Not Found' }));
});

// Handle WebSocket Upgrade
server.on('upgrade', (req, socket, head) => {
  const upgradeHeader = req.headers['upgrade'];
  if (!upgradeHeader || upgradeHeader.toLowerCase() !== 'websocket') {
    socket.destroy();
    return;
  }

  const key = req.headers['sec-websocket-key'];
  if (!key) {
    socket.destroy();
    return;
  }

  const GUID = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11';
  const acceptKey = crypto.createHash('sha1').update(key + GUID).digest('base64');

  const responseHeaders = [
    'HTTP/1.1 101 Switching Protocols',
    'Upgrade: websocket',
    'Connection: Upgrade',
    `Sec-WebSocket-Accept: ${acceptKey}`,
  ];

  socket.write(responseHeaders.join('\r\n') + '\r\n\r\n');
  new WebSocketConnection(socket);
});

server.listen(PORT, HOST, () => {
  console.log(`[CloudRelay] Service running on http://${HOST}:${PORT} (WebSocket ready)`);
});

// Clean termination handling
process.on('SIGINT', () => {
  console.log('[CloudRelay] Shutting down...');
  server.close(() => process.exit(0));
});
process.on('SIGTERM', () => {
  console.log('[CloudRelay] Shutting down...');
  server.close(() => process.exit(0));
});
