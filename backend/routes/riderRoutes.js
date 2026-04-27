const express = require("express");
const router = express.Router();
const { getRiderOrders } = require("../controllers/riderControllers.js");

router.get("/orders", getRiderOrders);

module.exports = router;