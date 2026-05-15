// const prisma = require('../lib/prisma')
const prisma = require('../../db');
const { sendAnnouncementNotification } = require('./notificationService')
const { deleteFile } = require('./fileService')

/**
 * ดึงรายการประกาศ + filter + pagination
 * userId: optional - if provided, will filter announcements based on user's resident info
 * filterByResident: if true, will filter by targetType and resident's unitNumber
 */
const getAnnouncements = async ({ 
  status, 
  category, 
  search, 
  page = 1, 
  limit = 10,
  userId = null,
  filterByResident = false 
}) => {
  const where = {}

  if (status) where.status = status
  if (category) where.category = category
  if (search) {
    where.title = { contains: search, mode: 'insensitive' }
  }

  // Filter by resident if specified
  if (filterByResident && userId) {
    const resident = await prisma.resident.findUnique({
      where: { userId: parseInt(userId) },
    })

    if (resident) {
      // Create filter for announcements that should be visible to this resident
      where.OR = [
        // ALL announcements are visible to everyone
        { targetType: 'ALL' },
        // UNIT announcements are visible only if resident's unitNumber is in targetUnits
        {
          AND: [
            { targetType: 'UNIT' },
            { targetUnits: { has: resident.unitNumber } },
          ],
        },
        // ZONE announcements are visible only if resident's zone is in targetZones
        {
          AND: [
            { targetType: 'ZONE' },
            { targetZones: { has: resident.unitNumber.split('/')[0] } }, // Assuming zone is extracted from unitNumber
          ],
        },
      ]
    }
  }

  const skip = (page - 1) * limit

  const [data, total] = await Promise.all([
    prisma.announcement.findMany({
      where,
      include: { attachments: true },
      orderBy: { createdAt: 'desc' },
      skip,
      take: Number(limit),
    }),
    prisma.announcement.count({ where }),
  ])

  return {
    data,
    pagination: {
      total,
      page: Number(page),
      limit: Number(limit),
      totalPages: Math.ceil(total / limit),
    },
  }
}

/**
 * ดึงรายการประกาศสำหรับ resident (รู้ว่ากรองตาม targetType + unitNumber แล้ว)
 */
const getAnnouncementsForResident = async (userId, { status, category, search, page = 1, limit = 10 }) => {
  return getAnnouncements({
    status,
    category,
    search,
    page,
    limit,
    userId,
    filterByResident: true,
  })
}

/**
 * ดึงรายละเอียด 1 ประกาศ
 */
const getAnnouncementById = async (id) => {
  return prisma.announcement.findUnique({
    where: { id },
    include: { attachments: true },
  })
}

/**
 * สร้างประกาศใหม่
 */
const createAnnouncement = async (data, userId) => {
  const { attachments = [], ...announcementData } = data

  return prisma.announcement.create({
    data: {
      ...announcementData,
      createdBy: String(userId),
      attachments: {
        create: attachments,
      },
    },
    include: { attachments: true },
  })
}

/**
 * แก้ไขประกาศ
 */
const updateAnnouncement = async (id, data) => {
  const { attachments, ...announcementData } = data

  return prisma.announcement.update({
    where: { id },
    data: announcementData,
    include: { attachments: true },
  })
}

/**
 * เปลี่ยนสถานะ
 */
const updateStatus = async (id, status) => {
  const updateData = { status }

  if (status === 'PUBLISHED') {
    updateData.publishedAt = new Date()
  }

  return prisma.announcement.update({
    where: { id },
    data: updateData,
    include: { attachments: true },
  })
}

/**
 * Publish + ส่ง Push Notification
 * tokens: FCM device tokens ของลูกบ้านเป้าหมาย (ควรดึงจากระบบ user/resident)
 */
const publishAnnouncement = async (id, tokens = []) => {
  const announcement = await prisma.announcement.update({
    where: { id },
    data: {
      status: 'PUBLISHED',
      publishedAt: new Date(),
    },
    include: { attachments: true },
  })

  // ส่ง FCM notification
  let notifResult = null
  if (tokens.length > 0) {
    notifResult = await sendAnnouncementNotification(announcement, tokens)
    if (notifResult.success) {
      await prisma.announcement.update({
        where: { id },
        data: { notifSent: true },
      })
    }
  }

  return { announcement, notifResult }
}

/**
 * ลบประกาศ + ลบไฟล์แนบ
 */
const deleteAnnouncement = async (id) => {
  const announcement = await prisma.announcement.findUnique({
    where: { id },
    include: { attachments: true },
  })

  if (!announcement) return null

  // ลบไฟล์แนบ
  for (const attachment of announcement.attachments) {
    await deleteFile(attachment.filename)
  }

  // ลบ record (attachments cascade)
  await prisma.announcement.delete({ where: { id } })

  return announcement
}

/**
 * ลบ attachment เดี่ยว
 */
const deleteAttachment = async (attachmentId) => {
  const attachment = await prisma.attachment.findUnique({ where: { id: attachmentId } })
  if (!attachment) return null

  await deleteFile(attachment.filename)
  await prisma.attachment.delete({ where: { id: attachmentId } })

  return attachment
}

module.exports = {
  getAnnouncements,
  getAnnouncementsForResident,
  getAnnouncementById,
  createAnnouncement,
  updateAnnouncement,
  updateStatus,
  publishAnnouncement,
  deleteAnnouncement,
  deleteAttachment,
}
