require('dotenv').config();
const { defineConfig } = require('@prisma/config');

module.exports = defineConfig({
    datasource: {
        url: process.env.DATABASE_URL,
    },
});