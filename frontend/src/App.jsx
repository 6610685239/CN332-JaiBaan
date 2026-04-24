import React, { useState } from 'react';
import axios from 'axios';
import './App.css';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import ForgotPassword from './pages/ForgotPassword';
import logoImg from './assets/logo.png';

import { FaUser } from 'react-icons/fa';
import { LuLockKeyhole } from 'react-icons/lu';

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userData, setUserData] = useState(null);
  const [activePage, setActivePage] = useState('dashboard');
  const [showForgotPassword, setShowForgotPassword] = useState(false);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const response = await axios.post('/api/auth/juristic/login', { username, password });
      setUserData(response.data.user);
      setIsLoggedIn(true);
    } catch (err) {
      console.error('Login Error:', err);
      setError(err.response?.data?.error || 'Login Failed. ตรวจสอบรหัสผ่านหรือสถานะ Server');
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setUserData(null);
    setUsername('');
    setPassword('');
  };

  if (isLoggedIn) {
    return (
      <div className="main-layout">
        <Sidebar activePage={activePage} setActivePage={setActivePage} onLogout={handleLogout} />
        <div className="content-area">
          {activePage === 'dashboard' && <Dashboard user={userData} />}
        </div>
      </div>
    );
  }

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
              <button
                type="button"
                className="btn-link"
                onClick={() => setShowForgotPassword(true)}
              >
                ลืมรหัสผ่าน?
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
