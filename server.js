const express = require('express');
const http = require('http');
const WebSocket = require('ws');

//init express and http server
const app = express();
const server = http.createServer(app);

//init websocket
const wss = new WebSocket.Server({ server });

wss.on('connection', (ws) => {
  console.log('New client connected');

  //handle incoming messages from clients
  ws.on('message', (message) => {
    console.log(`Received message => ${message}`);

    //broadcast the message to all clients
    wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(message);
      }
    });
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

server.listen(8080, () => {
  console.log('WebSocket server running on port 8080');
});
