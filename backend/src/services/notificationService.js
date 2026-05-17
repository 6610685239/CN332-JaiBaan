const admin = require('firebase-admin')
const path = require('path')

let initialized = false

const initFirebase = () => {
  if (initialized) return
  try {
    const serviceAccount = require(path.resolve(process.env.FIREBASE_SERVICE_ACCOUNT || './firebase-service-account.json'))
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    })
    initialized = true
    console.log('✅ Firebase Admin initialized')
  } catch (err) {
    console.warn('⚠️  Firebase not initialized:', err.message)
  }
}

/**
 * ส่ง Push Notification ผ่าน FCM
 * @param {object} announcement - ข้อมูลประกาศ
 * @param {string[]} tokens - FCM device tokens ของลูกบ้าน (จากระบบ auth เดิม)
 */
const sendAnnouncementNotification = async (announcement, tokens = []) => {
  if (!initialized) {
    console.warn('Firebase not initialized — skipping notification')
    return { success: false, reason: 'Firebase not initialized' }
  }

  if (tokens.length === 0) {
    console.warn('No FCM tokens provided — skipping notification')
    return { success: false, reason: 'No tokens' }
  }

  const categoryEmoji = {
    GENERAL: '📢',
    MAINTENANCE: '🔧',
    EVENT: '🎉',
    FINANCE: '💰',
    URGENT: '🚨',
  }

  const message = {
    notification: {
      title: `${categoryEmoji[announcement.category] || '📢'} ${announcement.title}`,
      body: stripHtml(announcement.content).slice(0, 100),
    },
    data: {
      announcementId: announcement.id,
      category: announcement.category,
      type: 'ANNOUNCEMENT',
    },
    tokens,
  }

  try {
    const response = await admin.messaging().sendEachForMulticast(message)
    console.log(`📨 FCM sent: ${response.successCount} success, ${response.failureCount} failed`)
    return {
      success: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
    }
  } catch (err) {
    console.error('FCM send error:', err)
    return { success: false, reason: err.message }
  }
}

// strip HTML tags for notification body preview
const stripHtml = (html = '') => html.replace(/<[^>]*>/g, '').replace(/\s+/g, ' ').trim()

const sendPushNotification = async (token, title, body, data = {}) => {
  if (!initialized) return { success: false, reason: 'Firebase not initialized' }
  if (!token) return { success: false, reason: 'No token' }
  try {
    await admin.messaging().send({ token, notification: { title, body }, data })
    return { success: true }
  } catch (err) {
    console.error('FCM send error:', err)
    return { success: false, reason: err.message }
  }
}

// Initialize on module load
initFirebase()

module.exports = { sendAnnouncementNotification, sendPushNotification }
