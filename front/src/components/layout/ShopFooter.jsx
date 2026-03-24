import React from 'react';
import {
  Box, Container, Typography, Grid, Link as MuiLink, Divider,
} from '@mui/material';
import WineBarIcon from '@mui/icons-material/WineBar';
import { Link } from 'react-router-dom';

const SHOP_LINKS = [
  { label: 'Tous nos vins', to: '/boutique' },
  { label: 'Vins rouges', to: '/boutique?famille=ROUGE' },
  { label: 'Vins blancs', to: '/boutique?famille=BLANC' },
  { label: 'Rosés', to: '/boutique?famille=ROSE' },
  { label: 'Pétillants', to: '/boutique?famille=PETILLANT' },
  { label: 'Digestifs', to: '/boutique?famille=DIGESTIF' },
];

export default function ShopFooter() {
  return (
    <Box
      component="footer"
      sx={{
        backgroundColor: 'primary.dark',
        color: 'rgba(255,255,255,0.9)',
        pt: 5,
        pb: 3,
        mt: 'auto',
      }}
    >
      <Container maxWidth="xl">
        <Grid container spacing={4}>
          {/* Brand */}
          <Grid item xs={12} md={4}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
              <WineBarIcon sx={{ fontSize: 28, color: 'secondary.main' }} />
              <Typography variant="h6" fontWeight={800}>
                NÉGOSUD
              </Typography>
            </Box>
            <Typography variant="body2" sx={{ opacity: 0.8, maxWidth: 280, lineHeight: 1.7 }}>
              Négociant en vins du terroir gascon. Découvrez nos sélections
              soigneusement choisies parmi les meilleurs domaines du Gers.
            </Typography>
          </Grid>

          {/* Navigation boutique */}
          <Grid item xs={6} md={3}>
            <Typography
              variant="subtitle2"
              fontWeight={700}
              sx={{ mb: 1.5, color: 'secondary.light' }}
            >
              La boutique
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.75 }}>
              {SHOP_LINKS.map((link) => (
                <MuiLink
                  key={link.label}
                  component={Link}
                  to={link.to}
                  sx={{
                    color: 'rgba(255,255,255,0.7)',
                    textDecoration: 'none',
                    fontSize: '0.875rem',
                    '&:hover': { color: 'secondary.main' },
                  }}
                >
                  {link.label}
                </MuiLink>
              ))}
            </Box>
          </Grid>

          {/* Contact */}
          <Grid item xs={6} md={3}>
            <Typography
              variant="subtitle2"
              fontWeight={700}
              sx={{ mb: 1.5, color: 'secondary.light' }}
            >
              Contact
            </Typography>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.75 }}>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                Route des Vins, 32000 Auch
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                contact@negosud.fr
              </Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }}>
                +33 5 62 00 00 00
              </Typography>
              <MuiLink
                component={Link}
                to="/boutique/contact"
                sx={{
                  color: 'secondary.main',
                  textDecoration: 'none',
                  fontSize: '0.875rem',
                  mt: 0.5,
                  '&:hover': { textDecoration: 'underline' },
                }}
              >
                Formulaire de contact →
              </MuiLink>
            </Box>
          </Grid>
        </Grid>

        <Divider sx={{ borderColor: 'rgba(255,255,255,0.1)', my: 3 }} />
        <Box sx={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 1 }}>
          <Typography variant="caption" sx={{ opacity: 0.5 }}>
            © {new Date().getFullYear()} NÉGOSUD — Tous droits réservés
          </Typography>
          <Typography variant="caption" sx={{ opacity: 0.5 }}>
            L'abus d'alcool est dangereux pour la santé. À consommer avec modération.
          </Typography>
        </Box>
      </Container>
    </Box>
  );
}
