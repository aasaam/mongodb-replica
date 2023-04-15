const path = require("path");

const mongoose = require("mongoose").default;
const { faker } = require("@faker-js/faker");
mongoose.set("strictQuery", true);
mongoose.set("debug", process.env.DEBUG === "true");

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
    // lower insert time for check changes between primary and secondary
  }, 100);

  setInterval(async () => {
    await Sample.findOne({ title: /e/i }, undefined, {
      readPreference: "primary",
    });

    await Sample.findOne({ title: /e/i }, undefined, {
      readPreference: "secondary",
    });

    const counts = [
      Sample.aggregate(
        [
          {
            $count: "total",
          },
        ],
        {
          readPreference: "primary",
        }
      ),
      Sample.aggregate(
        [
          {
            $count: "total",
          },
        ],
        {
          readPreference: "secondary",
        }
      ),
    ];

    const r = (await Promise.all(counts)).map((i) => i[0].total);

    log({ primary: r[0], secondary: r[1], diff: r[0] !== r[1] });
  }, 333);
})();
