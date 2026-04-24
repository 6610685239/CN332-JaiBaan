const express = require('express')
const { body } = require('express-validator')
const router = express.Router()

const controller = require('../controllers/announcementController')
const { auth } = require('../middleware/auth')
const upload = require('../middleware/upload')

// Validation rules
const announcementValidation = [
  body('title').notEmpty().withMessage('หัวข้อประกาศห้ามว่าง').trim(),
  body('category')
    .isIn(['GENERAL', 'MAINTENANCE', 'EVENT', 'FINANCE', 'URGENT'])
    .withMessage('ประเภทประกาศไม่ถูกต้อง'),
  body('content').notEmpty().withMessage('เนื้อหาห้ามว่าง'),
  body('effectiveDate').isISO8601().withMessage('วันที่มีผลไม่ถูกต้อง'),
  body('targetType')
    .isIn(['ALL', 'ZONE', 'UNIT'])
    .withMessage('กลุ่มเป้าหมายไม่ถูกต้อง'),
]

// All routes require auth
// router.use(auth)

// File upload
router.post('/upload', upload.single('file'), controller.uploadFile)

// Attachment delete
router.delete('/attachments/:attachmentId', controller.removeAttachment)

// CRUD
router.get('/', controller.list)
router.get('/:id', controller.getById)
router.post('/', announcementValidation, controller.create)
router.put('/:id', announcementValidation, controller.update)

// Status management
router.patch('/:id/status', controller.changeStatus)
router.post('/:id/publish', controller.publish)

// Delete
router.delete('/:id', controller.remove)

module.exports = router
