const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const prisma = require('../../db');
const jwt = require('jsonwebtoken');
const admin = require('firebase-admin');
const axios = require('axios');
require('../services/notificationService');

// Register new resident user
exports.register = async (req, res) => {
    try {
        const { username, password, firstName, lastName, phoneNumber, roomNumber } = req.body;

        // Validate required fields
        if (!username || !password || !roomNumber) {
            return res.status(400).json({ message: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
        }

        // Check if username already exists
        const existingUser = await prisma.user.findUnique({
            where: { username }
        });

        if (existingUser) {
            return res.status(400).json({ message: 'Username นี้ถูกใช้ไปแล้ว' });
        }

        // Hash password
        const passwordHash = await bcrypt.hash(password, 10);

        // Create new user with resident profile
        const newUser = await prisma.user.create({
            data: {
                username,
                passwordHash,
                firstName: firstName || '',
                lastName: lastName || '',
                phoneNumber: phoneNumber || '',
                role: 'resident',
                resident: {
                    create: {
                        unitNumber: roomNumber
                    }
                }
            },
            include: {
                resident: true
            }
        });

        res.status(201).json({ 
            message: 'ลงทะเบียนสำเร็จ',
            user: {
                id: newUser.id,
                username: newUser.username,
                firstName: newUser.firstName,
                lastName: newUser.lastName
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server Error', error: error.message });
    }
};

// Resident login
exports.residentLogin = async (req, res) => {
    try {
        const { username, password } = req.body;

        if (!username || !password) {
            return res.status(400).json({ error: 'กรุณากรอก username และ password' });
        }

        const user = await prisma.user.findUnique({
            where: { username }
        });

        if (!user) {
            return res.status(401).json({ error: 'Username หรือ password ไม่ถูกต้อง' });
        }

        // Only allow resident role to login via this endpoint
        if (user.role !== 'resident') {
            return res.status(403).json({ error: 'Access Denied' });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(401).json({ error: 'Username หรือ password ไม่ถูกต้อง' });
        }

        const token = jwt.sign(
            {
                id: user.id,
                role: user.role,
                username: user.username
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.json({
            message: 'Login Successful',
            token,
            user: {
                id: user.id,
                username: user.username,
                role: user.role,
                firstName: user.firstName,
                lastName: user.lastName,
                phoneNumber: user.phoneNumber,
                email: user.email,
                avatarUrl: user.avatarUrl
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server Error' });
    }
};

exports.juristicLogin = async (req, res) => {
    try {
        const { username, password } = req.body;

        const user = await prisma.user.findUnique({
            where: { username }
        });
        
        const token = jwt.sign(
            {
                id: user.id,
                role: user.role,
                name: user.username
            },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        if (!user || (user.role !== 'admin' && user.role !== 'juristic')) {
            return res.status(403).json({ error: 'Access Denied: ไม่ใช่เจ้าหน้าที่นิติ' });
        }

        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(400).json({ error: 'รหัสผ่านไม่ถูกต้อง' });
        }

        res.json({
            message: 'Login Successful',
            token,
            user: {
                id: user.id,
                username: user.username,
                role: user.role,
                firstName: user.firstName,
                lastName: user.lastName
            }
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server Error' });
    }
};

// Google Sign-In — verify token, check if user exists
exports.googleLogin = async (req, res) => {
    try {
        const { idToken, accessToken } = req.body;
        if (!idToken && !accessToken) {
            return res.status(400).json({ message: 'idToken or accessToken is required' });
        }

        let decoded;
        if (idToken) {
            // Verify Google OAuth token via Google's tokeninfo endpoint
            const googleRes = await axios.get(`https://oauth2.googleapis.com/tokeninfo?id_token=${idToken}`);
            decoded = googleRes.data;
        } else {
            // Verify via Access Token
            const googleRes = await axios.get('https://www.googleapis.com/oauth2/v3/userinfo', {
                headers: { Authorization: `Bearer ${accessToken}` }
            });
            decoded = googleRes.data;
        }

        if (decoded.error || (!decoded.sub && !decoded.id)) {
            return res.status(401).json({ message: 'Invalid Google token' });
        }

        const uid = decoded.sub || decoded.id;
        const email = decoded.email;
        const name = decoded.name;
        const picture = decoded.picture;

        // 1. Check if user already linked social account
        let existingUser = await prisma.user.findFirst({ where: { socialId: uid } });

        // 2. If not, check if user exists with the same email (and link them)
        if (!existingUser && email) {
            existingUser = await prisma.user.findFirst({ where: { email: email } });
            if (existingUser) {
                // Link the account
                await prisma.user.update({
                    where: { id: existingUser.id },
                    data: { socialId: uid, avatarUrl: existingUser.avatarUrl || picture }
                });
            }
        }

        if (existingUser) {
            const token = jwt.sign(
                { id: existingUser.id, role: existingUser.role, username: existingUser.username },
                process.env.JWT_SECRET,
                { expiresIn: '7d' }
            );
            return res.json({
                needsSetup: false,
                token,
                user: {
                    id: existingUser.id,
                    username: existingUser.username,
                    role: existingUser.role,
                    firstName: existingUser.firstName,
                    lastName: existingUser.lastName,
                },
            });
        }

        // New user — needs room setup
        return res.json({
            needsSetup: true,
            googleId: uid,
            email: email || '',
            name: name || '',
            picture: picture || '',
        });
    } catch (error) {
        console.error('Google Login Error:', error.response?.data || error.message);
        res.status(500).json({ message: 'Google login failed', error: error.message });
    }
};

// Google Sign-In — complete setup with room number
exports.googleComplete = async (req, res) => {
    try {
        const { googleId, email, name, picture, roomNumber } = req.body;
        if (!googleId || !roomNumber) {
            return res.status(400).json({ message: 'googleId and roomNumber are required' });
        }

        const existingUser = await prisma.user.findFirst({ where: { socialId: googleId } });
        if (existingUser) {
            return res.status(400).json({ message: 'User already registered' });
        }

        const nameParts = (name || '').split(' ');
        const firstName = nameParts[0] || 'Google';
        const lastName = nameParts.slice(1).join(' ') || 'User';
        
        // Handle username conflict
        let username = email ? email.split('@')[0] : googleId.substring(0, 10);
        const userExists = await prisma.user.findUnique({ where: { username } });
        if (userExists) {
            username = `${username}_${crypto.randomBytes(3).toString('hex')}`;
        }

        const newUser = await prisma.user.create({
            data: {
                username,
                passwordHash: '',
                firstName,
                lastName,
                phoneNumber: '',
                email: email || null,
                role: 'resident',
                socialId: googleId,
                avatarUrl: picture || null,
                resident: { create: { unitNumber: roomNumber } },
            },
            include: { resident: true },
        });

        const token = jwt.sign(
            { id: newUser.id, role: newUser.role, username: newUser.username },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );

        res.status(201).json({
            message: 'Registration successful',
            token,
            user: {
                id: newUser.id,
                username: newUser.username,
                role: newUser.role,
                firstName: newUser.firstName,
                lastName: newUser.lastName,
            },
        });
    } catch (error) {
        console.error('Google Complete Error:', error);
        res.status(500).json({ message: 'Setup failed', error: error.message });
    }
};

exports.forgotPassword = async (req, res) => {
    try {
        const { username } = req.body;

        const user = await prisma.user.findUnique({ where: { username } });

        // ไม่เปิดเผยว่า user มีอยู่จริงหรือไม่ถ้าไม่ใช่ admin/juristic
        if (!user || (user.role !== 'admin' && user.role !== 'juristic')) {
            return res.status(404).json({ error: 'ไม่พบบัญชีผู้ใช้ในระบบ' });
        }

        const resetToken = crypto.randomBytes(32).toString('hex');
        const resetTokenExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 นาที

        await prisma.user.update({
            where: { username },
            data: { resetToken, resetTokenExpiry }
        });

        // NOTE: ในระบบจริงให้ส่ง token ทาง email ไม่ใช่ return กลับมา
        res.json({
            message: 'สร้าง reset token สำเร็จ',
            resetToken,
            note: 'Token นี้จะหมดอายุใน 15 นาที — โปรดนำไปใช้รีเซ็ตรหัสผ่านทันที'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server Error' });
    }
};

exports.resetPassword = async (req, res) => {
    try {
        const { resetToken, newPassword } = req.body;

        if (!resetToken || !newPassword) {
            return res.status(400).json({ error: 'กรุณาระบุ token และรหัสผ่านใหม่' });
        }

        if (newPassword.length < 6) {
            return res.status(400).json({ error: 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร' });
        }

        const user = await prisma.user.findFirst({
            where: {
                resetToken,
                resetTokenExpiry: { gt: new Date() }
            }
        });

        if (!user) {
            return res.status(400).json({ error: 'Token ไม่ถูกต้องหรือหมดอายุแล้ว' });
        }

        const passwordHash = await bcrypt.hash(newPassword, 10);

        await prisma.user.update({
            where: { id: user.id },
            data: {
                passwordHash,
                resetToken: null,
                resetTokenExpiry: null
            }
        });

        res.json({ message: 'รีเซ็ตรหัสผ่านสำเร็จ กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server Error' });
    }
};
