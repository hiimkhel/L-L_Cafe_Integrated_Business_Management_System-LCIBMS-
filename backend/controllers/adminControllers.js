const db = require("../config/dbConnection.js");

const getAllCustomers = async (req, res) => {
    try {
        let { search = "" } = req.query;

        let params = [];

        // Base query
        let query = `
            SELECT 
                id,
                firebase_uid,
                full_name,
                email,
                role,
                provider,
                created_at,
                updated_at
            FROM users
            WHERE role = 'customer'
        `;

        // Search filter
        if (search) {
            query += ` AND (full_name LIKE ? OR email LIKE ?)`;
            params.push(`%${search}%`, `%${search}%`);
        }

        // Order results
        query += ` ORDER BY created_at DESC`;

        const [customers] = await db.query(query, params);

        return res.status(200).json({
            success: true,
            total: customers.length,
            data: customers
        });

    } catch (err) {
        console.error("Get Customers Error:", err);

        res.status(500).json({
            success: false,
            message: "Server Error",
            error: err.message
        });
    }
};

module.exports = {
    getAllCustomers
};