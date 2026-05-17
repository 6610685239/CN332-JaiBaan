const express = require('express');
const { auth } = require('../middleware/auth');
const { updateSettings } = require('../controllers/userSettingsController');

const router = express.Router();

router.put('/settings', auth, updateSettings);

module.exports = router;