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

const updateOrderStatus = async (req, res) => {
  const {id} = req.params;
  const { status } = req.body;

    try {
      
      // Error handling
      if (!status){
        req.status(400).json({message: 'Status field is missing!'});
      }

      await db.query("UPDATE orders SET status = ? WHERE id = ?", [status, id]);

      res.status(200).json({ message: "Order status updated" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}


const getOnlineOrders = async (req, res ) => {

    try {
        const [rows] = await db.query(`
        SELECT 
            o.id,
            o.order_number,
            o.customer_name,
            o.customer_phone,
            o.status,
            o.subtotal,
            o.delivery_address,
            o.delivery_fee,
            o.total,
            o.payment_status,
            o.payment_method,
            o.notes,
            oi.id AS item_id,
            oi.item_name,
            oi.quantity,
            oi.unit_price,
            oi.subtotal AS item_subtotal
        FROM orders o
        LEFT JOIN order_items oi ON oi.order_id = o.id
        WHERE o.source = 'online'
        ORDER BY o.created_at DESC
        `);

        const ordersMap = {};

        rows.forEach(row => {
        if (!ordersMap[row.id]) {
            ordersMap[row.id] = {
            id: row.id,
            order_number: row.order_number,
            customer_name: row.customer_name,
            customer_phone: row.customer_phone,
            status: row.status,
            subtotal: row.subtotal,
            delivery_address: row.delivery_address,
            delivery_fee: row.delivery_fee,
            total: row.total,
            payment_status: row.payment_status,
            payment_method: row.payment_method,
            notes: row.notes,
            items: []
            };
        }

        if (row.item_id) {
            ordersMap[row.id].items.push({
            id: row.item_id,
            name: row.item_name,
            quantity: row.quantity,
            unit_price: row.unit_price,
            subtotal: row.item_subtotal
            });
        }
        });

        res.json({
        success: true,
        data: Object.values(ordersMap)
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({
        success: false,
        message: "Failed to fetch online orders"
        });
    }
}

const acceptOrder = async (req, res) => {
    try{
         const { id } = req.params;

        await db.query(
            `UPDATE orders SET status = 'preparing' WHERE id = ?`,
            [id]
        );

        res.json({ success: true });
    }catch(err){
        console.error(err);
        res.status(500).json({error: err.message})
    }
}


const rejectOrder = async (req, res) => {
    try{
        const { id } = req.params;

        await db.query(
            `UPDATE orders SET status = 'rejected' WHERE id = ?`,
            [id]
        );

        res.json({ success: true });
    }catch(err){
        console.error(err);
        res.status(500).json({error: err.message})
    }
}


const fetchPreparingOrders = async (req, res) => {
    try{
        const [rows] = await db.query(`
            SELECT COUNT(*) AS count
            FROM orders
            WHERE status = 'pending'
        `);

        res.json({
        success: true,
        count: rows[0].count,
        });
    }catch(err){
        console.error('Error fetching in-progress count:', error);
        res.status(500).json({
        success: false,
        message: 'Failed to fetch in-progress count',
        });
    }
}
module.exports = {getOrdersByStatus, updateOrderStatus, getOnlineOrders, acceptOrder, rejectOrder, fetchPreparingOrders}