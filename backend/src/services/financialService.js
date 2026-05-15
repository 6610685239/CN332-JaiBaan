const prisma = require('../../db')
const { deleteFile } = require('./financialFileService')

const CATEGORY_LABELS = {
  COMMON_FEE: 'ค่าส่วนกลาง',
  RENTAL: 'ค่าเช่าพื้นที่',
  OTHER_INCOME: 'รายรับอื่นๆ',
  ELECTRICITY: 'ค่าไฟฟ้าส่วนกลาง',
  WATER: 'ค่าน้ำ',
  MAINTENANCE: 'ซ่อมบำรุ้ง',
  OTHER_EXPENSE: 'รายจ่ายอื่นๆ',
}

const toNumber = (value) => {
  if (value == null) return 0
  return Number(value)
}

const getTransactions = async ({ year, month, type, category, search, page = 1, limit = 10 }) => {
  const where = {}

  if (year) where.year = Number(year)
  if (month) where.month = Number(month)
  if (type) where.type = type
  if (category) where.category = category
  if (search) {
    where.description = { contains: search, mode: 'insensitive' }
  }

  const skip = (page - 1) * limit

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
      totalPages: Math.max(1, Math.ceil(total / limit)),
    },
  }
}

const getTransactionById = async (id) => {
  return prisma.financialTransaction.findUnique({
    where: { id },
    include: { attachments: true },
  })
}

const createTransaction = async (data, userId) => {
  const { attachments = [], transactionDate, ...transactionData } = data
  const date = new Date(transactionDate)
  const year = date.getFullYear()
  const month = date.getMonth() + 1

  return prisma.financialTransaction.create({
    data: {
      ...transactionData,
      amount: transactionData.amount,
      transactionDate: date,
      year,
      month,
      createdBy: String(userId),
      attachments: {
        create: attachments,
      },
    },
    include: { attachments: true },
  })
}

const updateTransaction = async (id, data) => {
  const { attachments = [], transactionDate, ...transactionData } = data
  const updateData = {
    ...transactionData,
    amount: transactionData.amount,
  }

  if (transactionDate) {
    const date = new Date(transactionDate)
    updateData.transactionDate = date
    updateData.year = date.getFullYear()
    updateData.month = date.getMonth() + 1
  }

  const newAttachments = attachments.filter((att) => !att.id)
  if (newAttachments.length > 0) {
    updateData.attachments = {
      create: newAttachments,
    }
  }

  return prisma.financialTransaction.update({
    where: { id },
    data: updateData,
    include: { attachments: true },
  })
}

const deleteTransaction = async (id) => {
  const transaction = await prisma.financialTransaction.findUnique({
    where: { id },
    include: { attachments: true },
  })

  if (!transaction) return null

  for (const attachment of transaction.attachments) {
    await deleteFile(attachment.filename)
  }

  await prisma.financialTransaction.delete({ where: { id } })
  return transaction
}

const deleteAttachment = async (attachmentId) => {
  const attachment = await prisma.financialAttachment.findUnique({ where: { id: attachmentId } })
  if (!attachment) return null

  await deleteFile(attachment.filename)
  await prisma.financialAttachment.delete({ where: { id: attachmentId } })
  return attachment
}

const getYears = async () => {
  const rows = await prisma.financialTransaction.groupBy({
    by: ['year'],
    orderBy: { year: 'desc' },
  })
  return rows.map((row) => row.year)
}

const getDashboard = async (year) => {
  const selectedYear = Number(year) || new Date().getFullYear()

  const monthlyGroups = await prisma.financialTransaction.groupBy({
    by: ['month', 'type'],
    where: { year: selectedYear },
    _sum: { amount: true },
    orderBy: [{ month: 'asc' }],
  })

  const expenseGroups = await prisma.financialTransaction.groupBy({
    by: ['category'],
    where: { year: selectedYear, type: 'EXPENSE' },
    _sum: { amount: true },
    orderBy: [{ _sum: { amount: 'desc' } }],
  })

  const monthlyChart = Array.from({ length: 12 }, (_, index) => ({
    month: index + 1,
    income: 0,
    expense: 0,
  }))

  monthlyGroups.forEach((item) => {
    const value = toNumber(item._sum.amount)
    if (item.type === 'INCOME') {
      monthlyChart[item.month - 1].income = value
    } else {
      monthlyChart[item.month - 1].expense = value
    }
  })

  const totalIncome = monthlyChart.reduce((sum, item) => sum + item.income, 0)
  const totalExpense = monthlyChart.reduce((sum, item) => sum + item.expense, 0)

  const expensePieChart = expenseGroups.map((item) => ({
    category: item.category,
    label: CATEGORY_LABELS[item.category] || item.category,
    amount: toNumber(item._sum.amount),
    percent: 0,
  }))

  const expenseTotal = expensePieChart.reduce((sum, item) => sum + item.amount, 0)
  expensePieChart.forEach((item) => {
    item.percent = expenseTotal > 0 ? Number(((item.amount / expenseTotal) * 100).toFixed(1)) : 0
  })

  return {
    year: selectedYear,
    summary: {
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    },
    monthlyChart,
    expensePieChart,
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
