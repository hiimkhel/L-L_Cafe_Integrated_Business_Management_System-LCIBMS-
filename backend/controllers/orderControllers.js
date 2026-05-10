const db = require("../config/dbConnection.js");

const createOrder = async (req, res) => {
  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    const {
      source,
      order_type,
      user_id,
      customer_name,
      customer_phone,
      subtotal,
      delivery_fee,
      delivery_address,
      total,
      payment_method,
      payment_status,
      items,
      notes,
      payment_proof_url,
    } = req.body;

    // 1. Create order number
    const orderNumber = Date.now().toString();

    // Handle status dependent on source of order (pos / online )
    const initialStatus = source.toLowerCase() === 'pos' ? 'preparing' : 'pending';

    // 2. Insert order
    const [orderResult] = await conn.query(
      `INSERT INTO orders 
      (order_number, source, user_id, customer_name, customer_phone,
       order_type, status, subtotal, delivery_fee, delivery_address, total,
       payment_status, payment_method, notes, payment_proof_url)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        orderNumber,
        source,
        user_id,
        customer_name,
        customer_phone,
        order_type,
        initialStatus,
        subtotal,
        delivery_fee,
        delivery_address,
        total,
        payment_status,
        payment_method,
        notes,
        payment_proof_url
      ]
    );

    const orderId = orderResult.insertId;

    // 3. Insert order items
    for (const item of items) {
      await conn.query(
        `INSERT INTO order_items 
        (order_id, menu_item_id, item_name, quantity, unit_price, subtotal)
        VALUES (?, ?, ?, ?, ?, ?)`,
        [
          orderId,
          item.menu_item_id,
          item.name,
          item.quantity,
          item.unit_price,
          item.subtotal
        ]
      );
    }

    await conn.commit();
    
    res.json({
      success: true,
      order_id: orderId,
      order_number: orderNumber
    });

  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(500).json({ success: false, message: "Order failed" });
  } finally {
    conn.release();
  }
}


module.exports = {createOrder}