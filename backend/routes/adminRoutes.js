const express = require('express');
const router = express.Router();
const { getAllCustomers } = require("../controllers/adminControllers.js");
const authorizeRoles = require("../middleware/authorizeRoles.js");
const authMiddleware = require("../middleware/authMiddleware.js");

router.get("/customers", getAllCustomers);

module.exports = router;