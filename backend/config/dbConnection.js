/**
 * @file dbConnection.js
 * @description Handles database connection and configuration to MONGODB
 * @module config/dbConnection
*/
const mysql = require('mysql2/promise');
const dotenv = require('dotenv');

dotenv.config();

// Create connection pool (BEST PRACTICE)
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  port: process.env.DB_PORT,
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'lcibms_database',

  timezone: '+08:00',
  
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Optional: test connection
pool.getConnection()
  .then((conn) => {
    console.log('MySQL Connected Successfully');
    conn.release();
  })
  .catch((err) => {
    console.error('MySQL Connection Failed:', err.message);
  });

module.exports = pool;