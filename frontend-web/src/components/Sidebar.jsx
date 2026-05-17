import React from 'react';
import { NavLink } from 'react-router-dom';
import logoImg from '../assets/logo.png';
import {
  FaChartPie, FaBox, FaSignOutAlt, FaBullhorn, FaBuilding, FaWallet, FaHome,
} from 'react-icons/fa';
import './Sidebar.css';

const menuItems = [
  { to: '/home',           label: 'Homepage',      icon: <FaHome /> },
  { to: '/dashboard',      label: 'Dashboard',    icon: <FaChartPie /> },
  { to: '/parcels',        label: 'Parcels',      icon: <FaBox /> },
  { to: '/announcements',  label: 'Announcements', icon: <FaBullhorn /> },
  { to: '/facilities',     label: 'Facilities',   icon: <FaBuilding /> },
  { to: '/financial',      label: 'Financial',    icon: <FaWallet /> },
];

const Sidebar = ({ user, onLogout }) => {
  return (
    <aside className="jaibaan-sidebar">
      <div className="sidebar-brand">
        <NavLink to="/home" className="brand-icon">
          <img src={logoImg} alt="JaiBaan Logo" className="sidebar-logo-img" />
        </NavLink>
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
