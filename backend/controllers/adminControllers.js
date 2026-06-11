/**
 * @file adminController.js
 * @description Handles Admin Screens Business logic
 * @module controllers/adminController
*/
const db = require("../config/dbConnection.js");

const getDashboardSummary = async (req, res) => {
    try {
        const calculateChange = (current, previous) => {
            if (previous <= 0) {
                return current > 0 ? 100 : 0;
            }

            return Number(
                (((current - previous) / previous) * 100).toFixed(1)
            );
        };

        // =========================
        // ALL-TIME BUSINESS METRICS
        // =========================

        const [revenueRows] = await db.query(`
            SELECT
                COALESCE(SUM(total), 0) AS revenue
            FROM orders
            WHERE status = 'completed'
        `);

        const [salesRows] = await db.query(`
            SELECT
                COUNT(*) AS total_sales
            FROM orders
            WHERE status = 'completed'
        `);

        const [customerRows] = await db.query(`
            SELECT
                COUNT(DISTINCT user_id) AS total_customers
            FROM orders
            WHERE status = 'completed'
        `);

        // =========================
        // CURRENT MONTH METRICS
        // =========================

        const [currentMonthRevenueRows] = await db.query(`
            SELECT
                COALESCE(SUM(total), 0) AS revenue
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(CURDATE())
              AND MONTH(created_at) = MONTH(CURDATE())
        `);

        const [currentMonthSalesRows] = await db.query(`
            SELECT
                COUNT(*) AS total_sales
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(CURDATE())
              AND MONTH(created_at) = MONTH(CURDATE())
        `);

        const [currentMonthCustomerRows] = await db.query(`
            SELECT
                COUNT(DISTINCT user_id) AS total_customers
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(CURDATE())
              AND MONTH(created_at) = MONTH(CURDATE())
        `);

        // =========================
        // PREVIOUS MONTH METRICS
        // =========================

        const [previousMonthRevenueRows] = await db.query(`
            SELECT
                COALESCE(SUM(total), 0) AS revenue
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
              AND MONTH(created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        `);

        const [previousMonthSalesRows] = await db.query(`
            SELECT
                COUNT(*) AS total_sales
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
              AND MONTH(created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        `);

        const [previousMonthCustomerRows] = await db.query(`
            SELECT
                COUNT(DISTINCT user_id) AS total_customers
            FROM orders
            WHERE status = 'completed'
              AND YEAR(created_at) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
              AND MONTH(created_at) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
        `);

        // =========================
        // TODAY'S REVENUE TARGET
        // =========================

        const [todayRevenueRows] = await db.query(`
            SELECT
                COALESCE(SUM(total), 0) AS revenue
            FROM orders
            WHERE status = 'completed'
              AND DATE(created_at) = CURDATE()
        `);

        const [settingsRows] = await db.query(`
            SELECT daily_revenue_target
            FROM business_settings
            LIMIT 1
        `);

        // =========================
        // VALUES
        // =========================

        const revenue =
            Number(revenueRows[0]?.revenue || 0);

        const sales =
            Number(salesRows[0]?.total_sales || 0);

        const customers =
            Number(customerRows[0]?.total_customers || 0);

        const currentMonthRevenue =
            Number(currentMonthRevenueRows[0]?.revenue || 0);

        const previousMonthRevenue =
            Number(previousMonthRevenueRows[0]?.revenue || 0);

        const currentMonthSales =
            Number(currentMonthSalesRows[0]?.total_sales || 0);

        const previousMonthSales =
            Number(previousMonthSalesRows[0]?.total_sales || 0);

        const currentMonthCustomers =
            Number(currentMonthCustomerRows[0]?.total_customers || 0);

        const previousMonthCustomers =
            Number(previousMonthCustomerRows[0]?.total_customers || 0);

        const revenueChange =
            calculateChange(
                currentMonthRevenue,
                previousMonthRevenue
            );

        const salesChange =
            calculateChange(
                currentMonthSales,
                previousMonthSales
            );

        const customerChange =
            calculateChange(
                currentMonthCustomers,
                previousMonthCustomers
            );

        const dailyTarget =
            Number(
                settingsRows[0]?.daily_revenue_target || 0
            );

        const todayRevenue =
            Number(todayRevenueRows[0]?.revenue || 0);

        const progress =
            dailyTarget > 0
                ? todayRevenue / dailyTarget
                : 0;

        return res.status(200).json({
            success: true,
            data: {
                daily_target: {
                    target: dailyTarget,
                    current: todayRevenue,
                    progress,
                },

                revenue,
                revenue_change: revenueChange,

                sales,
                sales_change: salesChange,

                customers,
                customer_change: customerChange,
            },
        });
    } catch (error) {
        console.error("Dashboard Summary Error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to fetch dashboard summary",
            error: error.message,
        });
    }
};

