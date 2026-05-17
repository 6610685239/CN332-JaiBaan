const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const prisma = require('../../db');

router.post('/register', authController.register);
router.post('/login', authController.residentLogin);
router.post('/juristic/login', authController.juristicLogin);
router.post('/forgot-password', authController.forgotPassword);
router.post('/reset-password', authController.resetPassword);
router.post('/google', authController.googleLogin);
router.post('/google/complete', authController.googleComplete);

// POST /api/auth/fcm-token  { userId, token }
router.post('/fcm-token', async (req, res) => {
  try {
    const { userId, token } = req.body;
    await prisma.user.update({ where: { id: parseInt(userId) }, data: { fcmToken: token } });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save FCM token' });
  }
});

module.exports = router;
