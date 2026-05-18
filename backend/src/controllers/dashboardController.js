const prisma = require('../../db');

exports.getDashboardStats = async (req, res) => {
  try {
    // 1. ดึงข้อมูลจำนวนลูกบ้านจริงจาก Database
    // นับจำนวนแถวทั้งหมดในตาราง Resident
    const totalResidents = await prisma.resident.count();

    // 2. ข้อมูล Mock สำหรับส่วนที่ยังไม่มี Table (พัสดุ, แจ้งซ่อม)
    const uncollectedParcels = 0; // ยังไม่มีตาราง Parcel
    const pendingRepairs = 0;     // ยังไม่มีตาราง Repair

    // 3. ส่งข้อมูลกลับไปให้ Frontend
    res.status(200).json({
      residentCount: totalResidents,
      parcelCount: uncollectedParcels,
      repairCount: pendingRepairs
    });

  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
};