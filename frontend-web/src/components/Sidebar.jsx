import React from 'react';
import { NavLink } from 'react-router-dom';
import logoImg from '../assets/logo.png';
import {
  FaChartPie, FaUsers, FaBox, FaWrench,
  FaClipboardList, FaSignOutAlt, FaBullhorn,
} from 'react-icons/fa';
import './Sidebar.css';

const menuItems = [
  { to: '/dashboard',      label: 'Dashboard',    icon: <FaChartPie /> },
  { to: '/residents',      label: 'Residents',    icon: <FaUsers /> },
  { to: '/parcels',        label: 'Parcels',      icon: <FaBox /> },
  { to: '/repairs',        label: 'Repairs',      icon: <FaWrench /> },
  { to: '/records',        label: 'Records',      icon: <FaClipboardList /> },
  { to: '/announcements',  label: 'Announcements',icon: <FaBullhorn /> },
];

const Sidebar = ({ user, onLogout }) => {
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
            <li key={item.to}>
              <NavLink
                to={item.to}
                className={({ isActive }) =>
                  `menu-item${isActive ? ' active' : ''}`
                }
              >
                <span className="menu-icon">{item.icon}</span>
                <span className="menu-label">{item.label}</span>
              </NavLink>
            </li>
          ))}
        </ul>
      </nav>

      <div className="sidebar-footer">
        <button className="logout-card" onClick={onLogout}>
          <div className="logout-icon-wrapper">
            <FaSignOutAlt />
          </div>
          <div className="logout-text">
            <span className="logout-title">Logout</span>
            <span className="logout-subtitle">{user?.username || 'Good Bye'}</span>
          </div>
        </button>
      </div>
    </aside>
  );
};

export default Sidebar;
