const express = require('express');
const http = require('http');
const WebSocket = require('ws');

const app = express();
const server = http.createServer(app);

const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('New client connected!');

  ws.on('message', (message) => {
    const [playerName, ...messageParts] = message.split(': ');
    const playerMessage = messageParts.join(': ');

    console.log(`Received message from ${playerName}: ${playerMessage}`);

    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(`${playerName}: ${playerMessage}`);
      }
    });
  });

  ws.on('close', () => {
    console.log('Client disconnected.');
  });
});

server.listen(8080, () => {
  console.log('WebSocket server running on port: 8080.');
});
