const db = require("../config/dbConnection.js");

const getOrderById = async (req, res) => {
    const { id } = req.params;

    try {
      let flavors = [];


        // Order header
        const [orderRows] = await db.query(
            `
            SELECT
                id,
                order_number,
                customer_name,
                payment_method,
                status,
                total,
                created_at,
                updated_at
            FROM orders
            WHERE id = ?
            `,
            [id]
        );

        if (orderRows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "Order not found",
            });
        }

        const order = orderRows[0];

        // Order items
        const [itemRows] = await db.query(
            `
            SELECT
                oi.id,
                oi.menu_item_id,
                oi.item_name,
                oi.quantity,
                oi.unit_price,
                oi.subtotal,
                oi.variant_id,
                oi.selected_flavors,

                mv.variant_name,
                mv.category AS variant_category

            FROM order_items oi

            LEFT JOIN menu_items_variants mv
                ON mv.id = oi.variant_id

            WHERE oi.order_id = ?
            `,
            [id]
        );

        const items = itemRows.map((item) => ({
          
            id: item.menu_item_id,
            name: item.item_name,
            qty: item.quantity,
            price: Number(item.unit_price),
            subtotal: Number(item.subtotal),

            variant_id: item.variant_id,

            variant_name: item.variant_name,

            variant_category: item.variant_category,

            flavors: parseFlavors(item.selected_flavors)
        }));

        return res.status(200).json({
            success: true,
            order: {
                ...order,
                items,
            },
        });

    } catch (err) {
        console.error(err);

        return res.status(500).json({
            success: false,
            error: err.message,
        });
    }
};

const createOrder = async (req, res) => {
  const conn = await db.getConnection();

  try {
    await conn.beginTransaction();

    const {
      orderNumber,
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
        (order_id, menu_item_id, item_name, quantity, unit_price, subtotal, variant_id, selected_flavors)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          orderId,
          item.menu_item_id,
          item.name,
          item.quantity,
          item.unit_price,
          item.subtotal,
          item.variant_id ?? null,
          JSON.stringify(
          (item.flavors ?? []).map(f => ({
            id: f.id,
            flavor_name: f.flavorName,
          }))
          )
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

const fetchCurrentOrderNumber = async (req, res) => {
  try{
    // Query the database for the max ID currently in the orders table
    const [rows] = await db.query("SELECT MAX(id) as lastId FROM orders");
    
    // If no orders exist yet, start at 1. Otherwise, increment lastId.
    const nextId = (rows[0].lastId || 0) + 1;

    res.json({ 
      success: true, 
      nextId: nextId 
    });

  }catch(err){  
    res.status(500).json({error: err.message})
  }
}

function parseFlavors(value) {
    if (value == null) {
        return [];
    }

    if (typeof value !== "string") {
        return [];
    }

    if (value.trim() === "") {
        return [];
    }

    try {
        return JSON.parse(value);
    } catch (err) {
        console.error("Invalid selected_flavors:", value);
        return [];
    }
}

module.exports = {getOrderById, createOrder, fetchCurrentOrderNumber}