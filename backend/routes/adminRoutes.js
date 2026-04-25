const express = require("express");
const router = express.Router();
const { fetchAllCustomer, fetchMenuItems, fetchMenuCategories,
    addMenuCategory, addMenuItem
 } = require("../controllers/adminControllers.js");

router.get("/customers", fetchAllCustomer);

// Menu Items
router.get("/menu-items", fetchMenuItems);
router.post("/menu-items", addMenuItem);

// Individual Menu Item
// router.get("/menu-items/:id");
// router.put("/menu-items/:id");
router.delete("/menu-items:id");


// // Menu Items Categories
router.get("/menu/category", fetchMenuCategories );
router.post("/menu/category", addMenuCategory);


module.exports = router;