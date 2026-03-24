import api from './api';

const BASE = '/clients';

export const clientService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  findCommandes: (id) => api.get(`${BASE}/${id}/commandes`),
  create: (data) => api.post(BASE, data),
  findOrCreate: (data) => api.post(`${BASE}/find-or-create`, data),
  update: (id, data) => api.put(`${BASE}/${id}`, data),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
