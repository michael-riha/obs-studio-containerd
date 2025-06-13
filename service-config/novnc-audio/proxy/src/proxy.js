const express = require('express');
const ws = require('ws');
const dgram = require('dgram');
const app = express();

// Configuration
const PORT = 8888;
const UDP_PORT = 1234;

// WebSocket clients
const audioClients = new Set();

// Create HTTP server
const server = app.listen(PORT, () => {
  console.log(`WebSocket proxy listening on port ${PORT}`);
});

// Create WebSocket server
const wss = new ws.Server({ server });

// Serve simple test page
app.get('/', (req, res) => {
  // res.send(`
  //   <html>
  //     <body>
  //       <h1>Audio Stream POC</h1>
  //       <button onclick="connectAudio()">Connect Audio</button>
  //       <script>
  //         let audioSocket;
  //         let audioContext;
  //         let processor;
          
  //         function connectAudio() {
  //           audioSocket = new WebSocket('ws://localhost:8888/audio');
  //           audioContext = new (window.AudioContext || window.webkitAudioContext)();
            
  //           audioSocket.binaryType = 'arraybuffer';
            
  //           audioSocket.onmessage = (event) => {
  //             if (!processor) {
  //               processor = audioContext.createScriptProcessor(1024, 1, 1);
  //               processor.onaudioprocess = (e) => {
  //                 const output = e.outputBuffer.getChannelData(0);
  //                 // Just play the raw data (will sound distorted for MP2 stream)
  //                 output.set(new Float32Array(event.data));
  //               };
  //               processor.connect(audioContext.destination);
  //             }
  //           };
  //         }
  //       </script>
  //     </body>
  //   </html>
  // `);
  res.send(`
  <!DOCTYPE html>
  <html>
    <head>
      <title>JSMpeg Stream Client</title>
      <style type="text/css">
        html, body {
          background-color: #111;
          text-align: center;
        }
      </style>
      
    </head>
    <body>
      <canvas id="video-canvas"></canvas>
      <script type="text/javascript" src="https://jsmpeg.com/jsmpeg.min.js"></script>
      <script type="text/javascript">
        var canvas = document.getElementById('video-canvas');
        var url = 'ws://'+document.location.hostname+':8882/';
        var player = new JSMpeg.Player(url, {canvas: canvas});
      </script>
    </body>
  </html>
  `); 
});

// WebSocket audio endpoint
wss.on('connection', (ws, req) => {
  if (req.url === '/audio') {
    audioClients.add(ws);
    ws.on('close', () => audioClients.delete(ws));
  }
});

// UDP server for audio stream
const udpServer = dgram.createSocket('udp4');
udpServer.on('message', (msg) => {
  // Broadcast to all audio clients
  audioClients.forEach(client => {
    if (client.readyState === ws.OPEN) {
      client.send(msg);
    }
  });
});

udpServer.bind(UDP_PORT, () => {
  console.log(`UDP server listening for audio on port ${UDP_PORT}`);
});