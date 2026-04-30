const express = require("express");
const router = express.Router();
const {getOrdersByStatus, updateOrderStatus, getOnlineOrders} = require("../controllers/posControllers.js");

router.get("/orders", getOrdersByStatus);
router.patch("/orders/:id/status", updateOrderStatus);
router.get("/orders/online", getOnlineOrders);

module.exports = router;