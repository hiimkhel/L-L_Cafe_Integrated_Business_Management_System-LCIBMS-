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

const getVariantsByMenuItem = async (req, res) => {
    try {
        const { menuItemId } = req.params;

        const [rows] = await db.query(
            `
            SELECT *
            FROM menu_items_variants
            WHERE menu_item_id = ?
              AND is_available = 1
            ORDER BY
                FIELD(category, 'Ala Carte', 'with Rice', 'Tray'),
                pieces ASC
            `,
            [menuItemId]
        );

        res.status(200).json(rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({
            message: "Failed to fetch menu variants"
        });
    }
};

const getAllFlavors = async (req, res) => {
    try {

        const [rows] = await db.query(`
            SELECT *
            FROM flavors
            ORDER BY flavor_name
        `);

        res.status(200).json(rows);

    } catch (err) {

        console.error(err);

        res.status(500).json({
            message: "Failed to fetch flavors"
        });

    }
};

const getFlavorsById = async (req, res) => {
    try {

        const { menuItemId } = req.params;

        const [rows] = await db.query(
            `
            SELECT
                f.id,
                f.flavor_name,
                f.is_available
            FROM item_flavors AS ifl
            JOIN flavors AS f
                ON ifl.flavor_id = f.id
            WHERE ifl.item_id = ?
            ORDER BY f.flavor_name
            `,
            [menuItemId]
        );

        res.status(200).json(rows);

    } catch (err) {

        console.error(err);

        res.status(500).json({
            message: "Failed to fetch flavors"
        });

    }
};


module.exports = {getAllMenuItems, getVariantsByMenuItem, getAllFlavors, getFlavorsById};