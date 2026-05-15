const { validationResult } = require('express-validator')
const service = require('../services/announcementService')
const { saveFile } = require('../services/fileService')

const handleValidation = (req, res) => {
  const errors = validationResult(req)
  if (!errors.isEmpty()) {
    res.status(400).json({ success: false, errors: errors.array() })
    return false
  }
  return true
}

// GET /api/announcements
const list = async (req, res) => {
  try {
    const { status, category, search, page, limit } = req.query
    // Use resident filtering for resident role users
    const filterByResident = req.user.role === 'resident'
    const result = await service.getAnnouncements({ 
      status, 
      category, 
      search, 
      page, 
      limit,
      userId: req.user.id,
      filterByResident 
    })
    res.json({ success: true, ...result })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/announcements/:id
const getById = async (req, res) => {
  try {
    const item = await service.getAnnouncementById(req.params.id)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบประกาศ' })
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/announcements
const create = async (req, res) => {
  if (!handleValidation(req, res)) return
  try {
    const data = req.body
    const item = await service.createAnnouncement(data, req.user.id)
    res.status(201).json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// PUT /api/announcements/:id
const update = async (req, res) => {
  if (!handleValidation(req, res)) return
  try {
    const item = await service.updateAnnouncement(req.params.id, req.body)
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// PATCH /api/announcements/:id/status
const changeStatus = async (req, res) => {
  try {
    const { status } = req.body
    const validStatuses = ['DRAFT', 'SCHEDULED', 'PUBLISHED', 'ARCHIVED']
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' })
    }
    const item = await service.updateStatus(req.params.id, status)
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/announcements/:id/publish
const publish = async (req, res) => {
  try {
    // tokens: FCM tokens ของลูกบ้านเป้าหมาย
    // ในระบบจริงควรดึงจาก user/resident service ตาม targetType
    const { tokens = [] } = req.body
    const { announcement, notifResult } = await service.publishAnnouncement(req.params.id, tokens)
    res.json({ success: true, data: announcement, notifResult })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// DELETE /api/announcements/:id
const remove = async (req, res) => {
  try {
    const item = await service.deleteAnnouncement(req.params.id)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบประกาศ' })
    res.json({ success: true, message: 'ลบสำเร็จ' })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/announcements/upload
const uploadFile = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'ไม่พบไฟล์' })
    }
    const fileData = await saveFile(req.file)
    res.json({ success: true, data: fileData })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// DELETE /api/announcements/attachments/:attachmentId
const removeAttachment = async (req, res) => {
  try {
    const item = await service.deleteAttachment(req.params.attachmentId)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบไฟล์' })
    res.json({ success: true, message: 'ลบไฟล์สำเร็จ' })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

module.exports = { list, getById, create, update, changeStatus, publish, remove, uploadFile, removeAttachment }
