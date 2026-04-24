import React, { useState } from 'react';
import axios from 'axios';
import { FaUser, FaKey } from 'react-icons/fa';
import { LuLockKeyhole } from 'react-icons/lu';

// ขั้นตอน: 'request' → ขอ token | 'reset' → ตั้งรหัสใหม่ | 'done' → สำเร็จ
function ForgotPassword({ onBack }) {
  const [step, setStep] = useState('request');
  const [username, setUsername] = useState('');
  const [resetToken, setResetToken] = useState('');
  const [tokenInput, setTokenInput] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleRequestToken = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const res = await axios.post('/api/auth/forgot-password', { username });
      setResetToken(res.data.resetToken);
      setStep('reset');
    } catch (err) {
      setError(err.response?.data?.error || 'เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async (e) => {
    e.preventDefault();
    setError('');
    if (newPassword !== confirmPassword) {
      setError('รหัสผ่านทั้งสองช่องไม่ตรงกัน');
      return;
    }
    setLoading(true);
    try {
      await axios.post('/api/auth/reset-password', {
        resetToken: tokenInput || resetToken,
        newPassword
      });
      setStep('done');
    } catch (err) {
      setError(err.response?.data?.error || 'เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="jaibaan-form">
      {step === 'request' && (
        <>
          <h2>ลืมรหัสผ่าน</h2>
          <p className="form-subtitle">กรอก Username ของคุณเพื่อรับ Reset Token</p>
          {error && <p className="error-text">{error}</p>}
          <form onSubmit={handleRequestToken} style={{ display: 'contents' }}>
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
            <button type="submit" className="btn-login" disabled={loading}>
              {loading ? 'กำลังดำเนินการ...' : 'ขอ Reset Token'}
            </button>
          </form>
          <button className="btn-link" onClick={onBack}>กลับไปหน้าเข้าสู่ระบบ</button>
        </>
      )}

      {step === 'reset' && (
        <>
          <h2>ตั้งรหัสผ่านใหม่</h2>
          {error && <p className="error-text">{error}</p>}

          {resetToken && (
            <div className="token-box">
              <p className="token-label">Reset Token ของคุณ (หมดอายุใน 15 นาที):</p>
              <code className="token-value">{resetToken}</code>
              <button
                className="btn-copy"
                onClick={() => { navigator.clipboard.writeText(resetToken); }}
              >
                คัดลอก
              </button>
            </div>
          )}

          <form onSubmit={handleResetPassword} style={{ display: 'contents' }}>
            <div className="input-box">
              <FaKey />
              <input
                type="text"
                placeholder="Reset Token"
                value={tokenInput || resetToken}
                onChange={(e) => setTokenInput(e.target.value)}
                required
              />
            </div>
            <div className="input-box">
              <LuLockKeyhole />
              <input
                type="password"
                placeholder="รหัสผ่านใหม่ (อย่างน้อย 6 ตัว)"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                required
              />
            </div>
            <div className="input-box">
              <LuLockKeyhole />
              <input
                type="password"
                placeholder="ยืนยันรหัสผ่านใหม่"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
              />
            </div>
            <button type="submit" className="btn-login" disabled={loading}>
              {loading ? 'กำลังรีเซ็ต...' : 'รีเซ็ตรหัสผ่าน'}
            </button>
          </form>
          <button className="btn-link" onClick={onBack}>กลับไปหน้าเข้าสู่ระบบ</button>
        </>
      )}

      {step === 'done' && (
        <>
          <h2>สำเร็จ!</h2>
          <p className="success-text">รีเซ็ตรหัสผ่านเรียบร้อยแล้ว กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่</p>
          <button className="btn-login" onClick={onBack}>กลับไปเข้าสู่ระบบ</button>
        </>
      )}
    </div>
  );
}

export default ForgotPassword;
