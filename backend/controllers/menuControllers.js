const db = require("../config/dbConnection.js");

const getAllMenuItems = async (req, res) => {
    const { category, search } = req.query;

    try {
        let sql = "SELECT * FROM menu_items WHERE is_available = 1"; // Only show available items to customers
        const params = [];

        // Category Filter
        if (category && category !== 'ALL') {
            sql += " AND category_id = ?";
            params.push(category);
        }

        // Search Filter
        if (search) {
            sql += " AND (name LIKE ? OR description LIKE ?)";
            const term = `%${search}%`;
            params.push(term, term);
        }

        const [rows] = await db.query(sql, params);
        res.status(200).json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Failed to fetch customer menu' });
    }
}

module.exports = {getAllMenuItems};