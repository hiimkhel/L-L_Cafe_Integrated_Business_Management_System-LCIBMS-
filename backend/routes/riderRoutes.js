const express = require("express");
const router = express.Router();
const { getRiderOrders, getDeliveryOrderDetails, updateDeliveryStatus } = require("../controllers/riderControllers.js");

router.get("/orders", getRiderOrders);
router.get("/orders/:id", getDeliveryOrderDetails);
router.patch("/orders/:id/status", updateDeliveryStatus);

module.exports = router;