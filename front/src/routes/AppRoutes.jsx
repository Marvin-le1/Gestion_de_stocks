import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

// Back-office
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
import Utilisateurs from '../pages/utilisateurs/Utilisateurs';

// Boutique (front-office client)
import ShopLayout from '../components/layout/ShopLayout';
import Catalogue from '../pages/shop/Catalogue';
import ProductDetail from '../pages/shop/ProductDetail';
import Cart from '../pages/shop/Cart';
import Checkout from '../pages/shop/Checkout';
import CheckoutSuccess from '../pages/shop/CheckoutSuccess';
import Contact from '../pages/shop/Contact';
import BoutiqueLogin from '../pages/shop/BoutiqueLogin';

function PrivateRoute({ children }) {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function AdminRoute({ children }) {
  const { user, isAuthenticated } = useAuth();
  if (!isAuthenticated) return <Navigate to="/login" replace />;
  if (user?.role !== 'ADMIN') return <Navigate to="/articles" replace />;
  return children;
}

export default function AppRoutes() {
  return (
    <Routes>
      {/* Boutique front-office — accès public */}
      <Route path="/boutique" element={<ShopLayout />}>
        <Route index element={<Catalogue />} />
        <Route path=":id" element={<ProductDetail />} />
        <Route path="panier" element={<Cart />} />
        <Route path="commande" element={<Checkout />} />
        <Route path="confirmation" element={<CheckoutSuccess />} />
        <Route path="contact" element={<Contact />} />
        <Route path="connexion" element={<BoutiqueLogin />} />
      </Route>

      {/* Back-office — accès privé */}
      <Route path="/login" element={<Login />} />
      <Route
        element={
          <PrivateRoute>
            <Layout />
          </PrivateRoute>
        }
      >
        <Route path="/articles" element={<Articles />} />
        <Route path="/familles" element={<Familles />} />
        <Route path="/fournisseurs" element={<Fournisseurs />} />
        <Route path="/clients" element={<Clients />} />
        <Route path="/commandes-clients" element={<CommandesClients />} />
        <Route path="/commandes-clients/:id" element={<CommandeClientDetail />} />
        <Route path="/commandes-fournisseurs" element={<CommandesFournisseurs />} />
        <Route path="/commandes-fournisseurs/:id" element={<CommandeFournisseurDetail />} />
        <Route path="/inventaire" element={<Inventaire />} />
        <Route
          path="/utilisateurs"
          element={
            <AdminRoute>
              <Utilisateurs />
            </AdminRoute>
          }
        />
      </Route>

      {/* Racine et routes inconnues → boutique */}
      <Route index element={<Navigate to="/boutique" replace />} />
      <Route path="*" element={<Navigate to="/boutique" replace />} />
    </Routes>
  );
}
