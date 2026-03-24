import api from './api';

const BASE = '/commandes-clients';

export const commandeClientService = {
  findAll: () => api.get(BASE),
  findById: (id) => api.get(`${BASE}/${id}`),
  findLignes: (id) => api.get(`${BASE}/${id}/lignes`),
  create: (data) => api.post(BASE, data),
  update: (id, data) => api.put(`${BASE}/${id}`, data),
  changerStatut: (id, statut) => api.patch(`${BASE}/${id}/statut`, { statut }),
  ajouterLigne: (id, data) => api.post(`${BASE}/${id}/lignes`, data),
  supprimerLigne: (id, ligneId) => api.delete(`${BASE}/${id}/lignes/${ligneId}`),
  delete: (id) => api.delete(`${BASE}/${id}`),
};
