import api from './axios'

export const announcementApi = {
  // รายการทั้งหมด
  list: (params) => api.get('/announcements', { params }).then((r) => r.data),

  // รายละเอียด
  getById: (id) => api.get(`/announcements/${id}`).then((r) => r.data),

  // สร้างใหม่
  create: (data) => api.post('/announcements', data).then((r) => r.data),

  // แก้ไข
  update: (id, data) => api.put(`/announcements/${id}`, data).then((r) => r.data),

  // เปลี่ยนสถานะ
  changeStatus: (id, status) =>
    api.patch(`/announcements/${id}/status`, { status }).then((r) => r.data),

  // Publish + ส่ง notification
  publish: (id, tokens = []) =>
    api.post(`/announcements/${id}/publish`, { tokens }).then((r) => r.data),

  // ลบ
  delete: (id) => api.delete(`/announcements/${id}`).then((r) => r.data),

  // อัพโหลดไฟล์
  uploadFile: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api
      .post('/announcements/upload', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data)
  },

  // ลบ attachment
  deleteAttachment: (attachmentId) =>
    api.delete(`/announcements/attachments/${attachmentId}`).then((r) => r.data),
}
