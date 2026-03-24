import api from './api';

const BASE = '/commandes-fournisseurs';

export const commandeFournisseurService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  create: (data) => api.post(BASE, data),
  update: (id, data) => api.put(`${BASE}/${id}`, data),
  changerStatut: (id, statut) => api.patch(`${BASE}/${id}/statut`, { statut }),
  ajouterLigne: (id, data) => api.post(`${BASE}/${id}/lignes`, data),
  supprimerLigne: (id, ligneId) => api.delete(`${BASE}/${id}/lignes/${ligneId}`),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
