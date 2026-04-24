const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

router.post('/juristic/login', authController.juristicLogin);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);

module.exports = router;
