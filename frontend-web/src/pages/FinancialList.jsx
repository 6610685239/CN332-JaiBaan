import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { FaPlus } from 'react-icons/fa'
import { financialApi } from '../api/financial'
import './FinancialList.css'

const typeLabels = {
  INCOME: 'รายรับ',
  EXPENSE: 'รายจ่าย',
}

export default function FinancialList() {
  const [transactions, setTransactions] = useState([])
  const [filters, setFilters] = useState({ type: '', year: '', month: '' })
  const [years, setYears] = useState([])
  const [loading, setLoading] = useState(false)

  const fetchList = async () => {
    setLoading(true)
    try {
      const result = await financialApi.list(filters)
      setTransactions(result.data || [])
    } finally {
      setLoading(false)
    }
  }

  const navigate = useNavigate()

  useEffect(() => {
    financialApi.years().then(setYears)
    fetchList()
  }, [])

  useEffect(() => {
    fetchList()
  }, [filters])

  return (
    <div className="financial-list-page">
      <div className="financial-list-header">
        <div>
          <h2>รายการการเงิน</h2>
          <p>ดูรายการและค้นหาตามประเภท ปี และเดือน</p>
        </div>
        <div className="financial-list-actions">
          <button className="financial-btn-primary" onClick={() => navigate('/financial/transactions/new')}>
            <FaPlus /> สร้างรายการใหม่
          </button>
        </div>
        <div className="financial-filter-group">
          <select
            value={filters.type}
            onChange={(e) => setFilters((prev) => ({ ...prev, type: e.target.value }))}
          >
            <option value="">ทั้งหมด</option>
            <option value="INCOME">รายรับ</option>
            <option value="EXPENSE">รายจ่าย</option>
          </select>
          <select
            value={filters.year}
            onChange={(e) => setFilters((prev) => ({ ...prev, year: e.target.value }))}
          >
            <option value="">ทุกปี</option>
            {years.map((year) => (
              <option key={year} value={year}>{year}</option>
            ))}
          </select>
          <select
            value={filters.month}
            onChange={(e) => setFilters((prev) => ({ ...prev, month: e.target.value }))}
          >
            <option value="">ทุกเดือน</option>
            {[...Array(12).keys()].map((month) => (
              <option key={month + 1} value={month + 1}>{month + 1}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="financial-table-wrapper">
        <table className="financial-table">
          <thead>
            <tr>
              <th>วันที่</th>
              <th>ประเภท</th>
              <th>หมวดหมู่</th>
              <th>รายละเอียด</th>
              <th className="financial-table-amount">จำนวนเงิน</th>
              <th>แนบไฟล์</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" className="financial-empty">กำลังโหลด...</td>
              </tr>
            ) : transactions.length === 0 ? (
              <tr>
                <td colSpan="6" className="financial-empty">ไม่มีรายการที่ตรงกับเงื่อนไข</td>
              </tr>
            ) : (
              transactions.map((item) => (
                <tr key={item.id}>
                  <td>{new Date(item.transactionDate).toLocaleDateString('th-TH')}</td>
                  <td>{typeLabels[item.type] || item.type}</td>
                  <td>{item.category}</td>
                  <td>{item.description}</td>
                  <td className="financial-table-amount">
                    {item.amount.toLocaleString('th-TH', { style: 'currency', currency: 'THB' })}
                  </td>
                  <td>{item.attachments?.length || 0}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}
