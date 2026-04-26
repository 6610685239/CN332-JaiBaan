require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { defineConfig } = require('@prisma/config');

module.exports = defineConfig({
    schema: require('path').resolve(__dirname, '../prisma/schema.prisma'),
    datasource: {
        url: process.env.DATABASE_URL,
    },
});