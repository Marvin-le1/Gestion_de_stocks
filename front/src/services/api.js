import axios from 'axios';

const api = axios.create({
  baseURL: process.env.REACT_APP_API_BASE_URL || 'http://localhost:8080/api',
  headers: { 'Content-Type': 'application/json' },
});

// Injecte automatiquement le token JWT dans chaque requête
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('negosud_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Si le token est expiré ou invalide → redirige vers /login (back-office seulement)
api.interceptors.response.use(
  (response) => response,
  (error) => {
    const isBoutique = window.location.pathname.startsWith('/boutique');
    if (error.response?.status === 401 && !isBoutique) {
      localStorage.removeItem('negosud_token');
      localStorage.removeItem('negosud_user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default api;
