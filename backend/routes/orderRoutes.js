const express = require('express');
const router = express.Router();
const {createOrder} = require("../controllers/orderControllers.js");

router.post('/', createOrder);

//-- Multer setup for file uploads
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/receipts/'),
  filename: (req, file, cb) => {
    const name = `receipt_${Date.now()}${path.extname(file.originalname)}`;
    cb(null, name);
  },
});
const upload = multer({ storage });

router.post('/upload-proof', upload.single('receipt'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file uploaded' });
  const filePath = `receipts/${req.file.filename}`;
  res.json({ path: filePath });
});
//-------------------------------------------

module.exports = router;