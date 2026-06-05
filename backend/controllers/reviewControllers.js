const db = require("../config/dbConnection.js");

const getPublicReviews = async (req, res) => {
  try {
       const [rows] = await db.execute(`
      SELECT 
        r.id,
        u.full_name AS customer_name,
        r.review_text,
        r.rating,
        r.created_at AS submitted_at
      FROM reviews r
      JOIN users u ON r.user_id = u.id
      WHERE r.status = 'published'
      ORDER BY r.rating DESC, r.created_at DESC
      LIMIT 5
    `);

    res.status(200).json(rows);
  } catch (error) {
    console.error('Get public reviews error:', error);

    res.status(500).json({
      message: 'Failed to fetch public reviews',
    });
  }
};

module.exports = { getPublicReviews }