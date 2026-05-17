import { useEffect, useState, useCallback } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  FaPlus, FaSearch, FaEdit, FaTrash, FaEllipsisV,
  FaFilePdf, FaImage, FaPaperclip, FaTimes, FaExternalLinkAlt,
  FaMoneyBillWave, FaCalendarAlt, FaTag, FaFileAlt,
} from 'react-icons/fa'
import { HiOutlineSparkles } from 'react-icons/hi2'
import { financialApi } from '../api/financial'
import './FinancialList.css'

const MONTH_LABELS = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.']

const CATEGORY_LABELS = {
  COMMON_FEE: 'ค่าส่วนกลาง', RENTAL: 'ค่าเช่าพื้นที่', OTHER_INCOME: 'รายรับอื่นๆ',
  ELECTRICITY: 'ค่าไฟฟ้าส่วนกลาง', WATER: 'ค่าน้ำ',
  MAINTENANCE: 'ซ่อมบำรุง', OTHER_EXPENSE: 'รายจ่ายอื่นๆ',
}

const LIMIT = 10

const fmtTHB = (n) =>
  Number(n || 0).toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

const fmtDate = (d) => {
  if (!d) return '—'
  const dt = new Date(d)
  return `${dt.getDate()} ${MONTH_LABELS[dt.getMonth()]} ${dt.getFullYear()}`
}

const formatBytes = (b) => {
  if (!b) return ''
  if (b < 1024) return `${b} B`
  if (b < 1048576) return `${(b / 1024).toFixed(1)} KB`
  return `${(b / 1048576).toFixed(1)} MB`
}

const isImage = (mime = '') => mime.startsWith('image/')
const isPdf   = (mime = '') => mime === 'application/pdf'

