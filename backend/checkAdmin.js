// backend/checkAdmin.js
const prisma = require('./db'); // เรียกตัวเชื่อมที่เราเพิ่งแก้จนผ่าน

async function check() {
    try {
        console.log("กำลังค้นหา user: admin ...");
        const user = await prisma.user.findFirst({
            where: { username: 'admin' } // หรือเปลี่ยนเป็น username ที่คุณมั่นใจว่ามี
        });

        if (!user) {
            console.log("❌ ไม่เจอ User นี้ในระบบ!");
        } else {
            console.log("✅ เจอ User แล้ว:");
            console.log("   ID:", user.id);
            console.log("   Role:", user.role); // <--- ดูตรงนี้ว่าเขียนว่าอะไร
            console.log("   Password Hash:", user.passwordHash); // <--- ดูว่าเป็นรหัสยาวๆ หรือสั้นๆ
        }
    } catch (e) {
        console.error(e);
    }
}

check();