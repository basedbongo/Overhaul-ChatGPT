const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('New client connected!');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      const playerName = data.player;
      const msg = data.message;
      console.log(`Received message from ${playerName}: ${msg}`);

      wss.clients.forEach(client => {
        client.send(JSON.stringify({ player: playerName, message: msg }));
      });
    } catch (error) {
      console.error("Error parsing message:", error);
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected.');
  });
});

server.listen(8080, () => {
  console.log('WebSocket server running on port: 8080.');
});
