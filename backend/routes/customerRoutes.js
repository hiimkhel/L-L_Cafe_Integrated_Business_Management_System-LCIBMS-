const express = require("express");
const router = express.Router();
const { getUserAddresses, getUserProfile, updateUserProfile, getCustomerOrders, cancelPendingOrder } = require("../controllers/customerControllers.js");
const {verifyFirebaseToken} = require("../middleware/authMiddleware.js");
router.put("/profile", updateUserProfile);

router.get("/orders", getCustomerOrders);
router.patch("/orders/:id/cancel", verifyFirebaseToken, cancelPendingOrder);

router.get("/:id", getUserProfile);
router.get("/:id/addresses", getUserAddresses); 


module.exports = router;