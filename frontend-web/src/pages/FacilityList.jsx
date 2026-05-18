import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaPlus, FaEdit, FaTrash, FaBuilding, FaSearch, FaClock, FaUsers } from 'react-icons/fa';
import { HiOutlineSparkles } from 'react-icons/hi2';
import { facilityApi } from '../api/facilities';
import './FacilityList.css';

export default function FacilityList() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [deleteTarget, setDeleteTarget] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const res = await facilityApi.list();
      setData(res);
    } catch { /* handle silently */ }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    await facilityApi.delete(deleteTarget.id).catch(() => {});
    setDeleteTarget(null);
    fetchData();
  };

  const filtered = data.filter((f) =>
    f.name.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="fac-page">
      <header className="fac-header">
        <div>
          <h1 className="fac-title">
            Facilities <HiOutlineSparkles className="fac-title-spark" />
          </h1>
          <p className="fac-subtitle">จัดการพื้นที่ส่วนกลางในโครงการ</p>
        </div>
        <button className="btn-primary" onClick={() => navigate('/facilities/new')}>
          <FaPlus /> เพิ่มสถานที่ใหม่
        </button>
      </header>

      <div className="fac-filter-bar">
        <div className="filter-search-box">
          <FaSearch className="filter-search-icon" />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ค้นหาชื่อสถานที่..."
            className="filter-input"
          />
        </div>
        <span className="fac-count">{filtered.length} สถานที่</span>
      </div>

      {loading ? (
        <div className="fac-loading">
          <div className="fac-spinner" />
          <p>กำลังโหลดข้อมูล...</p>
        </div>
      ) : filtered.length === 0 ? (
        <div className="fac-empty">
          <div className="fac-empty-icon-wrap"><FaBuilding /></div>
          <p className="fac-empty-title">ไม่พบสถานที่</p>
          <p className="fac-empty-sub">ลองเปลี่ยนคำค้นหา หรือเพิ่มสถานที่ใหม่</p>
        </div>
      ) : (
        <div className="fac-grid">
          {filtered.map((item) => (
            <div key={item.id} className="fac-card">
              <div className="fac-card-img-wrap">
                {item.imageUrl ? (
                  <img src={item.imageUrl} alt={item.name} className="fac-card-img" />
                ) : (
                  <div className="fac-card-img-placeholder">
                    <FaBuilding />
                  </div>
                )}
                <div className="fac-card-actions">
                  <button
                    className="fac-action-btn fac-action-edit"
                    onClick={() => navigate(`/facilities/${item.id}/edit`)}
                    title="แก้ไข"
                  >
                    <FaEdit />
                  </button>
                  <button
                    className="fac-action-btn fac-action-delete"
                    onClick={() => setDeleteTarget(item)}
                    title="ลบ"
                  >
                    <FaTrash />
                  </button>
                </div>
              </div>

              <div className="fac-card-body">
                <h3 className="fac-card-name">{item.name}</h3>
                {item.description && (
                  <p className="fac-card-desc">{item.description}</p>
                )}
                <div className="fac-card-meta">
                  {(item.capacityMin || item.capacityMax) && (
                    <span className="fac-badge fac-badge-capacity">
                      <FaUsers /> {item.capacityMin ?? '—'}–{item.capacityMax ?? '—'} คน
                    </span>
                  )}
                  {item.openTime && item.closeTime && (
                    <span className="fac-badge fac-badge-time">
                      <FaClock /> {item.openTime} – {item.closeTime}
                    </span>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {deleteTarget && (
        <div className="fac-dialog-overlay" onClick={() => setDeleteTarget(null)}>
          <div className="fac-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="dialog-icon-wrap">
              <FaTrash className="dialog-icon" />
            </div>
            <h3 className="dialog-title">ลบสถานที่</h3>
            <p className="dialog-sub">ข้อมูลการจองที่เกี่ยวข้องอาจได้รับผลกระทบ</p>
            <div className="dialog-target">"{deleteTarget.name}"</div>
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
