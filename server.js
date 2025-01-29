const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const MAX_HISTORY_LENGTH = 20;
let messageHistory = [];

wss.on('connection', (ws) => {
  console.log('New client connected!');
  
  // Send message history to the new client
  ws.send(JSON.stringify({ history: messageHistory }));

  ws.on('message', (message) => {
    let data;
    try {
      data = JSON.parse(message);
    } catch (error) {
      console.error('Invalid message format:', error);
      return;
    }

    const { player, message: msg } = data;
    if (!player || !msg) {
      console.error('Invalid message structure');
      return;
    }

    console.log(`Received message from ${player}: ${msg}`);

    // Add message to history and limit size
    messageHistory.push({ player, message: msg });
    if (messageHistory.length > MAX_HISTORY_LENGTH) {
      messageHistory.shift();
    }

    // Broadcast to all clients except the sender
    wss.clients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(JSON.stringify({ player, message: msg }));
      }
    });
  });

  ws.on('close', () => {
    console.log('Client disconnected.');
  });
});

server.listen(8080, () => {
  console.log('WebSocket server running on port 8080.');
});
