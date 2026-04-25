const db = require("../config/dbConnection.js");

const getAllMenuItems = async (req, res) => {

    try{
        const [rows] = await db.query(`
            SELECT *
            FROM menu_items
        `);

        res.json(rows);
        
    }catch(err){
         console.error(err);
        res.status(500).json({ message: 'Failed to fetch menu' });
    }
}

module.exports = {getAllMenuItems};