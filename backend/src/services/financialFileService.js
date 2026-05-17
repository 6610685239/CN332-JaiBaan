const path = require('path')
const fs = require('fs')
const { createClient } = require('@supabase/supabase-js')

const UPLOAD_DIR = path.join(__dirname, '..', '..', process.env.UPLOAD_DIR || 'uploads')

// Ensure local upload dir exists (used as temporary storage by multer)
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true })
}

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY
const SUPABASE_BUCKET = process.env.SUPABASE_BUCKET || 'Financial_files'

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in environment')
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

const saveFile = async (file) => {
  const localPath = path.join(UPLOAD_DIR, file.filename)

  let fileBuffer
  try {
    fileBuffer = fs.readFileSync(localPath)
  } catch (err) {
    throw new Error(`Failed to read uploaded file: ${err.message}`)
  }

  const destPath = file.filename

  const { error: uploadErr } = await supabase.storage
    .from(SUPABASE_BUCKET)
    .upload(destPath, fileBuffer, { contentType: file.mimetype, upsert: false })

  if (uploadErr) {
    throw new Error(`Supabase upload error: ${uploadErr.message}`)
  }

  const { data: publicData, error: urlErr } = supabase.storage
    .from(SUPABASE_BUCKET)
    .getPublicUrl(destPath)

  if (urlErr) {
    throw new Error(`Supabase getPublicUrl error: ${urlErr.message}`)
  }

  try {
    if (fs.existsSync(localPath)) fs.unlinkSync(localPath)
  } catch (err) {
    console.error('Failed to remove local upload file:', err)
  }

  return {
    filename: file.filename,
    originalName: file.originalname,
    url: publicData.publicUrl,
    mimeType: file.mimetype,
    size: file.size,
  }
}

const deleteFile = async (filename) => {
  try {
    const { error } = await supabase.storage.from(SUPABASE_BUCKET).remove([filename])
    if (error) {
      console.error('Supabase delete error:', error)
      return false
    }
    return true
  } catch (err) {
    console.error('Failed to delete file from Supabase:', err)
    return false
  }
}

module.exports = { saveFile, deleteFile, UPLOAD_DIR }
