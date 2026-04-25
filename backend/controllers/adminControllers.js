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

module.exports = { fetchAllCustomer, 
    fetchMenuItems,
    fetchMenuCategories,
    addMenuCategory
 };