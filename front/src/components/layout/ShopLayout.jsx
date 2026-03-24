import React from 'react';
import { Box } from '@mui/material';
import { Outlet } from 'react-router-dom';
import ShopNavbar from './ShopNavbar';
import ShopFooter from './ShopFooter';
import CartDrawer from '../shop/CartDrawer';

export default function ShopLayout() {
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
      <ShopNavbar />
      <CartDrawer />
      <Box component="main" sx={{ flexGrow: 1 }}>
        <Outlet />
      </Box>
      <ShopFooter />
    </Box>
  );
}
