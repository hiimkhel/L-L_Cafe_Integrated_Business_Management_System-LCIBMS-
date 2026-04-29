const express = require("express");
const router = express.Router();
const { getUserAddresses } = require("../controllers/customerControllers.js");

router.get("/:id/addresses", getUserAddresses);

module.exports = router;