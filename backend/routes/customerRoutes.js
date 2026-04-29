const express = require("express");
const router = express.Router();
const { getUserAddresses, getUserProfile, updateUserProfile } = require("../controllers/customerControllers.js");

router.get("/:id", getUserProfile);
router.get("/:id/addresses", getUserAddresses);

router.put("/profile", updateUserProfile);

module.exports = router;