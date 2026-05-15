const express = require('express')
const router = express.Router()
const controller = require('../controllers/parcelController')
const { auth } = require('../middleware/auth')
const upload = require('../middleware/upload')

router.use(auth)

// Photo upload (juristic only in practice, but auth is enough here)
router.post('/upload-photo', upload.single('file'), controller.uploadPhoto)

// Resident: view own parcels (unit from JWT → Resident record)
router.get('/my', controller.listMine)

// Resident mobile: view by unitNumber directly
router.get('/unit/:unitNumber', controller.listByUnit)

// Admin/Juristic: full list with filters
router.get('/', controller.list)
router.get('/:id', controller.getById)

// Juristic: register inbound parcel
router.post('/', controller.create)

// Juristic: delete orphaned photo from storage
router.delete('/photo', controller.removePhoto)

// Resident: confirm pickup
router.patch('/:id/pickup', controller.pickup)

// Juristic: mark returned
router.patch('/:id/return', controller.returned)

// Admin: update any status
router.patch('/:id/status', controller.updateStatus)

// Admin: delete record
router.delete('/:id', controller.remove)

module.exports = router
