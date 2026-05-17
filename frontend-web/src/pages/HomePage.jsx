import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaBox, FaBullhorn, FaBuilding, FaWallet, FaSignOutAlt, FaArrowRight, FaChartPie } from 'react-icons/fa';
import { parcelApi } from '../api/parcels';
import { announcementApi } from '../api/announcements';
import { facilityApi } from '../api/facilities';
import { financialApi } from '../api/financial';
import logoImg from '../assets/logo.png';
import './HomePage.css';

const DASHBOARD_MOD = {
  key: 'dashboard',
  name: 'Dashboard',
  desc: 'ภาพรวมและสรุปข้อมูลทั้งระบบ',
  path: '/dashboard',
  Icon: FaChartPie,
  color: '#f97316',
  bg: '#fff7ed',
  border: '#fed7aa',
  iconBg: '#ffedd5',
};

const MODULES = [
  {
    key: 'parcel',
    name: 'Parcel Management',
    desc: 'ลงทะเบียนและติดตามพัสดุที่เข้ามา',
    path: '/parcels',
    Icon: FaBox,
    color: '#ff6b6b',
    bg: '#fff5f3',
    border: '#ffd6d0',
    iconBg: '#ffecea',
  },
  {
    key: 'announcement',
    name: 'Announcements',
    desc: 'โพสต์และจัดการประกาศสำหรับผู้พักอาศัย',
    path: '/announcements',
    Icon: FaBullhorn,
    color: '#7c3aed',
    bg: '#f5f3ff',
    border: '#ddd6fe',
    iconBg: '#ede9fe',
  },
  {
    key: 'facility',
    name: 'Facilities',
    desc: 'จัดการการจองพื้นที่ส่วนกลาง',
    path: '/facilities',
    Icon: FaBuilding,
    color: '#2563eb',
    bg: '#eff6ff',
    border: '#bfdbfe',
    iconBg: '#dbeafe',
  },
  {
    key: 'financial',
    name: 'Financial',
    desc: 'บันทึกและติดตามรายรับรายจ่าย',
    path: '/financial',
    Icon: FaWallet,
    color: '#059669',
    bg: '#f0fdf4',
    border: '#bbf7d0',
    iconBg: '#dcfce7',
  },
];

const WEEKDAYS = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
const MONTHS   = ['January','February','March','April','May','June','July','August','September','October','November','December'];

