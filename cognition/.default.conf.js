module.exports = {

  http: {
    port: 8080,
    address: null  // null to listen on any address (0.0.0.0, ::)
  },

  https: {
    enabled: true,
    port: 8443,
    address: null,  // null to listen on any address (0.0.0.0, ::)
    key: 'dev.key.pem',   // relative to the tls directory
    cert: 'dev.cert.pem', // relative to the tls directory
  },

  auth: {
    enabled: false,
    realm: 'Cognition'
  },

  db: "mongodb://localhost/test"
}
