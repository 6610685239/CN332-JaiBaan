const jwt = require('jsonwebtoken')
const prisma = require('../../db');
/**
 * Auth middleware — ต่อกับระบบ JWT เดิม
 * คาดว่า token จะอยู่ใน Authorization: Bearer <token>
 * และ payload มี { id, role, name }
 */
const auth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Unauthorized' })
    }

    const token = authHeader.split(' ')[1]
    const decoded = jwt.verify(token, process.env.JWT_SECRET)

    req.user = decoded // { id, role, name, ... }
    next()
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' })
  }
}

/**
 * Role guard — ใช้ต่อจาก auth middleware
 * ตัวอย่าง: requireRole('admin', 'staff')
 */
const requireRole = (...roles) => (req, res, next) => {
  if (!req.user || !roles.includes(req.user.role)) {
    return res.status(403).json({ success: false, message: 'Forbidden' })
  }
  next()
}

module.exports = { auth, requireRole }
