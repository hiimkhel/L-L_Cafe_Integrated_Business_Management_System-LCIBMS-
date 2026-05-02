const express = require('express');
const router = express.Router();
const db = require('../config/dbConnection.js'); 

router.post('/add-review', (req, res) => {
  const { user_id, review_text, rating } = req.body;

  console.log("Calling db.query now...");

  db.query(
    'INSERT INTO reviews (user_id, review_text, rating) VALUES (?, ?, ?)',
    [user_id, review_text, rating],
    (err, result) => {
      console.log("DB callback fired"); // if this never prints, pool is broken
      if (err) {
        console.error("CODE:", err.code);
        console.error("MSG:", err.sqlMessage);
        return res.status(500).json({ error: err.sqlMessage, code: err.code });
      }
      return res.status(201).json({ message: "Review saved", id: result.insertId });
    }
  );
});

module.exports = router;