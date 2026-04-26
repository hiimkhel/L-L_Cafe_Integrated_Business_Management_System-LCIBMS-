/**
 * @file authRoutes.js
 * @description Handles all API endpoints under auth module
 * @module routes/authRoutes.js
*/

const express = require('express');
const router = express.Router();
const db = require('../config/dbConnection.js');
const { login, register } = require("../controllers/authControllers");


router.post('/login', login);
router.post('/register', register);

module.exports = router;