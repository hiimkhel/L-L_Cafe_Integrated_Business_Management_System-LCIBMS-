/**
 * @file authRoutes.js
 * @description Handles all /menu endpoints
 * @module routes/menuRoutes.js
*/
const express = require('express');
const router = express.Router();
const db = require("../config/dbConnection.js");
const {getAllMenuItems, getVariantsByMenuItem} = require("../controllers/menuControllers.js");

router.get("/", getAllMenuItems);
router.get("/:menuItemId/variants", getVariantsByMenuItem);

module.exports = router;