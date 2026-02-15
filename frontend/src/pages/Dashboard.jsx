import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Dashboard.css';

// นำเข้าไอคอนที่จำเป็น
import { FaHouseUser, FaBoxOpen, FaTools, FaSpinner } from "react-icons/fa";
import { HiOutlineSparkles } from "react-icons/hi2";

const Dashboard = ({ user }) => {
  // 1. State สำหรับเก็บข้อมูลสถิติ
  const [stats, setStats] = useState({
    residentCount: 0,
    parcelCount: 0,
    repairCount: 0
  });

  // 2. State สำหรับสถานะการโหลด
  const [loading, setLoading] = useState(true);

  // 3. ดึงข้อมูลจาก API เมื่อหน้าจอถูกเปิดขึ้นมา
  useEffect(() => {
    const fetchData = async () => {
      try {
        // ใช้ URL ของคุณตามที่ยืนยันว่าใช้งานได้
        const response = await axios.get('https://musical-meme-7qwgvr7q6wqh7qr-3000.app.github.dev/api/dashboard/stats');

        // อัปเดตข้อมูล (ข้อมูลจริงคือ residentCount ส่วนที่เหลือคือ 0 ตามที่เราทำใน Backend)
        setStats(response.data);
      } catch (error) {
        console.error("Dashboard Error:", error);
      } finally {
        // หยุดการโหลดไม่ว่าจะสำเร็จหรือไม่
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  // 4. ตั้งค่าข้อมูลการ์ด (สีและไอคอนตามดีไซน์ที่คุณต้องการ)
  const cards = [
    {
      label: "Total Resident",
      value: stats.residentCount,
      color: "#ff8a75", // สีชมพูอมส้ม
      icon: <FaHouseUser />
    },
    {
      label: "Uncollected Parcels",
      value: stats.parcelCount,
      color: "#ff6b6b", // สีชมพูแดง
      icon: <FaBoxOpen />
    },
    {
      label: "Pending repairs",
      value: stats.repairCount,
      color: "#ffa502", // สีส้มเหลือง
      icon: <FaTools />
    }
  ];

  return (
    <div className="dashboard-page-container">
      <main className="dashboard-main-content">

        {/* --- ส่วนหัวข้อต้อนรับ --- */}
        <header className="dashboard-header-section">
          <h1>
            Hello, {user?.username || 'admin_test'}
            <HiOutlineSparkles className="greeting-sparkle" />
          </h1>
          <p className="dashboard-subtitle">Dashboard Overview</p>
        </header>

        {/* --- ส่วนแสดงผลการ์ด --- */}
        <section className="dashboard-stats-grid">
          {loading ? (
            // แสดง Spinner ตอนกำลังโหลดข้อมูล
            <div className="dashboard-loading">
              <FaSpinner className="spin-animate" />
              <p>กำลังดึงข้อมูลจากระบบ...</p>
            </div>
          ) : (
            // แสดงการ์ดเมื่อโหลดเสร็จ
            cards.map((card, i) => (
              <div
                key={i}
                className="stat-info-card"
                style={{ borderTop: `6px solid ${card.color}` }}
              >
                <div className="stat-card-icon" style={{ color: card.color }}>
                  {card.icon}
                </div>
                <div className="stat-card-details">
                  <span className="stat-card-label">{card.label}</span>
                  <h2 className="stat-card-value" style={{ color: card.color }}>
                    {card.value.toLocaleString()}
                  </h2>
                </div>
              </div>
            ))
          )}
        </section>

      </main>
    </div>
  );
};

export default Dashboard;