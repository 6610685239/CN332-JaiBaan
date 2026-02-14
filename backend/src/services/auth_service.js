const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

async function syncXUser(supabaseUser) {
    const { id, user_metadata } = supabaseUser;

    return await prisma.user.upsert({
        where: { username: user_metadata.user_name || id },
        update: {
            avatarUrl: user_metadata.avatar_url,
        },
        create: {
            username: user_metadata.user_name || id,
            passwordHash: '',
            firstName: user_metadata.full_name?.split(' ')[0] || 'X_User',
            lastName: user_metadata.full_name?.split(' ')[1] || '',
            role: 'resident',
            socialId: id,
            avatarUrl: user_metadata.avatar_url,
        },
    });
}