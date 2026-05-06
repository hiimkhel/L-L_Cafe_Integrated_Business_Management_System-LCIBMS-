const express = require("express");
const router = express.Router();
const { fetchAllCustomer, fetchMenuItems, fetchMenuCategories,
    addMenuCategory, addMenuItem, deleteMenuItem, getItemById, updateMenuItem
 } = require("../controllers/adminControllers.js");

router.get("/customers", fetchAllCustomer);

// Menu Items
router.get("/menu-items", fetchMenuItems);
router.post("/menu-items", addMenuItem);

// Individual Menu Item
router.get("/menu-items/:id", getItemById);
router.put("/menu-items/:id", updateMenuItem);
router.delete("/menu-items/:id", deleteMenuItem);


// // Menu Items Categories
router.get("/menu/category", fetchMenuCategories );
router.post("/menu/category", addMenuCategory);
router.get("/reviews", );


module.exports = router;