/**
 * @file authController.js
 * @description Handles user authentication
 * @module controllers/authController
*/
const db = require("../config/dbConnection.js");


const register = async (req, res) => {
    const {firebase_uid, full_name, email } = req.body;
    const role = 'customer';

    try{
        const [existing] = await db.query(
            'SELECT * FROM user WHERE firebase_uid = ? OR email = ?',
            [firebase_uid, email]
        )

        if(existing.length > 0 ){
            return res.status(400).json({
                message: 'User already exists',
            });
        }

        await db.query(
            `INSERT INTO user (firebase_uid, full_name, email, role) VALUES (?, ?, ?, ?)`, 
            [firebase_uid, full_name, email , role]
        );

        res.status(201).json({
            message: 'User registered successfully!',
            role: role
        });
    }catch(err){
        console.error(err);
        res.status(500).json({
            message: 'Server error',
        })
    }
}

const login = async (req, res) => {
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
}

module.exports = {login, register};