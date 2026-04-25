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

const authSync = async (req, res) => {
  try {

    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({ message: "No token provided" });
    }

    const idToken = authHeader.split(" ")[1];
    //  Verify Firebase token
    const decoded = await admin.auth().verifyIdToken(idToken);


    const uid = decoded.uid;
    const email = decoded.email || "";
    const name = decoded.name || "User";
    const picture = decoded.picture || "";
    const provider = decoded.firebase?.sign_in_provider || "unknown";

    // Get user from DB
    let user = await findUserByFirebaseUID(uid);

    // Create user if not exists
    if (!user) {
      user = await createUser({
        firebase_uid: uid,
        email,
        full_name: name,
        profile_picture: picture,
        provider,
        role: "customer", // default role ONLY here
      });
    }

    // ALWAYS return DB as source of truth
    return res.status(200).json({
      id: user.id,
      firebase_uid: user.firebase_uid,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      profile_picture: user.profile_picture,
    });

  } catch (error) {
    console.error("Auth error:", error);
    return res.status(401).json({
      message: "Invalid or expired token",
    });
  }
}

module.exports = {login, register, authSync};