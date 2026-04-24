import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import {
  FaArrowLeft, FaEye, FaSave, FaRocket,
  FaPlus, FaTimes,
} from 'react-icons/fa';
import { HiOutlineSparkles } from 'react-icons/hi2';
import { announcementApi } from '../api/announcements';
import RichTextEditor from '../components/RichTextEditor';
import FileUploader from '../components/FileUploader';
import PreviewModal from '../components/PreviewModal';
import './AnnouncementForm.css';

const CATEGORIES = [
  { value: 'GENERAL',     label: 'ทั่วไป',      emoji: '📢' },
  { value: 'MAINTENANCE', label: 'ซ่อมบำรุง',   emoji: '🔧' },
  { value: 'EVENT',       label: 'กิจกรรม',     emoji: '🎉' },
  { value: 'FINANCE',     label: 'การเงิน',     emoji: '💰' },
  { value: 'URGENT',      label: 'เร่งด่วน',    emoji: '🚨' },
];

const TARGET_TYPES = [
  { value: 'ALL',  label: 'ลูกบ้านทั้งหมด' },
  { value: 'ZONE', label: 'เฉพาะโซน' },
  { value: 'UNIT', label: 'เฉพาะบ้านเลขที่' },
];

const ZONE_OPTIONS = ['Zone A', 'Zone B', 'Zone C', 'Zone D'];

const INIT = {
  title: '', category: 'GENERAL', content: '',
  effectiveDate: new Date(), expiryDate: null,
  targetType: 'ALL', targetZones: [], targetUnits: [], attachments: [],
};

