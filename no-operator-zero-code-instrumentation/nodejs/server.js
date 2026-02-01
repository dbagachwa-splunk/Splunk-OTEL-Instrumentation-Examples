// server.js
const http = require('http');

const requestListener = function (req, res) {
  res.writeHead(200);
  res.end('Hello from Manually Instrumented Node.js!');
};

const server = http.createServer(requestListener);
server.listen(8080, '0.0.0.0', () => {
    console.log('Server is running on port 8080');
});
