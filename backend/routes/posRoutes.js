const express = require("express");
const router = express.Router();
const {getOrdersByStatus, updateOrderStatus, getOnlineOrders, acceptOrder, rejectOrder, fetchPreparingOrders} = require("../controllers/posControllers.js");

router.get("/orders", getOrdersByStatus);
router.patch("/orders/:id/status", updateOrderStatus);

// Order Queue
router.get("/orders/preparing-count", fetchPreparingOrders);
// Online Orders
router.get("/orders/online", getOnlineOrders);
router.patch('/orders/online/:id/accept', acceptOrder);
router.patch('/orders/online/:id/reject', rejectOrder);


module.exports = router;