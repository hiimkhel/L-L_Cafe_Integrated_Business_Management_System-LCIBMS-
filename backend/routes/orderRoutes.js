const express = require('express');
const router = express.Router();
const {createOrder, fetchCurrentOrderNumber} = require("../controllers/orderControllers.js");

router.post('/', createOrder);
router.get("/current-order-num", fetchCurrentOrderNumber);


module.exports = router;