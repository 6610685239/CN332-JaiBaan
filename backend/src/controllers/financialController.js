const { validationResult } = require('express-validator')
const service = require('../services/financialService')
const { saveFile } = require('../services/financialFileService')

const handleValidation = (req, res) => {
  const errors = validationResult(req)
  if (!errors.isEmpty()) {
    res.status(400).json({ success: false, errors: errors.array() })
    return false
  }
  return true
}

const list = async (req, res) => {
  try {
    const { year, month, type, category, search, page, limit } = req.query
    const result = await service.getTransactions({ year, month, type, category, search, page, limit })
    res.json({ success: true, ...result })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const getById = async (req, res) => {
  try {
    const item = await service.getTransactionById(req.params.id)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบรายการ'} )
    res.json({ success: true, data: item })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const create = async (req, res) => {
  if (!handleValidation(req, res)) return
  try {
    const item = await service.createTransaction(req.body, req.user.id)
    res.status(201).json({ success: true, data: item })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const update = async (req, res) => {
  if (!handleValidation(req, res)) return
  try {
    const item = await service.updateTransaction(req.params.id, req.body)
    res.json({ success: true, data: item })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const remove = async (req, res) => {
  try {
    const item = await service.deleteTransaction(req.params.id)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบรายการ' })
    res.json({ success: true, message: 'ลบสำเร็จ' })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const dashboard = async (req, res) => {
  try {
    const { year } = req.query
    const data = await service.getDashboard(year)
    res.json({ success: true, data })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const getYears = async (req, res) => {
  try {
    const years = await service.getYears()
    res.json({ success: true, data: years })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const uploadFile = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'ไม่พบไฟล์' })
    const fileData = await saveFile(req.file)
    res.json({ success: true, data: fileData })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

const removeAttachment = async (req, res) => {
  try {
    const item = await service.deleteAttachment(req.params.attachmentId)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบไฟล์' })
    res.json({ success: true, message: 'ลบไฟล์สำเร็จ' })
  } catch (err) {
    console.error(err)
    res.status(500).json({ success: false, message: err.message })
  }
}

module.exports = {
  list,
  getById,
  create,
  update,
  remove,
  dashboard,
  getYears,
  uploadFile,
  removeAttachment,
}
