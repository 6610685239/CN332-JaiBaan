const prisma = require('../../db')
const { deleteFile } = require('./financialFileService')

const CATEGORY_LABELS = {
  COMMON_FEE:    'ค่าส่วนกลาง',
  RENTAL:        'ค่าเช่าพื้นที่',
  OTHER_INCOME:  'รายรับอื่นๆ',
  ELECTRICITY:   'ค่าไฟฟ้าส่วนกลาง',
  WATER:         'ค่าน้ำ',
  MAINTENANCE:   'ซ่อมบำรุง',
  OTHER_EXPENSE: 'รายจ่ายอื่นๆ',
}

const toNumber = (value) => (value == null ? 0 : Number(value))

// ─── CRUD ────────────────────────────────────────────────────────────

const getTransactions = async ({ year, month, type, category, search, page = 1, limit = 10 }) => {
  const where = {}
  if (year)     where.year     = Number(year)
  if (month)    where.month    = Number(month)
  if (type)     where.type     = type
  if (category) where.category = category
  if (search)   where.description = { contains: search, mode: 'insensitive' }

  const skip = (Number(page) - 1) * Number(limit)
  const [data, total] = await Promise.all([
    prisma.financialTransaction.findMany({
      where,
      include: { attachments: true },
      orderBy: { transactionDate: 'desc' },
      skip,
      take: Number(limit),
    }),
    prisma.financialTransaction.count({ where }),
  ])

  return {
    data,
    pagination: {
      total,
      page: Number(page),
      limit: Number(limit),
      totalPages: Math.max(1, Math.ceil(total / Number(limit))),
    },
  }
}

const getTransactionById = (id) =>
  prisma.financialTransaction.findUnique({ where: { id }, include: { attachments: true } })

const createTransaction = async (data, userId) => {
  const { attachments = [], transactionDate, ...rest } = data
  const date  = new Date(transactionDate)
  const year  = date.getFullYear()
  const month = date.getMonth() + 1

  return prisma.financialTransaction.create({
    data: { ...rest, transactionDate: date, year, month, createdBy: String(userId),
            attachments: { create: attachments } },
    include: { attachments: true },
  })
}

const updateTransaction = async (id, data) => {
  const { attachments = [], transactionDate, ...rest } = data
  const updateData = { ...rest }

  if (transactionDate) {
    const date = new Date(transactionDate)
    updateData.transactionDate = date
    updateData.year  = date.getFullYear()
    updateData.month = date.getMonth() + 1
  }

  const newAttachments = attachments.filter((a) => !a.id)
  if (newAttachments.length > 0) updateData.attachments = { create: newAttachments }

  return prisma.financialTransaction.update({
    where: { id }, data: updateData, include: { attachments: true },
  })
}

const deleteTransaction = async (id) => {
  const tx = await prisma.financialTransaction.findUnique({ where: { id }, include: { attachments: true } })
  if (!tx) return null
  for (const a of tx.attachments) await deleteFile(a.filename)
  await prisma.financialTransaction.delete({ where: { id } })
  return tx
}

const deleteAttachment = async (attachmentId) => {
  const a = await prisma.financialAttachment.findUnique({ where: { id: attachmentId } })
  if (!a) return null
  await deleteFile(a.filename)
  await prisma.financialAttachment.delete({ where: { id: attachmentId } })
  return a
}

const getYears = async () => {
  const rows = await prisma.financialTransaction.groupBy({
    by: ['year'], orderBy: { year: 'desc' },
  })
  return rows.map((r) => r.year)
}

// ─── DASHBOARD ───────────────────────────────────────────────────────

