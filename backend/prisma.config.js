require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { defineConfig } = require('@prisma/config');

module.exports = defineConfig({
    datasource: {
        url: process.env.DATABASE_URL,
    },
});