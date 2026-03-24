import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import Layout from '../components/layout/Layout';
import Login from '../pages/auth/Login';
import Articles from '../pages/articles/Articles';
import Familles from '../pages/familles/Familles';
import Fournisseurs from '../pages/fournisseurs/Fournisseurs';
import Clients from '../pages/clients/Clients';
import CommandesClients from '../pages/commandes-clients/CommandesClients';
import CommandeClientDetail from '../pages/commandes-clients/CommandeClientDetail';
import CommandesFournisseurs from '../pages/commandes-fournisseurs/CommandesFournisseurs';
import CommandeFournisseurDetail from '../pages/commandes-fournisseurs/CommandeFournisseurDetail';
import Inventaire from '../pages/inventaire/Inventaire';

function PrivateRoute({ children }) {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

export default function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route index element={<Navigate to="/articles" replace />} />
        <Route path="/articles" element={<Articles />} />
        <Route path="/familles" element={<Familles />} />
        <Route path="/fournisseurs" element={<Fournisseurs />} />
        <Route path="/clients" element={<Clients />} />
        <Route path="/commandes-clients" element={<CommandesClients />} />
        <Route path="/commandes-clients/:id" element={<CommandeClientDetail />} />
        <Route path="/commandes-fournisseurs" element={<CommandesFournisseurs />} />
        <Route path="/commandes-fournisseurs/:id" element={<CommandeFournisseurDetail />} />
        <Route path="/inventaire" element={<Inventaire />} />
      </Route>
    </Routes>
  );
}
