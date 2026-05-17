import { useState, useEffect, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { FaArrowLeft, FaBuilding, FaSave, FaCamera, FaTimes } from 'react-icons/fa';
import { facilityApi } from '../api/facilities';
import './FacilityForm.css';

const EMPTY = {
  name: '',
  description: '',
  capacityMin: '',
  capacityMax: '',
  openTime: '',
  closeTime: '',
  imageUrl: '',
};

export default function FacilityForm() {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEdit = Boolean(id);

  const [form, setForm] = useState(EMPTY);
  const fileRef = useRef(null);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState('');
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleFileChange = async (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setUploading(true);
    const prevUrl = form.imageUrl;
    if (prevUrl) facilityApi.deletePhoto(prevUrl).catch(() => {});
    try {
      const res = await facilityApi.uploadPhoto(file);
      setForm((prev) => ({ ...prev, imageUrl: res.url }));
      showToast('อัพโหลดรูปสำเร็จ');
    } catch {
      showToast('อัพโหลดรูปไม่สำเร็จ', 'error');
    } finally {
      setUploading(false);
      e.target.value = '';
    }
  };

  const handleRemovePhoto = () => {
    if (form.imageUrl) facilityApi.deletePhoto(form.imageUrl).catch(() => {});
    setForm((prev) => ({ ...prev, imageUrl: '' }));
  };

  useEffect(() => {
    if (!isEdit) return;
    setLoading(true);
    facilityApi.getById(id)
      .then((data) => {
        setForm({
          name: data.name ?? '',
          description: data.description ?? '',
          capacityMin: data.capacityMin ?? '',
          capacityMax: data.capacityMax ?? '',
          openTime: data.openTime ?? '',
          closeTime: data.closeTime ?? '',
          imageUrl: data.imageUrl ?? '',
        });
      })
      .catch(() => setError('โหลดข้อมูลไม่สำเร็จ'))
      .finally(() => setLoading(false));
  }, [id, isEdit]);

  const set = (field) => (e) => setForm((prev) => ({ ...prev, [field]: e.target.value }));

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.name.trim()) { setError('กรุณากรอกชื่อสถานที่'); return; }
    setSaving(true);
    setError('');
    try {
      if (isEdit) {
        await facilityApi.update(id, form);
      } else {
        await facilityApi.create(form);
      }
      navigate('/facilities');
    } catch (err) {
      setError(err.response?.data?.error || 'บันทึกไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="facform-page">
        <div className="facform-loading">
          <div className="facform-spinner" />
          <p>กำลังโหลดข้อมูล...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="facform-page">
      {toast && <div className={`facform-toast facform-toast--${toast.type}`}>{toast.msg}</div>}
      <header className="facform-header">
        <button className="btn-back" onClick={() => navigate('/facilities')}>
          <FaArrowLeft /> กลับ
        </button>
        <div>
          <h1 className="facform-title">
            {isEdit ? 'แก้ไขสถานที่' : 'เพิ่มสถานที่ใหม่'}
          </h1>
          <p className="facform-subtitle">
            {isEdit ? 'อัพเดตข้อมูลพื้นที่ส่วนกลาง' : 'เพิ่มพื้นที่ส่วนกลางใหม่'}
          </p>
        </div>
      </header>

      <form className="facform-body" onSubmit={handleSubmit}>
        {error && <div className="facform-error">{error}</div>}

        <div className="facform-card">
          <div className="facform-section-title">
            <FaBuilding className="section-icon" /> ข้อมูลพื้นฐาน
          </div>

          <div className="facform-field">
            <label className="facform-label">ชื่อสถานที่ <span className="required">*</span></label>
            <input
              className="facform-input"
              type="text"
              placeholder="เช่น สระว่ายน้ำ, ห้องประชุม"
              value={form.name}
              onChange={set('name')}
              required
            />
          </div>

          <div className="facform-field">
            <label className="facform-label">รายละเอียด</label>
            <textarea
              className="facform-textarea"
              placeholder="อธิบายสถานที่..."
              value={form.description}
              onChange={set('description')}
              rows={3}
            />
          </div>

          <div className="facform-field">
            <label className="facform-label">รูปภาพ</label>
            <div className="facform-photo-area">
              {form.imageUrl ? (
                <div className="facform-photo-preview">
                  <img src={form.imageUrl} alt="facility" className="facform-preview-img" />
                  <button type="button" className="facform-photo-remove" onClick={handleRemovePhoto}>
                    <FaTimes />
                  </button>
                </div>
              ) : (
                <button
                  type="button"
                  className="facform-upload-btn"
                  onClick={() => fileRef.current?.click()}
                  disabled={uploading}
                >
                  {uploading ? (
                    <span className="facform-upload-spinner" />
                  ) : (
                    <FaCamera className="facform-camera-icon" />
                  )}
                  <span>{uploading ? 'กำลังอัพโหลด...' : 'เลือกรูปภาพ'}</span>
                </button>
              )}
              <input
                ref={fileRef}
                type="file"
                accept="image/*"
                style={{ display: 'none' }}
                onChange={handleFileChange}
              />
            </div>
          </div>
        </div>

        <div className="facform-card">
          <div className="facform-section-title">ความจุและเวลาเปิดบริการ</div>

          <div className="facform-row">
            <div className="facform-field">
              <label className="facform-label">ความจุขั้นต่ำ (คน)</label>
              <input
                className="facform-input"
                type="number"
                min="0"
                placeholder="0"
                value={form.capacityMin}
                onChange={set('capacityMin')}
              />
            </div>
            <div className="facform-field">
              <label className="facform-label">ความจุสูงสุด (คน)</label>
              <input
                className="facform-input"
                type="number"
                min="0"
                placeholder="0"
                value={form.capacityMax}
                onChange={set('capacityMax')}
              />
            </div>
          </div>

          <div className="facform-row">
            <div className="facform-field">
              <label className="facform-label">เวลาเปิด</label>
              <input
                className="facform-input"
                type="time"
                value={form.openTime}
                onChange={set('openTime')}
              />
            </div>
            <div className="facform-field">
              <label className="facform-label">เวลาปิด</label>
              <input
                className="facform-input"
                type="time"
                value={form.closeTime}
                onChange={set('closeTime')}
              />
            </div>
          </div>
        </div>

        <div className="facform-actions">
          <button type="button" className="btn-cancel" onClick={() => navigate('/facilities')}>
            ยกเลิก
          </button>
          <button type="submit" className="btn-save" disabled={saving}>
            <FaSave /> {saving ? 'กำลังบันทึก...' : 'บันทึก'}
          </button>
        </div>
      </form>
    </div>
  );
}