const updateDailyTarget = async (req, res) => {
  const { target } = req.body;

  if (!target || target <= 0) {
    return res.status(400).json({
      success: false,
      message: "Target must be greater than zero",
    });
  }

  try {
    await db.query(
      `
      UPDATE business_settings
      SET daily_revenue_target = ?
      `,
      [target]
    );

    res.json({
      success: true,
      message: "Daily revenue target updated",
    });
  } catch (error) {
    console.error(error);

    res.status(500).json({
      success: false,
      message: "Failed to update target",
    });
  }
};

const getRevenueTrend = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
          DATE_FORMAT(created_at, '%Y-%m') AS month,
          COALESCE(SUM(total), 0) AS revenue
      FROM orders
      WHERE status = 'completed'
        AND created_at >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
      GROUP BY DATE_FORMAT(created_at, '%Y-%m')
      ORDER BY DATE_FORMAT(created_at, '%Y-%m')
    `);

    return res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);

    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

const getTopMenus = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
          mi.id,
          mi.name,
          mi.price,
          SUM(oi.quantity) AS sold
      FROM order_items oi
      INNER JOIN menu_items mi
          ON oi.menu_item_id = mi.id
      INNER JOIN orders o
          ON oi.order_id = o.id
      WHERE o.status = 'completed'
      GROUP BY mi.id
      ORDER BY sold DESC
      LIMIT 5
    `);

    return res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);

    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

