import React from 'react';
import { Outlet } from 'react-router-dom';
import { Box } from '@mui/material';
import Sidebar from './Sidebar';

export default function Layout() {
  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', backgroundColor: 'background.default' }}>
      <Sidebar />
      <Box
        component="main"
        sx={{ flexGrow: 1, p: 3, overflow: 'auto' }}
      >
        <Outlet />
      </Box>
    </Box>
  );
}
