const db = require("../config/dbConnection.js");

const getOrdersByStatus = async (req, res) => {
    const status = req.query.status || 'pending';

    try {
        const sql = `
            SELECT 
                o.id, o.source, o.order_number, o.customer_name, o.status, o.total, o.created_at, o.updated_at,
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
                    source: row.source,
                    order_number: row.order_number,
                    customer_name: row.customer_name || "WALK-IN",
                    status: row.status,
                    total: row.total,
                    created_at: row.created_at,
                    updated_at: row.updated_at,
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
            DATE_FORMAT(o.created_at, '%Y-%m-%dT%H:%i:%sZ') AS created_at,
            o.payment_proof_url,
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
            payment_proof_url: row.payment_proof_url,
            created_at: row.created_at,
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
            WHERE status = 'preparing'
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

const fetchPendingOrdersCount = async (req, res) => {
    try {
    const [rows] = await db.query(
      `SELECT COUNT(*) AS count 
       FROM orders 
       WHERE status = 'pending' 
       AND source = 'online'`
    );

    res.json({ count: rows[0].count });
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch count" });
  }
}

const getOrderHistory = async (req, res) => {
  try {
    const {
      search = "",
      dateFilter = "all",
      startDate = "", // Added this
      endDate = "",   // Added this
      page = 1,
      limit = 10,
    } = req.query;

    const currentPage = parseInt(page, 10);
    const pageSize = parseInt(limit, 10);
    const offset = (currentPage - 1) * pageSize;

    let whereClauses = [];
    let params = [];

    // 1. Base Filter: History should only show finalized states
    whereClauses.push(`o.status IN ('completed', 'cancelled', 'rejected')`);

    // 2. Search Logic
    if (search.trim()) {
      whereClauses.push(`(o.order_number LIKE ? OR o.customer_name LIKE ?)`);
      params.push(`%${search}%`, `%${search}%`);
    }

    // 3. Date Filters (Fixed with Custom Range support)
    switch (dateFilter) {
      case "today":
        whereClauses.push(`DATE(o.created_at) = CURDATE()`);
        break;

      case "yesterday":
        whereClauses.push(`DATE(o.created_at) = CURDATE() - INTERVAL 1 DAY`);
        break;

      case "last7days":
        whereClauses.push(`o.created_at >= CURDATE() - INTERVAL 7 DAY`);
        break;

      case "custom": // Added this case
        if (startDate && endDate) {
          // We use >= and <= with time to ensure we get the full last day
          whereClauses.push(`DATE(o.created_at) BETWEEN ? AND ?`);
          params.push(startDate, endDate);
        }
        break;

      case "all":
      default:
        break;
    }

    const whereSQL = whereClauses.length > 0 
      ? `WHERE ${whereClauses.join(" AND ")}` 
      : "";

    // --- COUNT QUERY ---
    const countQuery = `SELECT COUNT(*) AS total FROM orders o ${whereSQL}`;
    const [countRows] = await db.query(countQuery, params);
    const totalRecords = countRows[0].total;
    const totalPages = Math.ceil(totalRecords / pageSize);

    // --- MAIN DATA QUERY ---
    const dataQuery = `
    SELECT 
        o.id, 
        o.order_number, 
        o.customer_name, 
        o.payment_method, 
        o.total, 
        o.created_at,
        -- Summing the quantity from the joined order_items table
        CAST(COALESCE(SUM(oi.quantity), 0) AS UNSIGNED) AS item_count,
        JSON_OBJECT(
        'id', o.id,
        'order_number', o.order_number,
        'customer_name', o.customer_name,
        'status', o.status,
        'total', o.total,
        'payment_method', o.payment_method,
        'created_at', o.created_at
        ) AS full_order_data
    FROM orders o
    LEFT JOIN order_items oi ON o.id = oi.order_id
    ${whereSQL}
    GROUP BY o.id
    ORDER BY o.created_at DESC
    LIMIT ? OFFSET ?
    `;

    const dataParams = [...params, pageSize, offset];
    const [orders] = await db.query(dataQuery, dataParams);

    return res.status(200).json({
      success: true,
      data: orders,
      pagination: { currentPage, pageSize, totalRecords, totalPages },
    });
  } catch (error) {
    console.error("Get Order History Error:", error);
    return res.status(500).json({ success: false, error: error.message });
  }
};

module.exports = {getOrdersByStatus, updateOrderStatus, getOnlineOrders, acceptOrder, rejectOrder, fetchPreparingOrders, fetchPendingOrdersCount, getOrderHistory}