const getRecentOrders = async (req, res) => {
  try {
    const [rows] = await db.query(`
      SELECT
          id,
          order_number,
          customer_name,
          order_type,
          status,
          payment_status,
          total,
          created_at
      FROM orders
      ORDER BY created_at DESC
      LIMIT 5
    `);

    return res.status(200).json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error(err);

    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};

const fetchAllCustomer = async (req, res) => {
    try {
        const { search = "" } = req.query;

        let params = [];

        let query = `
            SELECT 
                u.id,
                u.firebase_uid,
                u.full_name,
                u.email,
                u.provider,
                u.role,
                u.created_at,

                COUNT(o.id) AS total_orders,

                COALESCE(
                    SUM(
                        CASE
                            WHEN o.status = 'completed'
                            THEN o.total
                            ELSE 0
                        END
                    ),
                    0
                ) AS total_spent

            FROM users u

            LEFT JOIN orders o
                ON u.id = o.user_id

            WHERE u.role = 'customer'
        `;

        // SEARCH FILTER
        if (search) {
            query += `
                AND (
                    u.full_name LIKE ?
                    OR u.email LIKE ?
                )
            `;

            params.push(`%${search}%`, `%${search}%`);
        }

        query += `
            GROUP BY u.id
            ORDER BY u.created_at DESC
        `;

        const [rows] = await db.query(query, params);

        return res.status(200).json({
            success: true,
            data: rows
        });

    } catch (error) {
        console.error("fetchAllCustomers error:", error);

        return res.status(500).json({
            success: false,
            message: "Failed to fetch customers",
            error: error.message
        });
    }
};

// [2] Menu APIs
// Fetch all items by category
const fetchMenuItems = async (req, res) => {
    try{
        // Get category id from request search query
        const { category_id } = req.query

        let query = `
            SELECT * from menu_items
        `;

        let params = [];

        if(category_id){
            query += `WHERE category_id = ? `;
            params.push(category_id);
        }

        query += `ORDER BY name ASC`;

        const [rows] = await db.query(query, params);

        res.json(rows);

    }catch(err){
        res.status(500).json({error: err.message});
    }
}

const fetchMenuCategories = async (req, res) => {
    try{
        const [ rows ] = await db.query(`SELECT id, name FROM menu_categories ORDER BY id ASC`);

        res.status(200).json(rows);
    }catch(err){    
        res.status(500).json({error: err.message});
    }
}

const addMenuCategory = async (req, res) => {
    try{
        const { name } = req.body;

        // Validate field
        if(!name){
            return res.status(400).json({message: "Category name is required!"});
        }

        // Query into our database
        const [result] = await db.query(`
            INSERT INTO menu_categories (name) VALUES (?)
            `, [name]
        );

        res.status(201).json({
            id: result.insertId,
            name
        })
    }catch(err){
        res.status(500).json({message: err.message})
    }
}

const getItemById = async (req, res) => {
    try{
        // Retrieve id value from request parameter
        const {id} = req.params;

        // Query into db
        const [rows] = await db.query("SELECT * FROM menu_items WHERE id = ?", [id]);

        // Check if it exist
        if (rows.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // Response JSON
        return res.status(200).json(rows[0]);
    }catch(err){
        console.error("Get menu item by id error:", err);
        return res.status(500).json({
        message: "Server error",
        });
    }
}


const addMenuItem = async (req, res) => {
    try{
        // Deconstruct body values
        const { name, price, description, category_id } = req.body;

        // Validate values
        if (!name || !price || !category_id) {
            return res.status(400).json({
                message: "Name, price, and category_id are required",
            });
        }

        // Check category
        const [category] = await db.query(
            "SELECT id FROM menu_categories WHERE id = ?",
            [category_id]
        );

        if (category.length === 0) {
            return res.status(404).json({
                message: "Category not found",
            });
        }

        // Insert data into db
        const [result] = await db.query(
            `INSERT INTO menu_items (name, price, description, category_id, is_available)
            VALUES (?, ?, ?, ?, 1)`,
            [name, price, description || null, category_id]
        );

        // JSON Response
        return res.status(201).json({
            message: "Menu item created successfully",
            item_id: result.insertId,
        });
    }catch(err){
        console.error("Add Menu Item Error:", error);
        return res.status(500).json({
        message: "Server error",
        });
    }
}

const deleteMenuItem = async (req, res) => {
    try{
        // Fetch id to delete from request parameter
        const { id } = req.params;

        const [item] = await db.query(
            "SELECT id FROM menu_items WHERE id = ?",
            [id]
        );

        // Check existence of id given
        if (item.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // If no errors, proceed to delete
        await db.query(
            "DELETE FROM menu_items WHERE id = ?",
            [id]
        );

        // Return JSON response
        return res.status(200).json({
            message: "Menu item deleted successfully",
        });
    }catch(err){
        console.error("Delete Menu Item Error:", error);
        return res.status(500).json({
        message: "Server error",
        });
    }
}

const updateMenuItem = async (req, res) => {
    try{
        const { id } = req.params;

        // Deconstruct all the menu-item details value
        const {
            name,
            price,
            description,
            is_available
        } = req.body

        // Validate values
        if (!name || price == null) {
            return res.status(400).json({
                message: "Name and price are required",
            });
        }

        // Check if item exists
        const [ existing ] = await db.query(
            "SELECT * FROM menu_items WHERE id = ?", [id]
        );

        if (existing.length === 0) {
            return res.status(404).json({
                message: "Menu item not found",
            });
        }

        // Update logic
        await db.query(
           `UPDATE menu_items 
            SET name = ?, price = ?, description = ?, is_available = ?
            WHERE id = ?`,
            [name, price, description, is_available ? 1 : 0, id]
        );

        // Return JSON
        return res.status(200).json({
            message: "Menu item updated successfully",
        });

    }catch(err){
        console.error("Update menu item error:", err);
        return res.status(500).json({
            message: "Server error",
        });
    }
}

const getOrders = async (req, res) => {
  try {
    const {
      startDate,
      endDate,
      status,
      search,
    } = req.query;

    let sql = `
      SELECT
        o.id,
        o.order_number,
        o.customer_name,
        o.status,
        o.total,
        o.created_at
      FROM orders o
      WHERE 1 = 1
    `;

    const params = [];

    if (startDate && endDate) {
      sql += `
        AND o.created_at BETWEEN ? AND ?
      `;

      params.push(
        `${startDate} 00:00:00`,
        `${endDate} 23:59:59`
      );
    }

    if (status) {
      sql += `
        AND o.status = ?
      `;

      params.push(status.toLowerCase());
    }

    if (search) {
      sql += `
        AND (
          o.order_number LIKE ?
          OR o.customer_name LIKE ?
        )
      `;

      params.push(
        `%${search}%`,
        `%${search}%`
      );
    }

    sql += `
      ORDER BY o.created_at DESC
    `;

    const [rows] = await db.query(sql, params);

    return res.status(200).json({
      success: true,
      data: rows,
    });

  } catch (err) {
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
};


const getCustomerReviews = async (req, res) => {
    try{

        // Retrieve all the necessary data uby joining reviews and users table
       const [rows] = await db.query(`
            SELECT 
                r.id,
                r.user_id,
                u.full_name AS customer_name,
                r.review_text,
                r.rating,
                r.status,
                r.created_at,
                u.profile_picture
            FROM reviews r
            JOIN users u ON r.user_id = u.id
            ORDER BY r.created_at DESC
        `);

        res.json(rows);

    }catch(err){
        res.status(500).json({error: err.message})
    }
}

const publishReview = async (req, res) => {
    try{
        // Retrieve review id
        const {id} = req.params;

        // Error handling   
        if(!id){
            return res.status(400).json({message: "Id field is required!"});
        }

        // Check review id existence
        const [rows] = await db.query(`
            SELECT status FROM reviews WHERE id = ?
        `, [id]);

        if(!rows.length){
            return res.status(404).json({message: "Customer Review not found!"})
        }

        // Check if published
        if(rows[0].status == 'published'){
            return res.status(400).json({message: "Customer Review already published!"})
        }

        // Execute query
        await db.query(`
            UPDATE reviews SET status = "published" WHERE id = ?    
        `, [id]);

        res.json({message: "Status updated successfully!"})

    }catch(err){
        res.status(500).json({error: err.message})
    }
}

const archiveReview = async (req, res) => {
    try{
        // Retrieve review id
        const {id} = req.params;

        // Error Handling
        if(!id) return res.status(400).json({error: "Id parameter is required!"})

        // Store review data
        const [row] = await db.query("SELECT status FROM reviews WHERE id = ?", [id]);

        // Check existence
        if(!row.length) return res.status(404).json({message: "Customer Review not found!"})

        // Check status if valid for archiving
        if(row[0].status == 'archived'){
            return res.status(400).json({message: "Customer Review already archived!" });
        }

        // Execute query
        await db. query("UPDATE reviews SET status = 'archived' WHERE id = ?", [id])

        res.status(200).json({message: "Status updated successfully!"})

    }catch(err){
        res.status(500).json({error: err.message})
    }
}

const deleteReview = async (req, res) => {
    try{
        // Retrieve review id
        const {id} = req.params;

        // Error Handling
        if(!id) return res.status(400).json({error: "Id parameter is required!"})

        // Store review data
        const [row] = await db.query("SELECT status FROM reviews WHERE id = ?", [id]);

        // Check existence
        if(!row.length) return res.status(404).json({message: "Customer Review not found!"})
        
        // Check status if valid for republishing   
        await db.query("DELETE FROM reviews WHERE id = ?", [id])

        return res.status(200).json({message: "Review deleted successfully!"})
        
    }catch(err){
        return res.status(500).json({error: err.message})
    }
}

const republishReview = async (req, res) => {
  try {
    // Retrieve review ID
    const { id } = req.params;

    // Validate ID
    if (!id) {
      return res.status(400).json({
        error: "Id parameter is required!"
      });
    }

    // Check if review exists
    const [rows] = await db.query(
      "SELECT status FROM reviews WHERE id = ?",
      [id]
    );

    // Review not found
    if (!rows.length) {
      return res.status(404).json({
        message: "Customer review not found!"
      });
    }

    const currentStatus = rows[0].status;

    // Only archived reviews can be re-published
    if (currentStatus !== 'archived') {
      return res.status(400).json({
        message: "Only archived reviews can be re-published"
      });
    }

    // Update status
    await db.query(
      "UPDATE reviews SET status = ? WHERE id = ?",
      ['published', id]
    );

    return res.status(200).json({
      message: "Review re-published successfully!",
      status: "published"
    });

  } catch (err) {
    return res.status(500).json({
      error: err.message
    });
  }
};

const getMenuSales = async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        let sql = `
            SELECT
                mi.name,
                mi.price,
                mi.image_url,
                SUM(oi.quantity) AS total_sold
            FROM order_items oi
            INNER JOIN orders o
                ON oi.order_id = o.id
            INNER JOIN menu_items mi
                ON oi.menu_item_id = mi.id
            WHERE o.status = 'completed'
        `;

        const params = [];

        if (startDate && endDate) {
            sql += `
                AND o.created_at BETWEEN ? AND ?
            `;

            params.push(
                `${startDate} 00:00:00`,
                `${endDate} 23:59:59`
            );
        }

        sql += `
            GROUP BY mi.id
            ORDER BY total_sold DESC
            LIMIT 10
        `;

        const [rows] =
            await db.query(sql, params);

        return res.status(200).json({
            success: true,
            data: rows,
        });

    } catch (err) {
        return res.status(500).json({
            error: err.message,
        });
    }
};

const getTopCustomer = async (req, res) => {
    try {

        const { startDate, endDate } = req.query;


        let sql = `
            SELECT
                u.id,
                u.profile_picture,
                u.full_name AS customer_name,
                SUM(o.total) AS total_spent
            FROM users u
            INNER JOIN orders o
                ON u.id = o.user_id
            WHERE o.status = 'completed'
        `;

        const params = [];
        params.push(
            `${startDate} 00:00:00`,
            `${endDate} 23:59:59`
        );

        if (startDate && endDate) {
            sql += `
                AND o.created_at BETWEEN ? AND ?
            `;

            params.push(startDate, endDate);
        }

        sql += `
            GROUP BY u.id
            ORDER BY total_spent DESC
            LIMIT 10
        `;

        const [rows] = await db.query(sql, params);

        return res.status(200).json({
            success: true,
            data: rows,
        });

    } catch (err) {
        return res.status(500).json({
            error: err.message,
        });
    }
};

const getRevenueReport = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    let query;
    let params = [];

    const isAllTime =
      !startDate ||
      !endDate ||
      startDate === "null" ||
      endDate === "null";

    if (isAllTime) {
      query = `
        SELECT
          COALESCE(SUM(total), 0) AS total_revenue,
          COALESCE(
            SUM(CASE WHEN source = 'online' THEN total ELSE 0 END),
            0
          ) AS online_revenue,
          COALESCE(
            SUM(CASE WHEN source = 'pos' THEN total ELSE 0 END),
            0
          ) AS walkin_revenue
        FROM orders
        WHERE status = 'completed'
      `;
    } else {
      query = `
        SELECT
          COALESCE(SUM(total), 0) AS total_revenue,
          COALESCE(
            SUM(CASE WHEN source = 'online' THEN total ELSE 0 END),
            0
          ) AS online_revenue,
          COALESCE(
            SUM(CASE WHEN source = 'pos' THEN total ELSE 0 END),
            0
          ) AS walkin_revenue
        FROM orders
        WHERE status = 'completed'
        AND created_at >= ?
        AND created_at < DATE_ADD(?, INTERVAL 1 DAY)
      `;

      params = [startDate, endDate];
    }

    const [rows] = await db.query(query, params);

    const [[settings]] = await db.query(`
      SELECT monthly_revenue_target
      FROM business_settings
      LIMIT 1
    `);

    res.status(200).json({
      success: true,
      data: {
        total_revenue: Number(rows[0].total_revenue),
        online_revenue: Number(rows[0].online_revenue),
        walkin_revenue: Number(rows[0].walkin_revenue),
        monthly_target: Number(
          settings?.monthly_revenue_target || 0
        ),
        growth_rate: 0
      }
    });

  } catch (err) {
    console.error("REVENUE REPORT ERROR:", err);

    res.status(500).json({
      success: false,
      error: err.message
    });
  }
};

