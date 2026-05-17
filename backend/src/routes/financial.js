const express = require('express')
const { body } = require('express-validator')
const router = express.Router()

const controller = require('../controllers/financialController')
const { auth } = require('../middleware/auth')
const upload = require('../middleware/upload')

const financialValidation = [
  body('type').isIn(['INCOME', 'EXPENSE']).withMessage('ประเภทธุรกรรมไม่ถูกต้อง'),
  body('category')
    .isIn([
      'COMMON_FEE', 'RENTAL', 'OTHER_INCOME',
      'ELECTRICITY', 'WATER', 'MAINTENANCE', 'OTHER_EXPENSE',
    ])
    .withMessage('หมวดหมู่ไม่ถูกต้อง'),
  body('description').notEmpty().withMessage('รายละเอียดห้ามว่าง'),
  body('transactionDate').isISO8601().withMessage('วันที่ทำรายการไม่ถูกต้อง'),
  body('amount').isFloat({ gt: 0 }).withMessage('จำนวนเงินต้องมากกว่า 0'),
]

router.use(auth)

router.get('/dashboard', controller.dashboard)
router.get('/years', controller.getYears)
router.get('/transactions', controller.list)
router.get('/transactions/:id', controller.getById)
router.post('/transactions', financialValidation, controller.create)
router.put('/transactions/:id', financialValidation, controller.update)
router.delete('/transactions/:id', controller.remove)
router.post('/upload', upload.single('file'), controller.uploadFile)
router.delete('/attachments/:attachmentId', controller.removeAttachment)

module.exports = router
