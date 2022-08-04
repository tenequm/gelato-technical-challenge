"use strict";

const express = require("express");

// Constants
const PORT = 8080;
const HOST = "0.0.0.0";

const environment = process.env.ENVIRONMENT || "local";
const blockchain_network_name = process.env.BLOCKCHAIN_NETWORK_NAME || "goerli";
const rpc_endpoint = process.env.RPC_ENDPOINT || "http://localhost:8080";

// DB configs
const db_host = process.env.DB_HOST || "localhost";
const db_user = process.env.DB_USER || "local-user";
const db_password = process.env.DB_PASSWORD || "local-password";

// App
const app = express();
app.get("/", (req, res) => {
  res.send(`<br>Environment: ${environment}
    <br>Blockchain network name: ${blockchain_network_name}
    <br>RPC Endpoint: ${rpc_endpoint}
    <br>Database Host: ${db_host}
    <br>Database User: ${db_user}
    <br>Database Password: ${db_password}
  `);
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
