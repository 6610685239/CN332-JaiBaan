const service = require('../services/parcelService')
const { saveParcelPhoto, deleteParcelPhoto } = require('../services/parcelFileService')

// POST /api/parcels/upload-photo
const uploadPhoto = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'ไม่พบไฟล์' })
    const url = await saveParcelPhoto(req.file)
    res.json({ success: true, url })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/parcels  (admin)
const list = async (req, res) => {
  try {
    const { status, unitNumber, carrier, search, sortOrder, dateFrom, dateTo, overdue, page, limit } = req.query
    const result = await service.getParcels({ status, unitNumber, carrier, search, sortOrder, dateFrom, dateTo, overdue, page, limit })
    res.json({ success: true, ...result })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/parcels/my  (resident — unit from JWT)
const listMine = async (req, res) => {
  try {
    const resident = await require('../../db').resident.findUnique({
      where: { userId: req.user.id },
    })
    if (!resident) return res.status(404).json({ success: false, message: 'ไม่พบข้อมูลผู้พักอาศัย' })
    const data = await service.getResidentParcels(resident.unitNumber)
    res.json({ success: true, data })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/parcels/unit/:unitNumber  (resident — mobile, unit in URL)
const listByUnit = async (req, res) => {
  try {
    const data = await service.getResidentParcels(req.params.unitNumber)
    res.json({ success: true, data })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/parcels/:id
const getById = async (req, res) => {
  try {
    const item = await service.getParcelById(req.params.id)
    if (!item) return res.status(404).json({ success: false, message: 'ไม่พบพัสดุ' })
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/parcels  (juristic registers inbound parcel)
const create = async (req, res) => {
  try {
    const { trackingNumber, carrier, unitNumber, storageLocation, photoUrl, notes } = req.body
    if (!trackingNumber || !carrier || !unitNumber) {
      return res.status(400).json({ success: false, message: 'trackingNumber, carrier, unitNumber ห้ามว่าง' })
    }
    const item = await service.createParcel({ trackingNumber, carrier, unitNumber, storageLocation, photoUrl, notes })
    res.status(201).json({ success: true, data: item })
  } catch (err) {
    if (err.code === 'P2002') {
      return res.status(409).json({ success: false, message: 'Tracking number นี้มีอยู่ในระบบแล้ว' })
    }
    res.status(500).json({ success: false, message: err.message })
  }
}

// PATCH /api/parcels/:id/pickup  (resident confirms pickup)
const pickup = async (req, res) => {
  try {
    const item = await service.markPickedUp(req.params.id)
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// PATCH /api/parcels/:id/return  (juristic marks as returned)
const returned = async (req, res) => {
  try {
    const item = await service.markReturned(req.params.id)
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// DELETE /api/parcels/:id  (admin)
const remove = async (req, res) => {
  try {
    await service.deleteParcel(req.params.id)
    res.json({ success: true, message: 'ลบพัสดุสำเร็จ' })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// PATCH /api/parcels/:id/status  (admin — any status)
const updateStatus = async (req, res) => {
  try {
    const { status } = req.body
    const allowed = ['ARRIVED', 'PICKED_UP', 'RETURNED']
    if (!allowed.includes(status)) {
      return res.status(400).json({ success: false, message: 'สถานะไม่ถูกต้อง' })
    }
    const item = await service.updateStatus(req.params.id, status)
    res.json({ success: true, data: item })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/parcels/bulk-delete  (admin)
const bulkDelete = async (req, res) => {
  try {
    const { ids } = req.body
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ success: false, message: 'ids required' })
    }
    const result = await service.bulkDelete(ids)
    res.json({ success: true, count: result.count })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// POST /api/parcels/bulk-return  (admin)
const bulkReturn = async (req, res) => {
  try {
    const { ids } = req.body
    if (!Array.isArray(ids) || ids.length === 0) {
      return res.status(400).json({ success: false, message: 'ids required' })
    }
    const result = await service.bulkReturn(ids)
    res.json({ success: true, count: result.count })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// GET /api/parcels/stats  (admin dashboard)
const stats = async (req, res) => {
  try {
    const data = await service.getStats()
    res.json({ success: true, data })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

// DELETE /api/parcels/photo  (juristic — remove orphaned upload)
const removePhoto = async (req, res) => {
  try {
    const { url } = req.body
    if (!url) return res.status(400).json({ success: false, message: 'url required' })
    // Extract filename from Supabase public URL
    const filename = url.split('/').pop()
    await deleteParcelPhoto(filename)
    res.json({ success: true })
  } catch (err) {
    res.status(500).json({ success: false, message: err.message })
  }
}

module.exports = { uploadPhoto, list, listMine, listByUnit, getById, create, pickup, returned, updateStatus, removePhoto, remove, stats, bulkDelete, bulkReturn }
