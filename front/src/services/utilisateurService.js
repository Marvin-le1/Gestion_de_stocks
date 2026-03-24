import api from './api';

const BASE = '/utilisateurs';

export const utilisateurService = {
  findAll: () => api.get(BASE),
  create: (data) => api.post(BASE, data),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
