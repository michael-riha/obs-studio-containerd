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
        #video-canvas {
        position: absolute;
            width: 120px;
            height: 10px;
        }
      </style>
          <style>

        body {
            margin: 0;
            background-color: dimgrey;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        html {
            height: 100%;
        }

        #top_bar {
            background-color: #6e84a3;
            color: white;
            font: bold 12px Helvetica;
            padding: 6px 5px 4px 5px;
            border-bottom: 1px outset;
        }
        #status {
            text-align: center;
        }
        #sendCtrlAltDelButton {
            position: fixed;
            top: 0px;
            right: 0px;
            border: 1px outset;
            padding: 5px 5px 4px 5px;
            cursor: pointer;
        }

        #screen {
            flex: 1; /* fill remaining space */
            overflow: hidden;
        }

    </style>

    <!-- Stylesheets -->
    <link rel="stylesheet" href="http://localhost:8080/app/styles/lite.css">

    <!-- promise polyfills promises for IE11 -->
    <script src="http://localhost:8080/vendor/promise.js"></script>
    <!-- ES2015/ES6 modules polyfill -->
    <script type="module">
        window._noVNC_has_module_support = true;
    </script>
    <script>
        window.addEventListener("load", function() {
            if (window._noVNC_has_module_support) return;
            var loader = document.createElement("script");
            loader.src = "http://localhost:8080/vendor/browser-es-module-loader/dist/browser-es-module-loader.js";
            document.head.appendChild(loader);
        });
    </script>

    <!-- actual script modules -->
    <script type="module" crossorigin="anonymous">
        // Load supporting scripts
        import * as WebUtil from 'http://localhost:8080/app/webutil.js';
        import RFB from 'http://localhost:8080/core/rfb.js';

        var rfb;
        var desktopName;

        function machineShutdown() {
            rfb.machineShutdown();
            return false;
        }
        function machineReboot() {
            rfb.machineReboot();
            return false;
        }
        function machineReset() {
            rfb.machineReset();
            return false;
        }
        function status(text, level) {
            switch (level) {
                case 'normal':
                case 'warn':
                case 'error':
                    break;
                default:
                    level = "warn";
            }
        }

        function connected(e) {
            // document.getElementById('sendCtrlAltDelButton').disabled = false;
            if (WebUtil.getConfigVar('encrypt',
                                     (window.location.protocol === "https:"))) {
                status("Connected (encrypted) to " + desktopName, "normal");
            } else {
                status("Connected (unencrypted) to " + desktopName, "normal");
            }
        }

        function disconnected(e) {
            // document.getElementById('sendCtrlAltDelButton').disabled = true;
            updatePowerButtons();
            if (e.detail.clean) {
                status("Disconnected", "normal");
            } else {
                status("Something went wrong, connection is closed", "error");
            }
        }

        function updatePowerButtons() {
            var powerbuttons;
            powerbuttons = document.getElementById('noVNC_power_buttons');
            if (rfb.capabilities.power) {
                powerbuttons.className= "noVNC_shown";
            } else {
                powerbuttons.className = "noVNC_hidden";
            }
        }


        WebUtil.init_logging(WebUtil.getConfigVar('logging', 'warn'));
        document.title = WebUtil.getConfigVar('title', 'noVNC');
        // By default, use the host and port of server that served this file
        var host = WebUtil.getConfigVar('host', window.location.hostname);
        var port = WebUtil.getConfigVar('port', window.location.port);

        // if port == 80 (or 443) then it won't be present and should be
        // set manually
        if (!port) {
            if (window.location.protocol.substring(0,5) == 'https') {
                port = 443;
            }
            else if (window.location.protocol.substring(0,4) == 'http') {
                port = 80;
            }
        }

        var password = WebUtil.getConfigVar('password', '');
        var path = WebUtil.getConfigVar('path', 'websockify');

        // If a token variable is passed in, set the parameter in a cookie.
        // This is used by nova-novncproxy.
        var token = WebUtil.getConfigVar('token', null);
        if (token) {
            // if token is already present in the path we should use it
            path = WebUtil.injectParamIfMissing(path, "token", token);

            WebUtil.createCookie('token', token, 1)
        }

        (function() {

            status("Connecting", "normal");

            if ((!host) || (!port)) {
                status('Must specify host and port in URL', 'error');
            }

            var url;

            if (WebUtil.getConfigVar('encrypt',
                                     (window.location.protocol === "https:"))) {
                url = 'wss';
            } else {
                url = 'ws';
            }

            url += '://' + host;
            url = 'ws://localhost:8080/websockify'
            if(port) {
                url += ':' + port;
            }
            url += '/' + path;

            rfb = new RFB(document.body, url,
                          { repeaterID: WebUtil.getConfigVar('repeaterID', ''),
                            shared: WebUtil.getConfigVar('shared', true),
                            credentials: { password: password } });
            rfb.viewOnly = WebUtil.getConfigVar('view_only', false);
            // rfb.addEventListener("connect",  connected);
            // rfb.addEventListener("disconnect", disconnected);
            // rfb.addEventListener("capabilities", function () { updatePowerButtons(); });
            // rfb.addEventListener("credentialsrequired", credentials);
            // rfb.addEventListener("desktopname", updateDesktopName);
            rfb.scaleViewport = WebUtil.getConfigVar('scale', false);
            rfb.resizeSession = WebUtil.getConfigVar('resize', false);
        })();
    </script>
    </head>
    <body>
      <canvas id="video-canvas"></canvas>
       <div id="screen">
        <!-- This is where the remote screen will appear -->
      </div>
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