const db = require("../config/dbConnection.js");

const getAllMenuItems = async (req, res) => {
    const { category, search } = req.query;

    try {
        let sql = "SELECT * FROM menu_items";
        const conditions = [];
        const params = [];

        // Category filter
        if (category && category !== 'ALL') {
            conditions.push("category_id = ?");
            params.push(category);
        }

        // Search filter
        if (search) {
            conditions.push("(name LIKE ? OR description LIKE ?)");
            const term = `%${search}%`;
            params.push(term, term);
        }

        // Apply conditions
        if (conditions.length > 0) {
            sql += " WHERE " + conditions.join(" AND ");
        }

        const [rows] = await db.query(sql, params);
        res.status(200).json(rows);

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Failed to fetch customer menu' });
    }
};

module.exports = {getAllMenuItems};