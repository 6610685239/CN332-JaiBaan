const prisma = require('./db')

const now = new Date()
const daysAgo = (n, hour = 10) => {
  const d = new Date(now)
  d.setDate(d.getDate() - n)
  d.setHours(hour, 0, 0, 0)
  return d
}
const photo = (n) => `https://picsum.photos/seed/parcel${n}/400/300`

const parcels = [
  // ── ARRIVED (รอรับ) ────────────────────────────────────────────
  {
    trackingNumber: 'KERRY00481293',
    carrier: 'Kerry',
    unitNumber: '12/5',
    storageLocation: 'ชั้น 1 ช่อง A',
    status: 'ARRIVED',
    arrivedAt: daysAgo(0, 9),
    notes: 'ระวังแตก',
    photoUrl: photo(1),
  },
  {
    trackingNumber: 'TH8830291047',
    carrier: 'Flash',
    unitNumber: '3/2',
    storageLocation: 'ชั้น 1 ช่อง B',
    status: 'ARRIVED',
    arrivedAt: daysAgo(1, 11),
    notes: null,
    photoUrl: null,
  },
  {
    trackingNumber: 'JT2948301029',
    carrier: 'J&T',
    unitNumber: '5/8',
    storageLocation: 'ชั้น 2 ช่อง A',
    status: 'ARRIVED',
    arrivedAt: daysAgo(1, 14),
    notes: 'ขนาดใหญ่มาก',
    photoUrl: photo(3),
  },
  {
    trackingNumber: 'SPXTH00293847',
    carrier: 'Shopee',
    unitNumber: '7/1',
    storageLocation: 'ชั้น 1 ช่อง C',
    status: 'ARRIVED',
    arrivedAt: daysAgo(2, 8),
    notes: null,
    photoUrl: photo(4),
  },
  {
    trackingNumber: 'LZD83920184',
    carrier: 'Lazada',
    unitNumber: '12/5',
    storageLocation: 'ชั้น 2 ช่อง B',
    status: 'ARRIVED',
    arrivedAt: daysAgo(6, 10),
    notes: 'ค้างนาน — ลองโทรแจ้ง',
    photoUrl: null,
  },
  {
    trackingNumber: 'KERRY00571820',
    carrier: 'Kerry',
    unitNumber: '2/4',
    storageLocation: 'ชั้น 1 ช่อง A',
    status: 'ARRIVED',
    arrivedAt: daysAgo(5, 13),
    notes: null,
    photoUrl: null,
  },
  {
    trackingNumber: 'EV293847156TH',
    carrier: 'Thailand Post',
    unitNumber: '9/3',
    storageLocation: 'ชั้น 2 ช่อง C',
    status: 'ARRIVED',
    arrivedAt: daysAgo(0, 15),
    notes: 'ลงทะเบียน — ต้องเซ็นรับ',
    photoUrl: photo(7),
  },
  {
    trackingNumber: '1234567890DHL',
    carrier: 'DHL',
    unitNumber: '4/6',
    storageLocation: 'ชั้น 3 ช่อง A',
    status: 'ARRIVED',
    arrivedAt: daysAgo(4, 9),
    notes: 'ส่งด่วน',
    photoUrl: null,
  },
  {
    trackingNumber: 'KERRY00382910',
    carrier: 'Kerry',
    unitNumber: '1/1',
    storageLocation: 'ชั้น 1 ช่อง B',
    status: 'ARRIVED',
    arrivedAt: daysAgo(7, 11),
    notes: null,
    photoUrl: photo(9),
  },
  {
    trackingNumber: 'TH9920481038',
    carrier: 'Flash',
    unitNumber: '6/2',
    storageLocation: 'ชั้น 2 ช่อง A',
    status: 'ARRIVED',
    arrivedAt: daysAgo(2, 16),
    notes: null,
    photoUrl: null,
  },

  // ── PICKED_UP (รับแล้ว) ────────────────────────────────────────
  {
    trackingNumber: 'KERRY00291038',
    carrier: 'Kerry',
    unitNumber: '3/2',
    storageLocation: 'ชั้น 1 ช่อง C',
    status: 'PICKED_UP',
    arrivedAt: daysAgo(5, 10),
    pickedUpAt: daysAgo(3, 14),
    notes: null,
    photoUrl: photo(11),
  },
  {
    trackingNumber: 'JT4820193847',
    carrier: 'J&T',
    unitNumber: '12/5',
    storageLocation: 'ชั้น 1 ช่อง A',
    status: 'PICKED_UP',
    arrivedAt: daysAgo(6, 9),
    pickedUpAt: daysAgo(4, 11),
    notes: null,
    photoUrl: null,
  },
  {
    trackingNumber: 'SPXTH00481920',
    carrier: 'Shopee',
    unitNumber: '5/8',
    storageLocation: null,
    status: 'PICKED_UP',
    arrivedAt: daysAgo(4, 8),
    pickedUpAt: daysAgo(2, 16),
    notes: null,
    photoUrl: photo(13),
  },
  {
    trackingNumber: 'LZD29384710',
    carrier: 'Lazada',
    unitNumber: '7/1',
    storageLocation: 'ชั้น 2 ช่อง B',
    status: 'PICKED_UP',
    arrivedAt: daysAgo(3, 14),
    pickedUpAt: daysAgo(1, 10),
    notes: 'เจ้าของมาเองตอนเย็น',
    photoUrl: null,
  },
  {
    trackingNumber: 'KERRY00193847',
    carrier: 'Kerry',
    unitNumber: '9/3',
    storageLocation: 'ชั้น 3 ช่อง A',
    status: 'PICKED_UP',
    arrivedAt: daysAgo(9, 11),
    pickedUpAt: daysAgo(7, 15),
    notes: null,
    photoUrl: null,
  },
  {
    trackingNumber: 'TH7710293847',
    carrier: 'Flash',
    unitNumber: '2/4',
    storageLocation: null,
    status: 'PICKED_UP',
    arrivedAt: daysAgo(2, 9),
    pickedUpAt: daysAgo(0, 12),
    notes: null,
    photoUrl: photo(16),
  },

  // ── RETURNED (คืนแล้ว) ─────────────────────────────────────────
  {
    trackingNumber: 'EV482910034TH',
    carrier: 'Thailand Post',
    unitNumber: '4/6',
    storageLocation: null,
    status: 'RETURNED',
    arrivedAt: daysAgo(12, 10),
    returnedAt: daysAgo(9, 14),
    notes: 'ไม่มีคนรับนาน 10 วัน',
    photoUrl: null,
  },
  {
    trackingNumber: 'KERRY00847291',
    carrier: 'Kerry',
    unitNumber: '6/2',
    storageLocation: null,
    status: 'RETURNED',
    arrivedAt: daysAgo(10, 9),
    returnedAt: daysAgo(7, 11),
    notes: null,
    photoUrl: photo(18),
  },
  {
    trackingNumber: 'JT9920481837',
    carrier: 'J&T',
    unitNumber: '1/1',
    storageLocation: null,
    status: 'RETURNED',
    arrivedAt: daysAgo(14, 13),
    returnedAt: daysAgo(11, 10),
    notes: null,
    photoUrl: null,
  },
  {
    trackingNumber: 'SPXTH00193020',
    carrier: 'Shopee',
    unitNumber: '12/5',
    storageLocation: null,
    status: 'RETURNED',
    arrivedAt: daysAgo(17, 8),
    returnedAt: daysAgo(14, 15),
    notes: 'ผู้รับปฏิเสธรับ',
    photoUrl: null,
  },
]

async function main() {
  console.log('Seeding 20 sample parcels...')
  let created = 0
  let skipped = 0

  for (const p of parcels) {
    try {
      await prisma.parcel.create({ data: p })
      created++
      console.log(`  ✓ ${p.trackingNumber} (${p.carrier} → ห้อง ${p.unitNumber})`)
    } catch (err) {
      if (err.code === 'P2002') {
        skipped++
        console.log(`  – ${p.trackingNumber} already exists, skipped`)
      } else {
        console.error(`  ✗ ${p.trackingNumber}:`, err.message)
      }
    }
  }

  console.log(`\nDone: ${created} created, ${skipped} skipped`)
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
