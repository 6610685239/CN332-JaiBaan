import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaArrowLeft, FaBox, FaSave, FaCamera, FaTimes } from 'react-icons/fa';
import { parcelApi } from '../api/parcels';
import './ParcelForm.css';

const CARRIERS = ['Kerry', 'Flash', 'J&T', 'Thailand Post', 'DHL', 'Lazada', 'Shopee', 'Amazon'];

const EMPTY = {
  trackingNumber: '',
  carrier: '',
  unitNumber: '',
  storageLocation: '',
  notes: '',
  photoUrl: '',
};

export default function ParcelForm() {
  const navigate = useNavigate();
  const fileRef = useRef(null);

  const [form, setForm] = useState(EMPTY);
  const [isOtherCarrier, setIsOtherCarrier] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const set = (field) => (e) => setForm((prev) => ({ ...prev, [field]: e.target.value }));

  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    // Delete previous uploaded-but-not-saved photo before uploading new one
    const prevUrl = form.photoUrl;
    if (prevUrl) parcelApi.deletePhoto(prevUrl).catch(() => {});
    try {
      const res = await parcelApi.uploadPhoto(file);
      setForm((prev) => ({ ...prev, photoUrl: res.url }));
      showToast('อัพโหลดรูปสำเร็จ');
    } catch {
      showToast('อัพโหลดรูปไม่สำเร็จ', 'error');
    } finally {
      setUploading(false);
      e.target.value = '';
    }
  };

  const handleRemovePhoto = () => {
    if (form.photoUrl) parcelApi.deletePhoto(form.photoUrl).catch(() => {});
    setForm((prev) => ({ ...prev, photoUrl: '' }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.trackingNumber.trim()) { setError('กรุณากรอก Tracking Number'); return; }
    if (!form.carrier.trim()) { setError('กรุณาเลือกหรือกรอกชื่อผู้ส่ง'); return; }
    if (!form.unitNumber.trim()) { setError('กรุณากรอกเลขห้อง'); return; }
    setSaving(true);
    setError('');
    try {
      await parcelApi.create({
        trackingNumber: form.trackingNumber.trim(),
        carrier: form.carrier.trim(),
        unitNumber: form.unitNumber.trim(),
        storageLocation: form.storageLocation.trim() || undefined,
        photoUrl: form.photoUrl || undefined,
        notes: form.notes.trim() || undefined,
      });
      navigate('/parcels');
    } catch (err) {
      const msg = err.response?.data?.message || 'บันทึกไม่สำเร็จ';
      setError(msg);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="pform-page">
      {toast && <div className={`pform-toast pform-toast--${toast.type}`}>{toast.msg}</div>}

      <header className="pform-header">
        <button className="btn-back" onClick={() => navigate('/parcels')}>
          <FaArrowLeft />
        </button>
        <div>
          <h1 className="pform-title"><FaBox className="pform-title-icon" /> ลงทะเบียนพัสดุ</h1>
          <p className="pform-subtitle">บันทึกพัสดุที่เข้ามาใหม่</p>
        </div>
      </header>

      <form className="pform-body" onSubmit={handleSubmit}>
        {error && <div className="pform-error">{error}</div>}

        <div className="pform-card">
          <div className="pform-section-title">ข้อมูลพัสดุ</div>

          <div className="pform-field">
            <label className="pform-label">Tracking Number <span className="required">*</span></label>
            <input
              className="pform-input"
              type="text"
              placeholder="เช่น TH123456789"
              value={form.trackingNumber}
              onChange={set('trackingNumber')}
              required
            />
          </div>

          <div className="pform-field">
            <label className="pform-label">ผู้ส่ง / บริษัทขนส่ง <span className="required">*</span></label>
            <div className="pform-carrier-row">
              <select
                className="pform-select"
                value={isOtherCarrier ? '__OTHER__' : form.carrier}
                onChange={(e) => {
                  if (e.target.value === '__OTHER__') {
                    setIsOtherCarrier(true);
                    setForm((prev) => ({ ...prev, carrier: '' }));
                  } else {
                    setIsOtherCarrier(false);
                    setForm((prev) => ({ ...prev, carrier: e.target.value }));
                  }
                }}
              >
                <option value="">เลือก...</option>
                {CARRIERS.map((c) => <option key={c} value={c}>{c}</option>)}
                <option value="__OTHER__">อื่นๆ</option>
              </select>
              <input
                className={`pform-input${!isOtherCarrier ? ' pform-input--locked' : ''}`}
                type="text"
                placeholder="ระบุชื่อขนส่ง"
                value={form.carrier}
                readOnly={!isOtherCarrier}
                onChange={set('carrier')}
                autoFocus={isOtherCarrier}
              />
            </div>
          </div>

          <div className="pform-field">
            <label className="pform-label">หมายเหตุ</label>
            <textarea
              className="pform-input pform-textarea"
              placeholder="เช่น ระวังแตก, โทรก่อนวาง, ขนาดใหญ่"
              value={form.notes}
              onChange={set('notes')}
              rows={2}
            />
          </div>

          <div className="pform-row">
            <div className="pform-field">
              <label className="pform-label">เลขห้อง <span className="required">*</span></label>
              <input
                className="pform-input"
                type="text"
                placeholder="เช่น 12/5"
                value={form.unitNumber}
                onChange={set('unitNumber')}
                required
              />
            </div>
            <div className="pform-field">
              <label className="pform-label">ที่เก็บ</label>
              <input
                className="pform-input"
                type="text"
                placeholder="เช่น ชั้น 2 ห้อง A"
                value={form.storageLocation}
                onChange={set('storageLocation')}
              />
            </div>
          </div>
        </div>

        <div className="pform-card">
          <div className="pform-section-title">รูปถ่ายพัสดุ</div>

          <div className="pform-photo-area">
            {form.photoUrl ? (
              <div className="pform-photo-preview">
                <img src={form.photoUrl} alt="parcel" className="pform-preview-img" />
                <button
                  type="button"
                  className="pform-photo-remove"
                  onClick={handleRemovePhoto}
                >
                  <FaTimes />
                </button>
              </div>
            ) : (
              <button
                type="button"
                className="pform-upload-btn"
                onClick={() => fileRef.current?.click()}
                disabled={uploading}
              >
                {uploading ? (
                  <span className="pform-upload-spinner" />
                ) : (
                  <FaCamera className="pform-camera-icon" />
                )}
                <span>{uploading ? 'กำลังอัพโหลด...' : 'ถ่ายรูป / เลือกรูป'}</span>
              </button>
            )}
            <input
              ref={fileRef}
              type="file"
              accept="image/*"
              style={{ display: 'none' }}
              onChange={handleFileChange}
            />
            {!form.photoUrl }
          </div>
        </div>

        <div className="pform-actions">
          <button
            type="button"
            className="btn-cancel"
            onClick={() => {
              if (form.photoUrl) parcelApi.deletePhoto(form.photoUrl).catch(() => {});
              navigate('/parcels');
            }}
          >
            ยกเลิก
          </button>
          <button type="submit" className="btn-save" disabled={saving || uploading}>
            <FaSave /> {saving ? 'กำลังบันทึก...' : 'บันทึกพัสดุ'}
          </button>
        </div>
      </form>
    </div>
  );
}
