import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  FaHouseUser, FaBoxOpen, FaExclamationTriangle,
  FaCalendarCheck, FaPlus, FaBullhorn, FaArrowRight,
} from 'react-icons/fa';
import { HiOutlineSparkles } from 'react-icons/hi2';
import { parcelApi } from '../api/parcels';
import { announcementApi } from '../api/announcements';
import { facilityApi } from '../api/facilities';
import api from '../api/axios';
import './Dashboard.css';

const WEEKDAYS = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
const MONTHS   = ['January','February','March','April','May','June','July','August','September','October','November','December'];

function formatDate(d) {
  return `${WEEKDAYS[d.getDay()]}, ${d.getDate()} ${MONTHS[d.getMonth()]} ${d.getFullYear()}`;
}

function formatTime(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
}

function formatShortDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return `${d.getDate()} ${MONTHS[d.getMonth()].slice(0, 3)}`;
}

const STATUS_CFG = {
  ARRIVED:   { label: 'Pending',    bg: '#fef3c7', fg: '#b45309' },
  PICKED_UP: { label: 'Picked up',  bg: '#dcfce7', fg: '#15803d' },
  RETURNED:  { label: 'Returned',   bg: '#f1f5f9', fg: '#64748b' },
};

export default function Dashboard({ user }) {
  const navigate = useNavigate();
  const [today]  = useState(() => new Date());
  const [loading, setLoading] = useState(true);
  const [data,    setData]    = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    const pad = (n) => String(n).padStart(2, '0');
    const todayISO = `${today.getFullYear()}-${pad(today.getMonth() + 1)}-${pad(today.getDate())}`;

    const [dashR, parcelR, recentR, reservR, annR] = await Promise.allSettled([
      api.get('/dashboard/stats').then(r => r.data),
      parcelApi.stats(),
      parcelApi.list({ limit: 5, sortOrder: 'desc' }),
      facilityApi.listReservations(),
      announcementApi.list({ limit: 5, status: 'PUBLISHED' }),
    ]);

    const todayBookings = reservR.status === 'fulfilled'
      ? (Array.isArray(reservR.value) ? reservR.value : [])
          .filter(r => r.status === 'CONFIRMED' && r.startTime?.slice(0, 10) === todayISO)
          .sort((a, b) => new Date(a.startTime) - new Date(b.startTime))
      : [];

    setData({
      residents:      dashR.status === 'fulfilled'  ? dashR.value?.residentCount  ?? 0 : 0,
      pending:        parcelR.status === 'fulfilled' ? parcelR.value?.totalPending  ?? 0 : 0,
      overdue:        parcelR.status === 'fulfilled' ? parcelR.value?.overdue        ?? 0 : 0,
      pickedUpToday:  parcelR.status === 'fulfilled' ? parcelR.value?.pickedUpToday  ?? 0 : 0,
      recentParcels:  recentR.status === 'fulfilled' ? (recentR.value?.data ?? [])         : [],
      todayBookings,
      announcements:  annR.status === 'fulfilled'    ? (annR.value?.data ?? [])             : [],
    });
    setLoading(false);
  }, [today]);

  useEffect(() => { load(); }, [load]);

  const stats = data ? [
    { label: 'Total Residents',   value: data.residents,     icon: <FaHouseUser />,           color: '#ff8a75', bg: '#fff5f3' },
    { label: 'Pending Parcels',   value: data.pending,       icon: <FaBoxOpen />,              color: '#f59e0b', bg: '#fffbeb' },
    { label: 'Overdue Parcels',   value: data.overdue,       icon: <FaExclamationTriangle />,  color: '#ef4444', bg: '#fef2f2' },
    { label: "Today's Bookings",  value: data.todayBookings.length, icon: <FaCalendarCheck />, color: '#059669', bg: '#f0fdf4' },
  ] : [];

  return (
    <div className="db-page">

      {/* ── Header ── */}
      <header className="db-header">
        <div>
          <h1 className="db-greeting">
            Hello, {user?.name || user?.username || 'Admin'}
            <HiOutlineSparkles className="db-sparkle" />
          </h1>
          <p className="db-date">{formatDate(today)}</p>
        </div>
        <div className="db-actions">
          <button className="db-btn-secondary" onClick={() => navigate('/announcements/new')}>
            <FaBullhorn /> New Announcement
          </button>
          <button className="db-btn-primary" onClick={() => navigate('/parcels/new')}>
            <FaPlus /> Register Parcel
          </button>
        </div>
      </header>

      {/* ── Stat cards ── */}
      <section className="db-stats">
        {loading
          ? Array.from({ length: 4 }).map((_, i) => <div key={i} className="db-stat-card db-skeleton" />)
          : stats.map((s) => (
              <div key={s.label} className="db-stat-card" style={{ '--c': s.color, '--bg': s.bg }}>
                <div className="db-stat-icon-wrap"><s.icon.type {...s.icon.props} /></div>
                <div>
                  <p className="db-stat-label">{s.label}</p>
                  <p className="db-stat-value">{s.value.toLocaleString()}</p>
                </div>
              </div>
            ))
        }
      </section>

      {/* ── Two-column body ── */}
      <div className="db-body">

        {/* Recent Parcels */}
        <section className="db-panel">
          <div className="db-panel-header">
            <h2 className="db-panel-title">Recent Parcels</h2>
            <button className="db-panel-link" onClick={() => navigate('/parcels')}>
              View all <FaArrowRight />
            </button>
          </div>

          {loading ? (
            <div className="db-list-skeleton">
              {Array.from({ length: 5 }).map((_, i) => <div key={i} className="db-skeleton db-skeleton-row" />)}
            </div>
          ) : data.recentParcels.length === 0 ? (
            <p className="db-empty">No parcels yet</p>
          ) : (
            <ul className="db-parcel-list">
              {data.recentParcels.map((p) => {
                const cfg = STATUS_CFG[p.status] ?? STATUS_CFG.RETURNED;
                return (
                  <li key={p.id} className="db-parcel-row">
                    <span className="db-parcel-badge" style={{ background: cfg.bg, color: cfg.fg }}>
                      {cfg.label}
                    </span>
                    <div className="db-parcel-info">
                      <span className="db-parcel-tracking">{p.trackingNumber}</span>
                      <span className="db-parcel-meta">{p.carrier} · Room {p.unitNumber}</span>
                    </div>
                    <span className="db-parcel-date">{formatShortDate(p.arrivedAt)}</span>
                  </li>
                );
              })}
            </ul>
          )}
        </section>

        {/* Right column */}
        <div className="db-right-col">

          {/* Today's Bookings */}
          <section className="db-panel">
            <div className="db-panel-header">
              <h2 className="db-panel-title">Today's Bookings</h2>
              <button className="db-panel-link" onClick={() => navigate('/facilities')}>
                View all <FaArrowRight />
              </button>
            </div>

            {loading ? (
              <div className="db-list-skeleton">
                {Array.from({ length: 3 }).map((_, i) => <div key={i} className="db-skeleton db-skeleton-row" />)}
              </div>
            ) : data.todayBookings.length === 0 ? (
              <p className="db-empty">No bookings today</p>
            ) : (
              <ul className="db-booking-list">
                {data.todayBookings.slice(0, 5).map((b) => (
                  <li key={b.id} className="db-booking-row">
                    <div className="db-booking-time">
                      <span>{formatTime(b.startTime)}</span>
                      <span className="db-booking-time-end">{formatTime(b.endTime)}</span>
                    </div>
                    <div className="db-booking-info">
                      <span className="db-booking-facility">{b.facility?.name ?? '—'}</span>
                      <span className="db-booking-meta">{b.pax} pax · {b.bookingCode}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </section>

          {/* Recent Announcements */}
          <section className="db-panel">
            <div className="db-panel-header">
              <h2 className="db-panel-title">Recent Announcements</h2>
              <button className="db-panel-link" onClick={() => navigate('/announcements')}>
                View all <FaArrowRight />
              </button>
            </div>

            {loading ? (
              <div className="db-list-skeleton">
                {Array.from({ length: 3 }).map((_, i) => <div key={i} className="db-skeleton db-skeleton-row" />)}
              </div>
            ) : data.announcements.length === 0 ? (
              <p className="db-empty">No announcements</p>
            ) : (
              <ul className="db-ann-list">
                {data.announcements.map((a) => (
                  <li key={a.id} className="db-ann-row">
                    <FaBullhorn className="db-ann-icon" />
                    <div className="db-ann-info">
                      <span className="db-ann-title">{a.title}</span>
                      <span className="db-ann-date">{formatShortDate(a.publishedAt ?? a.createdAt)}</span>
                    </div>
                  </li>
                ))}
              </ul>
            )}
          </section>

        </div>
      </div>
    </div>
  );
}
