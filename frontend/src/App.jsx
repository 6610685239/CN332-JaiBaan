import React, { useState } from 'react';
import axios from 'axios';
import './App.css';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import logoImg from './assets/logo.png';

// Icons
import { FaUser } from "react-icons/fa";
import { LuLockKeyhole } from "react-icons/lu";

function App() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userData, setUserData] = useState(null);
  const [activePage, setActivePage] = useState('dashboard');

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    
    try {
      // ใช้ URL ที่คุณยืนยันว่าใช้งานได้
      const response = await axios.post('https://musical-meme-7qwgvr7q6wqh7qr-3000.app.github.dev/api/auth/juristic/login', { 
        username, 
        password 
      });
      
      setUserData(response.data.user);
      setIsLoggedIn(true);
    } catch (err) {
      console.error("Login Error:", err);
      setError(err.response?.data?.error || "Login Failed. ตรวจสอบรหัสผ่านหรือสถานะ Server");
    } finally {
      setLoading(false);
    }
  };

  if (isLoggedIn) {
    return (
      <div className="main-layout" style={{ display: 'flex', width: '100vw', height: '100vh' }}>
        <Sidebar activePage={activePage} setActivePage={setActivePage} />
        <div className="content-area" style={{ flex: 1, overflowY: 'auto', backgroundColor: '#fff5f3' }}>
          {activePage === 'dashboard' && <Dashboard user={userData} />}
          {/* หน้า Residents ถูกถอดออกชั่วคราวตามสั่ง */}
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
          <form onSubmit={handleLogin} className="jaibaan-form">
            <h2>Sign In</h2>
            {error && <p className="error-text">{error}</p>}
            <div className="input-box">
              <FaUser />
              <input type="text" placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} required />
            </div>
            <div className="input-box">
              <LuLockKeyhole />
              <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required />
            </div>
            <button type="submit" className="btn-login" disabled={loading}>
              {loading ? "VERIFYING..." : "LOGIN"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}

export default App;