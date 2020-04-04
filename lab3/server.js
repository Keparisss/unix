const net = require('net');
const utils = require('./utils');
const locale = require('./locale.json');

const connectionListener = utils.getConnectionListener();

const server = net.createServer(connectionListener);

server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    process.stdout.write(locale.addressAlreadyInUse);
  }
});

process.on('SIGINT', () => {
  process.stdout.write(locale.caughtSIGINT);
  process.exit();
});

const [portOrSocket] = process.argv.slice(2);

server.listen(portOrSocket || utils.PORT, () => {
  if (!isNaN(parseInt(portOrSocket))) {
    process.stdout.write(locale.serverOnPort + portOrSocket + '\n');
  } else {
    process.stdout.write(locale.serverOnSocket + portOrSocket + '\n');
  }
});