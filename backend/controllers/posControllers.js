const db = require("../config/dbConnection.js");

const getOrdersByStatus = async (req, res) => {
    const status = req.query.status || 'pending';

    try {
        const sql = `
            SELECT 
                o.id, o.order_number, o.customer_name, o.status, o.total, o.created_at,
                oi.item_name, oi.quantity, oi.unit_price
            FROM orders o 
            LEFT JOIN order_items oi ON o.id = oi.order_id
            WHERE o.status = ?
            ORDER BY o.created_at ASC`;

        const [rows] = await db.query(sql, [status]);

        // Group rows by Order ID
        const ordersMap = {};
        rows.forEach(row => {
            if (!ordersMap[row.id]) {
                ordersMap[row.id] = {
                    id: row.id,
                    order_number: row.order_number,
                    customer_name: row.customer_name || "WALK-IN",
                    status: row.status,
                    total: row.total,
                    created_at: row.created_at,
                    items: []
                };
            }
            if (row.item_name) {
                ordersMap[row.id].items.push({
                    name: row.item_name,
                    qty: row.quantity,
                    price: row.unit_price
                });
            }
        });

        res.status(200).json(Object.values(ordersMap));
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = {getOrdersByStatus}