import React from 'react';
import {
  AppBar, Toolbar, Typography, Box, IconButton, Badge,
  Button, Container, useMediaQuery, useTheme, Drawer,
  List, ListItemButton, ListItemText, Divider,
} from '@mui/material';
import WineBarIcon from '@mui/icons-material/WineBar';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import MenuIcon from '@mui/icons-material/Menu';
import { Link, useLocation } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';

const NAV_LINKS = [
  { label: 'Notre boutique', to: '/boutique' },
  { label: 'Contact', to: '/boutique/contact' },
];

export default function ShopNavbar() {
  const { cartCount, setDrawerOpen } = useCart();
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const [mobileOpen, setMobileOpen] = React.useState(false);
  const location = useLocation();

  return (
    <>
      <AppBar position="sticky" color="primary" elevation={2}>
        <Container maxWidth="xl">
          <Toolbar disableGutters sx={{ minHeight: 64 }}>
            {/* Logo */}
            <Box
              component={Link}
              to="/boutique"
              sx={{
                display: 'flex',
                alignItems: 'center',
                gap: 1,
                textDecoration: 'none',
                color: 'inherit',
                flexGrow: { xs: 1, md: 0 },
                mr: { md: 4 },
              }}
            >
              <WineBarIcon sx={{ fontSize: 28 }} />
              <Box>
                <Typography variant="h6" fontWeight={800} lineHeight={1}>
                  NÉGOSUD
                </Typography>
                <Typography variant="caption" sx={{ opacity: 0.8, lineHeight: 1 }}>
                  Vins du terroir gascon
                </Typography>
              </Box>
            </Box>

            {/* Desktop nav links */}
            {!isMobile && (
              <Box sx={{ display: 'flex', gap: 0.5, flexGrow: 1 }}>
                {NAV_LINKS.map((link) => (
                  <Button
                    key={link.to}
                    color="inherit"
                    component={Link}
                    to={link.to}
                    sx={{
                      fontWeight: location.pathname.startsWith(link.to) ? 700 : 400,
                      borderBottom: location.pathname.startsWith(link.to)
                        ? '2px solid rgba(255,255,255,0.8)'
                        : '2px solid transparent',
                      borderRadius: 0,
                    }}
                  >
                    {link.label}
                  </Button>
                ))}
              </Box>
            )}

            {/* Cart + mobile menu */}
            <IconButton
              color="inherit"
              onClick={() => setDrawerOpen(true)}
              aria-label="Ouvrir le panier"
            >
              <Badge badgeContent={cartCount} color="secondary">
                <ShoppingCartIcon />
              </Badge>
            </IconButton>

            {isMobile && (
              <IconButton color="inherit" onClick={() => setMobileOpen(true)}>
                <MenuIcon />
              </IconButton>
            )}
          </Toolbar>
        </Container>
      </AppBar>

      {/* Mobile menu drawer */}
      <Drawer
        anchor="top"
        open={mobileOpen}
        onClose={() => setMobileOpen(false)}
      >
        <List>
          {NAV_LINKS.map((link) => (
            <ListItemButton
              key={link.to}
              component={Link}
              to={link.to}
              onClick={() => setMobileOpen(false)}
            >
              <ListItemText primary={link.label} />
            </ListItemButton>
          ))}
          <Divider />
          <ListItemButton
            component={Link}
            to="/boutique/panier"
            onClick={() => setMobileOpen(false)}
          >
            <ListItemText primary={`Panier (${cartCount})`} />
          </ListItemButton>
        </List>
      </Drawer>
    </>
  );
}
