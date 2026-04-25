const express = require("express");
const router = express.Router();
const { fetchAllCustomer } = require("../controllers/adminControllers.js");

router.get("/customers", fetchAllCustomer);

module.exports = router;