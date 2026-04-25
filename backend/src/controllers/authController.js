const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const prisma = require('../../db');
const jwt = require('jsonwebtoken');

// Register new resident user
exports.register = async (req, res) => {
    try {
        const { username, password, firstName, lastName, phoneNumber, roomNumber } = req.body;

        // Validate required fields
        if (!username || !password || !firstName || !lastName || !phoneNumber || !roomNumber) {
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
                firstName,
                lastName,
                phoneNumber,
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
            process.env.JWT_SECRET || 'your_secret_key',
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
                phoneNumber: user.phoneNumber
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
