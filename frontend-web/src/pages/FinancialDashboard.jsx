import { FaArrowRight } from 'react-icons/fa'
import './FinancialDashboard.css'

const MONTH_LABELS = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']

export default function FinancialDashboard({ dashboard, year, years, onYearChange }) {
  if (!dashboard) return null

  const maxAmount = Math.max(
    ...dashboard.monthlyChart.map((item) => Math.max(item.income, item.expense)),
    1,
  )

  return (
    <div className="fin-dashboard">
      <div className="fin-dashboard-header">
        <div>
          <h2>รายงานการเงิน {year}</h2>
          <p>สรุปรายรับ-รายจ่ายและสัดส่วนค่าใช้จ่าย</p>
        </div>
        <select value={year} onChange={(e) => onYearChange(Number(e.target.value))} className="fin-select">
          {years.map((y) => (
            <option key={y} value={y}>{y}</option>
          ))}
        </select>
      </div>

      <div className="fin-summary-grid">
        <div className="fin-summary-card fin-summary-card--income">
          <span>รายรับรวม</span>
          <strong>{dashboard.summary.totalIncome.toLocaleString('th-TH', { style: 'currency', currency: 'THB' })}</strong>
        </div>
        <div className="fin-summary-card fin-summary-card--expense">
          <span>รายจ่ายรวม</span>
          <strong>{dashboard.summary.totalExpense.toLocaleString('th-TH', { style: 'currency', currency: 'THB' })}</strong>
        </div>
        <div className="fin-summary-card fin-summary-card--balance">
          <span>ยอดคงเหลือ</span>
          <strong>{dashboard.summary.balance.toLocaleString('th-TH', { style: 'currency', currency: 'THB' })}</strong>
        </div>
      </div>

      <div className="fin-chart-grid">
        <div className="fin-chart-card">
          <div className="fin-card-title">กราฟรายรับ-รายจ่ายรายเดือน</div>
          <div className="fin-monthly-chart">
            {dashboard.monthlyChart.map((item) => {
              const incomeHeight = (item.income / maxAmount) * 100
              const expenseHeight = (item.expense / maxAmount) * 100
              return (
                <div key={item.month} className="fin-month-column">
                  <div className="fin-bar-group">
                    <div className="fin-bar fin-bar--income" style={{ height: `${incomeHeight}%` }} />
                    <div className="fin-bar fin-bar--expense" style={{ height: `${expenseHeight}%` }} />
                  </div>
                  <span>{MONTH_LABELS[item.month - 1]}</span>
                </div>
              )
            })}
          </div>
        </div>

        <div className="fin-chart-card">
          <div className="fin-card-title">สัดส่วนค่าใช้จ่าย</div>
          <div className="fin-pie-list">
            {dashboard.expensePieChart.length === 0 ? (
              <p className="fin-empty">ยังไม่มีข้อมูลค่าใช้จ่ายในปีนี้</p>
            ) : (
              dashboard.expensePieChart.map((item) => (
                <div key={item.category} className="fin-pie-row">
                  <div className="fin-pie-info">
                    <strong>{item.label}</strong>
                    <span>{item.amount.toLocaleString('th-TH', { style: 'currency', currency: 'THB' })} • {item.percent}%</span>
                  </div>
                  <div className="fin-pie-bar">
                    <div className="fin-pie-bar-fill" style={{ width: `${item.percent}%` }} />
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      <div className="fin-report-cta">
        <span>รายงานการเงินสามารถใช้เป็นข้อมูลประกอบการตรวจสอบและประชุมบริหาร</span>
        <FaArrowRight />
      </div>
    </div>
  )
}
