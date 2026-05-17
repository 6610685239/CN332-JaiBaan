const { updateUserSettings } = require('../services/userSettingsService');
const prisma = require('../../db');
const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY
);
const AVATAR_BUCKET = process.env.SUPABASE_BUCKET || 'Announcement_images';

const getMe = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const user = await prisma.user.findUnique({ where: { id: userId } });
        if (!user) return res.status(404).json({ message: 'User not found' });

        res.json({
            id: user.id,
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            nickname: user.nickname,
            gender: user.gender,
            country: user.country,
            address: user.address,
            phoneNumber: user.phoneNumber,
            avatarUrl: user.avatarUrl,
            role: user.role,
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateSettings = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const { name, lastName, email, phone, nickname, gender, country, address } = req.body;
        const data = {};
        if (name !== undefined) data.firstName = name;
        if (lastName !== undefined) data.lastName = lastName;
        if (email !== undefined) data.email = email;
        if (phone !== undefined) data.phoneNumber = phone;
        if (nickname !== undefined) data.nickname = nickname;
        if (gender !== undefined) data.gender = gender;
        if (country !== undefined) data.country = country;
        if (address !== undefined) data.address = address;

        const updated = await updateUserSettings(userId, data);
        res.json({
            success: true,
            user: {
                id: updated.id,
                username: updated.username,
                firstName: updated.firstName,
                lastName: updated.lastName,
                email: updated.email,
                nickname: updated.nickname,
                gender: updated.gender,
                country: updated.country,
                address: updated.address,
                phoneNumber: updated.phoneNumber,
                avatarUrl: updated.avatarUrl,
                role: updated.role,
            },
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

const uploadAvatar = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });
        if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

        const fileBuffer = fs.readFileSync(req.file.path);
        const ext = path.extname(req.file.originalname).toLowerCase() || '.jpg';
        const storagePath = `avatars/${userId}_${Date.now()}${ext}`;
        const extMimeMap = { '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.gif': 'image/gif', '.webp': 'image/webp' };
        const contentType = req.file.mimetype === 'application/octet-stream'
            ? (extMimeMap[ext] || 'image/jpeg')
            : req.file.mimetype;

        const { error: uploadErr } = await supabase.storage
            .from(AVATAR_BUCKET)
            .upload(storagePath, fileBuffer, {
                contentType,
                upsert: true,
            });

        // Clean up local temp file
        fs.unlinkSync(req.file.path);

        if (uploadErr) {
            console.error('Supabase avatar upload error:', uploadErr);
            return res.status(500).json({ success: false, message: uploadErr.message });
        }

        const { data: publicData } = supabase.storage
            .from(AVATAR_BUCKET)
            .getPublicUrl(storagePath);

        const avatarUrl = publicData.publicUrl;

        await prisma.user.update({
            where: { id: userId },
            data: { avatarUrl },
        });

        res.json({ success: true, avatarUrl });
    } catch (error) {
        console.error('uploadAvatar error:', error);
        res.status(500).json({ success: false, message: error.message });
    }
};

module.exports = { getMe, updateSettings, uploadAvatar };