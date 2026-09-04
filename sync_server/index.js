const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const fs = require('fs');
const path = require('path');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  },
  pingInterval: 5000,
  pingTimeout: 3000,
});

app.use(express.json());

const SALES_LOG_PATH = path.join(__dirname, 'sales_log.json');
const activeTerminals = new Map();

// 1. Health & Status endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    version: '1.0.0',
    uptimeSeconds: Math.floor(process.processUptime ? process.processUptime() : process.uptime()),
    connectedTerminals: io.engine.clientsCount,
    timestamp: new Date().toISOString()
  });
});

// 2. Process & broadcast new sale transaction
app.post('/sale', (req, res) => {
  const sale = req.body;
  if (!sale || (!sale.invoiceId && !sale.id)) {
    return res.status(400).json({ error: 'Invalid sale payload: invoiceId or id required' });
  }

  const transactionId = sale.invoiceId || sale.id;
  const payload = {
    transactionId,
    invoiceId: transactionId,
    departmentId: sale.departmentId || 'retail_main',
    dept: sale.dept || 'Main Store',
    patient: sale.patient || sale.customerName || 'Walk-In Customer',
    amount: sale.grossTotal || sale.amount || 0.0,
    grossTotal: sale.grossTotal || sale.amount || 0.0,
    netTotal: sale.netTotal || sale.amount || 0.0,
    time: 'Just now',
    timestamp: new Date().toISOString(),
    status: sale.status || 'PAID',
    items: sale.items || [],
    providerCommissions: sale.providerCommissions || {},
  };

  // Persist to local JSON ledger
  try {
    let sales = [];
    if (fs.existsSync(SALES_LOG_PATH)) {
      sales = JSON.parse(fs.readFileSync(SALES_LOG_PATH, 'utf8') || '[]');
    }
    sales.push(payload);
    fs.writeFileSync(SALES_LOG_PATH, JSON.stringify(sales, null, 2));
  } catch (err) {
    console.error('Failed to append sale log:', err);
  }

  // Real-time broadcast to all connected Manager apps & POS terminals
  io.emit('sale_event', payload);
  res.status(201).json({ success: true, transactionId });
});

// 3. OTA Catalog & Price Push
app.post('/ota/push', (req, res) => {
  const payload = req.body;
  io.emit('catalog_update', payload);
  res.json({ success: true, broadcastCount: io.engine.clientsCount });
});

// WebSocket Connection & Real-Time Lifecycle Audit Stream
io.on('connection', (socket) => {
  const terminalId = socket.handshake.query.terminalId || `terminal_${socket.id}`;
  const ip = socket.handshake.address;
  const timestamp = new Date().toISOString();

  activeTerminals.set(socket.id, {
    terminalId,
    connectedAt: timestamp,
    ip
  });

  // Broadcast connection log event to all connected monitoring dashboards
  io.emit('connection_log_event', {
    type: 'CONNECTED',
    terminalId,
    ip,
    timestamp,
    activeCount: io.engine.clientsCount
  });

  io.emit('terminal_roster_update', Array.from(activeTerminals.values()));

  socket.on('disconnect', (reason) => {
    activeTerminals.delete(socket.id);
    io.emit('connection_log_event', {
      type: 'DISCONNECTED',
      terminalId,
      ip,
      reason: reason || 'Client Disconnected',
      timestamp: new Date().toISOString(),
      activeCount: io.engine.clientsCount
    });
    io.emit('terminal_roster_update', Array.from(activeTerminals.values()));
  });
});

// Graceful Termination: broadcast server_shutdown, disconnect clients, close server
let isShuttingDown = false;
function gracefulShutdown(signal) {
  if (isShuttingDown) return;
  isShuttingDown = true;

  console.log(`[OmniSync] Received ${signal}. Initiating graceful teardown...`);
  
  // 1. Broadcast server_shutdown event to all connected clients
  io.emit('server_shutdown', {
    timestamp: new Date().toISOString(),
    signal: signal,
    reason: 'Host server shutting down gracefully'
  });

  // 2. Close all active socket connections gracefully
  io.disconnectSockets(true);

  // 3. Close the HTTP server and exit
  server.close(() => {
    console.log('[OmniSync] Server closed successfully. Exiting process.');
    process.exit(0);
  });

  // Failsafe timeout in case cleanup hangs
  setTimeout(() => {
    console.warn('[OmniSync] Forced exit after shutdown timeout.');
    process.exit(0);
  }, 2500).unref();
}

process.on('SIGINT', () => gracefulShutdown('SIGINT'));
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`[OmniSync] Real-time synchronization daemon running on 0.0.0.0:${PORT}`);
});

module.exports = { app, server, io, gracefulShutdown };