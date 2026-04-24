const path = require('path')
const fs = require('fs')
const { v4: uuidv4 } = require('uuid')

const STORAGE_MODE = process.env.STORAGE_MODE || 'local'
const UPLOAD_DIR = path.join(__dirname, '..', '..', process.env.UPLOAD_DIR || 'uploads')

// Ensure local upload dir exists
if (STORAGE_MODE === 'local' && !fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true })
}

/**
 * บันทึกไฟล์ที่ upload ขึ้นมา
 * Dev: ไฟล์อยู่ที่ /uploads/<filename> แล้ว (Multer จัดการ)
 * Prod: ต้อง upload ขึ้น GCS แล้วคืน public URL
 */
const saveFile = async (file) => {
  if (STORAGE_MODE === 'gcs') {
    return saveToGCS(file)
  }
  return saveToLocal(file)
}

const saveToLocal = async (file) => {
  const url = `/uploads/${file.filename}`
  return {
    filename: file.filename,
    originalName: file.originalname,
    url,
    mimeType: file.mimetype,
    size: file.size,
  }
}

const saveToGCS = async (file) => {
  // TODO: implement when switching to production
  // const { Storage } = require('@google-cloud/storage')
  // const storage = new Storage({ keyFilename: process.env.GCS_KEY_FILE })
  // const bucket = storage.bucket(process.env.GCS_BUCKET_NAME)
  // ...
  throw new Error('GCS storage not yet implemented — set STORAGE_MODE=local for development')
}

/**
 * ลบไฟล์
 */
const deleteFile = async (filename) => {
  if (STORAGE_MODE === 'local') {
    const filePath = path.join(UPLOAD_DIR, filename)
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath)
    }
    return true
  }
  // TODO: GCS delete
  return true
}

module.exports = { saveFile, deleteFile, UPLOAD_DIR }
