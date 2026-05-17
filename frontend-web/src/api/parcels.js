import api from './axios';

export const parcelApi = {
  stats: () => api.get('/parcels/stats').then((r) => r.data),
  list: (params) => api.get('/parcels', { params }).then((r) => r.data),
  getById: (id) => api.get(`/parcels/${id}`).then((r) => r.data),
  create: (data) => api.post('/parcels', data).then((r) => r.data),
  pickup: (id) => api.patch(`/parcels/${id}/pickup`).then((r) => r.data),
  return: (id) => api.patch(`/parcels/${id}/return`).then((r) => r.data),
  delete: (id) => api.delete(`/parcels/${id}`).then((r) => r.data),
  bulkDelete: (ids) => api.post('/parcels/bulk-delete', { ids }).then((r) => r.data),
  bulkReturn: (ids) => api.post('/parcels/bulk-return', { ids }).then((r) => r.data),
  updateStatus: (id, status) => api.patch(`/parcels/${id}/status`, { status }).then((r) => r.data),
  deletePhoto: (url) => api.delete('/parcels/photo', { data: { url } }).then((r) => r.data),
  uploadPhoto: (file) => {
    const formData = new FormData();
    formData.append('file', file);
    return api
      .post('/parcels/upload-photo', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      })
      .then((r) => r.data);
  },
};
