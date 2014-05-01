var http = require('http');
var os = require("os");

var hostname = os.hostname();

var server = http.createServer(function(req, res) {
  res.writeHead(200);
  res.end('Hello World from ' + hostname + ' !' + "\n");
});
server.listen(8080);

