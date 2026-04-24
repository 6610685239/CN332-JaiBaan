import { useRef, useState } from 'react';
import { FaCloudUploadAlt, FaTimes, FaFilePdf, FaImage } from 'react-icons/fa';
import { announcementApi } from '../api/announcements';
import './FileUploader.css';

const formatBytes = (b) => {
  if (b < 1024) return `${b} B`;
  if (b < 1048576) return `${(b / 1024).toFixed(1)} KB`;
  return `${(b / 1048576).toFixed(1)} MB`;
};

const FileIcon = ({ mimeType }) =>
  mimeType === 'application/pdf'
    ? <FaFilePdf className="file-icon file-icon--pdf" />
    : <FaImage className="file-icon file-icon--img" />;

export default function FileUploader({ attachments = [], onAttachmentsChange }) {
  const inputRef = useRef();
  const [uploading, setUploading] = useState(false);
  const [dragging, setDragging] = useState(false);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleFiles = async (files) => {
    const arr = Array.from(files);
    setUploading(true);
    const results = await Promise.allSettled(
      arr.map((f) => announcementApi.uploadFile(f).then((r) => r.data))
    );
    const ok = results.filter((r) => r.status === 'fulfilled').map((r) => r.value);
    const fail = results.filter((r) => r.status === 'rejected').length;
    if (fail > 0) showToast(`อัพโหลดไม่สำเร็จ ${fail} ไฟล์`, 'error');
    if (ok.length > 0) {
      onAttachmentsChange([...attachments, ...ok]);
      showToast(`อัพโหลดสำเร็จ ${ok.length} ไฟล์`);
    }
    setUploading(false);
  };

  const handleRemove = async (att, idx) => {
    if (att.id) await announcementApi.deleteAttachment(att.id).catch(() => {});
    onAttachmentsChange(attachments.filter((_, i) => i !== idx));
  };

  return (
    <div className="uploader">
      {toast && (
        <div className={`uploader-toast uploader-toast--${toast.type}`}>{toast.msg}</div>
      )}

      <div
        className={`uploader-zone${dragging ? ' uploader-zone--drag' : ''}`}
        onClick={() => inputRef.current?.click()}
        onDragOver={(e) => { e.preventDefault(); setDragging(true); }}
        onDragLeave={() => setDragging(false)}
        onDrop={(e) => { e.preventDefault(); setDragging(false); handleFiles(e.dataTransfer.files); }}
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
          {attachments.map((f, i) => (
            <li key={f.id || i} className="uploader-item">
              <FileIcon mimeType={f.mimeType} />
              <div className="uploader-item-info">
                <span className="uploader-item-name">{f.originalName}</span>
                <span className="uploader-item-size">{formatBytes(f.size)}</span>
              </div>
              <button
                type="button"
                className="uploader-remove"
                onClick={() => handleRemove(f, i)}
              >
                <FaTimes />
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
