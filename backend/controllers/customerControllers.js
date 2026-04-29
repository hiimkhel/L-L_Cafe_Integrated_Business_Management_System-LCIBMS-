const db = require("../config/dbConnection.js");

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



module.exports = { getUserAddresses, getUserProfile};