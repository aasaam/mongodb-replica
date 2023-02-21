const path = require("path");

const mongoose = require("mongoose").default;
const { faker } = require("@faker-js/faker");
mongoose.set("strictQuery", true);
mongoose.set("debug", true);

const { Schema } = mongoose;

const sampleSchema = new Schema(
  {
    title: String,
  },
  {
    versionKey: false,
  }
);

const Sample = mongoose.model("Sample", sampleSchema);

const [clientCertPath, connectionString] = process.argv.slice(2);

const { log } = console;

(async () => {
  log(faker.lorem.paragraph());
  const mongooseConnection = await mongoose.connect(connectionString, {
    socketTimeoutMS: 1000,
    connectTimeoutMS: 1000,
    serverSelectionTimeoutMS: 2000,
    // deprecated
    // ssl: true,
    // sslCA: path.resolve(clientCertPath, "ca.pem"),
    // sslKey: path.resolve(clientCertPath, "client-combined.pem"),
    // sslValidate: true,
    tls: true,
    tlsCAFile: path.resolve(clientCertPath, "ca.pem"),
    tlsCertificateKeyFile: path.resolve(clientCertPath, "client-combined.pem"),
    tlsInsecure: false,
  });

  log("init success, try to down and up nodes...");

  [
    "close",
    "connected",
    "connecting",
    "disconnected",
    "disconnecting",
    "fullsetup",
    "open",
    "reconnected",
  ].forEach((event) => {
    mongooseConnection.connection.on(event, function () {
      log({ on: event });
    });
  });

  mongooseConnection.connection.on("error", function (e) {
    log({ on: "error", e });
  });

  setInterval(() => {
    const doc = new Sample();
    doc.title = faker.lorem.paragraph();
    doc.save();
  }, 666);

  setInterval(async () => {
    await Sample.findOne({ title: /e/i });
  }, 333);
})();
