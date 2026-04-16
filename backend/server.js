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
app.use(express.json());

const PORT = process.env.SERVER_PORT || 3006;

app.use(express.json()); // middleware to parse incoming requests

// [ ROUTING SYSTEM ]
// Note: This is where you add your API endpoints
app.use('/api/auth', require("./routes/authRoutes.js"));
app.use('/api/customer', (req,res) => {
    // [!] Temporary: Change this to customerRoutes.js
    console.log("This are customer module routes");
})
app.use('/api/pos', (req,res) => {
    // [!] Temporary: Change this to posRoutes.js
    console.log("This are pos module routes");
})
app.use('/api/rider', (req,res) => {
    // [!] Temporary: Change this to riderRoutes.js
    console.log("This are rider's module routes");
})
app.use('/api/admin', (req,res) => {
    // [!] Temporary: Change this to adminRoutes.js
    console.log("This are admin module routes");
})
app.listen(PORT, () => {
    console.log(`Server is running on ${PORT}`);
});

