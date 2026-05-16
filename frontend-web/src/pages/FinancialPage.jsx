import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { financialApi } from '../api/financial'
import FinancialDashboard from '../components/FinancialDashboard'
import './FinancialPage.css'

export default function FinancialPage() {
  const [dashboard, setDashboard] = useState(null)
  const [years, setYears] = useState([])
  const [year, setYear] = useState(new Date().getFullYear())
  const [loading, setLoading] = useState(true)

  const loadDashboard = async (selectedYear) => {
    setLoading(true)
    try {
      const data = await financialApi.dashboard(selectedYear)
      setDashboard(data)
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    financialApi.years().then((result) => {
      setYears(result)
      if (result.length > 0 && !result.includes(year)) {
        setYear(result[0])
      }
    })
  }, [])

  useEffect(() => {
    loadDashboard(year)
  }, [year])

  return (
    <div className="financial-page-wrapper">
      {loading && (
        <div className="financial-page-loading">
          <p>กำลังโหลดข้อมูลการเงิน...</p>
        </div>
      )}

      {!loading && !dashboard && (
        <div className="financial-page-empty">
          <h2>ยังไม่มีข้อมูลการเงิน</h2>
          <p>สร้างรายการรายรับหรือรายจ่ายครั้งแรกเพื่อเริ่มบันทึกข้อมูลทางการเงิน</p>
          <Link to="/financial/transactions/new" className="financial-cta-button">
            สร้างรายการใหม่
          </Link>
        </div>
      )}

      {dashboard && (
        <>
          <FinancialDashboard
            dashboard={dashboard}
            year={year}
            years={years}
            onYearChange={setYear}
          />
          <div className="financial-cta-row">
            <Link to="/financial/transactions" className="financial-cta-button">
              ดูรายการทั้งหมด
            </Link>
          </div>
        </>
      )}
    </div>
  )
}