const getDashboard = async (year) => {
  const selectedYear = Number(year) || new Date().getFullYear()
  const prevYear     = selectedYear - 1
  const now          = new Date()
  const currentMonth = now.getMonth() + 1 // 1-12

  // ── 1. Monthly groups (current year) ──────────────────────────────
  const [monthlyGroups, prevMonthlyGroups] = await Promise.all([
    prisma.financialTransaction.groupBy({
      by: ['month', 'type'],
      where: { year: selectedYear },
      _sum: { amount: true },
      orderBy: [{ month: 'asc' }],
    }),
    prisma.financialTransaction.groupBy({
      by: ['month', 'type'],
      where: { year: prevYear },
      _sum: { amount: true },
      orderBy: [{ month: 'asc' }],
    }),
  ])

  // Build monthly chart arrays
  const monthlyChart = Array.from({ length: 12 }, (_, i) => ({
    month: i + 1, income: 0, expense: 0,
  }))
  const prevMonthlyChart = Array.from({ length: 12 }, (_, i) => ({
    month: i + 1, income: 0, expense: 0,
  }))

  monthlyGroups.forEach(({ month, type, _sum }) => {
    const v = toNumber(_sum.amount)
    if (type === 'INCOME')   monthlyChart[month - 1].income  = v
    else                     monthlyChart[month - 1].expense = v
  })
  prevMonthlyGroups.forEach(({ month, type, _sum }) => {
    const v = toNumber(_sum.amount)
    if (type === 'INCOME')   prevMonthlyChart[month - 1].income  = v
    else                     prevMonthlyChart[month - 1].expense = v
  })

  // Add net (กำไรสุทธิ) to each month
  monthlyChart.forEach((m) => { m.net = m.income - m.expense })

  // ── 2. Summary (full year) ─────────────────────────────────────────
  const totalIncome  = monthlyChart.reduce((s, m) => s + m.income,  0)
  const totalExpense = monthlyChart.reduce((s, m) => s + m.expense, 0)
  const totalNet     = totalIncome - totalExpense

  // previous year totals
  const prevIncome  = prevMonthlyChart.reduce((s, m) => s + m.income,  0)
  const prevExpense = prevMonthlyChart.reduce((s, m) => s + m.expense, 0)

  const pctChange = (curr, prev) =>
    prev === 0 ? null : Number((((curr - prev) / prev) * 100).toFixed(1))

  // total transaction count (current year)
  const [totalCount, thisMonthCount] = await Promise.all([
    prisma.financialTransaction.count({ where: { year: selectedYear } }),
    prisma.financialTransaction.count({ where: { year: selectedYear, month: currentMonth } }),
  ])

  // ── 3. Expense breakdown (pie) ────────────────────────────────────
  const expenseGroups = await prisma.financialTransaction.groupBy({
    by: ['category'],
    where: { year: selectedYear, type: 'EXPENSE' },
    _sum: { amount: true },
    orderBy: [{ _sum: { amount: 'desc' } }],
  })

  const expensePieChart = expenseGroups.map((item) => ({
    category: item.category,
    label:    CATEGORY_LABELS[item.category] || item.category,
    amount:   toNumber(item._sum.amount),
    percent:  0,
  }))
  const expenseTotal = expensePieChart.reduce((s, i) => s + i.amount, 0)
  expensePieChart.forEach((item) => {
    item.percent = expenseTotal > 0
      ? Number(((item.amount / expenseTotal) * 100).toFixed(1))
      : 0
  })

  // ── 4. Recent transactions (5 latest) ────────────────────────────
  const recentTransactions = await prisma.financialTransaction.findMany({
    where:   { year: selectedYear },
    orderBy: { transactionDate: 'desc' },
    take: 5,
    include: { attachments: true },
  })

  // ── 5. Monthly Insights (current month vs previous month) ─────────
  const prevMonth = currentMonth === 1 ? 12 : currentMonth - 1
  const prevMonthYear = currentMonth === 1 ? selectedYear - 1 : selectedYear

  const [currMonthGroups, prevMonthGroups] = await Promise.all([
    prisma.financialTransaction.groupBy({
      by: ['type'],
      where: { year: selectedYear, month: currentMonth },
      _sum: { amount: true },
    }),
    prisma.financialTransaction.groupBy({
      by: ['type'],
      where: { year: prevMonthYear, month: prevMonth },
      _sum: { amount: true },
    }),
  ])

  const getTypeSum = (groups, type) => {
    const g = groups.find((x) => x.type === type)
    return toNumber(g?._sum?.amount)
  }

  const currMonthExpense = getTypeSum(currMonthGroups, 'EXPENSE')
  const prevMonthExpense = getTypeSum(prevMonthGroups, 'EXPENSE')
  const expenseChangeP   = pctChange(currMonthExpense, prevMonthExpense)

  // อัตราเก็บค่าส่วนกลาง: income COMMON_FEE this month vs total units (stub — ปรับได้)
  // ถ้ายังไม่มีข้อมูล unit จาก DB ส่ง null ไปให้ frontend ซ่อน
  const collectionRate = null // TODO: เชื่อม resident count

  // หมวดจ่ายสูงสุด
  const topCategory = expensePieChart.length > 0 ? expensePieChart[0] : null

  // ── 6. Trend (last 6 months) ──────────────────────────────────────
  // สร้าง array 6 เดือนล่าสุด (อาจข้ามปี)
  const trendMonths = []
  for (let i = 5; i >= 0; i--) {
    let m = currentMonth - i
    let y = selectedYear
    if (m <= 0) { m += 12; y -= 1 }
    trendMonths.push({ year: y, month: m })
  }

  const trendData = trendMonths.map(({ year: y, month: m }) => {
    const chartMonth = y === selectedYear
      ? monthlyChart.find((c) => c.month === m)
      : prevMonthlyChart.find((c) => c.month === m)
    return {
      label: m,
      year:  y,
      income:  chartMonth?.income  ?? 0,
      expense: chartMonth?.expense ?? 0,
      net:     (chartMonth?.income ?? 0) - (chartMonth?.expense ?? 0),
    }
  })

  // ── Return ────────────────────────────────────────────────────────
  return {
    year: selectedYear,
    summary: {
      totalIncome,
      totalExpense,
      balance: totalNet,
      totalCount,
      thisMonthCount,
      incomePctChange:  pctChange(totalIncome,  prevIncome),
      expensePctChange: pctChange(totalExpense, prevExpense),
      balancePctChange: pctChange(totalNet, prevIncome - prevExpense),
    },
    monthlyChart,
    expensePieChart,
    recentTransactions,
    insights: {
      expenseChangePct:    expenseChangeP,
      currentMonthExpense: currMonthExpense,
      collectionRate,
      topCategory,
    },
    trendChart: trendData,
  }
}

module.exports = {
  getTransactions,
  getTransactionById,
  createTransaction,
  updateTransaction,
  deleteTransaction,
  deleteAttachment,
  getYears,
  getDashboard,
}