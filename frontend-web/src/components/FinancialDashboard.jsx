import { useState } from 'react'
import { Link } from 'react-router-dom'
import { HiOutlineSparkles } from 'react-icons/hi2'
import {
  FaArrowUp, FaArrowDown, FaChartLine, FaBell,
  FaList, FaWallet, FaBolt, FaTint, FaWrench, FaBoxOpen,
  FaStar, FaPercent, FaLightbulb,
} from 'react-icons/fa'
import './FinancialDashboard.css'

const MONTH_LABELS = ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']

const CATEGORY_COLORS = {
  OTHER_EXPENSE: '#a78bfa', MAINTENANCE: '#fb923c',
  ELECTRICITY: '#f87171', WATER: '#38bdf8',
  COMMON_FEE: '#34d399', RENTAL: '#60a5fa',
  OTHER_INCOME: '#a3e635',
}
const CATEGORY_ICONS = {
  OTHER_EXPENSE: <FaBoxOpen />, MAINTENANCE: <FaWrench />,
  ELECTRICITY: <FaBolt />, WATER: <FaTint />,
  COMMON_FEE: <FaWallet />, RENTAL: <FaWallet />,
  OTHER_INCOME: <FaWallet />,
}

const fmtTHB = (n) =>
  Number(n || 0).toLocaleString('th-TH', { minimumFractionDigits: 2, maximumFractionDigits: 2 })

const fmtDate = (d) => {
  if (!d) return ''
  const dt = new Date(d)
  return `${dt.getDate()} ${MONTH_LABELS[dt.getMonth()]} ${dt.getFullYear()}`
}

const PctBadge = ({ value }) => {
  if (value == null) return null
  const up = value >= 0
  return (
    <span className={`fin-pct ${up ? 'fin-pct--up' : 'fin-pct--down'}`}>
      {up ? <FaArrowUp /> : <FaArrowDown />} {Math.abs(value)}% จากปีก่อน
    </span>
  )
}

// ── Bar Chart ──────────────────────────────────────────────────
function BarChart({ data }) {
  const [hovered, setHovered] = useState(null)
  const H = 160
  const maxVal = Math.max(...data.map((m) => Math.max(m.income, m.expense)), 1)
  const fmtK = (n) => n >= 1000 ? `${Math.round(n / 1000)}k` : `${Math.round(n)}`

  return (
    <div>
      <div className="fin-bar-legend">
        <span><i className="fin-dot" style={{ background: '#6B8AF7' }} /> รายรับ</span>
        <span><i className="fin-dot" style={{ background: '#F28B82' }} /> รายจ่าย</span>
      </div>
      <div className="fin-bar-wrap">
        {/* Y-axis */}
        <div className="fin-y-axis">
          {[maxVal, maxVal * 0.5, 0].map((v, i) => <span key={i}>{fmtK(v)}</span>)}
        </div>
        {/* Canvas */}
        <div className="fin-canvas" style={{ '--h': H + 'px' }}>
          {/* Grid */}
          <div className="fin-grid">
            {[0, 1, 2].map((i) => <div key={i} className="fin-grid-line" />)}
          </div>
          {/* Bars */}
          <div className="fin-bars-row" style={{ height: H }}>
            {data.map((m, i) => {
              const iH = Math.max((m.income / maxVal) * H, m.income > 0 ? 4 : 0)
              const eH = Math.max((m.expense / maxVal) * H, m.expense > 0 ? 4 : 0)
              return (
                <div
                  key={i}
                  className="fin-col"
                  style={{ position: 'relative', cursor: 'pointer' }}
                  onMouseEnter={() => setHovered(i)}
                  onMouseLeave={() => setHovered(null)}
                >
                  {/* แสดง Tooltip เมื่อเอาเมาส์ชี้ */}
                  {hovered === i && (
                    <div className="fin-tooltip">
                      <div style={{ display: 'flex', gap: '12px', justifyContent: 'space-between' }}>
                        <span style={{ color: '#8ca6ff' }}>รับ</span> <strong>฿{fmtTHB(m.income)}</strong>
                      </div>
                      <div style={{ display: 'flex', gap: '12px', justifyContent: 'space-between', marginTop: '2px' }}>
                        <span style={{ color: '#ffb3ac' }}>จ่าย</span> <strong>฿{fmtTHB(m.expense)}</strong>
                      </div>
                    </div>
                  )}

                  <div className="fin-pair" style={{ height: H }}>
                    <div className="fin-bar fin-bar--i" style={{ height: iH }} />
                    <div className="fin-bar fin-bar--e" style={{ height: eH }} />
                  </div>
                  <span className="fin-lbl">{MONTH_LABELS[m.month - 1]}</span>
                </div>
              )
            })}
          </div>
        </div>
      </div>
    </div>
  )
}

