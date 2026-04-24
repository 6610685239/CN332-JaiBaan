require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');

// ตัด ?ssl=require ออกจาก URL เพื่อป้องกัน pg parse ssl เป็น string แล้ว configure ผ่าน options แทน
const connectionString = (process.env.DATABASE_URL || '')
  .replace(/[?&]ssl=require/g, '')
  .replace(/[?&]sslmode=require/g, '');

const pool = new Pool({
  connectionString,
  ssl: { rejectUnauthorized: false },
});

const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({
  adapter,
  log: ['info', 'warn', 'error'],
});

module.exports = prisma;