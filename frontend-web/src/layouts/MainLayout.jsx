import React from 'react';
import { Outlet } from 'react-router-dom';
import Sidebar from '../components/Sidebar';

const MainLayout = ({ user, onLogout }) => {
  return (
    <div className="main-layout">
      <Sidebar user={user} onLogout={onLogout} />
      <div className="content-area">
        <Outlet />
      </div>
    </div>
  );
};

export default MainLayout;
