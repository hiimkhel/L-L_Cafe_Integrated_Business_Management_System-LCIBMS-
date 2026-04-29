const express = require("express");
const router = express.Router();
const { getUserAddresses, getUserProfile } = require("../controllers/customerControllers.js");

router.get("/:id", getUserProfile);
router.get("/:id/addresses", getUserAddresses);

module.exports = router;