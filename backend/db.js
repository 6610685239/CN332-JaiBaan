require('dotenv').config({ path: require('path').resolve(__dirname, '.env') });

const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');

// Strip ssl/sslmode params — pgbouncer handles TLS at the network level
const connectionString = (process.env.DATABASE_URL || '')
  .replace(/[?&]ssl(mode)?=[^&]*/gi, '')
  .replace(/[?&]$/, '');

const pool = new Pool({ connectionString });

const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({
  adapter,
  log: ['warn', 'error'],
});

module.exports = prisma;
