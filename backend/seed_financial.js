const prisma = require('./db')

function rnd(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min
}

async function main() {
  const year = 2026

  console.log(`Seeding financial transactions for year ${year}...`)

  // ลบข้อมูล seed เก่าออกก่อน
  await prisma.financialTransaction.deleteMany({
    where: {
      year,
      createdBy: 'seed',
    },
  })

  const items = []

  for (let m = 1; m <= 5; m++) {
    // รายรับค่าส่วนกลาง
    const income = rnd(58000, 68000)

    items.push({
      type: 'INCOME',
      category: 'COMMON_FEE',
      amount: income,
      description: `ค่าส่วนกลาง เดือน ${m}/${year}`,
      transactionDate: new Date(year, m - 1, 5),
      year,
      month: m,
      createdBy: 'seed',
    })

    // ค่าไฟฟ้าส่วนกลาง
    items.push({
      type: 'EXPENSE',
      category: 'ELECTRICITY',
      amount: rnd(8000, 15000),
      description: `ค่าไฟฟ้าส่วนกลาง เดือน ${m}/${year}`,
      transactionDate: new Date(year, m - 1, 10),
      year,
      month: m,
      createdBy: 'seed',
    })

    // ค่าน้ำส่วนกลาง
    items.push({
      type: 'EXPENSE',
      category: 'WATER',
      amount: rnd(2000, 6000),
      description: `ค่าน้ำส่วนกลาง เดือน ${m}/${year}`,
      transactionDate: new Date(year, m - 1, 12),
      year,
      month: m,
      createdBy: 'seed',
    })

    // ค่าซ่อมบำรุง
    items.push({
      type: 'EXPENSE',
      category: 'MAINTENANCE',
      amount: rnd(5000, 20000),
      description: `ค่าซ่อมบำรุง เดือน ${m}/${year}`,
      transactionDate: new Date(year, m - 1, 18),
      year,
      month: m,
      createdBy: 'seed',
    })

    // ค่าใช้จ่ายอื่น ๆ
    items.push({
      type: 'EXPENSE',
      category: 'OTHER_EXPENSE',
      amount: rnd(12000, 28000),
      description: `ค่าใช้จ่ายทั่วไป เดือน ${m}/${year}`,
      transactionDate: new Date(year, m - 1, 25),
      year,
      month: m,
      createdBy: 'seed',
    })

    // บางเดือนมีค่าซ่อมฉุกเฉินเพิ่ม
    if (Math.random() > 0.7) {
      items.push({
        type: 'EXPENSE',
        category: 'MAINTENANCE',
        amount: rnd(10000, 30000),
        description: `ค่าซ่อมฉุกเฉิน เดือน ${m}/${year}`,
        transactionDate: new Date(year, m - 1, 27),
        year,
        month: m,
        createdBy: 'seed',
      })
    }
  }

  // Insert ทีละรายการ
  for (const it of items) {
    const data = {
      type: it.type,
      category: it.category,
      amount: Number(it.amount),
      description: it.description,
      transactionDate: it.transactionDate,
      year: it.year,
      month: it.month,
      createdBy: it.createdBy,
    }

    try {
      await prisma.financialTransaction.create({ data })
      console.log(`Created: ${data.description} - ${data.amount} บาท`)
    } catch (err) {
      console.error('Failed to create transaction', data, err.message)
    }
  }

  console.log(`Inserted ${items.length} financial transactions for ${year}.`)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })