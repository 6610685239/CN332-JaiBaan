import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { th } from 'date-fns/locale';
import {
  FaPlus, FaSearch, FaBox, FaEllipsisV, FaTrash, FaUndo, FaImage, FaEdit,
} from 'react-icons/fa';
import { parcelApi } from '../api/parcels';
import './ParcelList.css';

const STATUS_LABEL = { ARRIVED: 'รอรับ', PICKED_UP: 'รับแล้ว', RETURNED: 'คืนแล้ว' };
const STATUS_CLASS = { ARRIVED: 'badge--arrived', PICKED_UP: 'badge--pickedup', RETURNED: 'badge--returned' };

const LIMIT = 10;
const fmt = (d) => { try { return format(new Date(d), 'd MMM yy', { locale: th }); } catch { return '—'; } };

export default function ParcelList() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [pagination, setPagination] = useState({ total: 0, page: 1, totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [page, setPage] = useState(1);
  const [openMenu, setOpenMenu] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [photoPreview, setPhotoPreview] = useState(null);
  const [editStatusTarget, setEditStatusTarget] = useState(null);
  const [editStatusValue, setEditStatusValue] = useState('');

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await parcelApi.list({
        search: search || undefined,
        status: statusFilter || undefined,
        page,
        limit: LIMIT,
      });
      setData(res.data);
      setPagination(res.pagination);
    } catch { /* silent */ }
    finally { setLoading(false); }
  }, [search, statusFilter, page]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleReturn = async (id) => {
    await parcelApi.return(id).catch(() => {});
    fetchData();
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
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    await parcelApi.delete(deleteTarget.id).catch(() => {});
    setDeleteTarget(null);
    fetchData();
  };

  const clearFilters = () => { setSearch(''); setStatusFilter(''); setPage(1); };

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
        {(search || statusFilter) && (
          <button className="filter-clear" onClick={clearFilters}>ล้างตัวกรอง</button>
        )}
      </div>

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
                <tr key={item.id} className="parcel-row">
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
    </div>
  );
}
