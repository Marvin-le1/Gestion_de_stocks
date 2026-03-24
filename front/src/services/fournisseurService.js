import api from './api';

const BASE = '/fournisseurs';

export const fournisseurService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  findArticles: (id) => api.get(`${BASE}/${id}/articles`),
  create: (data) => api.post(BASE, data),
  update: (id, data) => api.put(`${BASE}/${id}`, data),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
