const express = require('express');
const router = express.Router();
const dashboardController = require('../controllers/dashboardController');

// สร้าง Path: GET /stats
router.get('/stats', dashboardController.getDashboardStats);

module.exports = router;