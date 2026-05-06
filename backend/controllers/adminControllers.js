/**
 * @file adminController.js
 * @description Handles Admin Screens Business logic
 * @module controllers/adminController
*/
const db = require("../config/dbConnection.js");

// [1] Customers API
const fetchAllCustomer = async (req, res) => {
     try {
        const { search = "" } = req.query;

        let params = [];

        let query = `
            SELECT 
                id,
                firebase_uid,
                full_name,
                email,
                provider,
                role,
                created_at
            FROM users
            WHERE role = 'customer'
        `;

        // SEARCH FILTER
        if (search) {
            query += ` AND (full_name LIKE ? OR email LIKE ?)`;
            params.push(`%${search}%`, `%${search}%`);
        }

        query += ` ORDER BY created_at DESC`;

        const [rows] = await db.query(query, params);

        return res.status(200).json({
            success: true,
            data: rows
        });

    } catch (error) {
        console.error("fetchAllCustomers error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to fetch customers",
            error: error.message
        });
    }
};


// [2] Menu APIs
// Fetch all items by category
const fetchMenuItems = async (req, res) => {
    try{
        // Get category id from request search query
        const { category_id } = req.query

        let query = `
            SELECT * from menu_items
        `;

        let params = [];

        if(category_id){
            query += `WHERE category_id = ? `;
            params.push(category_id);
        }

        query += `ORDER BY name ASC`;

        const [rows] = await db.query(query, params);

        res.json(rows);

    }catch(err){
        res.status(500).json({error: err.message});
    }
}

const fetchMenuCategories = async (req, res) => {
    try{
        const [ rows ] = await db.query(`SELECT id, name FROM menu_categories ORDER BY id ASC`);

        res.status(200).json(rows);
    }catch(err){    
        res.status(500).json({error: err.message});
    }
}

const addMenuCategory = async (req, res) => {
    try{
        const { name } = req.body;

        // Validate field
        if(!name){
            return res.status(400).json({message: "Category name is required!"});
        }

        // Query into our database
        const [result] = await db.query(`
            INSERT INTO menu_categories (name) VALUES (?)
            `, [name]
        );

        res.status(201).json({
            id: result.insertId,
            name
        })
    }catch(err){
        res.status(500).json({message: err.message})
    }
}

const getItemById = async (req, res) => {
    try{
        // Retrieve id value from request parameter
        const {id} = req.params;

        // Query into db
        const [rows] = await db.query("SELECT * FROM menu_items WHERE id = ?", [id]);

        // Check if it exist
        if (rows.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // Response JSON
        return res.status(200).json(rows[0]);
    }catch(err){
        console.error("Get menu item by id error:", err);
        return res.status(500).json({
        message: "Server error",
        });
    }
}


const addMenuItem = async (req, res) => {
    try{
        // Deconstruct body values
        const { name, price, description, category_id } = req.body;

        // Validate values
        if (!name || !price || !category_id) {
            return res.status(400).json({
                message: "Name, price, and category_id are required",
            });
        }

        // Check category
        const [category] = await db.query(
            "SELECT id FROM menu_categories WHERE id = ?",
            [category_id]
        );

        if (category.length === 0) {
            return res.status(404).json({
                message: "Category not found",
            });
        }

        // Insert data into db
        const [result] = await db.query(
            `INSERT INTO menu_items (name, price, description, category_id, is_available)
            VALUES (?, ?, ?, ?, 1)`,
            [name, price, description || null, category_id]
        );

        // JSON Response
        return res.status(201).json({
            message: "Menu item created successfully",
            item_id: result.insertId,
        });
    }catch(err){
        console.error("Add Menu Item Error:", error);
        return res.status(500).json({
        message: "Server error",
        });
    }
}

const deleteMenuItem = async (req, res) => {
    try{
        // Fetch id to delete from request parameter
        const { id } = req.params;

        const [item] = await db.query(
            "SELECT id FROM menu_items WHERE id = ?",
            [id]
        );

        // Check existence of id given
        if (item.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // If no errors, proceed to delete
        await db.query(
            "DELETE FROM menu_items WHERE id = ?",
            [id]
        );

        // Return JSON response
        return res.status(200).json({
            message: "Menu item deleted successfully",
        });
    }catch(err){
        console.error("Delete Menu Item Error:", error);
        return res.status(500).json({
        message: "Server error",
        });
    }
}

const updateMenuItem = async (req, res) => {
    try{
        const { id } = req.params;

        // Deconstruct all the menu-item details value
        const {
            name,
            price,
            description,
            is_available
        } = req.body

        // Validate values
        if (!name || price == null) {
            return res.status(400).json({
                message: "Name and price are required",
            });
        }

        // Check if item exists
        const [ existing ] = await db.query(
            "SELECT * FROM menu_items WHERE id = ?", [id]
        );

        if (existing.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // Update logic
        await db.query(
           `UPDATE menu_items 
            SET name = ?, price = ?, description = ?, is_available = ?
            WHERE id = ?`,
            [name, price, description, is_available ? 1 : 0, id]
        );

        // Return JSON
        return res.status(200).json({
            message: "Menu item updated successfully",
        });

    }catch(err){
        console.error("Update menu item error:", err);
        return res.status(500).json({
            message: "Server error",
        });
    }
}

const getCustomerReviews = async (req, res) => {
    try{

        // Retrieve all the necessary data uby joining reviews and users table
       const [rows] = await db.query(`
            SELECT 
                r.id,
                r.user_id,
                u.full_name AS customer_name,
                r.review_text,
                r.rating,
                r.status,
                r.created_at,
                u.profile_picture
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            ORDER BY r.created_at DESC
        `);

        res.json(rows);

    }catch(err){
        res.status(500).json({error: err.message})
    }
}
module.exports = { fetchAllCustomer, 
    fetchMenuItems,
    fetchMenuCategories,
    addMenuCategory,
    addMenuItem,
    deleteMenuItem,
    getItemById,
    updateMenuItem,
    getCustomerReviews
 };