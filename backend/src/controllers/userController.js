const prisma = require('../../db');

exports.getStats = async (req, res) => {
  try {
    // นับจำนวน user ที่มี role เป็น 'resident'
    const residentCount = await prisma.user.count({
      where: { role: 'resident' }
    });

    res.json({
      residentCount: residentCount
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch stats' });
  }
};