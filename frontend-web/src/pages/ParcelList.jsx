import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { th } from 'date-fns/locale';
import {
  FaPlus, FaSearch, FaBox, FaEllipsisV, FaTrash, FaUndo, FaImage, FaEdit,
  FaClock, FaCheckCircle, FaExclamationTriangle, FaTruck,
} from 'react-icons/fa';
import { parcelApi } from '../api/parcels';
import './ParcelList.css';

const STATUS_LABEL = { ARRIVED: 'รอรับ', PICKED_UP: 'รับแล้ว', RETURNED: 'คืนแล้ว' };
const STATUS_CLASS = { ARRIVED: 'badge--arrived', PICKED_UP: 'badge--pickedup', RETURNED: 'badge--returned' };
const CARRIERS = ['Kerry', 'Flash', 'J&T', 'Thailand Post', 'DHL', 'Lazada', 'Shopee', 'Amazon'];

const LIMIT = 10;
const fmt = (d) => { try { return format(new Date(d), 'd MMM yy', { locale: th }); } catch { return '—'; } };

export default function ParcelList() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [pagination, setPagination] = useState({ total: 0, page: 1, totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [carrierFilter, setCarrierFilter] = useState('');
  const [page, setPage] = useState(1);
  const [openMenu, setOpenMenu] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [photoPreview, setPhotoPreview] = useState(null);
  const [editStatusTarget, setEditStatusTarget] = useState(null);
  const [editStatusValue, setEditStatusValue] = useState('');
  const [statsData, setStatsData] = useState(null);

  // Multi-select
  const [selected, setSelected] = useState(new Set());
  const [bulkAction, setBulkAction] = useState(null); // 'delete' | 'return'

  useEffect(() => {
    parcelApi.stats().then((r) => setStatsData(r.data)).catch(() => {});
  }, []);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await parcelApi.list({
        search: search || undefined,
        status: statusFilter || undefined,
        carrier: carrierFilter || undefined,
        page,
        limit: LIMIT,
      });
      setData(res.data);
      setPagination(res.pagination);
    } catch { /* silent */ }
    finally { setLoading(false); }
  }, [search, statusFilter, carrierFilter, page]);

  useEffect(() => { fetchData(); }, [fetchData]);

  // Clear selection when data changes
  useEffect(() => { setSelected(new Set()); }, [data]);

  const refreshStats = () => parcelApi.stats().then((r) => setStatsData(r.data)).catch(() => {});

  const handleReturn = async (id) => {
    await parcelApi.return(id).catch(() => {});
    fetchData();
    refreshStats();
  };

  const openEditStatus = (item) => {
    setEditStatusTarget(item);
    setEditStatusValue(item.status);
    setOpenMenu(null);
  };

  const handleUpdateStatus = async () => {
    if (!editStatusTarget) return;
    await parcelApi.updateStatus(editStatusTarget.id, editStatusValue).catch(() => {});
    setEditStatusTarget(null);
    fetchData();
    refreshStats();
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    await parcelApi.delete(deleteTarget.id).catch(() => {});
    setDeleteTarget(null);
    fetchData();
    refreshStats();
  };

  const handleBulkConfirm = async () => {
    const ids = [...selected];
    if (bulkAction === 'delete') await parcelApi.bulkDelete(ids).catch(() => {});
    if (bulkAction === 'return') await parcelApi.bulkReturn(ids).catch(() => {});
    setBulkAction(null);
    setSelected(new Set());
    fetchData();
    refreshStats();
  };

  const clearFilters = () => { setSearch(''); setStatusFilter(''); setCarrierFilter(''); setPage(1); };

  // Checkbox helpers
  const allSelected = data.length > 0 && data.every((item) => selected.has(item.id));
  const someSelected = data.some((item) => selected.has(item.id));

  const toggleAll = () => {
    if (allSelected) {
      setSelected((prev) => { const s = new Set(prev); data.forEach((item) => s.delete(item.id)); return s; });
    } else {
      setSelected((prev) => { const s = new Set(prev); data.forEach((item) => s.add(item.id)); return s; });
    }
  };

  const toggleOne = (id) => {
    setSelected((prev) => {
      const s = new Set(prev);
      s.has(id) ? s.delete(id) : s.add(id);
      return s;
    });
  };

  const selectedArrivedCount = data.filter((item) => selected.has(item.id) && item.status === 'ARRIVED').length;

  return (
    <div className="parcel-page">
      <header className="parcel-header">
        <div>
          <h1 className="parcel-title"><FaBox className="parcel-title-icon" /> Parcels</h1>
          <p className="parcel-subtitle">จัดการพัสดุและของฝากสำหรับลูกบ้าน</p>
        </div>
        <button className="btn-primary" onClick={() => navigate('/parcels/new')}>
          <FaPlus /> ลงทะเบียนพัสดุ
        </button>
      </header>

      {statsData && (
        <div className="parcel-stats-grid">
          <div className="stat-card stat-card--pending">
            <div className="stat-icon-wrap"><FaClock /></div>
            <div className="stat-body">
              <div className="stat-value">{statsData.totalPending}</div>
              <div className="stat-label">รอรับ (Pending)</div>
            </div>
          </div>

          <div className="stat-card stat-card--pickedup">
            <div className="stat-icon-wrap"><FaCheckCircle /></div>
            <div className="stat-body">
              <div className="stat-value">{statsData.pickedUpToday}</div>
              <div className="stat-label">รับแล้ววันนี้</div>
            </div>
          </div>

          <div className={`stat-card ${statsData.overdue > 0 ? 'stat-card--overdue' : 'stat-card--ok'}`}>
            <div className="stat-icon-wrap"><FaExclamationTriangle /></div>
            <div className="stat-body">
              <div className="stat-value">{statsData.overdue}</div>
              <div className="stat-label">ค้างเกิน 3 วัน</div>
            </div>
          </div>

          <div className="stat-card stat-card--carrier">
            <div className="stat-icon-wrap"><FaTruck /></div>
            <div className="stat-body">
              <div className="stat-label" style={{ marginBottom: 6 }}>ขนส่งที่รอรับ</div>
              {statsData.carrierDistribution.length === 0 ? (
                <div className="stat-carrier-empty">ไม่มีข้อมูล</div>
              ) : (
                <div className="stat-carrier-list">
                  {statsData.carrierDistribution.map((c) => (
                    <div key={c.carrier} className="stat-carrier-row">
                      <span className="stat-carrier-name">{c.carrier}</span>
                      <span className="stat-carrier-count">{c.count}</span>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      <div className="parcel-filter-bar">
        <div className="filter-search-box">
          <FaSearch className="filter-search-icon" />
          <input
            type="text"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            placeholder="ค้นหา tracking / ผู้ส่ง / ห้อง..."
            className="filter-input"
          />
        </div>
        <select
          value={statusFilter}
          onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }}
          className="filter-select"
        >
          <option value="">ทุกสถานะ</option>
          {Object.entries(STATUS_LABEL).map(([k, v]) => (
            <option key={k} value={k}>{v}</option>
          ))}
        </select>
        <select
          value={carrierFilter}
          onChange={(e) => { setCarrierFilter(e.target.value); setPage(1); }}
          className="filter-select"
        >
          <option value="">ทุกขนส่ง</option>
          {CARRIERS.map((c) => <option key={c} value={c}>{c}</option>)}
        </select>
        {(search || statusFilter || carrierFilter) && (
          <button className="filter-clear" onClick={clearFilters}>ล้างตัวกรอง</button>
        )}
      </div>

      {selected.size > 0 && (
        <div className="bulk-bar">
          <span className="bulk-bar-info">เลือก {selected.size} รายการ</span>
          <div className="bulk-bar-actions">
            {selectedArrivedCount > 0 && (
              <button className="bulk-btn bulk-btn--return" onClick={() => setBulkAction('return')}>
                <FaUndo /> คืนพัสดุ ({selectedArrivedCount})
              </button>
            )}
            <button className="bulk-btn bulk-btn--delete" onClick={() => setBulkAction('delete')}>
              <FaTrash /> ลบ ({selected.size})
            </button>
            <button className="bulk-btn bulk-btn--cancel" onClick={() => setSelected(new Set())}>
              ยกเลิก
            </button>
          </div>
        </div>
      )}

      <div className="parcel-card">
        {loading ? (
          <div className="parcel-loading">
            <div className="parcel-spinner" />
            <p>กำลังโหลดข้อมูล...</p>
          </div>
        ) : data.length === 0 ? (
          <div className="parcel-empty">
            <FaBox className="parcel-empty-icon" />
            <p>ไม่พบรายการพัสดุ</p>
          </div>
        ) : (
          <table className="parcel-table">
            <thead>
              <tr>
                <th className="col-check">
                  <input
                    type="checkbox"
                    className="parcel-checkbox"
                    checked={allSelected}
                    ref={(el) => { if (el) el.indeterminate = someSelected && !allSelected; }}
                    onChange={toggleAll}
                  />
                </th>
                <th>รูป</th>
                <th>Tracking No.</th>
                <th>ผู้ส่ง</th>
                <th>ห้อง</th>
                <th>ที่เก็บ</th>
                <th>สถานะ</th>
                <th>วันที่มาถึง</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {data.map((item) => (
                <tr
                  key={item.id}
                  className={`parcel-row ${selected.has(item.id) ? 'parcel-row--selected' : ''}`}
                >
                  <td className="col-check">
                    <input
                      type="checkbox"
                      className="parcel-checkbox"
                      checked={selected.has(item.id)}
                      onChange={() => toggleOne(item.id)}
                    />
                  </td>
                  <td>
                    {item.photoUrl ? (
                      <img
                        src={item.photoUrl}
                        alt="parcel"
                        className="parcel-thumb"
                        onClick={() => setPhotoPreview(item.photoUrl)}
                        onError={(e) => { e.target.style.display = 'none'; }}
                      />
                    ) : (
                      <div className="parcel-no-photo"><FaImage /></div>
                    )}
                  </td>
                  <td><span className="parcel-tracking">{item.trackingNumber}</span></td>
                  <td>{item.carrier}</td>
                  <td><span className="parcel-unit">{item.unitNumber}</span></td>
                  <td className="parcel-location">{item.storageLocation || '—'}</td>
                  <td>
                    <span className={`badge ${STATUS_CLASS[item.status] || ''}`}>
                      {STATUS_LABEL[item.status]}
                    </span>
                  </td>
                  <td className="parcel-date">{fmt(item.arrivedAt)}</td>
                  <td>
                    <div className="action-menu-wrap">
                      <button
                        className="action-trigger"
                        onClick={() => setOpenMenu(openMenu === item.id ? null : item.id)}
                      >
                        <FaEllipsisV />
                      </button>
                      {openMenu === item.id && (
                        <>
                          <div className="action-backdrop" onClick={() => setOpenMenu(null)} />
                          <div className="action-dropdown">
                            <button onClick={() => openEditStatus(item)}>
                              <FaEdit /> แก้ไขสถานะ
                            </button>
                            {item.status === 'ARRIVED' && (
                              <button
                                className="action-return"
                                onClick={() => { handleReturn(item.id); setOpenMenu(null); }}
                              >
                                <FaUndo /> คืนพัสดุ
                              </button>
                            )}
                            <div className="action-divider" />
                            <button
                              className="action-delete"
                              onClick={() => { setDeleteTarget(item); setOpenMenu(null); }}
                            >
                              <FaTrash /> ลบ
                            </button>
                          </div>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {pagination.totalPages > 1 && (
        <div className="parcel-pagination">
          <span className="pagination-info">
            แสดง {(page - 1) * LIMIT + 1}–{Math.min(page * LIMIT, pagination.total)} จาก {pagination.total} รายการ
          </span>
          <div className="pagination-btns">
            <button disabled={page === 1} onClick={() => setPage((p) => p - 1)} className="pagination-btn">← ก่อนหน้า</button>
            <span className="pagination-current">หน้า {page} / {pagination.totalPages}</span>
            <button disabled={page === pagination.totalPages} onClick={() => setPage((p) => p + 1)} className="pagination-btn">ถัดไป →</button>
          </div>
        </div>
      )}

      {photoPreview && (
        <div className="photo-overlay" onClick={() => setPhotoPreview(null)}>
          <img src={photoPreview} alt="parcel preview" className="photo-full" />
        </div>
      )}

      {editStatusTarget && (
        <div className="parcel-dialog-overlay" onClick={() => setEditStatusTarget(null)}>
          <div className="parcel-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="dialog-icon-wrap" style={{ background: '#f3e8ff' }}>
              <FaEdit style={{ fontSize: '1.4rem', color: '#7c3aed' }} />
            </div>
            <h3 className="dialog-title">แก้ไขสถานะพัสดุ</h3>
            <p className="dialog-sub">{editStatusTarget.trackingNumber}</p>
            <select
              value={editStatusValue}
              onChange={(e) => setEditStatusValue(e.target.value)}
              className="status-edit-select"
            >
              {Object.entries(STATUS_LABEL).map(([k, v]) => (
                <option key={k} value={k}>{v}</option>
              ))}
            </select>
            <div className="dialog-actions" style={{ marginTop: '20px' }}>
              <button className="btn-cancel" onClick={() => setEditStatusTarget(null)}>ยกเลิก</button>
              <button
                className="btn-save-status"
                onClick={handleUpdateStatus}
                disabled={editStatusValue === editStatusTarget.status}
              >
                บันทึก
              </button>
            </div>
          </div>
        </div>
      )}

      {deleteTarget && (
        <div className="parcel-dialog-overlay" onClick={() => setDeleteTarget(null)}>
          <div className="parcel-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="dialog-icon-wrap">
              <FaTrash className="dialog-icon" />
            </div>
            <h3 className="dialog-title">ลบพัสดุ</h3>
            <p className="dialog-sub">ไม่สามารถกู้คืนได้หลังจากลบ</p>
            <div className="dialog-target">{deleteTarget.trackingNumber}</div>
            <div className="dialog-actions">
              <button className="btn-cancel" onClick={() => setDeleteTarget(null)}>ยกเลิก</button>
              <button className="btn-danger" onClick={handleDelete}>ลบ</button>
            </div>
          </div>
        </div>
      )}

      {bulkAction && (
        <div className="parcel-dialog-overlay" onClick={() => setBulkAction(null)}>
          <div className="parcel-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="dialog-icon-wrap" style={bulkAction === 'return' ? { background: '#f3e8ff' } : {}}>
              {bulkAction === 'return'
                ? <FaUndo style={{ fontSize: '1.4rem', color: '#7c3aed' }} />
                : <FaTrash className="dialog-icon" />}
            </div>
            <h3 className="dialog-title">
              {bulkAction === 'return' ? 'คืนพัสดุหลายชิ้น' : 'ลบพัสดุหลายชิ้น'}
            </h3>
            <p className="dialog-sub">
              {bulkAction === 'return'
                ? `คืนพัสดุสถานะ "รอรับ" จำนวน ${selectedArrivedCount} รายการ`
                : `ลบพัสดุที่เลือกทั้งหมด ${selected.size} รายการ — ไม่สามารถกู้คืนได้`}
            </p>
            <div className="dialog-actions">
              <button className="btn-cancel" onClick={() => setBulkAction(null)}>ยกเลิก</button>
              {bulkAction === 'return'
                ? <button className="btn-save-status" onClick={handleBulkConfirm}>ยืนยัน</button>
                : <button className="btn-danger" onClick={handleBulkConfirm}>ลบ</button>}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
