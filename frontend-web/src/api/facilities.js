import api from './axios';

export const facilityApi = {
  list: () => api.get('/facilities').then((r) => r.data),
  getById: (id) => api.get(`/facilities/${id}`).then((r) => r.data),
  create: (data) => api.post('/facilities', data).then((r) => r.data),
  update: (id, data) => api.put(`/facilities/${id}`, data).then((r) => r.data),
  delete: (id) => api.delete(`/facilities/${id}`).then((r) => r.data),
  listReservations: () => api.get('/facilities/reservations').then((r) => r.data),
  uploadPhoto: (file) => {
    const fd = new FormData();
    fd.append('file', file);
    return api.post('/facilities/upload-photo', fd, { headers: { 'Content-Type': 'multipart/form-data' } }).then((r) => r.data);
  },
  deletePhoto: (url) => {
    const filename = url.split('/').pop();
    return api.delete('/facilities/photo', { data: { filename } }).then((r) => r.data);
  },
};
