import React, { useState } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import axios from 'axios';
import './App.css';

import MainLayout from './layouts/MainLayout';
import Dashboard from './pages/Dashboard';
import AnnouncementList from './pages/AnnouncementList';
import AnnouncementForm from './pages/AnnouncementForm';
import ForgotPassword from './pages/ForgotPassword';
import logoImg from './assets/logo.png';

import { FaUser } from 'react-icons/fa';
import { LuLockKeyhole } from 'react-icons/lu';

function LoginPage({ onLogin }) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showForgotPassword, setShowForgotPassword] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await axios.post('/api/auth/juristic/login', { username, password });
      // store token for api requests and notify app of logged-in user
      if (response.data.token) localStorage.setItem('token', response.data.token)
      onLogin(response.data.user);
    } catch (err) {
      setError(err.response?.data?.error || 'Login Failed. ตรวจสอบรหัสผ่านหรือสถานะ Server');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="jaibaan-bg">
      <div className="login-wrapper">
        <div className="logo-section">
          <img src={logoImg} alt="JaiBaan Logo" className="login-logo-img" />
        </div>
        <div className="form-container">
          {showForgotPassword ? (
            <ForgotPassword onBack={() => setShowForgotPassword(false)} />
          ) : (
            <form onSubmit={handleLogin} className="jaibaan-form">
              <h2>Sign In</h2>
              {error && <p className="error-text">{error}</p>}
              <div className="input-box">
                <FaUser />
                <input
                  type="text"
                  placeholder="Username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                />
              </div>
              <div className="input-box">
                <LuLockKeyhole />
                <input
                  type="password"
                  placeholder="Password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
              <button type="submit" className="btn-login" disabled={loading}>
                {loading ? 'VERIFYING...' : 'LOGIN'}
              </button>
              <button type="button" className="btn-link" onClick={() => setShowForgotPassword(true)}>
                ลืมรหัสผ่าน?
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}

function App() {
  const [userData, setUserData] = useState(null);

  const handleLogin = (user) => setUserData(user);
  const handleLogout = () => {
    localStorage.removeItem('token')
    setUserData(null)
  };

  if (!userData) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<MainLayout user={userData} onLogout={handleLogout} />}>
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route path="dashboard" element={<Dashboard user={userData} />} />
          <Route path="announcements" element={<AnnouncementList />} />
          <Route path="announcements/new" element={<AnnouncementForm />} />
          <Route path="announcements/:id/edit" element={<AnnouncementForm />} />
        </Route>
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;