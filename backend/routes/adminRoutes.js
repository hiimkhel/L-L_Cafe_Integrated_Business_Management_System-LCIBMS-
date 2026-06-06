const express = require("express");
const router = express.Router();
const { getDashboardSummary, fetchAllCustomer, fetchMenuItems, fetchMenuCategories,
    addMenuCategory, addMenuItem, deleteMenuItem, getItemById, updateMenuItem, getCustomerReviews, publishReview, archiveReview, deleteReview, republishReview,
    getTopCustomer, getMenuSales, getRevenueReport, getOrdersReport, getSalesDistributionReport, getSalesSummaryReport, getOrders
 } = require("../controllers/adminControllers.js");

router.get("/customers", fetchAllCustomer);

// Dashboard 
router.get("/dashboard/summary", getDashboardSummary);
router.get("/dashboard/revenue-trend", fetchAllCustomer);
router.get("/dashboard/top-menus", fetchAllCustomer);

// Menu Items
router.get("/menu-items", fetchMenuItems);
router.post("/menu-items", addMenuItem);

// Orders
router.get("/orders", getOrders);

// Individual Menu Item
router.get("/menu-items/:id", getItemById);
router.put("/menu-items/:id", updateMenuItem);
router.delete("/menu-items/:id", deleteMenuItem);


// // Menu Items Categories
router.get("/menu/category", fetchMenuCategories );
router.post("/menu/category", addMenuCategory);

// Sales & Report Screen
router.get("/reports/revenue", getRevenueReport);
router.get("/reports/orders", getOrdersReport);
router.get("/reports/sales", getSalesDistributionReport);
router.get("/reports/menu", getMenuSales);
router.get("/reports/customer", getTopCustomer);
router.get("/reports/chart", getSalesSummaryReport);




// Reviews Screen
router.get("/reviews", getCustomerReviews);
router.patch("/reviews/:id/publish", publishReview);
router.patch("/reviews/:id/archive", archiveReview);
router.delete("/reviews/:id", deleteReview);
router.patch("/reviews/:id/republish", republishReview);


module.exports = router;