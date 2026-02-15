const bcrypt = require('bcryptjs');
const prisma = require('../../db');

exports.juristicLogin = async (req, res) => {
    try {
        const { username, password } = req.body;

        // 1. ค้นหา User (จากรูป Username คือ 'admin_test')
        const user = await prisma.user.findUnique({
            where: { username: username } 
        });

        // 2. เช็คว่าเจอไหม และ Role ต้องเป็น 'admin' (ตามรูป db ของคุณ)
        // (ผมเผื่อคำว่า 'juristic' ไว้ให้ด้วย เผื่อในอนาคตมีเพิ่ม)
        if (!user || (user.role !== 'admin' && user.role !== 'juristic')) {
            return res.status(403).json({ error: 'Access Denied: ไม่ใช่เจ้าหน้าที่นิติ (Role หรือ User ผิด)' });
        }

        // 3. ตรวจสอบรหัสผ่าน
        // *** สำคัญ: คุณต้องรู้รหัสผ่านจริงๆ ของ admin_test นะครับ ***
        // (ลองเดาดูน่าจะเป็น: "123456", "password", หรือ "admin")
        const isMatch = await bcrypt.compare(password, user.passwordHash);
        
        if (!isMatch) {
            return res.status(400).json({ error: 'รหัสผ่านไม่ถูกต้อง' });
        }

        // 4. ผ่านทุกด่าน
        res.json({
            message: 'Login Successful',
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