const express = require("express");
const router = express.Router();
const { getUserAddresses, getUserProfile, updateUserProfile, getCustomerOrders } = require("../controllers/customerControllers.js");

router.put("/profile", updateUserProfile);

router.get("/orders", getCustomerOrders);

router.get("/:id", getUserProfile);
router.get("/:id/addresses", getUserAddresses);


module.exports = router;