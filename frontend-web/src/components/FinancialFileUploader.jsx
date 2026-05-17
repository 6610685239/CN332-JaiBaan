import { useRef, useState } from 'react'
import { FaCloudUploadAlt, FaTimes, FaFilePdf, FaImage } from 'react-icons/fa'
import { financialApi } from '../api/financial'
import './FileUploader.css'

const formatBytes = (bytes) => {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1048576) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1048576).toFixed(1)} MB`
}

const FileIcon = ({ mimeType }) =>
  mimeType === 'application/pdf'
    ? <FaFilePdf className="file-icon file-icon--pdf" />
    : <FaImage className="file-icon file-icon--img" />

export default function FinancialFileUploader({ attachments = [], onAttachmentsChange }) {
  const inputRef = useRef()
  const [uploading, setUploading] = useState(false)
  const [dragging, setDragging] = useState(false)
  const [toast, setToast] = useState(null)

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type })
    setTimeout(() => setToast(null), 3000)
  }

  const handleFiles = async (files) => {
    const arr = Array.from(files)
    if (arr.length === 0) return
    setUploading(true)

    const results = await Promise.allSettled(
      arr.map((file) => financialApi.uploadFile(file))
    )

    const uploaded = results
      .filter((result) => result.status === 'fulfilled')
      .map((result) => result.value)
    const failedCount = results.filter((result) => result.status === 'rejected').length

    if (failedCount > 0) showToast(`อัพโหลดไม่สำเร็จ ${failedCount} ไฟล์`, 'error')
    if (uploaded.length > 0) {
      onAttachmentsChange([...attachments, ...uploaded])
      showToast(`อัพโหลดสำเร็จ ${uploaded.length} ไฟล์`, 'success')
    }

    setUploading(false)
  }

  const handleRemove = async (attachment, index) => {
    if (attachment.id) {
      await financialApi.deleteAttachment(attachment.id).catch(() => {})
    }
    onAttachmentsChange(attachments.filter((_, i) => i !== index))
  }

  return (
    <div className="uploader">
      {toast && (
        <div className={`uploader-toast uploader-toast--${toast.type}`}>{toast.msg}</div>
      )}

      <div
        className={`uploader-zone${dragging ? ' uploader-zone--drag' : ''}`}
        onClick={() => inputRef.current?.click()}
        onDragOver={(e) => { e.preventDefault(); setDragging(true) }}
        onDragLeave={() => setDragging(false)}
        onDrop={(e) => { e.preventDefault(); setDragging(false); handleFiles(e.dataTransfer.files) }}
      >
        <input
          ref={inputRef}
          type="file"
          multiple
          accept=".pdf,image/*"
          className="uploader-input"
          onChange={(e) => handleFiles(e.target.files)}
        />

        {uploading ? (
          <div className="uploader-loading">
            <div className="uploader-spinner" />
            <p>กำลังอัพโหลด...</p>
          </div>
        ) : (
          <>
            <FaCloudUploadAlt className="uploader-icon" />
            <p className="uploader-hint-main">คลิกเพื่ออัพโหลด หรือลากไฟล์มาวางที่นี่</p>
            <p className="uploader-hint-sub">PDF, JPG, PNG, WEBP (สูงสุด 10MB ต่อไฟล์)</p>
          </>
        )}
      </div>

      {attachments.length > 0 && (
        <ul className="uploader-list">
          {attachments.map((file, index) => (
            <li key={file.id || `${file.filename}-${index}`} className="uploader-item">
              <FileIcon mimeType={file.mimeType} />
              <div className="uploader-item-info">
                <span className="uploader-item-name">{file.originalName}</span>
                <span className="uploader-item-size">{formatBytes(file.size)}</span>
              </div>
              <button type="button" className="uploader-remove" onClick={() => handleRemove(file, index)}>
                <FaTimes />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
