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
  }
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
  if (!sale || !sale.invoiceId) {
    return res.status(400).json({ error: 'Invalid sale payload: invoiceId required' });
  }

  // Persist to local JSON ledger
  try {
    let sales = [];
    if (fs.existsSync(SALES_LOG_PATH)) {
      sales = JSON.parse(fs.readFileSync(SALES_LOG_PATH, 'utf8') || '[]');
    }
    sales.push({ ...sale, receivedAt: new Date().toISOString() });
    fs.writeFileSync(SALES_LOG_PATH, JSON.stringify(sales, null, 2));
  } catch (err) {
    console.error('Failed to append sale log:', err);
  }

  // Real-time broadcast to all connected Manager apps & POS terminals
  io.emit('sale_event', sale);
  res.status(201).json({ success: true, invoiceId: sale.invoiceId });
});

// 3. OTA Catalog & Price Push
app.post('/ota/push', (req, res) => {
  const payload = req.body;
  io.emit('catalog_update', payload);
  res.json({ success: true, broadcastCount: io.engine.clientsCount });
});

// WebSocket Connection & Roster Management
io.on('connection', (socket) => {
  const terminalId = socket.handshake.query.terminalId || `terminal_${socket.id}`;
  activeTerminals.set(socket.id, {
    terminalId,
    connectedAt: new Date().toISOString(),
    ip: socket.handshake.address
  });

  io.emit('terminal_roster_update', Array.from(activeTerminals.values()));

  socket.on('disconnect', () => {
    activeTerminals.delete(socket.id);
    io.emit('terminal_roster_update', Array.from(activeTerminals.values()));
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`[OmniSync] Real-time synchronization daemon running on 0.0.0.0:${PORT}`);
});
