const express = require("express");
const router = express.Router();
const { getRiderOrders, getDeliveryOrderDetails } = require("../controllers/riderControllers.js");

router.get("/orders", getRiderOrders);
router.get("/orders/:id", getDeliveryOrderDetails);

module.exports = router;