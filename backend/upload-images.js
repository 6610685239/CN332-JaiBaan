const { createClient } = require('@supabase/supabase-js');
const { PrismaClient } = require('@prisma/client');
const { PrismaPg } = require('@prisma/adapter-pg');
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const SUPABASE_URL = 'https://dwmvazfegxsckwlfsqzu.supabase.co';
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_KEY;
const BUCKET = 'facilities';

if (!SUPABASE_KEY) {
  console.error('❌ SUPABASE_SERVICE_KEY is not set in .env');
  console.error('   Go to: Supabase Dashboard → Project Settings → API → service_role key');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const IMAGE_DIR = path.join(__dirname, 'public/images/facilities');

const facilityImages = [
  { name: 'สระว่ายน้ำ',       file: 'pool.png' },
  { name: 'ห้องฟิตเนส',       file: 'fitness.png' },
  { name: 'ห้องประชุมใหญ่',   file: 'conference room.png' },
  { name: 'สนามบาสเกตบอล',   file: 'basketballcourt.png' },
  { name: 'ห้องสมุด',         file: 'library.png' },
];

async function main() {
  // Create bucket (public) — ignore error if it already exists
  const { error: bucketErr } = await supabase.storage.createBucket(BUCKET, {
    public: true,
    allowedMimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
  });
  if (bucketErr && !bucketErr.message.toLowerCase().includes('already exists')) {
    console.error('❌ Could not create bucket:', bucketErr.message);
    process.exit(1);
  }

  for (const item of facilityImages) {
    const filePath = path.join(IMAGE_DIR, item.file);
    const fileBuffer = fs.readFileSync(filePath);
    const storageName = item.file.replace(/ /g, '_'); // spaces → underscores

    const { error: uploadErr } = await supabase.storage
      .from(BUCKET)
      .upload(storageName, fileBuffer, { contentType: 'image/png', upsert: true });

    if (uploadErr) {
      console.error(`❌ Upload failed for ${item.file}:`, uploadErr.message);
      continue;
    }

    const { data: { publicUrl } } = supabase.storage
      .from(BUCKET)
      .getPublicUrl(storageName);

    await prisma.facility.updateMany({
      where: { name: item.name },
      data: { imageUrl: publicUrl },
    });

    console.log(`✅ ${item.name} → ${publicUrl}`);
  }

  await prisma.$disconnect();
  console.log('\n🎉 All images uploaded and database updated!');
}

main().catch(e => { console.error('❌', e.message); process.exit(1); });
