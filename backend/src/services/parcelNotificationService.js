// Notification stub — not connected to any push service yet
// TODO: Connect to FCM or other push notification provider

const sendParcelArrivalNotification = async (unitNumber, parcel) => {
  console.log(`[NOTIFICATION STUB] Parcel arrived for unit ${unitNumber}`)
  console.log(`  Tracking: ${parcel.trackingNumber} | Carrier: ${parcel.carrier}`)
  // Future: look up FCM tokens for residents in unitNumber, send push
}

const sendParcelReminderNotification = async (unitNumber, parcel) => {
  console.log(`[NOTIFICATION STUB] Reminder: parcel still waiting for unit ${unitNumber}`)
  console.log(`  Tracking: ${parcel.trackingNumber} | Since: ${parcel.arrivedAt}`)
  // Future: auto-reminder after 3 days via cron
}

module.exports = { sendParcelArrivalNotification, sendParcelReminderNotification }
