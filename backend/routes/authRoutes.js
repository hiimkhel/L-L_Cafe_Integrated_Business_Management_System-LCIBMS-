/**
 * @file authRoutes.js
 * @description Handles all API endpoints under auth module
 * @module routes/authRoutes.js
*/

const express = require('express');
const router = express.Router();
const db = require('../config/dbConnection.js');
const admin = require("../config/firebase.js");
const { login, register } = require("../controllers/authControllers");
const { findUserByFirebaseUID, createUser } = require("../models/userServices.js");


router.post('/login', login);
router.post('/register', register);
router.post("/", async (req, res) => {
  try {

    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "No token provided" });
    }

    const idToken = authHeader.split(" ")[1];
    //  Verify Firebase token
    const decoded = await admin.auth().verifyIdToken(idToken);
      console.log("✅ TOKEN VERIFIED:");
    console.log(decoded);


    const uid = decoded.uid;
    const email = decoded.email || "";
    const name = decoded.name || "User";
    const picture = decoded.picture || "";
    const provider = decoded.firebase?.sign_in_provider || "unknown";

    // 🔎 Get user from DB
    let user = await findUserByFirebaseUID(uid);

    // 🆕 Create user if not exists
    if (!user) {
      user = await createUser({
        firebase_uid: uid,
        email,
        full_name: name,
        profile_picture: picture,
        provider,
        role: "customer", // default role ONLY here
      });
    }

    // 🔁 ALWAYS return DB as source of truth
    return res.status(200).json({
      id: user.id,
      firebase_uid: user.firebase_uid,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      profile_picture: user.profile_picture,
    });

  } catch (error) {
    console.error("Auth error:", error);
    return res.status(401).json({
      message: "Invalid or expired token",
    });
  }
});

module.exports = router;