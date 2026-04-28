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

const getDeliveryOrderDetails= async (req, res) => {
    try{

        const { id } = req.params;

       const [orderRows] = await db.query(
            `SELECT 
                o.order_number AS id, 
                o.status, 
                o.customer_name AS name, 
                o.customer_phone AS phone, 
                o.notes,
                o.delivery_fee AS deliveryFee,
                o.created_at AS time,
                ua.full_address AS address 
             FROM orders o
             LEFT JOIN user_addresses ua ON o.address_id = ua.id
             WHERE o.id = ?`, 
            [id]
        );
        
        // Check order existence
        if (orderRows.length === 0) {
            return res.status(404).json({ success: false, message: 'Order not found' });
        }

        const orderInfo = orderRows[0];

        // 2. Fetch the specific items for this order
        const [itemRows] = await db.query(
            `SELECT item_name AS name, unit_price AS price, quantity 
             FROM order_items 
             WHERE order_id = ?`, 
            [id]
        );

        // 3. Combine them to match your Flutter "Map<String, dynamic> order"
        const responseData = {
            ...orderInfo,
            // Convert status to uppercase to match your Flutter logic if necessary
            status: orderInfo.status.toUpperCase(), 
            order: itemRows
        };

        res.status(200).json({
            success: true,
            data: responseData
        });
    }catch(err){
        res.status(500).json({error: err.message});
    }
}

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