export default function AnnouncementForm() {
  const navigate = useNavigate();
  const { id } = useParams();
  const isEditing = Boolean(id);

  const [form, setForm] = useState(INIT);
  const [loading, setLoading] = useState(false);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [showPreview, setShowPreview] = useState(false);
  const [unitInput, setUnitInput] = useState('');
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3500);
  };

  useEffect(() => {
    if (!isEditing) return;
    setLoading(true);
    announcementApi.getById(id)
      .then((res) => {
        const d = res.data;
        setForm({
          title: d.title, category: d.category, content: d.content,
          effectiveDate: d.effectiveDate ? new Date(d.effectiveDate) : new Date(),
          expiryDate: d.expiryDate ? new Date(d.expiryDate) : null,
          targetType: d.targetType, targetZones: d.targetZones || [],
          targetUnits: d.targetUnits || [], attachments: d.attachments || [],
        });
      })
      .catch(() => showToast('โหลดข้อมูลไม่สำเร็จ', 'error'))
      .finally(() => setLoading(false));
  }, [id, isEditing]);

  const set = (key) => (val) => setForm((f) => ({ ...f, [key]: val }));

  const buildPayload = () => ({
    title: form.title.trim(),
    category: form.category,
    content: form.content,
    effectiveDate: form.effectiveDate?.toISOString(),
    expiryDate: form.expiryDate?.toISOString() || null,
    targetType: form.targetType,
    targetZones: form.targetType === 'ZONE' ? form.targetZones : [],
    targetUnits: form.targetType === 'UNIT' ? form.targetUnits : [],
    attachments: form.attachments.map(({ id: aid, filename, originalName, url, mimeType, size }) => ({
      ...(aid && { id: aid }), filename, originalName, url, mimeType, size,
    })),
  });

  const validate = () => {
    if (!form.title.trim()) { showToast('กรุณากรอกหัวข้อประกาศ', 'error'); return false; }
    if (!form.content || form.content === '<p></p>') { showToast('กรุณากรอกเนื้อหา', 'error'); return false; }
    if (!form.effectiveDate) { showToast('กรุณาเลือกวันที่มีผล', 'error'); return false; }
    return true;
  };

  const handleSaveDraft = async () => {
    if (!validate()) return;
    setSaving(true);
    try {
      const payload = buildPayload();
      if (isEditing) { await announcementApi.update(id, payload); showToast('บันทึกร่างสำเร็จ'); }
      else { await announcementApi.create({ ...payload, status: 'DRAFT' }); showToast('บันทึกร่างสำเร็จ'); navigate('/announcements'); }
    } catch { showToast('บันทึกไม่สำเร็จ', 'error'); }
    finally { setSaving(false); }
  };

  const handlePublish = async () => {
    if (!validate()) return;
    setPublishing(true);
    try {
      const payload = buildPayload();
      let itemId = id;
      if (!isEditing) { const res = await announcementApi.create({ ...payload, status: 'DRAFT' }); itemId = res.data.id; }
      else { await announcementApi.update(id, payload); }
      await announcementApi.publish(itemId, []);
      showToast('เผยแพร่ประกาศสำเร็จ 🚀');
      setTimeout(() => navigate('/announcements'), 1200);
    } catch { showToast('เผยแพร่ไม่สำเร็จ', 'error'); }
    finally { setPublishing(false); }
  };

  const addUnit = () => {
    const val = unitInput.trim();
    if (val && !form.targetUnits.includes(val)) { set('targetUnits')([...form.targetUnits, val]); setUnitInput(''); }
  };

  if (loading) return (
    <div className="form-page form-page--loading">
      <div className="form-spinner" />
      <p>กำลังโหลดข้อมูล...</p>
    </div>
  );

  return (
    <div className="form-page">
      {/* Toast */}
      {toast && <div className={`form-toast form-toast--${toast.type}`}>{toast.msg}</div>}

      {/* Header */}
      <header className="form-header">
        <div className="form-header-left">
          <button className="btn-back" onClick={() => navigate('/announcements')}>
            <FaArrowLeft />
          </button>
          <div>
            <h1 className="form-title">
              {isEditing ? 'แก้ไขประกาศ' : 'สร้างประกาศใหม่'}
              <HiOutlineSparkles className="form-title-spark" />
            </h1>
            <p className="form-subtitle">
              {isEditing ? 'แก้ไขข้อมูลและบันทึก' : 'กรอกข้อมูลประกาศสำหรับลูกบ้าน'}
            </p>
          </div>
        </div>
        <div className="form-header-actions">
          <button className="btn-ghost" onClick={() => setShowPreview(true)}>
            <FaEye /> ดูตัวอย่าง
          </button>
          <button className="btn-outline" onClick={handleSaveDraft} disabled={saving}>
            {saving ? <span className="btn-spinner" /> : <FaSave />}
            บันทึกร่าง
          </button>
          <button className="btn-gradient" onClick={handlePublish} disabled={publishing}>
            {publishing ? <span className="btn-spinner btn-spinner--white" /> : <FaRocket />}
            เผยแพร่
          </button>
        </div>
      </header>

      {/* Body */}
      <div className="form-body">
        {/* Left: Main */}
        <div className="form-main">
          {/* Title */}
          <div className="form-card">
            <label className="form-label">หัวข้อประกาศ <span className="form-required">*</span></label>
            <input
              type="text"
              value={form.title}
              onChange={(e) => set('title')(e.target.value)}
              placeholder="ระบุหัวข้อประกาศ..."
              className="form-input form-input--title"
            />
          </div>

          {/* Content */}
          <div className="form-card">
            <label className="form-label">เนื้อหา <span className="form-required">*</span></label>
            <RichTextEditor
              value={form.content}
              onChange={set('content')}
              placeholder="พิมพ์เนื้อหาประกาศที่นี่..."
            />
          </div>

          {/* Attachments */}
          <div className="form-card">
            <label className="form-label">ไฟล์แนบ</label>
            <FileUploader
              attachments={form.attachments}
              onAttachmentsChange={set('attachments')}
            />
          </div>
        </div>

        {/* Right: Settings */}
        <div className="form-sidebar">
          {/* Category */}
          <div className="form-card">
            <label className="form-label">ประเภทประกาศ <span className="form-required">*</span></label>
            <div className="category-grid">
              {CATEGORIES.map((c) => (
                <button
                  key={c.value}
                  type="button"
                  onClick={() => set('category')(c.value)}
                  className={`category-btn${form.category === c.value ? ' category-btn--active' : ''}`}
                >
                  <span className="category-emoji">{c.emoji}</span>
                  <span className="category-label">{c.label}</span>
                </button>
              ))}
            </div>
          </div>

          {/* Dates */}
          <div className="form-card">
            <label className="form-label">วันที่</label>
            <div className="date-fields">
              <div className="date-field">
                <span className="date-field-label">วันที่มีผล *</span>
                <DatePicker
                  selected={form.effectiveDate}
                  onChange={set('effectiveDate')}
                  dateFormat="dd/MM/yyyy"
                  placeholderText="เลือกวันที่"
                  className="form-datepicker"
                />
              </div>
              <div className="date-field">
                <span className="date-field-label">วันหมดอายุ (ถ้ามี)</span>
                <DatePicker
                  selected={form.expiryDate}
                  onChange={set('expiryDate')}
                  dateFormat="dd/MM/yyyy"
                  minDate={form.effectiveDate}
                  isClearable
                  placeholderText="ไม่มีวันหมดอายุ"
                  className="form-datepicker"
                />
              </div>
            </div>
          </div>

          {/* Target */}
          <div className="form-card">
            <label className="form-label">กลุ่มเป้าหมาย <span className="form-required">*</span></label>
            <div className="target-options">
              {TARGET_TYPES.map((t) => (
                <label key={t.value} className="target-radio">
                  <input
                    type="radio"
                    name="targetType"
                    value={t.value}
                    checked={form.targetType === t.value}
                    onChange={() => set('targetType')(t.value)}
                    className="target-radio-input"
                  />
                  <span className="target-radio-label">{t.label}</span>
                </label>
              ))}
            </div>

            {/* Zone picker */}
            {form.targetType === 'ZONE' && (
              <div className="target-extra">
                <div className="tag-list">
                  {form.targetZones.map((z) => (
                    <span key={z} className="tag">
                      {z}
                      <button type="button" onClick={() => set('targetZones')(form.targetZones.filter(x => x !== z))}>
                        <FaTimes />
                      </button>
                    </span>
                  ))}
                </div>
                <select
                  value=""
                  onChange={(e) => {
                    if (e.target.value && !form.targetZones.includes(e.target.value))
                      set('targetZones')([...form.targetZones, e.target.value]);
                  }}
                  className="form-select-small"
                >
                  <option value="">+ เพิ่มโซน</option>
                  {ZONE_OPTIONS.filter(z => !form.targetZones.includes(z)).map(z => (
                    <option key={z} value={z}>{z}</option>
                  ))}
                </select>
              </div>
            )}

            {/* Unit input */}
            {form.targetType === 'UNIT' && (
              <div className="target-extra">
                <div className="tag-list">
                  {form.targetUnits.map((u) => (
                    <span key={u} className="tag">
                      {u}
                      <button type="button" onClick={() => set('targetUnits')(form.targetUnits.filter(x => x !== u))}>
                        <FaTimes />
                      </button>
                    </span>
                  ))}
                </div>
                <div className="unit-input-row">
                  <input
                    type="text"
                    value={unitInput}
                    onChange={(e) => setUnitInput(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && (e.preventDefault(), addUnit())}
                    placeholder="เช่น 12/5"
                    className="form-input-small"
                  />
                  <button type="button" onClick={addUnit} className="btn-add-unit">
                    <FaPlus />
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Preview */}
      {showPreview && (
        <PreviewModal
          announcement={{ ...form, effectiveDate: form.effectiveDate?.toISOString() }}
          onClose={() => setShowPreview(false)}
        />
      )}
    </div>
  );
}
