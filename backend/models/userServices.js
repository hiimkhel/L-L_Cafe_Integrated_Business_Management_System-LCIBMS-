// services/userService.js

const db = require("../config/dbConnection.js"); // your DB connection

async function findUserByFirebaseUID(uid) {
  const [rows] = await db.query(
    "SELECT * FROM users WHERE firebase_uid = ?",
    [uid]
  );
  return rows[0];
}

async function createUser(user) {
  const { firebase_uid, email, full_name, profile_picture, provider, role } = user;

  await db.query(
    `INSERT INTO users (firebase_uid, email, full_name, profile_picture, provider, role)
     VALUES (?, ?, ?, ?, ?, ?)`,
    [firebase_uid, email, full_name, profile_picture, provider, role]
  );

  return findUserByFirebaseUID(firebase_uid);
}

module.exports = {
  findUserByFirebaseUID,
  createUser,
};