const admin = require("firebase-admin");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

const serviceAccountPath = path.resolve(
  process.env.FIREBASE_SERVICE_ACCOUNT_PATH
);

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;