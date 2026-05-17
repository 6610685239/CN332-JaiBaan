const express = require('express');
const { auth } = require('../middleware/auth');
const { getMe, updateSettings, uploadAvatar } = require('../controllers/userSettingsController');
const upload = require('../middleware/upload');

const router = express.Router();

router.get('/me', auth, getMe);
router.put('/settings', auth, updateSettings);
router.post('/avatar', auth, upload.single('avatar'), uploadAvatar);

module.exports = router;