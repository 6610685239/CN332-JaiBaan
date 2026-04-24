// backend/createUser.js
// วิธีใช้: node backend/createUser.js <username> <password> <firstName> <lastName> [role]
// ตัวอย่าง:
//   node backend/createUser.js admin admin1234 Admin Test admin
//   node backend/createUser.js pun 1234 Pun Jitrawang resident

const prisma = require('./db');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

async function createUser() {
    const username = process.argv[2];
    const password = process.argv[3];
    const firstName = process.argv[4];
    const lastName = process.argv[5];
    const role = process.argv[6] || 'resident';

    if (!username || !password || !firstName || !lastName) {
        console.error('❌ ใช้งาน: node backend/createUser.js <username> <password> <firstName> <lastName> [role]');
        console.error('   role ที่ใช้ได้: admin, juristic, resident, technician, guard');
        console.error('   ตัวอย่าง: node backend/createUser.js admin admin1234 Admin Test admin');
        process.exit(1);
    }

    try {
        const passwordHash = await bcrypt.hash(password, 10);

        const user = await prisma.user.upsert({
            where: { username },
            update: {
                passwordHash,
                role,
                firstName,
                lastName,
            },
            create: {
                username,
                passwordHash,
                role,
                firstName,
                lastName,
            },
        });

        console.log('✅ สร้าง/อัปเดต user สำเร็จ!');
        console.log('   ID        :', user.id);
        console.log('   Username  :', user.username);
        console.log('   Role      :', user.role);
        console.log('   Name      :', `${user.firstName} ${user.lastName}`);
        console.log('   Password  :', password, '(จำให้ดีครับ)');
    } catch (e) {
        console.error('❌ Error:', e.message);
    } finally {
        await prisma.$disconnect();
    }
}

createUser();