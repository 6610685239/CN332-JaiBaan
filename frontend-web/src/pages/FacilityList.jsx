import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { FaPlus, FaEdit, FaTrash, FaEllipsisV, FaBuilding, FaSearch } from 'react-icons/fa';
import { HiOutlineSparkles } from 'react-icons/hi2';
import { facilityApi } from '../api/facilities';
import './FacilityList.css';

export default function FacilityList() {
  const navigate = useNavigate();
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [openMenu, setOpenMenu] = useState(null);
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
      </div>

      <div className="fac-card">
        {loading ? (
          <div className="fac-loading">
            <div className="fac-spinner" />
            <p>กำลังโหลดข้อมูล...</p>
          </div>
        ) : filtered.length === 0 ? (
          <div className="fac-empty">
            <FaBuilding className="fac-empty-icon" />
            <p>ไม่พบสถานที่</p>
          </div>
        ) : (
          <table className="fac-table">
            <thead>
              <tr>
                <th>สถานที่</th>
                <th>รายละเอียด</th>
                <th>ความจุ</th>
                <th>เวลาเปิด-ปิด</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((item) => (
                <tr key={item.id} className="fac-row">
                  <td>
                    <div className="fac-name-cell">
                      {item.imageUrl ? (
                        <img src={item.imageUrl} alt={item.name} className="fac-thumb" />
                      ) : (
                        <div className="fac-thumb-placeholder"><FaBuilding /></div>
                      )}
                      <span className="fac-name">{item.name}</span>
                    </div>
                  </td>
                  <td>
                    <span className="fac-desc">{item.description || '—'}</span>
                  </td>
                  <td>
                    {item.capacityMin || item.capacityMax ? (
                      <span className="fac-capacity">
                        {item.capacityMin ?? '—'} – {item.capacityMax ?? '—'} คน
                      </span>
                    ) : '—'}
                  </td>
                  <td>
                    {item.openTime && item.closeTime ? (
                      <span className="fac-time">{item.openTime} – {item.closeTime}</span>
                    ) : '—'}
                  </td>
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
                            <button onClick={() => { navigate(`/facilities/${item.id}/edit`); setOpenMenu(null); }}>
                              <FaEdit /> แก้ไข
                            </button>
                            <div className="action-divider" />
                            <button className="action-delete" onClick={() => { setDeleteTarget(item); setOpenMenu(null); }}>
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
