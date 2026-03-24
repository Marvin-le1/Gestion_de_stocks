import React from 'react';
import { NavLink } from 'react-router-dom';
import {
  Drawer, List, ListItemButton, ListItemIcon, ListItemText,
  Toolbar, Typography, Divider, Box,
} from '@mui/material';
import WineBarIcon from '@mui/icons-material/WineBar';
import CategoryIcon from '@mui/icons-material/Category';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import PeopleIcon from '@mui/icons-material/People';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import InventoryIcon from '@mui/icons-material/Inventory';
import AssignmentIcon from '@mui/icons-material/Assignment';

const DRAWER_WIDTH = 240;

const NAV_ITEMS = [
  { label: 'Articles', to: '/articles', icon: <WineBarIcon /> },
  { label: 'Familles', to: '/familles', icon: <CategoryIcon /> },
  { label: 'Fournisseurs', to: '/fournisseurs', icon: <LocalShippingIcon /> },
  { label: 'Clients', to: '/clients', icon: <PeopleIcon /> },
  { divider: true },
  { label: 'Commandes clients', to: '/commandes-clients', icon: <ShoppingCartIcon /> },
  { label: 'Commandes fournisseurs', to: '/commandes-fournisseurs', icon: <AssignmentIcon /> },
  { divider: true },
  { label: 'Inventaire', to: '/inventaire', icon: <InventoryIcon /> },
];

export default function Sidebar() {
  return (
    <Drawer
      variant="permanent"
      sx={{
        width: DRAWER_WIDTH,
        flexShrink: 0,
        '& .MuiDrawer-paper': {
          width: DRAWER_WIDTH,
          boxSizing: 'border-box',
          borderRight: '1px solid',
          borderColor: 'divider',
          backgroundColor: 'background.paper',
        },
      }}
    >
      <Toolbar sx={{ px: 2 }}>
        <WineBarIcon sx={{ mr: 1, color: 'primary.main' }} />
        <Typography variant="h6" color="primary" fontWeight={700} letterSpacing={0.5}>
          NEGOSUD
        </Typography>
      </Toolbar>
      <Divider />
      <Box sx={{ overflow: 'auto', mt: 1 }}>
        <List dense>
          {NAV_ITEMS.map((item, idx) =>
            item.divider ? (
              <Divider key={idx} sx={{ my: 1 }} />
            ) : (
              <ListItemButton
                key={item.to}
                component={NavLink}
                to={item.to}
                sx={{
                  mx: 1,
                  borderRadius: 1,
                  '&.active': {
                    backgroundColor: 'primary.main',
                    color: 'primary.contrastText',
                    '& .MuiListItemIcon-root': { color: 'primary.contrastText' },
                  },
                  '&:hover:not(.active)': { backgroundColor: 'action.hover' },
                }}
              >
                <ListItemIcon sx={{ minWidth: 36, color: 'text.secondary' }}>
                  {item.icon}
                </ListItemIcon>
                <ListItemText primary={item.label} />
              </ListItemButton>
            )
          )}
        </List>
      </Box>
    </Drawer>
  );
}
