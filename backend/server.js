const express = require('express');
const path = require('path');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const cors = require('cors');

const app = express();

app.use(express.json());
app.use(cors());
app.use('/public', express.static(path.join(__dirname, 'public'))); // เปิดให้บริการไฟล์ Static เช่น รูปภาพ
// ตั้งค่า Adapter สำหรับ Prisma 7 (เหมือนใน seed.js)
const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

// API Login
app.post('/api/auth/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        // 1. ค้นหา User จาก username
        const user = await prisma.user.findUnique({
            where: { username: username }
        });

        if (!user) {
            return res.status(401).json({ message: "ไม่พบชื่อผู้ใช้งานนี้" });
        }

        // 2. ตรวจสอบรหัสผ่านที่ Hash ไว้
        const isMatch = await bcrypt.compare(password, user.passwordHash);
        if (!isMatch) {
            return res.status(401).json({ message: "รหัสผ่านไม่ถูกต้อง" });
        }

        // 3. สร้าง JWT Token เพื่อส่งกลับไปให้ Flutter
        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET || 'jaibaan_secret_key',
            { expiresIn: '7d' }
        );

        res.json({
            success: true,
            message: "Login Successful",
            token: token,
            user: { id: user.id, username: user.username, role: user.role }
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: "Internal Server Error" });
    }
});

app.post('/api/register', async (req, res) => {
    // 1. รับค่า (ดึง email ออกมาเพื่อใช้กับ RegistrationRequest เท่านั้น)
    const { username, password, firstName, lastName, phoneNumber, roomNumber, email } = req.body;

    try {
        // 2. ตรวจสอบ Username ใน User (ห้ามใส่ email ในนี้เพราะ Schema ไม่มี!)
        const existingUser = await prisma.user.findUnique({
            where: { username: username }
        });

        if (existingUser) {
            return res.status(400).json({ message: "Username นี้ถูกใช้งานแล้ว" });
        }

        // 3. ตรวจสอบ Email ซ้ำในคำขอเดิม (ถ้าต้องการ)
        const existingRequest = await prisma.registrationRequest.findFirst({
            where: { email: email, status: "pending" }
        });

        if (existingRequest) {
            return res.status(400).json({ message: "Email นี้ส่งคำขอไว้แล้ว" });
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!emailRegex.test(email)) {
            return res.status(400).json({ message: "รูปแบบ Email ไม่ถูกต้อง"});
        }

        // 4. เตรียมข้อมูลรหัสผ่าน
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // 5. บันทึกลง RegistrationRequest
        const newRequest = await prisma.registrationRequest.create({
            data: {
                email: email,
                roomNumber: roomNumber || "0",
                status: "pending",
                providerType: "Email"
            }
        });

        // 6. ส่งผลลัพธ์กลับ (ต้องอยู่ในบล็อก try)
        return res.status(201).json({
            success: true,
            message: "ส่งคำขอสำเร็จ",
            requestId: newRequest.id // ใช้ .id ตาม Schema ของคุณ
        });

    } catch (error) {
        console.error("Register Error:", error);
        return res.status(500).json({ message: "Internal Server Error" });
    }
});

// feature/facility

const facilityRoutes = require('./src/FacilityService/facility.routes');

app.use('/api/facilities', facilityRoutes);

app.listen(3000, () => console.log('🚀 JaiBaan API running on port 3000'));