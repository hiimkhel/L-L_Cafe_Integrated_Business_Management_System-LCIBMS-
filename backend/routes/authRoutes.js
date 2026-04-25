/**
 * @file authRoutes.js
 * @description Handles all API endpoints under auth module
 * @module routes/authRoutes.js
*/

const express = require('express');
const router = express.Router();
const db = require('../config/dbConnection.js');
const admin = require("../config/firebase.js");
const { login, register, authSync } = require("../controllers/authControllers");
const { findUserByFirebaseUID, createUser } = require("../models/userServices.js");


router.post('/login', login);
router.post('/register', register);
router.post("/", authSync);

module.exports = router;