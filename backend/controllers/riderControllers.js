const db = require("../config/dbConnection.js");

const getRiderOrders = async (req, res) => {
    try {
        const status = req.query.status || 'ready';

        const sql = `
            SELECT 
                o.id, o.order_number, o.customer_name, o.customer_phone, 
                o.status, o.total, o.created_at,
                ua.label as address_label, ua.full_address,
                oi.item_name, oi.quantity, oi.unit_price
            FROM orders o 
            LEFT JOIN user_addresses ua ON o.address_id = ua.id
            LEFT JOIN order_items oi ON o.id = oi.order_id
            WHERE o.status = ? AND o.order_type = 'delivery'
            ORDER BY o.created_at ASC`;
            
        const [rows] = await db.query(sql, [status]);

        const ordersMap = {};
        rows.forEach(row => {
            if (!ordersMap[row.id]) {
                ordersMap[row.id] = {
                    id: row.id,
                    order_number: row.order_number,
                    customer_name: row.customer_name || "Guest",
                    customer_phone: row.customer_phone,
                    // Combine address fields into a readable string for the Rider
                    address: `${row.address_line || 'No Address'}, ${row.city || ''}`.trim(),
                    address_notes: row.address_notes,
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
        console.error("[RIDER ERROR]", err);
        res.status(500).json({ success: false, message: err.message });
    }
};

module.exports = { getRiderOrders };