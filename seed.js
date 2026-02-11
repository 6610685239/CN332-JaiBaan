const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function main() {
    const hash = await bcrypt.hash('123456', 10);

    // สร้าง User ที่เป็น Admin หรือเจ้าบ้านคนแรก
    const admin = await prisma.user.upsert({
        where: { username: 'admin_test' },
        update: {},
        create: {
            username: 'admin_test',
            passwordHash: hash,
            firstName: 'Parunchai', // ข้อมูลจากโปรไฟล์ของคุณ
            lastName: 'Timklip',
            role: 'admin',
            phoneNumber: '0812345678'
        },
    });

    console.log('✅ สร้างข้อมูลทดสอบสำเร็จ: ', admin.username);
}

main()
    .catch((e) => console.error(e))
    .finally(async () => {
        await prisma.$disconnect();
        await pool.end();
    });