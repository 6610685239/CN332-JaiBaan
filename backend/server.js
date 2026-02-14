const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const cors = require('cors');

require('dotenv').config();

const app = express();
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

// ตั้งค่า Adapter
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

// API Login
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        // ค้นหา User
        const user = await prisma.user.findUnique({
            where: { username: username }
        });

        if (!user) {
            return res.status(401).json({ message: "ไม่พบชื่อผู้ใช้งานนี้" });
        }

        // ตรวจสอบรหัสผ่านที่ Hash ไว้
        const isMatch = await bcrypt.compare(password, user.passwordHash);
        console.log("Is password match?:", isMatch);

        if (!isMatch) {
            return res.status(401).json({ message: "รหัสผ่านไม่ถูกต้อง" });
        }

        // สร้าง JWT Token เพื่อส่งกลับไปให้ Flutter
        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET || 'jaibaan_secret_key',
            { expiresIn: '7d' }
        );

        return res.json({
            success: true,
            message: "Login Successful",
            token: token,
            user: { id: user.id, username: user.username, role: user.role }
        });

    } catch (error) {
        console.error(error);
        if (!res.headersSent) {
            return res.status(500).json({ message: "Internal Server Error" });
        }
    }
});

app.listen(3000, () => console.log('🚀 JaiBaan API running on port 3000'));