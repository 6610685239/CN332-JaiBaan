import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import DatePicker from 'react-datepicker'
import 'react-datepicker/dist/react-datepicker.css'
import { FaArrowLeft, FaSave, FaPlus } from 'react-icons/fa'
import { financialApi } from '../api/financial'
import FinancialFileUploader from '../components/FinancialFileUploader'
import './FinancialForm.css'

const TYPE_OPTIONS = [
  { value: 'INCOME', label: 'รายรับ' },
  { value: 'EXPENSE', label: 'รายจ่าย' },
]

const CATEGORY_OPTIONS = {
  INCOME: [
    { value: 'COMMON_FEE', label: 'ค่าส่วนกลาง' },
    { value: 'RENTAL', label: 'ค่าเช่าพื้นที่' },
    { value: 'OTHER_INCOME', label: 'รายรับอื่นๆ' },
  ],
  EXPENSE: [
    { value: 'ELECTRICITY', label: 'ค่าไฟฟ้าส่วนกลาง' },
    { value: 'WATER', label: 'ค่าน้ำ' },
    { value: 'MAINTENANCE', label: 'ซ่อมบำรุง' },
    { value: 'OTHER_EXPENSE', label: 'รายจ่ายอื่นๆ' },
  ],
}

const INIT_FORM = {
  type: 'INCOME',
  category: 'COMMON_FEE',
  amount: '',
  description: '',
  transactionDate: new Date(),
  attachments: [],
}

