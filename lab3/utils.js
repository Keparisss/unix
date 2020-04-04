const locale = require('./locale.json');

const PORT = 8080;
const HOSTNAME = '0.0.0.0';

const socketAddress = 'socket';

const dataHandler = (data) => {
  process.stdout.write(data.length.toString());
  process.stdout.write('\n');
};

const getConnectionListener = () => {
  let connections = [];

  const connectionCloseHandler = () => {
    process.stdout.write(locale.disconnect + connections[0].connectionName + '\n');
    connections = [];
  };

  const connectListener = (connection) => {
    const connectionName = connection.remotePort || socketAddress;

    if (connections.length > 0) {
      process.stdout.write(locale.connectTry + connectionName + '\n');

      connection.write(locale.disconnectClient);
      connection.destroy();

      return;
    }

    connection.write(locale.connectClient);
    connections.push({ connection, connectionName });

    // income data from connection
    connection.on('data', dataHandler);
    connection.on('close', connectionCloseHandler);

    process.stdout.write(locale.currentConnection + connectionName + '\n');
  };

  return connectListener;
};

module.exports = { HOSTNAME, PORT, getConnectionListener };
