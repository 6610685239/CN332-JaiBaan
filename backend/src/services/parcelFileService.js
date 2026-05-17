const path = require('path')
const fs = require('fs')
const { createClient } = require('@supabase/supabase-js')

const UPLOAD_DIR = path.join(__dirname, '..', '..', process.env.UPLOAD_DIR || 'uploads')

if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true })
}

const SUPABASE_URL = process.env.SUPABASE_URL
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY
const SUPABASE_BUCKET = process.env.SUPABASE_PARCEL_BUCKET || 'parcel_photos'

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  throw new Error('SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set in environment')
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

const saveParcelPhoto = async (file) => {
  const localPath = path.join(UPLOAD_DIR, file.filename)

  let fileBuffer
  try {
    fileBuffer = fs.readFileSync(localPath)
  } catch (err) {
    throw new Error(`Failed to read uploaded file: ${err.message}`)
  }

  const { error: uploadErr } = await supabase.storage
    .from(SUPABASE_BUCKET)
    .upload(file.filename, fileBuffer, { contentType: file.mimetype, upsert: false })

  if (uploadErr) throw new Error(`Supabase upload error: ${uploadErr.message}`)

  const { data: publicData } = supabase.storage
    .from(SUPABASE_BUCKET)
    .getPublicUrl(file.filename)

  try {
    if (fs.existsSync(localPath)) fs.unlinkSync(localPath)
  } catch (err) {
    console.error('Failed to remove local upload file:', err)
  }

  return publicData.publicUrl
}

const deleteParcelPhoto = async (filename) => {
  try {
    const { error } = await supabase.storage.from(SUPABASE_BUCKET).remove([filename])
    if (error) console.error('Supabase delete error:', error)
  } catch (err) {
    console.error('Failed to delete parcel photo from Supabase:', err)
  }
}

module.exports = { saveParcelPhoto, deleteParcelPhoto, UPLOAD_DIR }
