import React from 'react';
import {
  AppBar, Toolbar, Typography, Box, IconButton, Badge,
  Button, Container, useMediaQuery, useTheme, Drawer,
  List, ListItemButton, ListItemText, Divider, Avatar,
  Menu, MenuItem,
} from '@mui/material';
import WineBarIcon from '@mui/icons-material/WineBar';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import MenuIcon from '@mui/icons-material/Menu';
import PersonIcon from '@mui/icons-material/Person';
import LogoutIcon from '@mui/icons-material/Logout';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';
import { useShopAuth } from '../../contexts/ShopAuthContext';

const NAV_LINKS = [
  { label: 'Notre boutique', to: '/boutique' },
  { label: 'Contact', to: '/boutique/contact' },
];

export default function ShopNavbar() {
  const { cartCount, setDrawerOpen } = useCart();
  const { shopClient, logoutShop }   = useShopAuth();
  const theme    = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const location = useLocation();
  const navigate = useNavigate();

  const [mobileOpen, setMobileOpen] = React.useState(false);
  const [anchorEl, setAnchorEl]     = React.useState(null);

  const handleMenuOpen  = (e) => setAnchorEl(e.currentTarget);
  const handleMenuClose = () => setAnchorEl(null);

  const handleLogout = () => {
    logoutShop();
    handleMenuClose();
    navigate('/boutique');
  };

  const initials = shopClient
    ? `${shopClient.prenom?.charAt(0) ?? ''}${shopClient.nom?.charAt(0) ?? ''}`.toUpperCase()
    : '';

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
                display: 'flex', alignItems: 'center', gap: 1,
                textDecoration: 'none', color: 'inherit',
                flexGrow: { xs: 1, md: 0 }, mr: { md: 4 },
              }}
            >
              <WineBarIcon sx={{ fontSize: 28 }} />
              <Box>
                <Typography variant="h6" fontWeight={800} lineHeight={1}>NÉGOSUD</Typography>
                <Typography variant="caption" sx={{ opacity: 0.8, lineHeight: 1 }}>
                  Vins du terroir gascon
                </Typography>
              </Box>
            </Box>

            {/* Desktop nav */}
            {!isMobile && (
              <Box sx={{ display: 'flex', gap: 0.5, flexGrow: 1 }}>
                {NAV_LINKS.map((link) => (
                  <Button
                    key={link.to}
                    color="inherit"
                    component={Link}
                    to={link.to}
                    sx={{
                      fontWeight: location.pathname === link.to ? 700 : 400,
                      borderBottom: location.pathname === link.to
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

            {/* Panier */}
            <IconButton color="inherit" onClick={() => setDrawerOpen(true)} aria-label="Ouvrir le panier">
              <Badge badgeContent={cartCount} color="secondary">
                <ShoppingCartIcon />
              </Badge>
            </IconButton>

            {/* Compte client */}
            {!isMobile && (
              shopClient ? (
                <>
                  <Avatar
                    onClick={handleMenuOpen}
                    sx={{
                      ml: 1.5, width: 34, height: 34, fontSize: 13,
                      bgcolor: 'secondary.main', color: 'primary.dark',
                      cursor: 'pointer', fontWeight: 700,
                      '&:hover': { opacity: 0.85 },
                    }}
                  >
                    {initials}
                  </Avatar>
                  <Menu
                    anchorEl={anchorEl}
                    open={Boolean(anchorEl)}
                    onClose={handleMenuClose}
                    transformOrigin={{ vertical: 'top', horizontal: 'right' }}
                    anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
                  >
                    <MenuItem disabled sx={{ opacity: '1 !important' }}>
                      <Box>
                        <Typography variant="body2" fontWeight={700}>
                          {shopClient.prenom} {shopClient.nom}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {shopClient.email}
                        </Typography>
                      </Box>
                    </MenuItem>
                    <Divider />
                    <MenuItem onClick={handleLogout} sx={{ gap: 1, color: 'error.main' }}>
                      <LogoutIcon fontSize="small" />
                      Se déconnecter
                    </MenuItem>
                  </Menu>
                </>
              ) : (
                <Button
                  color="inherit"
                  component={Link}
                  to="/boutique/connexion"
                  startIcon={<PersonIcon />}
                  sx={{ ml: 1.5, border: '1px solid rgba(255,255,255,0.4)', borderRadius: 2, px: 1.5 }}
                >
                  Se connecter
                </Button>
              )
            )}

            {/* Mobile menu */}
            {isMobile && (
              <IconButton color="inherit" onClick={() => setMobileOpen(true)}>
                <MenuIcon />
              </IconButton>
            )}
          </Toolbar>
        </Container>
      </AppBar>

      {/* Mobile drawer */}
      <Drawer anchor="top" open={mobileOpen} onClose={() => setMobileOpen(false)}>
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
          <Divider />
          {shopClient ? (
            <ListItemButton onClick={() => { logoutShop(); setMobileOpen(false); }}>
              <ListItemText
                primary={`${shopClient.prenom} ${shopClient.nom}`}
                secondary="Se déconnecter"
              />
            </ListItemButton>
          ) : (
            <ListItemButton
              component={Link}
              to="/boutique/connexion"
              onClick={() => setMobileOpen(false)}
            >
              <ListItemText primary="Se connecter" />
            </ListItemButton>
          )}
        </List>
      </Drawer>
    </>
  );
}
