/**
 * @file authRoutes.js
 * @description Handles all API endpoints under auth module
 * @module routes/authRoutes.js
*/

const express = require('express');
const router = express.Router();
const db = require('../config/dbConnection.js');


router.post('/login', async (req, res) => {
  const { firebase_uid } = req.body;

  try {
    const [rows] = await db.execute(
      'SELECT * FROM user WHERE firebase_uid = ?',
      [firebase_uid]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];

    res.json({
      email: user.email,
      full_name: user.full_name,
      role: user.role
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;