const express = require("express");
const router = express.Router();
const {getOrdersByStatus} = require("../controllers/posControllers.js");

router.get("/orders", getOrdersByStatus);

module.exports = router;