export default function FinancialForm() {
  const navigate = useNavigate()
  const { id } = useParams()
  const isEditing = Boolean(id)

  const [form, setForm] = useState(INIT_FORM)
  const [loading, setLoading] = useState(false)
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState(null)

  const showToast = (message, type = 'success') => {
    setToast({ message, type })
    setTimeout(() => setToast(null), 4000)
  }

  useEffect(() => {
    if (!isEditing) return
    setLoading(true)
    financialApi.getById(id)
      .then((data) => {
        setForm({
          type: data.type,
          category: data.category,
          amount: Number(data.amount),
          description: data.description,
          transactionDate: new Date(data.transactionDate),
          attachments: data.attachments || [],
        })
      })
      .catch(() => showToast('ไม่สามารถโหลดข้อมูลรายการได้', 'error'))
      .finally(() => setLoading(false))
  }, [id, isEditing])

  const setField = (key) => (value) => setForm((prev) => ({ ...prev, [key]: value }))

  const handleTypeChange = (value) => {
    const nextCategory = CATEGORY_OPTIONS[value][0]?.value || ''
    setForm((prev) => ({ ...prev, type: value, category: nextCategory }))
  }

  const validateForm = () => {
    if (!form.description.trim()) {
      showToast('กรุณากรอกคำอธิบาย', 'error')
      return false
    }
    if (!form.amount || Number(form.amount) <= 0) {
      showToast('กรุณากรอกจำนวนเงินที่ถูกต้อง', 'error')
      return false
    }
    if (!form.transactionDate) {
      showToast('กรุณาเลือกวันที่ทำรายการ', 'error')
      return false
    }
    return true
  }

  const buildPayload = () => ({
    type: form.type,
    category: form.category,
    amount: Number(form.amount),
    description: form.description.trim(),
    transactionDate: form.transactionDate.toISOString(),
    attachments: form.attachments.map((att) => ({
      ...(att.id && { id: att.id }),
      filename: att.filename,
      originalName: att.originalName,
      url: att.url,
      mimeType: att.mimeType,
      size: att.size,
    })),
  })

  const handleSave = async () => {
    if (!validateForm()) return
    setSaving(true)
    try {
      const payload = buildPayload()
      if (isEditing) {
        await financialApi.update(id, payload)
        showToast('อัปเดตรายการสำเร็จ')
      } else {
        await financialApi.create(payload)
        showToast('สร้างรายการสำเร็จ')
      }
      setTimeout(() => navigate('/financial/transactions'), 800)
    } catch (err) {
      console.error(err)
      showToast('บันทึกรายการไม่สำเร็จ', 'error')
    } finally {
      setSaving(false)
    }
  }

  // if (loading) {
  //   return (
  //     <div className="financial-form-page financial-form-loading">
  //       <div className="financial-form-spinner" />
  //       <p>กำลังโหลดข้อมูล...</p>
  //     </div>
  //   )
  // }

  return (
    <div className="financial-form-page">
      {toast && <div className={`financial-toast financial-toast--${toast.type}`}>{toast.message}</div>}

      <header className="financial-form-header">
        <div>
          <button className="financial-btn-back" onClick={() => navigate('/financial/transactions')}>
            <FaArrowLeft /> กลับ
          </button>
          <h1>{isEditing ? 'แก้ไขรายการการเงิน' : 'สร้างรายการการเงินใหม่'}</h1>
          <p>{isEditing ? 'ปรับปรุงข้อมูลธุรกรรมและแนบไฟล์' : 'บันทึกรายรับหรือรายจ่ายสำหรับระบบการเงิน'}</p>
        </div>
        <button className="financial-btn-primary" onClick={handleSave} disabled={saving}>
          {saving ? 'กำลังบันทึก...' : <><FaSave /> บันทึก</>}
        </button>
      </header>

      <div className="financial-form-grid">
        <section className="financial-form-main">
          <div className="financial-card">
            <label>ประเภท</label>
            <div className="financial-radio-group">
              {TYPE_OPTIONS.map((option) => (
                <label key={option.value} className="financial-radio-label">
                  <input
                    type="radio"
                    name="type"
                    checked={form.type === option.value}
                    onChange={() => handleTypeChange(option.value)}
                  />
                  <span>{option.label}</span>
                </label>
              ))}
            </div>
          </div>

          <div className="financial-card">
            <label>หมวดหมู่</label>
            <select
              value={form.category}
              onChange={(e) => setField('category')(e.target.value)}
            >
              {CATEGORY_OPTIONS[form.type].map((item) => (
                <option key={item.value} value={item.value}>{item.label}</option>
              ))}
            </select>
          </div>

          <div className="financial-card">
            <label>จำนวนเงิน</label>
            <input
              type="number"
              min="0"
              step="0.01"
              value={form.amount}
              onChange={(e) => setField('amount')(e.target.value)}
              placeholder="0.00"
            />
          </div>

          <div className="financial-card">
            <label>คำอธิบาย</label>
            <textarea
              value={form.description}
              onChange={(e) => setField('description')(e.target.value)}
              rows="5"
              placeholder="ระบุรายละเอียดเพิ่มเติม..."
            />
          </div>

          <div className="financial-card">
            <label>แนบไฟล์</label>
            <FinancialFileUploader
              attachments={form.attachments}
              onAttachmentsChange={setField('attachments')}
            />
          </div>
        </section>

        <aside className="financial-form-side">
          <div className="financial-card">
            <label>วันที่ทำรายการ</label>
            <DatePicker
              selected={form.transactionDate}
              onChange={setField('transactionDate')}
              dateFormat="dd/MM/yyyy"
              className="financial-datepicker"
            />
          </div>

          <div className="financial-card financial-summary-card">
            <h2>สรุป</h2>
            <div className="financial-summary-row">
              <span>ประเภท</span>
              <strong>{TYPE_OPTIONS.find((item) => item.value === form.type)?.label}</strong>
            </div>
            <div className="financial-summary-row">
              <span>หมวดหมู่</span>
              <strong>{CATEGORY_OPTIONS[form.type].find((item) => item.value === form.category)?.label}</strong>
            </div>
            <div className="financial-summary-row">
              <span>จำนวนเงิน</span>
              <strong>{Number(form.amount || 0).toLocaleString('th-TH', { style: 'currency', currency: 'THB' })}</strong>
            </div>
            <div className="financial-summary-row">
              <span>ไฟล์แนบ</span>
              <strong>{form.attachments.length} รายการ</strong>
            </div>
          </div>
        </aside>
      </div>
    </div>
  )
}
