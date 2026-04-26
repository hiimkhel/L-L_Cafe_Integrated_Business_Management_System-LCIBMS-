/**
 * @file authRoutes.js
 * @description Handles all API endpoints under auth module
 * @module routes/authRoutes.js
*/

const express = require('express');
const router = express.Router();
const { login, register, authSync } = require("../controllers/authControllers");


router.post('/login', login);
router.post('/register', register);
router.post("/", authSync);

module.exports = router;