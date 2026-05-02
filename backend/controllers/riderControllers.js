const db = require("../config/dbConnection.js");

const getRiderOrders = async (req, res) => {
    try {
        const status = req.query.status || 'ready';

        const sql = `
            SELECT 
                o.id,
                o.order_number,
                o.customer_name,
                o.customer_phone,
                o.status,
                o.total,
                o.created_at,
                o.delivery_address,
                oi.item_name,
                oi.quantity,
                oi.unit_price
            FROM orders o
            LEFT JOIN order_items oi ON o.id = oi.order_id
            WHERE o.status = ? AND o.order_type = 'delivery'
            ORDER BY o.created_at ASC
        `;
            
        const [rows] = await db.query(sql, [status]);

        const ordersMap = {};
        rows.forEach(row => {
            if (!ordersMap[row.id]) {
                ordersMap[row.id] = {
                    id: row.id,
                    order_number: row.order_number,
                    customer_name: row.customer_name || "Guest",
                    customer_phone: row.customer_phone,
                    delivery_address: row.delivery_address || "No Address",
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

const getDeliveryOrderDetails = async (req, res) => {
    try {
        const { id } = req.params;

        const [orderRows] = await db.query(
            `SELECT 
                o.id,
                o.order_number,
                o.status,
                o.customer_name,
                o.customer_phone,
                o.notes,
                o.subtotal,
                o.delivery_fee,
                o.total,
                o.created_at,
                o.delivery_address
             FROM orders o
             WHERE o.id = ?`,
            [id]
        );

        if (orderRows.length === 0) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        const orderInfo = orderRows[0];

        const [itemRows] = await db.query(
            `SELECT 
                item_name AS name,
                unit_price AS price,
                quantity AS qty
            FROM order_items 
            WHERE order_id = ?`,
            [id]
        );

        const formattedItems = itemRows.map(item => ({
            name: item.name,
            qty: Number(item.qty),
            price: Number(item.price)
        }));

        res.status(200).json({
            success: true,
            data: {
                id: orderInfo.order_number,
                db_id: orderInfo.id,
                name: orderInfo.customer_name,
                phone: orderInfo.customer_phone,
                delivery_address: orderInfo.delivery_address,
                notes: orderInfo.notes,
                status: orderInfo.status.toUpperCase(),
                time: orderInfo.created_at,
                subtotal: orderInfo.subtotal,        // 👈 ADD THIS
                delivery_fee: orderInfo.delivery_fee,
                total: orderInfo.total,
                items: formattedItems   
            }
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const updateDeliveryStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { newStatus } = req.body;

        // ENUM values
        const validStatuses = ['preparing', 'ready', 'out_for_delivery', 'completed'];

        // Check if newStatus is valid
        if (!validStatuses.includes(newStatus)) {
            return res.status(400).json({ 
                success: false, 
                message: `Invalid status. Must be one of: ${validStatuses.join(', ')}` 
            });
        }

        const sql = "UPDATE orders SET status = ? WHERE id = ?";
        const [result] = await db.query(sql, [newStatus, id]);

        if (result.affectedRows === 0) {
            return res.status(404).json({ 
                success: false, 
                message: "Order not found" 
            });
        }

        res.status(200).json({ success: true, message: `Status updated to ${newStatus}` });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
}

module.exports = { getRiderOrders, getDeliveryOrderDetails, updateDeliveryStatus };