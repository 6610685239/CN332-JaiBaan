const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
    datasourceUrl: process.env.DATABASE_URL,
});

module.exports = prisma;