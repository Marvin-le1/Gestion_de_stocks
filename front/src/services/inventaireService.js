import api from './api';

const BASE = '/inventaires';

export const inventaireService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  create: (data) => api.post(BASE, data),
  regulariser: (id) => api.post(`${BASE}/${id}/regulariser`),
};
