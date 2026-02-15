const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// สร้างเส้นทาง POST /juristic/login
router.post('/juristic/login', authController.juristicLogin);

module.exports = router;