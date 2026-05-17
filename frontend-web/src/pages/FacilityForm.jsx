import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { FaArrowLeft, FaBuilding, FaSave } from 'react-icons/fa';
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
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

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
            <label className="facform-label">URL รูปภาพ</label>
            <input
              className="facform-input"
              type="text"
              placeholder="http://localhost:3000/public/images/facilities/pool.png"
              value={form.imageUrl}
              onChange={set('imageUrl')}
            />
            <p className="facform-hint">
              ใช้ URL เต็ม เช่น <code>http://&lt;server-ip&gt;:3000/public/images/facilities/filename.png</code> เพื่อให้แอปมือถือโหลดได้
            </p>
            {form.imageUrl && (
              <div className="facform-preview">
                <img src={form.imageUrl} alt="preview" className="facform-img-preview"
                  onError={(e) => { e.target.style.display = 'none'; }}
                />
              </div>
            )}
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
