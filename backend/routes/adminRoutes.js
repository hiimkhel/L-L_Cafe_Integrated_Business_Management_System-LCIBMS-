const express = require("express");
const router = express.Router();
const { fetchAllCustomer, fetchMenuItems } = require("../controllers/adminControllers.js");

router.get("/customers", fetchAllCustomer);

// Menu Items
router.get("/menu-items", fetchMenuItems);
// router.get("/menu-items/:id");
// router.post("/menu-items");
// router.put("/menu-items/:id");
// router.delete("/menu-items:id");


// // Menu Items Categories
// router.get("menu/categories");
// router.post("menu/categories");


module.exports = router;