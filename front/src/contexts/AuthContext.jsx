import React, { createContext, useContext, useState, useCallback } from 'react';
import api from '../services/api';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem('negosud_user');
    return stored ? JSON.parse(stored) : null;
  });

  const login = useCallback(async (email, motDePasse) => {
    const res = await api.post('/auth/login', { email, motDePasse });
    const { token, nom, role } = res.data;
    const userData = { email, nom, role, token };
    localStorage.setItem('negosud_user', JSON.stringify(userData));
    localStorage.setItem('negosud_token', token);
    setUser(userData);
    return userData;
  }, []);

  const logout = useCallback(() => {
    localStorage.removeItem('negosud_user');
    localStorage.removeItem('negosud_token');
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider value={{ user, login, logout, isAuthenticated: !!user }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth doit être utilisé dans AuthProvider');
  return ctx;
}
