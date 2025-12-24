const http = require('http');

const PORT = process.env.PORT || 1337;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'ok', message: 'Strapi Mock Running' }));
});

server.listen(PORT, () => {
  console.log(`Mock Strapi listening on port ${PORT}`);
});
