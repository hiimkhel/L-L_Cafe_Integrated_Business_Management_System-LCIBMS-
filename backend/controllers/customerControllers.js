const db = require("../config/dbConnection.js");

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



module.exports = { getUserAddresses };