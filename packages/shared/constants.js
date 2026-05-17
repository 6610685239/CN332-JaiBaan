// Shared constants between frontend and backend

const CATEGORY = {
  GENERAL: 'GENERAL',
  MAINTENANCE: 'MAINTENANCE',
  EVENT: 'EVENT',
  FINANCE: 'FINANCE',
  URGENT: 'URGENT',
}

const CATEGORY_LABEL = {
  GENERAL: 'ทั่วไป',
  MAINTENANCE: 'ซ่อมบำรุง',
  EVENT: 'กิจกรรม',
  FINANCE: 'การเงิน',
  URGENT: 'เร่งด่วน',
}

const CATEGORY_COLOR = {
  GENERAL: '#6B7280',
  MAINTENANCE: '#F59E0B',
  EVENT: '#3B82F6',
  FINANCE: '#10B981',
  URGENT: '#EF4444',
}

const STATUS = {
  DRAFT: 'DRAFT',
  SCHEDULED: 'SCHEDULED',
  PUBLISHED: 'PUBLISHED',
  ARCHIVED: 'ARCHIVED',
}

const STATUS_LABEL = {
  DRAFT: 'ร่าง',
  SCHEDULED: 'ตั้งเวลา',
  PUBLISHED: 'เผยแพร่แล้ว',
  ARCHIVED: 'เก็บถาวร',
}

const TARGET_TYPE = {
  ALL: 'ALL',
  ZONE: 'ZONE',
  UNIT: 'UNIT',
}

const TARGET_TYPE_LABEL = {
  ALL: 'ลูกบ้านทั้งหมด',
  ZONE: 'เฉพาะโซน',
  UNIT: 'เฉพาะบ้านเลขที่',
}

module.exports = {
  CATEGORY,
  CATEGORY_LABEL,
  CATEGORY_COLOR,
  STATUS,
  STATUS_LABEL,
  TARGET_TYPE,
  TARGET_TYPE_LABEL,
}
