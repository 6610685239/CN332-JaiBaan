const multer = require('multer')
const path = require('path')
const { v4: uuidv4 } = require('uuid')
const { UPLOAD_DIR } = require('../services/announcementFileService')

const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'application/pdf',
]

const ALLOWED_IMAGE_EXTS = ['.jpg', '.jpeg', '.png', '.gif', '.webp']

const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR)
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg'
    cb(null, `${uuidv4()}${ext}`)
  },
})

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase()
  const isAllowedMime = ALLOWED_MIME_TYPES.includes(file.mimetype)
  const isOctetStreamImage = file.mimetype === 'application/octet-stream' && ALLOWED_IMAGE_EXTS.includes(ext)
  if (isAllowedMime || isOctetStreamImage) {
    cb(null, true)
  } else {
    cb(new Error(`ไม่รองรับไฟล์ประเภท ${file.mimetype}`), false)
  }
}

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: MAX_FILE_SIZE },
})

module.exports = upload