const getOrdersReport = async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        const [summaryRows] = await db.query(
            `
            SELECT
                COUNT(*) AS total_orders,

                SUM(
                    CASE
                        WHEN order_type = 'dine-in'
                        THEN 1
                        ELSE 0
                    END
                ) AS dine_in_orders,

                SUM(
                    CASE
                        WHEN order_type = 'takeout'
                        THEN 1
                        ELSE 0
                    END
                ) AS takeout_orders,

                SUM(
                    CASE
                        WHEN order_type IN ('delivery', 'pickup')
                        THEN 1
                        ELSE 0
                    END
                ) AS delivery_orders

            FROM orders
            WHERE status = 'completed'
            AND created_at >= ?
            AND created_at < DATE_ADD(?, INTERVAL 1 DAY)
            `,
            [startDate, endDate]
        );

        const [peakRows] = await db.query(
            `
            SELECT
                HOUR(created_at) AS hour_bucket,
                COUNT(*) AS total_orders
            FROM orders
            WHERE status = 'completed'
            AND created_at >= ?
            AND created_at < DATE_ADD(?, INTERVAL 1 DAY)
            GROUP BY HOUR(created_at)
            ORDER BY total_orders DESC
            LIMIT 1
            `,
            [startDate, endDate]
        );

        let peakOrderTime = 'N/A';

        if (peakRows.length > 0) {
            const hour = peakRows[0].hour_bucket;

            const formatHour = (h) => {
                const period = h >= 12 ? 'PM' : 'AM';
                const display = h % 12 || 12;
                return `${display}${period}`;
            };

            peakOrderTime =
                `${formatHour(hour)} - ${formatHour((hour + 2) % 24)}`;
        }

        const data = {
            total_orders: Number(summaryRows[0].total_orders) || 0,
            dine_in_orders: Number(summaryRows[0].dine_in_orders) || 0,
            takeout_orders: Number(summaryRows[0].takeout_orders) || 0,
            delivery_orders: Number(summaryRows[0].delivery_orders) || 0,
            order_growth: 0,
            peak_order_time: peakOrderTime,
        };

        return res.status(200).json({
            success: true,
            data,
        });

    } catch (err) {
        console.error(err);

        return res.status(500).json({
            success: false,
            error: err.message,
        });
    }
};

