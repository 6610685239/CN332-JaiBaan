import { FaTimes, FaPaperclip, FaClock } from 'react-icons/fa';
import { format } from 'date-fns';
import { th } from 'date-fns/locale';
import './PreviewModal.css';

const CATEGORY_LABEL = {
  GENERAL: 'ทั่วไป', MAINTENANCE: 'ซ่อมบำรุง',
  EVENT: 'กิจกรรม', FINANCE: 'การเงิน', URGENT: 'เร่งด่วน',
};
const CATEGORY_COLOR = {
  GENERAL: '#8e7f7d', MAINTENANCE: '#f59e0b',
  EVENT: '#3b82f6',   FINANCE: '#10b981', URGENT: '#ff6b6b',
};

const fmt = (d) => {
  if (!d) return '—';
  try { return format(new Date(d), 'd MMM yyyy', { locale: th }); } catch { return '—'; }
};

export default function PreviewModal({ announcement, onClose }) {
  if (!announcement) return null;
  const color = CATEGORY_COLOR[announcement.category] || '#ff8a75';

  return (
    <div className="preview-overlay" onClick={onClose}>
      <div className="preview-modal" onClick={(e) => e.stopPropagation()}>
        {/* Header */}
        <div className="preview-modal-header">
          <div className="preview-badge">
            <span className="preview-badge-dot" />
            ตัวอย่างที่ลูกบ้านจะเห็น
          </div>
          <button className="preview-close" onClick={onClose}><FaTimes /></button>
        </div>

        {/* Phone mockup */}
        <div className="preview-body">
          <div className="preview-phone">
            {/* Colored top strip */}
            <div className="preview-strip" style={{ background: color }} />
            <div className="preview-phone-content">
              {/* Category + Date */}
              <div className="preview-meta">
                <span className="preview-category-badge" style={{ background: color }}>
                  {CATEGORY_LABEL[announcement.category] || announcement.category}
                </span>
                <span className="preview-date">{fmt(announcement.effectiveDate || new Date())}</span>
              </div>

              {/* Title */}
              <h3 className="preview-title">
                {announcement.title || 'หัวข้อประกาศ'}
              </h3>

              {/* Content */}
              <div
                className="preview-content"
                dangerouslySetInnerHTML={{
                  __html: announcement.content || '<p style="color:#c0aaa8">ยังไม่มีเนื้อหา</p>',
                }}
              />

              {/* Attachments */}
              {announcement.attachments?.length > 0 && (
                <div className="preview-attachments">
                  <p className="preview-attach-label">ไฟล์แนบ</p>
                  {announcement.attachments.map((f, i) => (
                    <div key={i} className="preview-attach-item">
                      <FaPaperclip /> {f.originalName}
                    </div>
                  ))}
                </div>
              )}

              {/* Expiry */}
              {announcement.expiryDate && (
                <div className="preview-expiry">
                  <FaClock /> หมดอายุ: {fmt(announcement.expiryDate)}
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="preview-footer">
          ตัวอย่าง mock-up — หน้าตาจริงในแอพอาจแตกต่างเล็กน้อย
        </div>
      </div>
    </div>
  );
}
