const express = require('express');
const cors = require('cors');
const path = require('path')
const app = express();
const port = 3000;

// 1. ตั้งค่า CORS แบบพื้นฐานที่สุด (ปลอดภัยและไม่พังแน่นอน)
app.use(cors()); 
app.use(express.json());

// 2. เพิ่มตัวเช็ค (Logger) ว่ามีใครยิง API เข้ามาไหม
app.use((req, res, next) => {
  console.log(`[REQUEST] ${req.method} ${req.originalUrl}`);
  next();
});

// 3. Routes
const authRoutes = require('./src/routes/authRoutes');
const dashboardRoutes = require('./src/routes/dashboardRoutes');
const announcementRoutes = require('./src/routes/announcements')

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/announcements', announcementRoutes)
 
// Health check
app.get('/health', (req, res) => res.json({ status: 'ok', timestamp: new Date() }))
 
// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  })
})


app.get('/', (req, res) => {
  res.send('JaiBaan Backend is Running! 🚀');
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});