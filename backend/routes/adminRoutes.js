const express = require("express");
const router = express.Router();
const { fetchAllCustomer, fetchMenuItems, fetchMenuCategories,
    addMenuCategory, addMenuItem, deleteMenuItem, getItemById, updateMenuItem, getCustomerReviews, publishReview, archiveReview, deleteReview, republishReview,
    getTopCustomer
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

// Sales & Report Screen
router.get("/reports/revenue", getCustomerReviews);
router.get("/reports/orders", getCustomerReviews);
router.get("/reports/menu", getCustomerReviews);
router.get("/reports/customer", getTopCustomer);
router.get("/reports/chart", getCustomerReviews);


// Reviews Screen
router.get("/reviews", getCustomerReviews);
router.patch("/reviews/:id/publish", publishReview);
router.patch("/reviews/:id/archive", archiveReview);
router.delete("/reviews/:id", deleteReview);
router.patch("/reviews/:id/republish", republishReview);


module.exports = router;