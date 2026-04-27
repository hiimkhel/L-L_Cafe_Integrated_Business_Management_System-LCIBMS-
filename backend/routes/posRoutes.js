const express = require("express");
const router = express.Router();
const {getOrdersByStatus, updateOrderStatus} = require("../controllers/posControllers.js");

router.get("/orders", getOrdersByStatus);
router.patch("/orders/:id/status", updateOrderStatus);

module.exports = router;