// ── Detail Modal ───────────────────────────────────────────────
function DetailModal({ item, onClose, onEdit, onDelete }) {
  if (!item) return null
  const isIncome = item.type === 'INCOME'

  return (
    <div className="fl-overlay" onClick={onClose}>
      <div className="fl-modal" onClick={(e) => e.stopPropagation()}>
        <div className="fl-modal-header">
          <div className="fl-modal-badges">
            <span className={`fl-type-badge fl-type-badge--${isIncome ? 'in' : 'out'}`}>
              {isIncome ? '↑ รายรับ' : '↓ รายจ่าย'}
            </span>
            <span className="fl-cat-tag">{CATEGORY_LABELS[item.category] || item.category}</span>
          </div>
          <button className="fl-modal-close" onClick={onClose}><FaTimes /></button>
        </div>

        <div className="fl-modal-body">
          <div className={`fl-modal-amount ${isIncome ? 'fl-modal-amount--in' : 'fl-modal-amount--out'}`}>
            {isIncome ? '+' : '-'}฿{fmtTHB(item.amount)}
          </div>

          <div className="fl-modal-meta">
            <div className="fl-meta-row">
              <FaCalendarAlt className="fl-meta-icon" />
              <span className="fl-meta-label">วันที่ทำรายการ</span>
              <span className="fl-meta-val">{fmtDate(item.transactionDate)}</span>
            </div>
            <div className="fl-meta-row">
              <FaTag className="fl-meta-icon" />
              <span className="fl-meta-label">หมวดหมู่</span>
              <span className="fl-meta-val">{CATEGORY_LABELS[item.category] || item.category}</span>
            </div>
            <div className="fl-meta-row fl-meta-row--desc">
              <FaFileAlt className="fl-meta-icon" />
              <span className="fl-meta-label">รายละเอียด</span>
              <span className="fl-meta-val">{item.description}</span>
            </div>
          </div>

          {/* Attachments */}
          {item.attachments?.length > 0 && (
            <div className="fl-modal-attachments">
              <p className="fl-attach-section-title">
                <FaPaperclip /> ไฟล์แนบ ({item.attachments.length})
              </p>
              <div className="fl-attach-grid">
                {item.attachments.map((att, i) => (
                  <a
                    key={att.id || i}
                    href={att.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="fl-attach-card"
                    onClick={(e) => e.stopPropagation()}
                  >
                    <div className="fl-attach-preview">
                      {isImage(att.mimeType) ? (
                        <img src={att.url} alt={att.originalName} className="fl-attach-img" />
                      ) : isPdf(att.mimeType) ? (
                        <div className="fl-attach-pdf">
                          <FaFilePdf />
                          <span>PDF</span>
                        </div>
                      ) : (
                        <div className="fl-attach-file">
                          <FaFileAlt />
                        </div>
                      )}
                    </div>
                    <div className="fl-attach-info">
                      <span className="fl-attach-name">{att.originalName}</span>
                      <span className="fl-attach-size">{formatBytes(att.size)}</span>
                    </div>
                    <FaExternalLinkAlt className="fl-attach-ext" />
                  </a>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="fl-modal-footer">
          <button className="fl-btn-edit" onClick={() => onEdit(item.id)}>
            <FaEdit /> แก้ไข
          </button>
          <button className="fl-btn-delete" onClick={() => onDelete(item)}>
            <FaTrash /> ลบ
          </button>
        </div>
      </div>
    </div>
  )
}

// ── Delete Confirm ─────────────────────────────────────────────
function DeleteConfirm({ item, onCancel, onConfirm }) {
  if (!item) return null
  return (
    <div className="fl-overlay" onClick={onCancel}>
      <div className="fl-dialog" onClick={(e) => e.stopPropagation()}>
        <div className="fl-dialog-icon-wrap"><FaTrash className="fl-dialog-icon" /></div>
        <h3 className="fl-dialog-title">ลบรายการ</h3>
        <p className="fl-dialog-sub">ไม่สามารถกู้คืนได้หลังจากลบ</p>
        <div className="fl-dialog-target">"{item.description}"</div>
        <div className="fl-dialog-actions">
          <button className="fl-btn-cancel" onClick={onCancel}>ยกเลิก</button>
          <button className="fl-btn-danger" onClick={() => onConfirm(item.id)}>ลบ</button>
        </div>
      </div>
    </div>
  )
}

// ── Action Menu ────────────────────────────────────────────────
function ActionMenu({ item, onView, onEdit, onDelete }) {
  const [open, setOpen] = useState(false)
  return (
    <div className="fl-action-wrap">
      <button
        className="fl-action-trigger"
        onClick={(e) => { e.stopPropagation(); setOpen(!open) }}
      >
        <FaEllipsisV />
      </button>
      {open && (
        <>
          <div className="fl-action-backdrop" onClick={() => setOpen(false)} />
          <div className="fl-action-dropdown">
            <button onClick={() => { onView(item); setOpen(false) }}><FaFileAlt /> ดูรายละเอียด</button>
            <button onClick={() => { onEdit(item.id); setOpen(false) }}><FaEdit /> แก้ไข</button>
            <div className="fl-action-divider" />
            <button className="fl-action-delete" onClick={() => { onDelete(item); setOpen(false) }}>
              <FaTrash /> ลบ
            </button>
          </div>
        </>
      )}
    </div>
  )
}

// ── Main ───────────────────────────────────────────────────────
export default function FinancialList() {
  const navigate = useNavigate()

  const [transactions, setTransactions] = useState([])
  const [pagination, setPagination]     = useState({ total: 0, page: 1, totalPages: 1 })
  const [years, setYears]               = useState([])
  const [loading, setLoading]           = useState(false)
  const [filters, setFilters]           = useState({ type: '', year: '', month: '', search: '' })
  const [page, setPage]                 = useState(1)
  const [detailItem, setDetailItem]     = useState(null)
  const [deleteTarget, setDeleteTarget] = useState(null)

  const fetchList = useCallback(async () => {
    setLoading(true)
    try {
      const params = { ...filters, page, limit: LIMIT }
      Object.keys(params).forEach((k) => { if (!params[k]) delete params[k] })
      const result = await financialApi.list(params)
      setTransactions(result.data || [])
      setPagination(result.pagination || { total: 0, page: 1, totalPages: 1 })
    } finally {
      setLoading(false)
    }
  }, [filters, page])

  useEffect(() => { financialApi.years().then(setYears) }, [])
  useEffect(() => { fetchList() }, [fetchList])

  const setFilter = (key) => (e) => {
    setFilters((p) => ({ ...p, [key]: e.target.value }))
    setPage(1)
  }

  const handleViewDetail = async (item) => {
    try {
      const full = await financialApi.getById(item.id)
      setDetailItem(full)
    } catch {
      setDetailItem(item)
    }
  }

  const handleDelete = async (id) => {
    await financialApi.delete(id).catch(() => {})
    setDeleteTarget(null)
    setDetailItem(null)
    fetchList()
  }

  const hasFilters = filters.type || filters.year || filters.month || filters.search

  return (
    <div className="fl-page">

      {/* Header */}
      <header className="fl-header">
        <div>
          <h1 className="fl-title">
            รายการการเงิน <HiOutlineSparkles className="fl-title-spark" />
          </h1>
          <p className="fl-subtitle">ดูรายการและค้นหาตามประเภท ปี และเดือน</p>
        </div>
        <button className="fl-btn-primary" onClick={() => navigate('/financial/transactions/new')}>
          <FaPlus /> สร้างรายการใหม่
        </button>
      </header>

      {/* Filters */}
      <div className="fl-filter-bar">
        <div className="fl-search-box">
          <FaSearch className="fl-search-icon" />
          <input
            type="text"
            value={filters.search}
            onChange={setFilter('search')}
            placeholder="ค้นหารายละเอียด..."
            className="fl-search-input"
          />
        </div>
        <select value={filters.type}  onChange={setFilter('type')}  className="fl-select">
          <option value="">ทุกประเภท</option>
          <option value="INCOME">รายรับ</option>
          <option value="EXPENSE">รายจ่าย</option>
        </select>
        <select value={filters.year}  onChange={setFilter('year')}  className="fl-select">
          <option value="">ทุกปี</option>
          {years.map((y) => <option key={y} value={y}>{y}</option>)}
        </select>
        <select value={filters.month} onChange={setFilter('month')} className="fl-select">
          <option value="">ทุกเดือน</option>
          {MONTH_LABELS.map((lbl, i) => <option key={i + 1} value={i + 1}>{lbl}</option>)}
        </select>
        {hasFilters && (
          <button className="fl-filter-clear" onClick={() => { setFilters({ type: '', year: '', month: '', search: '' }); setPage(1) }}>
            ล้างตัวกรอง
          </button>
        )}
      </div>

      {/* Table */}
      <div className="fl-card">
        {loading ? (
          <div className="fl-loading">
            <div className="fl-spinner" />
            <p>กำลังโหลดข้อมูล...</p>
          </div>
        ) : transactions.length === 0 ? (
          <div className="fl-empty-state">
            <FaMoneyBillWave className="fl-empty-icon" />
            <p>ไม่พบรายการที่ตรงกับเงื่อนไข</p>
          </div>
        ) : (
          <table className="fl-table">
            <thead>
              <tr>
                <th>วันที่</th>
                <th>ประเภท</th>
                <th>หมวดหมู่</th>
                <th>รายละเอียด</th>
                <th className="fl-tr">จำนวนเงิน</th>
                <th>ไฟล์แนบ</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {transactions.map((item) => {
                const isIncome = item.type === 'INCOME'
                return (
                  <tr key={item.id} className="fl-row" onClick={() => handleViewDetail(item)}>
                    <td>{fmtDate(item.transactionDate)}</td>
                    <td>
                      <span className={`fl-type-badge fl-type-badge--${isIncome ? 'in' : 'out'}`}>
                        {isIncome ? '↑ รายรับ' : '↓ รายจ่าย'}
                      </span>
                    </td>
                    <td>
                      <span className="fl-cat-tag">{CATEGORY_LABELS[item.category] || item.category}</span>
                    </td>
                    <td className="fl-row-desc">{item.description}</td>
                    <td className={`fl-tr fl-amount ${isIncome ? 'fl-amount--in' : 'fl-amount--out'}`}>
                      {isIncome ? '+' : '-'}฿{fmtTHB(item.amount)}
                    </td>
                    <td>
                      {item.attachments?.length > 0
                        ? <span className="fl-attach-count"><FaPaperclip /> {item.attachments.length}</span>
                        : <span className="fl-attach-none">—</span>}
                    </td>
                    <td onClick={(e) => e.stopPropagation()}>
                      <ActionMenu
                        item={item}
                        onView={handleViewDetail}
                        onEdit={(id) => navigate(`/financial/transactions/${id}/edit`)}
                        onDelete={setDeleteTarget}
                      />
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Pagination */}
      {pagination.totalPages > 1 && (
        <div className="fl-pagination">
          <span className="fl-pagination-info">
            แสดง {(page - 1) * LIMIT + 1}–{Math.min(page * LIMIT, pagination.total)} จาก {pagination.total} รายการ
          </span>
          <div className="fl-pagination-btns">
            <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="fl-page-btn">← ก่อนหน้า</button>
            <span className="fl-page-current">หน้า {page} / {pagination.totalPages}</span>
            <button disabled={page === pagination.totalPages} onClick={() => setPage(p => p + 1)} className="fl-page-btn">ถัดไป →</button>
          </div>
        </div>
      )}

      {detailItem && (
        <DetailModal
          item={detailItem}
          onClose={() => setDetailItem(null)}
          onEdit={(id) => { setDetailItem(null); navigate(`/financial/transactions/${id}/edit`) }}
          onDelete={(item) => { setDetailItem(null); setDeleteTarget(item) }}
        />
      )}

      {deleteTarget && (
        <DeleteConfirm
          item={deleteTarget}
          onCancel={() => setDeleteTarget(null)}
          onConfirm={handleDelete}
        />
      )}
    </div>
  )
}