import { FaCircle } from 'react-icons/fa'
import './FinancialDashboard.css'
import { HiOutlineSparkles } from 'react-icons/hi2';


const MONTH_LABELS = [
  'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
  'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
]

// Pie chart colors per category
const PIE_COLORS = {
  ELECTRICITY:   '#ff8a75',
  WATER:         '#4fc3f7',
  MAINTENANCE:   '#ffb74d',
  OTHER_EXPENSE: '#ce93d8',
  DEFAULT:       '#a5d6a7',
}

// ─── SVG Donut Chart ──────────────────────────────────────────
function DonutChart({ data }) {
  const SIZE = 180
  const STROKE = 32
  const R = (SIZE - STROKE) / 2
  const C = 2 * Math.PI * R

  // Build segments
  let cumulative = 0
  const segments = data.map((item, i) => {
    const color = PIE_COLORS[item.category] || PIE_COLORS.DEFAULT
    const pct = item.percent / 100
    const dash = pct * C
    const gap = C - dash
    const offset = C - cumulative * C
    cumulative += pct
    return { ...item, color, dash, gap, offset }
  })

  return (
    <svg
      width={SIZE}
      height={SIZE}
      viewBox={`0 0 ${SIZE} ${SIZE}`}
      style={{ transform: 'rotate(-90deg)', flexShrink: 0 }}
    >
      {/* Background circle */}
      <circle
        cx={SIZE / 2}
        cy={SIZE / 2}
        r={R}
        fill="none"
        stroke="#f3f4f6"
        strokeWidth={STROKE}
      />
      {/* Segments */}
      {segments.map((seg, i) => (
        <circle
          key={i}
          cx={SIZE / 2}
          cy={SIZE / 2}
          r={R}
          fill="none"
          stroke={seg.color}
          strokeWidth={STROKE}
          strokeDasharray={`${seg.dash} ${seg.gap}`}
          strokeDashoffset={seg.offset}
          strokeLinecap="butt"
        />
      ))}
    </svg>
  )
}

// ─── Bar Chart ────────────────────────────────────────────────
function BarChart({ monthlyChart }) {
  const CHART_HEIGHT = 180 // px

  const maxAmount = Math.max(
    ...monthlyChart.map((m) => Math.max(m.income, m.expense)),
    1,
  )

  const fmt = (n) =>
    n >= 1000 ? `${(n / 1000).toFixed(0)}k` : String(n)

  return (
    <div className="fin-bar-chart-wrap">
      {/* Y-axis labels */}
      <div className="fin-y-axis">
        {[1, 0.5, 0].map((ratio) => (
          <span key={ratio}>{fmt(Math.round(maxAmount * ratio))}</span>
        ))}
      </div>

      {/* Bars */}
      <div className="fin-bars-area" style={{ height: CHART_HEIGHT }}>
        {monthlyChart.map((item) => {
          const incH = Math.max((item.income / maxAmount) * CHART_HEIGHT, item.income > 0 ? 4 : 0)
          const expH = Math.max((item.expense / maxAmount) * CHART_HEIGHT, item.expense > 0 ? 4 : 0)
          return (
            <div key={item.month} className="fin-month-col">
              <div className="fin-bar-group" style={{ height: CHART_HEIGHT }}>
                <div className="fin-bar fin-bar--income" style={{ height: incH }} />
                <div className="fin-bar fin-bar--expense" style={{ height: expH }} />
              </div>
              <span className="fin-month-label">{MONTH_LABELS[item.month - 1]}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}

// ─── Main Dashboard ───────────────────────────────────────────
export default function FinancialDashboard({ dashboard, year, years, onYearChange }) {
  if (!dashboard) return null

  const { summary, monthlyChart, expensePieChart } = dashboard

  const fmtTHB = (n) =>
    Number(n).toLocaleString('th-TH', { style: 'currency', currency: 'THB' })

  const balancePositive = summary.balance >= 0

  return (
    <div className="fin-dashboard">
      {/* Header */}
      <div className="fin-dashboard-header">
        <div>
          <h2>Financial {year} <HiOutlineSparkles className="fac-title-spark" /></h2>
          <p>สรุปรายรับ-รายจ่ายและสัดส่วนค่าใช้จ่าย</p>
        </div>
        <select
          value={year}
          onChange={(e) => onYearChange(Number(e.target.value))}
          className="fin-select"
        >
          {years.map((y) => (
            <option key={y} value={y}>{y}</option>
          ))}
        </select>
      </div>

      {/* Summary cards */}
      <div className="fin-summary-grid">
        <div className="fin-summary-card fin-summary-card--income">
          <span>รายรับรวม</span>
          <strong>{fmtTHB(summary.totalIncome)}</strong>
        </div>
        <div className="fin-summary-card fin-summary-card--expense">
          <span>รายจ่ายรวม</span>
          <strong>{fmtTHB(summary.totalExpense)}</strong>
        </div>
        <div className={`fin-summary-card fin-summary-card--balance${balancePositive ? '' : ' fin-summary-card--negative'}`}>
          <span>ยอดคงเหลือ</span>
          <strong>{fmtTHB(summary.balance)}</strong>
        </div>
      </div>

      {/* Charts */}
      <div className="fin-chart-grid">
        {/* Bar chart */}
        <div className="fin-chart-card">
          <div className="fin-card-title">กราฟรายรับ-รายจ่ายรายเดือน</div>
          <div className="fin-bar-legend">
            <span><FaCircle style={{ color: '#2563eb' }} /> รายรับ</span>
            <span><FaCircle style={{ color: '#ef4444' }} /> รายจ่าย</span>
          </div>
          {monthlyChart.every((m) => m.income === 0 && m.expense === 0) ? (
            <p className="fin-empty">ยังไม่มีข้อมูลในปีนี้</p>
          ) : (
            <BarChart monthlyChart={monthlyChart} />
          )}
        </div>

        {/* Donut pie chart */}
        <div className="fin-chart-card">
          <div className="fin-card-title">สัดส่วนค่าใช้จ่าย</div>
          {expensePieChart.length === 0 ? (
            <p className="fin-empty">ยังไม่มีข้อมูลค่าใช้จ่ายในปีนี้</p>
          ) : (
            <div className="fin-pie-wrap">
              {/* Donut */}
              <div className="fin-donut-wrap">
                <DonutChart data={expensePieChart} />
                <div className="fin-donut-center">
                  <span>รายจ่าย</span>
                  <strong>{fmtTHB(summary.totalExpense)}</strong>
                </div>
              </div>

              {/* Legend */}
              <ul className="fin-pie-legend">
                {expensePieChart.map((item) => {
                  const color = PIE_COLORS[item.category] || PIE_COLORS.DEFAULT
                  return (
                    <li key={item.category} className="fin-pie-legend-item">
                      <span className="fin-pie-dot" style={{ background: color }} />
                      <div className="fin-pie-legend-info">
                        <span className="fin-pie-legend-label">{item.label}</span>
                        <span className="fin-pie-legend-val">
                          {fmtTHB(item.amount)}
                          <em>{item.percent}%</em>
                        </span>
                      </div>
                    </li>
                  )
                })}
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}