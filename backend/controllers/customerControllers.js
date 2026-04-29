const db = require("../config/dbConnection.js");
const admin = require("../config/firebase.js");


const getUserProfile = async (req, res) => {

    try{
        const userId = req.params.id;
        // 1. Get user info
        const [userRows] = await db.query(
        `SELECT id, full_name, email, phone, profile_picture, created_at
        FROM users WHERE id = ?`,
        [userId]
        );

        if (userRows.length === 0) {
        return res.status(404).json({ success: false, message: "User not found" });
        }

        // 2. Get addresses
        const [addressRows] = await db.query(
        `SELECT id, label, full_address 
        FROM user_addresses 
        WHERE user_id = ?`,
        [userId]
        );

        // 3. Combine response
        res.json({
        success: true,
        user: userRows[0],
        addresses: addressRows
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, message: err.message });
    }
    
}

const getUserAddresses = async (req, res) => {
    try{
        const userId = req.params.id;
 
        const [rows] = await db.query(
            `SELECT id, label, full_address FROM user_addresses WHERE user_id = ?`, [userId]
        );

        res.json({success: true, addresses: rows})
    }catch(err){
        console.error(err);
        res.status(500).json({error: err.message})
    }
}
const updateUserProfile = async (req, res) => {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({ message: "No token provided" });
        }
        console.log("RAW AUTH HEADER:", req.headers.authorization);

        const idToken = authHeader.split(" ")[1];
        console.log("TOKEN RECEIVED:", idToken);
        const decoded = await admin.auth().verifyIdToken(idToken);
        console.log("TOKEN DECODED:", decoded);
        const uid = decoded.uid;

        const { full_name, phone } = req.body;

        if (!full_name) {
        return res.status(400).json({ message: "Full name is required" });
        }

        // UPDATE
        await db.query(
        `UPDATE users SET full_name = ?, phone = ? WHERE firebase_uid = ?`,
        [full_name, phone || null, uid]
        );

        // FETCH UPDATED USER
        const [rows] = await db.query(
        `SELECT id, firebase_uid, email, full_name, phone, profile_picture, role 
        FROM user WHERE firebase_uid = ?`,
        [uid]
        );

        return res.json({
        message: "Profile updated successfully",
        user: rows[0],
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: err.message });
    }
};
module.exports = { getUserAddresses, getUserProfile, updateUserProfile};