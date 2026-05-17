const { updateUserSettings } = require('../services/userSettingsService');

const updateSettings = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const { name, email, phone } = req.body;
        const data = {};
        if (name !== undefined) data.firstName = name;
        if (email !== undefined) data.email = email;
        if (phone !== undefined) data.phoneNumber = phone;

        const updated = await updateUserSettings(userId, data);
        res.json({ success: true, user: updated });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = {
    updateSettings,
};