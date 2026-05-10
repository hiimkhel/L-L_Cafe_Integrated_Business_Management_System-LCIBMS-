// Entry point of our backend server
// This file contains the code required to initialize and start the LCIBMS server 
// Listens to incoming HTTPS requests and responds to it

const dotenv = require('dotenv');
const express = require('express');
const cors = require('cors');

//  Load dotenv 
dotenv.config();

const app = express();
app.use(cors());

const PORT = process.env.SERVER_PORT || 3006;

app.use(express.json()); // middleware to parse incoming requests

// [ ROUTING SYSTEM ]
// Note: This is where you add your API endpoints
app.use('/api/auth', require("./routes/authRoutes.js"));
app.use('/api/customer', require("./routes/customerRoutes.js"))
app.use('/api/pos', require("./routes/posRoutes.js"));

app.use('/api/orders', require("./routes/orderRoutes.js"));
app.use('/uploads', (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  next();
}, express.static('uploads'));
// Serve uploaded files from the 'uploads' directory
app.use('/api/rider', require("./routes/riderRoutes.js"));
app.use('/api/admin', require("./routes/adminRoutes.js"));

app.use('/api/reviews', require("./routes/reviewRoutes.js"));
app.use('/api/menu', require("./routes/menuRoutes.js"));
app.listen(PORT, () => {
    console.log(`Server is running on ${PORT}`);
});

