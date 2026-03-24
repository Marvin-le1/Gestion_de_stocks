import React from 'react';
import { BrowserRouter } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme';
import { NotificationProvider } from './contexts/NotificationContext';
import { AuthProvider } from './contexts/AuthContext';
import { CartProvider } from './contexts/CartContext';
import { ShopAuthProvider } from './contexts/ShopAuthContext';
import AppRoutes from './routes/AppRoutes';

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <AuthProvider>
          <ShopAuthProvider>
            <CartProvider>
              <NotificationProvider>
                <AppRoutes />
              </NotificationProvider>
            </CartProvider>
          </ShopAuthProvider>
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  );
}
