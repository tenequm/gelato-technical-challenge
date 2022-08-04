"use strict";

const express = require("express");

// Constants
const PORT = 8080;
const HOST = "0.0.0.0";

const blockchain_network_name = process.env.BLOCKCHAIN_NETWORK_NAME || "goerli";
const rpc_endpoint = process.env.RPC_ENDPOINT || "http://localhost:8080";
const db_host = process.env.DB_HOST || "http://localhost:5432";
const environment = process.env.ENVIRONMENT || "local";

// App
const app = express();
app.get("/", (req, res) => {
  res.send(`Blockchain network name: ${blockchain_network_name}
    <br>RPC Endpoint: ${rpc_endpoint}
    <br>Database Host: ${db_host}
    <br>Environment: ${environment}
  `);
});

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);
