import api from './axios'

export const financialApi = {
  dashboard: (year) => api.get('/financial/dashboard', { params: { year } }).then((r) => r.data.data),
  years: () => api.get('/financial/years').then((r) => r.data.data),
  list: (params) => api.get('/financial/transactions', { params }).then((r) => r.data),
  getById: (id) => api.get(`/financial/transactions/${id}`).then((r) => r.data.data),
  create: (data) => api.post('/financial/transactions', data).then((r) => r.data.data),
  update: (id, data) => api.put(`/financial/transactions/${id}`, data).then((r) => r.data.data),
  delete: (id) => api.delete(`/financial/transactions/${id}`).then((r) => r.data),
  uploadFile: (file) => {
    const formData = new FormData()
    formData.append('file', file)
    return api.post('/financial/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    }).then((r) => r.data.data)
  },
  deleteAttachment: (attachmentId) => api.delete(`/financial/attachments/${attachmentId}`).then((r) => r.data),
}