const getSalesDistributionReport = async (req, res) => {
    try {
        const { startDate, endDate } = req.query;

        const [categoryRows] = await db.query(
            `
            SELECT
                mc.id,
                mc.name,
                COALESCE(SUM(oi.subtotal), 0) AS sales
            FROM menu_categories mc
            LEFT JOIN menu_items mi
                ON mc.id = mi.category_id
            LEFT JOIN order_items oi
                ON mi.id = oi.menu_item_id
            LEFT JOIN orders o
                ON oi.order_id = o.id
                AND o.created_at >= ?
                AND o.created_at < DATE_ADD(?, INTERVAL 1 DAY)
            GROUP BY mc.id, mc.name
            ORDER BY sales DESC
            `,
            [startDate, endDate]
        );

        const [summaryRows] = await db.query(
            `
            SELECT
                COUNT(*) AS total_orders,
                COALESCE(SUM(total), 0) AS total_sales
            FROM orders
            WHERE status = 'completed'
            AND created_at >= ?
            AND created_at < DATE_ADD(?, INTERVAL 1 DAY)
            `,
            [startDate, endDate]
        );

        return res.status(200).json({
            success: true,
            data: {
                total_sales:
                    Number(summaryRows[0].total_sales) || 0,

                total_orders:
                    Number(summaryRows[0].total_orders) || 0,

                categories: categoryRows.map(category => ({
                    name: category.name.toUpperCase(),
                    sales: Number(category.sales) || 0,
                })),
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


const getSalesSummaryReport = async (req, res) => {
    try {
        const { range = "last24hours" } = req.query;

        let query = "";
        let params = [];

        switch (range) {
            case "last24hours":
                    query = `
                        SELECT
                            LPAD(hour_num, 2, '0') AS label,
                            SUM(total) AS sales
                        FROM (
                            SELECT
                                HOUR(created_at) AS hour_num,
                                total
                            FROM orders
                            WHERE status = 'completed'
                            AND created_at >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
                        ) t
                        GROUP BY hour_num
                        ORDER BY hour_num
                    `;
                break;

           case "last7days":
                query = `
                    SELECT
                        DATE_FORMAT(day_date, '%a') AS label,
                        SUM(total) AS sales
                    FROM (
                        SELECT
                            DATE(created_at) AS day_date,
                            total
                        FROM orders
                        WHERE status = 'completed'
                        AND created_at >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
                    ) t
                    GROUP BY day_date
                    ORDER BY day_date
                `;
                break;

           case "last30days":
                query = `
                    SELECT
                        CONCAT('W', week_num) AS label,
                        SUM(total) AS sales
                    FROM (
                        SELECT
                            FLOOR(
                                DATEDIFF(
                                    created_at,
                                    DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                                ) / 7
                            ) + 1 AS week_num,
                            total
                        FROM orders
                        WHERE status = 'completed'
                        AND created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
                    ) t
                    GROUP BY week_num
                    ORDER BY week_num
                `;
                break;

            case "last3months":
                query = `
                    SELECT
                        DATE_FORMAT(
                            MIN(created_at),
                            '%b'
                        ) AS label,
                        SUM(total) AS sales
                    FROM orders
                    WHERE status = 'completed'
                    AND created_at >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
                    GROUP BY YEAR(created_at), MONTH(created_at)
                    ORDER BY YEAR(created_at), MONTH(created_at)
                `;
                break;

            case "thisyear":
                query = `
                    SELECT
                        DATE_FORMAT(
                            MIN(created_at),
                            '%b'
                        ) AS label,
                        SUM(total) AS sales
                    FROM orders
                    WHERE status = 'completed'
                    AND YEAR(created_at) = YEAR(CURDATE())
                    GROUP BY YEAR(created_at), MONTH(created_at)
                    ORDER BY YEAR(created_at), MONTH(created_at)
                `;
                break;

            case "alltime":
                 query = `
                    SELECT
                        YEAR(created_at) AS label,
                        SUM(total) AS sales
                    FROM orders
                    WHERE status = 'completed'
                    GROUP BY YEAR(created_at)
                    ORDER BY YEAR(created_at)
                `;
                break;

            default:
                return res.status(400).json({
                    success: false,
                    message: "Invalid range"
                });
        }

        const [rows] = await db.query(query, params);

        return res.status(200).json({
            success: true,
            data: rows
        });

    } catch (err) {
        console.error(err);

        return res.status(500).json({
            success: false,
            error: err.message
        });
    }
};

module.exports = { 
    getDashboardSummary,
    updateDailyTarget,
    getRevenueTrend,
    getTopMenus,
    getRecentOrders,
    fetchAllCustomer, 
    fetchMenuItems,
    fetchMenuCategories,
    addMenuCategory,
    addMenuItem,
    deleteMenuItem,
    getItemById,
    updateMenuItem,
    getOrders,
    getCustomerReviews,
    publishReview,
    archiveReview, 
    deleteReview,
    republishReview,
    getMenuSales,
    getTopCustomer,
    getRevenueReport,
    getOrdersReport,
    getSalesDistributionReport,
    getSalesSummaryReport
 };