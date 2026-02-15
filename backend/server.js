const express = require('express');
const cors = require('cors');
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

app.use('/api/auth', authRoutes);
app.use('/api/dashboard', dashboardRoutes);

app.get('/', (req, res) => {
  res.send('JaiBaan Backend is Running! 🚀');
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});