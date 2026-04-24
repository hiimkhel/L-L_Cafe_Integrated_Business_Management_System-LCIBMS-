/**
 * @file authMiddleware.js
 * @description Middleware for verifying JWT authentication
*/

const admin = require("../config/firebase");
const db = require("../config/dbConnection.js");

const authMiddleware = async (req, res, next) => {
    try {
        const token = req.headers.authorization?.split(" ")[1];

        if (!token) {
            return res.status(401).json({
                success: false,
                message: "No token provided"
            });
        }

        const decoded = await admin.auth().verifyIdToken(token);

        // get user from MySQL
        const [rows] = await db.query(
            "SELECT id, firebase_uid, full_name, email, role FROM users WHERE firebase_uid = ?",
            [decoded.uid]
        );

        if (rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "User not found in database"
            });
        }

        req.user = rows[0]; // attach user

        next();

    } catch (error) {
        return res.status(401).json({
            success: false,
            message: "Invalid or expired token",
            error: error.message
        });
    }
};

module.exports = authMiddleware;