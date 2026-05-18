import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { format } from 'date-fns';
import { th } from 'date-fns/locale';
import {
  FaPlus, FaSearch, FaBullhorn, FaEye, FaEdit,
  FaTrash, FaRocket, FaArchive, FaEllipsisV, FaBell, FaBellSlash,
} from 'react-icons/fa';
import { HiOutlineSparkles } from 'react-icons/hi2';
import { announcementApi } from '../api/announcements';
import PreviewModal from '../components/PreviewModal';
import './AnnouncementList.css';

const CATEGORY_LABEL = {
  GENERAL: 'ทั่วไป', MAINTENANCE: 'ซ่อมบำรุง',
  EVENT: 'กิจกรรม', FINANCE: 'การเงิน', URGENT: 'เร่งด่วน',
};
const CATEGORY_COLOR = {
  GENERAL: '#8e7f7d', MAINTENANCE: '#f59e0b',
  EVENT: '#3b82f6',   FINANCE: '#10b981', URGENT: '#ff6b6b',
};
const STATUS_LABEL  = { DRAFT: 'ร่าง', SCHEDULED: 'ตั้งเวลา', PUBLISHED: 'เผยแพร่แล้ว', ARCHIVED: 'เก็บถาวร' };
const STATUS_CLASS  = { DRAFT: 'badge--draft', SCHEDULED: 'badge--scheduled', PUBLISHED: 'badge--published', ARCHIVED: 'badge--archived' };

const fmt = (d) => { try { return format(new Date(d), 'd MMM yy', { locale: th }); } catch { return '—'; } };
const LIMIT = 10;

