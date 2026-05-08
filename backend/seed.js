const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });


const connectionString = process.env.DATABASE_URL;
const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);


const prisma = new PrismaClient({ adapter });

async function main() {
    const hashedPassword = await bcrypt.hash('123456', 10);

    const admin = await prisma.user.upsert({
        where: { username: 'admin_test' },
        update: {},
        create: {
            username: 'admin_test',
            passwordHash: hashedPassword,
            role: 'admin',
            firstName: 'Admin',
            lastName: 'Test',
        },
    });

    console.log('success:', admin.username);
}

main()
    .catch((e) => console.error('error:', e))
    .finally(async () => {
        await prisma.$disconnect();
        await pool.end();
    });