// ── Line Chart (trend) ─────────────────────────────────────────
function LineChart({ data }) {
  const H = 100
  const maxVal = Math.max(...data.flatMap((m) => [m.income, m.expense]), 1)
  const fmtK = (n) => n >= 1000 ? `${Math.round(n / 1000)}k` : `${Math.round(n)}`
  const pts = (key) => data.map((m, i) => {
    const x = data.length < 2 ? 50 : (i / (data.length - 1)) * 100
    const y = H - (m[key] / maxVal) * H
    return `${x},${y}`
  }).join(' ')

  return (
    <div>
      <div className="fin-bar-legend fin-bar-legend--sm">
        <span><i className="fin-dot" style={{ background: '#6B8AF7' }} /> รายรับ</span>
        <span><i className="fin-dot" style={{ background: '#F28B82' }} /> รายจ่าย</span>
        {/* <span><i className="fin-dot fin-dot--dash" style={{ background: '#94a3b8' }} /> กำไรสุทธิ</span> */}
      </div>
      <div className="fin-bar-wrap">
        <div className="fin-y-axis fin-y-axis--sm">
          {[maxVal, maxVal * 0.5, 0].map((v, i) => <span key={i}>{fmtK(v)}</span>)}
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ position: 'relative', height: H }}>
            {/* SVG สำหรับวาดเส้น: ใช้ viewBox ร่วมกับ preserveAspectRatio="none" */}
            <svg
              viewBox={`0 0 100 ${H}`}
              preserveAspectRatio="none"
              style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%', overflow: 'visible' }}
            >
              <polyline fill="none" stroke="#6B8AF7" strokeWidth="2" vectorEffect="non-scaling-stroke" strokeLinecap="round" strokeLinejoin="round" points={pts('income')} />
              <polyline fill="none" stroke="#F28B82" strokeWidth="2" vectorEffect="non-scaling-stroke" strokeLinecap="round" strokeLinejoin="round" points={pts('expense')} />
            </svg>

            {/* การวาดจุดด้วย HTML Div วางซ้อนทับ SVG เพื่อป้องกันจุดเบี้ยวเป็นวงรีจากการขยายของ Flexbox */}
            {data.map((m, i) => {
              const x = data.length < 2 ? 50 : (i / (data.length - 1)) * 100
              const yInc = H - (m.income / maxVal) * H
              const yExp = H - (m.expense / maxVal) * H
              return (
                <div key={i}>
                  <div style={{ position: 'absolute', left: `${x}%`, top: yInc, width: 6, height: 6, background: '#6B8AF7', borderRadius: '50%', transform: 'translate(-50%, -50%)' }} />
                  <div style={{ position: 'absolute', left: `${x}%`, top: yExp, width: 6, height: 6, background: '#F28B82', borderRadius: '50%', transform: 'translate(-50%, -50%)' }} />
                </div>
              )
            })}
          </div>
          <div className="fin-x-axis" style={{ marginTop: '8px' }}>
            {data.map((m, i) => <span key={i}>{MONTH_LABELS[m.label - 1]}</span>)}
          </div>
        </div>
      </div>
    </div>
  )
}

