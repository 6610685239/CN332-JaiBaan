// frontend/src/components/Sidebar.jsx
import React from 'react';
import logoImg from '../assets/logo.png';
import { FaChartPie, FaUsers, FaBox, FaWrench, FaClipboardList, FaSignOutAlt } from "react-icons/fa";
import './Sidebar.css';

const Sidebar = ({ activePage, setActivePage }) => {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: <FaChartPie /> },
    { id: 'residents', label: 'Residents', icon: <FaUsers /> },
    { id: 'parcels', label: 'Parcels', icon: <FaBox /> },
    { id: 'repairs', label: 'Repairs', icon: <FaWrench /> },
    { id: 'records', label: 'Records', icon: <FaClipboardList /> },
  ];

  return (
    <aside className="jaibaan-sidebar">
      <div className="sidebar-brand">
        <div className="brand-icon">
          <img src={logoImg} alt="JaiBaan Logo" className="sidebar-logo-img" />
        </div>
      </div>

      <nav className="sidebar-nav">
        <ul className="menu-list">
          {menuItems.map((item) => (
            <li 
              key={item.id} 
              // เช็คว่า id ตรงกับหน้าปัจจุบันไหม เพื่อแสดงสีชมพู (Active)
              className={`menu-item ${activePage === item.id ? 'active' : ''}`}
              // *** จุดสำคัญ: เมื่อคลิก ให้สั่งเปลี่ยนหน้า ***
              onClick={() => setActivePage(item.id)}
            >
              <span className="menu-icon">
                {item.icon}
              </span>
              <span className="menu-label">{item.label}</span>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar-footer">
        <button className="logout-card" onClick={() => window.location.reload()}>
          <div className="logout-icon-wrapper">
            <FaSignOutAlt />
          </div>
          <div className="logout-text">
            <span className="logout-title">Logout</span>
            <span className="logout-subtitle">Good Bye</span>
          </div>
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;