export default function AnnouncementList() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [pagination, setPagination] = useState({ total: 0, page: 1, totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [preview, setPreview] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');
  const [page, setPage] = useState(1);
  const [openMenu, setOpenMenu] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await announcementApi.list({
        search: search || undefined,
        status: statusFilter || undefined,
        category: categoryFilter || undefined,
        page, limit: LIMIT,
      });
      setData(res.data);
      setPagination(res.pagination);
    } catch { /* handle silently */ }
    finally { setLoading(false); }
  }, [search, statusFilter, categoryFilter, page]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    await announcementApi.delete(deleteTarget.id).catch(() => {});
    setDeleteTarget(null);
    fetchData();
  };

  const handlePublish = async (id) => {
    await announcementApi.publish(id, []).catch(() => {});
    fetchData();
  };

  const handleArchive = async (id) => {
    await announcementApi.changeStatus(id, 'ARCHIVED').catch(() => {});
    fetchData();
  };

  const clearFilters = () => { setSearch(''); setStatusFilter(''); setCategoryFilter(''); setPage(1); };

  return (
    <div className="ann-page">
      {/* Page Header */}
      <header className="ann-header">
        <div>
          <h1 className="ann-title">
            Announcements <HiOutlineSparkles className="ann-title-spark" />
          </h1>
          <p className="ann-subtitle">จัดการประกาศสำหรับลูกบ้านทั้งหมด</p>
        </div>
        <button className="btn-primary" onClick={() => navigate('/announcements/new')}>
          <FaPlus /> สร้างประกาศใหม่
        </button>
      </header>

      {/* Filters */}
      <div className="ann-filter-bar">
        <div className="filter-search-box">
          <FaSearch className="filter-search-icon" />
          <input
            type="text"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(1); }}
            placeholder="ค้นหาหัวข้อประกาศ..."
            className="filter-input"
          />
        </div>

        <select value={statusFilter} onChange={(e) => { setStatusFilter(e.target.value); setPage(1); }} className="filter-select">
          <option value="">ทุกสถานะ</option>
          {Object.entries(STATUS_LABEL).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>

        <select value={categoryFilter} onChange={(e) => { setCategoryFilter(e.target.value); setPage(1); }} className="filter-select">
          <option value="">ทุกประเภท</option>
          {Object.entries(CATEGORY_LABEL).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>

        {(search || statusFilter || categoryFilter) && (
          <button className="filter-clear" onClick={clearFilters}>ล้างตัวกรอง</button>
        )}
      </div>

      {/* Table Card */}
      <div className="ann-card">
        {loading ? (
          <div className="ann-loading">
            <div className="ann-spinner" />
            <p>กำลังโหลดข้อมูล...</p>
          </div>
        ) : data.length === 0 ? (
          <div className="ann-empty">
            <FaBullhorn className="ann-empty-icon" />
            <p>ไม่พบรายการประกาศ</p>
          </div>
        ) : (
          <table className="ann-table">
            <thead>
              <tr>
                <th>หัวข้อ</th>
                <th>ประเภท</th>
                <th>สถานะ</th>
                <th>วันที่มีผล</th>
                <th>แจ้งเตือน</th>
                <th>สร้างเมื่อ</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {data.map((item) => (
                <tr key={item.id} className="ann-row">
                  <td>
                    <span className="row-title">{item.title}</span>
                    {item.attachments?.length > 0 && (
                      <span className="row-attach">📎 {item.attachments.length} ไฟล์</span>
                    )}
                  </td>
                  <td>
                    <span
                      className="badge badge--category"
                      style={{ background: CATEGORY_COLOR[item.category] + '22', color: CATEGORY_COLOR[item.category] }}
                    >
                      {CATEGORY_LABEL[item.category]}
                    </span>
                  </td>
                  <td>
                    <span className={`badge ${STATUS_CLASS[item.status] || ''}`}>
                      {STATUS_LABEL[item.status]}
                    </span>
                  </td>
                  <td className="row-date">{fmt(item.effectiveDate)}</td>
                  <td>
                    {item.notifSent
                      ? <span className="notif-sent"><FaBell /> ส่งแล้ว</span>
                      : <span className="notif-no"><FaBellSlash /></span>}
                  </td>
                  <td className="row-date">{fmt(item.createdAt)}</td>
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
                            <button onClick={() => { setPreview(item); setOpenMenu(null); }}><FaEye /> ดูตัวอย่าง</button>
                            <button onClick={() => { navigate(`/announcements/${item.id}/edit`); setOpenMenu(null); }}><FaEdit /> แก้ไข</button>
                            {item.status === 'DRAFT' && (
                              <button className="action-publish" onClick={() => { handlePublish(item.id); setOpenMenu(null); }}><FaRocket /> เผยแพร่</button>
                            )}
                            {item.status === 'PUBLISHED' && (
                              <button onClick={() => { handleArchive(item.id); setOpenMenu(null); }}><FaArchive /> เก็บถาวร</button>
                            )}
                            <div className="action-divider" />
                            <button className="action-delete" onClick={() => { setDeleteTarget(item); setOpenMenu(null); }}><FaTrash /> ลบ</button>
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

      {/* Pagination */}
      {pagination.totalPages > 1 && (
        <div className="ann-pagination">
          <span className="pagination-info">
            แสดง {(page - 1) * LIMIT + 1}–{Math.min(page * LIMIT, pagination.total)} จาก {pagination.total} รายการ
          </span>
          <div className="pagination-btns">
            <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="pagination-btn">← ก่อนหน้า</button>
            <span className="pagination-current">หน้า {page} / {pagination.totalPages}</span>
            <button disabled={page === pagination.totalPages} onClick={() => setPage(p => p + 1)} className="pagination-btn">ถัดไป →</button>
          </div>
        </div>
      )}

      {/* Preview Modal */}
      {preview && <PreviewModal announcement={preview} onClose={() => setPreview(null)} />}

      {/* Delete Confirm */}
      {deleteTarget && (
        <div className="ann-dialog-overlay" onClick={() => setDeleteTarget(null)}>
          <div className="ann-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="dialog-icon-wrap">
              <FaTrash className="dialog-icon" />
            </div>
            <h3 className="dialog-title">ลบประกาศ</h3>
            <p className="dialog-sub">ไม่สามารถกู้คืนได้หลังจากลบ</p>
            <div className="dialog-target">"{deleteTarget.title}"</div>
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