// ── Main ───────────────────────────────────────────────────────
export default function FinancialDashboard({ dashboard, year, years, onYearChange }) {
  if (!dashboard) return null
  const { summary, monthlyChart, expensePieChart, recentTransactions = [], insights, trendChart = [] } = dashboard
  const noBarData = monthlyChart.every((m) => m.income === 0 && m.expense === 0)

  return (
    <div className="fin-dash">

      {/* Header */}
      <div className="fin-header">
        <div>
          <h1 className="fin-title">Financial {year} <HiOutlineSparkles className="fin-spark" /></h1>
          <p className="fin-subtitle">สรุปรายรับ-รายจ่ายและสัดส่วนค่าใช้จ่ายของหมู่บ้าน</p>
        </div>
        <div className="fin-header-right">
          <select value={year} onChange={(e) => onYearChange(Number(e.target.value))} className="fin-select">
            {years.map((y) => <option key={y} value={y}>{y}</option>)}
          </select>
          {/* <button className="fin-bell"><FaBell /></button> */}
        </div>
      </div>

      {/* Summary cards */}
      <div className="fin-sum-grid">
        <div className="fin-sum-card">
          <div className="fin-sum-ico fin-sum-ico--in"><FaChartLine /></div>
          <div className="fin-sum-info">
            <span>รายรับรวม</span>
            <strong>฿{fmtTHB(summary.totalIncome)}</strong>
            <PctBadge value={summary.incomePctChange} />
          </div>
        </div>
        <div className="fin-sum-card">
          <div className="fin-sum-ico fin-sum-ico--out"><FaArrowDown /></div>
          <div className="fin-sum-info">
            <span>รายจ่ายรวม</span>
            <strong>฿{fmtTHB(summary.totalExpense)}</strong>
            <PctBadge value={summary.expensePctChange} />
          </div>
        </div>
        <div className="fin-sum-card">
          <div className="fin-sum-ico fin-sum-ico--bal"><FaWallet /></div>
          <div className="fin-sum-info">
            <span>ยอดคงเหลือ</span>
            <strong className={summary.balance < 0 ? 'fin-neg' : ''}>฿{fmtTHB(summary.balance)}</strong>
            <PctBadge value={summary.balancePctChange} />
          </div>
        </div>
        <div className="fin-sum-card">
          <div className="fin-sum-ico fin-sum-ico--cnt"><FaList /></div>
          <div className="fin-sum-info">
            <span>รายการทั้งหมด</span>
            <strong>{(summary.totalCount || 0).toLocaleString()} รายการ</strong>
            <span className="fin-sum-sub">เดือนนี้ {summary.thisMonthCount || 0} รายการ</span>
          </div>
        </div>
      </div>

      {/* Bar + Expense breakdown */}
      <div className="fin-row fin-row--charts">
        <div className="fin-card fin-card--bar">
          <div className="fin-card-head">
            <span className="fin-card-title">กราฟรายรับ-รายจ่ายรายเดือน</span>
            <span className="fin-badge">รายเดือน</span>
          </div>
          {noBarData
            ? <p className="fin-empty">ยังไม่มีข้อมูลในปีนี้</p>
            : <BarChart data={monthlyChart} />}
        </div>

        <div className="fin-card fin-card--pie">
          <div className="fin-card-head">
            <span className="fin-card-title">สัดส่วนค่าใช้จ่ายปี {year}</span>
            <span className="fin-badge">ทั้งหมด</span>
          </div>
          {expensePieChart.length === 0
            ? <p className="fin-empty">ยังไม่มีข้อมูลค่าใช้จ่ายในปีนี้</p>
            : (
              <ul className="fin-exp-list">
                {expensePieChart.map((item) => {
                  const color = CATEGORY_COLORS[item.category] || '#94a3b8'
                  return (
                    <li key={item.category} className="fin-exp-item">
                      <div className="fin-exp-ico" style={{ background: color + '22', color }}>
                        {CATEGORY_ICONS[item.category] || <FaBoxOpen />}
                      </div>
                      <div className="fin-exp-body">
                        <div className="fin-exp-row1">
                          <span className="fin-exp-name">{item.label}</span>
                          <span className="fin-exp-pct">{item.percent}%</span>
                        </div>
                        <div className="fin-exp-row2">
                          <span className="fin-exp-cat">({item.category})</span>
                          <span className="fin-exp-amt">฿{fmtTHB(item.amount)}</span>
                        </div>
                        <div className="fin-exp-bar">
                          <div style={{ width: `${item.percent}%`, background: color }} />
                        </div>
                      </div>
                    </li>
                  )
                })}
              </ul>
            )}
        </div>
      </div>

      {/* Recent + Insights + Trend */}
      <div className="fin-row fin-row--bottom">
        {/* Recent transactions */}
        <div className="fin-card fin-card--recent">
          <div className="fin-card-head">
            <span className="fin-card-title">รายการล่าสุด</span>
            <Link to="/financial/transactions" className="fin-card-link">ดูทั้งหมด →</Link>
          </div>
          {recentTransactions.length === 0
            ? <p className="fin-empty">ยังไม่มีรายการ</p>
            : (
              <table className="fin-table">
                <thead>
                  <tr>
                    <th>วันที่</th><th>ประเภท</th><th>หมวดหมู่</th><th>รายละเอียด</th>
                    <th className="fin-tr">จำนวนเงิน</th>
                  </tr>
                </thead>
                <tbody>
                  {recentTransactions.map((tx) => (
                    <tr key={tx.id}>
                      <td>{fmtDate(tx.transactionDate)}</td>
                      <td>
                        <span className={`fin-type fin-type--${tx.type === 'INCOME' ? 'in' : 'out'}`}>
                          {tx.type === 'INCOME' ? '↑ รายรับ' : '↓ รายจ่าย'}
                        </span>
                      </td>
                      <td><span className="fin-cat-tag">{tx.category}</span></td>
                      <td className="fin-desc">{tx.description}</td>
                      <td className={`fin-tr fin-amt fin-amt--${tx.type === 'INCOME' ? 'in' : 'out'}`}>
                        {tx.type === 'INCOME' ? '+' : '-'}฿{fmtTHB(tx.amount)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
        </div>

        {/* Insights */}
        <div className="fin-card fin-card--insight">
          <div className="fin-card-head">
            <span className="fin-card-title"><FaLightbulb className="fin-insight-bulb" /> Monthly Insights</span>
            <span className="fin-insight-month">{MONTH_LABELS[new Date().getMonth()]} {year}</span>
          </div>
          <div className="fin-insight-list">
            <div className="fin-insight-item">
              <div className="fin-insight-ico fin-insight-ico--blue"><FaChartLine /></div>
              <div>
                <p className="fin-insight-lbl">รายจ่าย{(insights?.expenseChangePct ?? 0) >= 0 ? 'เพิ่มขึ้น' : 'ลดลง'}</p>
                <strong className="fin-insight-val">
                  {insights?.expenseChangePct != null ? `${insights.expenseChangePct >= 0 ? '+' : ''}${insights.expenseChangePct}%` : '—'}
                </strong>
                <p className="fin-insight-sub">เทียบกับเดือนก่อน</p>
              </div>
            </div>
            <div className="fin-insight-item">
              <div className="fin-insight-ico fin-insight-ico--green"><FaPercent /></div>
              <div>
                <p className="fin-insight-lbl">รายรับ{(insights?.incomeChangePct ?? 0) >= 0 ? 'เพิ่มขึ้น' : 'ลดลง'}</p>
                <strong className="fin-insight-val">
                  {insights?.incomeChangePct != null ? `${insights.incomeChangePct >= 0 ? '+' : ''}${insights.incomeChangePct}%` : '—'}
                </strong>
                <p className="fin-insight-sub">เทียบกับเดือนก่อน</p>
              </div>
            </div>
            <div className="fin-insight-item">
              <div className="fin-insight-ico fin-insight-ico--yellow"><FaStar /></div>
              <div>
                <p className="fin-insight-lbl">หมวดที่ใช้จ่ายสูงสุด</p>
                <strong className="fin-insight-val fin-insight-val--cat">{insights?.topCategory?.category ?? '—'}</strong>
              </div>
            </div>
          </div>
        </div>

        {/* Trend */}
        <div className="fin-card fin-card--trend">
          <div className="fin-card-head">
            <span className="fin-card-title">แนวโน้ม 6 เดือนล่าสุด</span>
            <span className="fin-badge">6 เดือน</span>
          </div>
          {trendChart.length > 1
            ? <LineChart data={trendChart} />
            : <p className="fin-empty">ยังไม่มีข้อมูลเพียงพอ</p>}
        </div>
      </div>

    </div>
  )
}