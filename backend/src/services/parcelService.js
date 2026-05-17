const prisma = require('../../db')
const { sendParcelArrivalNotification } = require('./parcelNotificationService')

const LIMIT = 10

const createParcel = async ({ trackingNumber, carrier, unitNumber, storageLocation, photoUrl }) => {
  const parcel = await prisma.parcel.create({
    data: { trackingNumber, carrier, unitNumber, storageLocation, photoUrl },
  })
  // Fire notification (stub) — non-blocking
  sendParcelArrivalNotification(unitNumber, parcel).catch(console.error)
  return parcel
}

const getParcels = async ({ status, unitNumber, carrier, search, page = 1, limit = LIMIT }) => {
  const where = {}
  if (status) where.status = status
  if (carrier) where.carrier = { equals: carrier, mode: 'insensitive' }
  if (unitNumber) where.unitNumber = { contains: unitNumber, mode: 'insensitive' }
  if (search) {
    where.OR = [
      { trackingNumber: { contains: search, mode: 'insensitive' } },
      { carrier: { contains: search, mode: 'insensitive' } },
      { unitNumber: { contains: search, mode: 'insensitive' } },
    ]
  }

  const skip = (parseInt(page) - 1) * parseInt(limit)
  const [data, total] = await Promise.all([
    prisma.parcel.findMany({
      where,
      orderBy: { arrivedAt: 'desc' },
      skip,
      take: parseInt(limit),
    }),
    prisma.parcel.count({ where }),
  ])

  return {
    data,
    pagination: { total, page: parseInt(page), totalPages: Math.ceil(total / parseInt(limit)) },
  }
}

// For mobile resident — only their unit, only ARRIVED parcels shown as actionable
const getResidentParcels = async (unitNumber) => {
  return prisma.parcel.findMany({
    where: { unitNumber },
    orderBy: { arrivedAt: 'desc' },
  })
}

const getParcelById = async (id) => {
  return prisma.parcel.findUnique({ where: { id: parseInt(id) } })
}

const markPickedUp = async (id) => {
  return prisma.parcel.update({
    where: { id: parseInt(id) },
    data: { status: 'PICKED_UP', pickedUpAt: new Date() },
  })
}

const markReturned = async (id) => {
  return prisma.parcel.update({
    where: { id: parseInt(id) },
    data: { status: 'RETURNED', returnedAt: new Date() },
  })
}

const updateStatus = async (id, status) => {
  const data = { status }
  if (status === 'PICKED_UP') data.pickedUpAt = new Date()
  if (status === 'RETURNED')  data.returnedAt  = new Date()
  if (status === 'ARRIVED')   { data.pickedUpAt = null; data.returnedAt = null }
  return prisma.parcel.update({ where: { id: parseInt(id) }, data })
}

const deleteParcel = async (id) => {
  return prisma.parcel.delete({ where: { id: parseInt(id) } })
}

const bulkDelete = async (ids) => {
  return prisma.parcel.deleteMany({ where: { id: { in: ids.map(Number) } } })
}

const bulkReturn = async (ids) => {
  return prisma.parcel.updateMany({
    where: { id: { in: ids.map(Number) }, status: 'ARRIVED' },
    data: { status: 'RETURNED', returnedAt: new Date() },
  })
}

const getStats = async () => {
  const now = new Date()
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const overdueDate = new Date(todayStart.getTime() - 3 * 24 * 60 * 60 * 1000)

  const [totalPending, pickedUpToday, overdue, carrierGroups] = await Promise.all([
    prisma.parcel.count({ where: { status: 'ARRIVED' } }),
    prisma.parcel.count({ where: { status: 'PICKED_UP', pickedUpAt: { gte: todayStart } } }),
    prisma.parcel.count({ where: { status: 'ARRIVED', arrivedAt: { lte: overdueDate } } }),
    prisma.parcel.groupBy({
      by: ['carrier'],
      _count: { carrier: true },
      where: { status: 'ARRIVED' },
      orderBy: { _count: { carrier: 'desc' } },
      take: 4,
    }),
  ])

  return {
    totalPending,
    pickedUpToday,
    overdue,
    carrierDistribution: carrierGroups.map((g) => ({ carrier: g.carrier, count: g._count.carrier })),
  }
}

module.exports = { createParcel, getParcels, getResidentParcels, getParcelById, markPickedUp, markReturned, updateStatus, deleteParcel, bulkDelete, bulkReturn, getStats }
