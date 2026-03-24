import api from './api';

const BASE = '/articles';

export const articleService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  findByFamille: (familleId) => api.get(`${BASE}/famille/${familleId}`),
  findByFournisseur: (fournisseurId) => api.get(`${BASE}/fournisseur/${fournisseurId}`),
  create: (data) => api.post(BASE, data),
  update: (id, data) => api.put(`${BASE}/${id}`, data),
  ajusterStock: (id, data) => api.patch(`${BASE}/${id}/stock`, data),
  toggleReapprovisionnement: (id, data) => api.patch(`${BASE}/${id}/reapprovisionnement`, data),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
