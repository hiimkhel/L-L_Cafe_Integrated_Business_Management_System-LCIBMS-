/**
 * @file adminController.js
 * @description Handles Admin Screens Business logic
 * @module controllers/adminController
*/
const db = require("../config/dbConnection.js");

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

module.exports = { fetchAllCustomer };