const admin = require("firebase-admin");
const dotenv = require("dotenv");
const path = require("path");

dotenv.config();

let serviceAccount;

if (process.env.NODE_ENV !== "production") {
  const serviceAccountPath = path.resolve(
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH || "./config/firebaseServiceAccount.json"
  );

  serviceAccount = require(serviceAccountPath);
}
else {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;