function formatDate(d) {
  return `${WEEKDAYS[d.getDay()]}, ${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

export default function HomePage({ user, onLogout }) {
  const navigate = useNavigate();
  const [today] = useState(() => new Date());
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const year      = today.getFullYear();
    const pad = (n) => String(n).padStart(2, '0');
    const todayISO = `${today.getFullYear()}-${pad(today.getMonth() + 1)}-${pad(today.getDate())}`;

    Promise.allSettled([
      parcelApi.stats(),
      announcementApi.list({ limit: 1 }),
      announcementApi.list({ limit: 1, status: 'PUBLISHED' }),
      facilityApi.list(),
      facilityApi.listReservations(),
      financialApi.dashboard(year),
    ]).then(([parcelR, annR, annPubR, facilityR, reservR, finR]) => {
      const todayResCount = reservR.status === 'fulfilled'
        ? (Array.isArray(reservR.value) ? reservR.value : [])
            .filter(r => r.status === 'CONFIRMED' && r.startTime?.slice(0, 10) === todayISO)
            .length
        : null;

      let finIncome = null, finExpense = null;
      if (finR.status === 'fulfilled' && finR.value) {
        const fin = finR.value;
        if (fin.summary != null) {
          finIncome = fin.summary.totalIncome; finExpense = fin.summary.totalExpense;
        } else if (typeof fin.totalIncome === 'number') {
          finIncome = fin.totalIncome; finExpense = fin.totalExpense;
        } else if (fin.totals) {
          finIncome = fin.totals.income; finExpense = fin.totals.expense;
        } else if (Array.isArray(fin.monthly)) {
          finIncome  = fin.monthly.reduce((s, m) => s + (m.income  || 0), 0);
          finExpense = fin.monthly.reduce((s, m) => s + (m.expense || 0), 0);
        }
      }

      setSummary({
        parcel:         parcelR.status === 'fulfilled'  ? parcelR.value  : null,
        annTotal:       annR.status === 'fulfilled'     ? (annR.value?.pagination?.total   ?? null) : null,
        annPublished:   annPubR.status === 'fulfilled'  ? (annPubR.value?.pagination?.total ?? null) : null,
        facilityCount:  facilityR.status === 'fulfilled'? (facilityR.value?.length ?? null)          : null,
        todayResCount,
        finIncome,
        finExpense,
      });
      setLoading(false);
    });
  }, [today]);

  const getStats = (key) => {
    if (!summary) return [];
    const num = (n, unit = '') => n != null ? `${Number(n).toLocaleString()}${unit}` : '—';
    switch (key) {
      case 'parcel':       return [
        { label: 'Pending',       value: num(summary.parcel?.totalPending,  ' items') },
        { label: 'Picked up today', value: num(summary.parcel?.pickedUpToday, ' items') },
      ];
      case 'announcement': return [
        { label: 'Total',         value: num(summary.annTotal,    ' posts') },
        { label: 'Published',     value: num(summary.annPublished, ' posts') },
      ];
      case 'facility':     return [
        { label: 'Locations',     value: num(summary.facilityCount, ' places') },
        { label: "Today's bookings", value: num(summary.todayResCount, ' bookings') },
      ];
      case 'financial':    return [
        { label: 'Income (YTD)',  value: summary.finIncome  != null ? `฿${summary.finIncome.toLocaleString()}`  : '—' },
        { label: 'Expense (YTD)', value: summary.finExpense != null ? `฿${summary.finExpense.toLocaleString()}` : '—' },
      ];
      default: return [];
    }
  };

  return (
    <div className="hp-page">
      {/* Header */}
      <header className="hp-header">
        <div className="hp-brand">
          <img src={logoImg} alt="JaiBaan" className="hp-logo" style={{ cursor: 'pointer' }} onClick={() => navigate('/home')} />
          <p className="hp-date">{formatDate(today)}</p>
        </div>
        <div className="hp-header-right">
          <div className="hp-welcome-wrap">
            <p className="hp-welcome">Hello, <strong>{user?.name || user?.username || 'Admin'}</strong></p>
          </div>
          <button className="hp-logout" onClick={onLogout}>
            <FaSignOutAlt /> Sign Out
          </button>
        </div>
      </header>

      {/* Main */}
      <main className="hp-main">
        <div className="hp-inner">
          <p className="hp-subtitle">Select a module to get started</p>

          {/* Dashboard — full-width banner card */}
          <div
            className="hp-dashboard-card"
            style={{ '--c': DASHBOARD_MOD.color, '--bg': DASHBOARD_MOD.bg, '--bd': DASHBOARD_MOD.border, '--ibg': DASHBOARD_MOD.iconBg }}
            onClick={() => navigate(DASHBOARD_MOD.path)}
          >
            <div className="hp-dc-left">
              <div className="hp-dc-icon-wrap"><DASHBOARD_MOD.Icon /></div>
              <div>
                <h3 className="hp-dc-name">{DASHBOARD_MOD.name}</h3>
                <p className="hp-dc-desc">{DASHBOARD_MOD.desc}</p>
              </div>
            </div>
            <div className="hp-dc-right">
              <FaArrowRight className="hp-dc-arrow" />
            </div>
          </div>

          {/* 4 module cards — 2×2 grid */}
          <div className="hp-grid">
            {MODULES.map((mod) => {
              const stats = getStats(mod.key);
              return (
                <div
                  key={mod.key}
                  className="hp-card"
                  style={{ '--c': mod.color, '--bg': mod.bg, '--bd': mod.border, '--ibg': mod.iconBg }}
                  onClick={() => navigate(mod.path)}
                >
                  <div className="hp-card-top">
                    <div className="hp-icon-wrap"><mod.Icon /></div>
                    <div className="hp-arrow-wrap"><FaArrowRight /></div>
                  </div>
                  <h3 className="hp-card-name">{mod.name}</h3>
                  <p className="hp-card-desc">{mod.desc}</p>
                  <div className="hp-divider" />
                  <div className="hp-stats">
                    {loading
                      ? <span className="hp-loading">Loading...</span>
                      : stats.map((s, i) => (
                          <div key={i} className="hp-stat-row">
                            <span className="hp-stat-label">{s.label}</span>
                            <span className="hp-stat-value">{s.value}</span>
                          </div>
                        ))
                    }
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </main>
    </div>
  );
}
