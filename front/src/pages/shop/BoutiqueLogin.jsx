import React, { useState } from 'react';
import {
  Container, Paper, Typography, TextField, Button, Box,
  Divider, Alert, CircularProgress, InputAdornment, IconButton, Link as MuiLink,
} from '@mui/material';
import WineBarIcon from '@mui/icons-material/WineBar';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import api from '../../services/api';
import { clientService } from '../../services/clientService';
import { useShopAuth } from '../../contexts/ShopAuthContext';
import { useAuth } from '../../contexts/AuthContext';

export default function BoutiqueLogin() {
  const { loginShop }  = useShopAuth();
  const { login }      = useAuth();
  const navigate       = useNavigate();
  const location       = useLocation();
  const from           = location.state?.from || '/boutique';

  const [email, setEmail]           = useState('');
  const [motDePasse, setMotDePasse] = useState('');
  const [showPwd, setShowPwd]       = useState(false);
  const [errors, setErrors]         = useState({});
  const [loginError, setLoginError] = useState('');
  const [loading, setLoading]       = useState(false);

  const validate = () => {
    const errs = {};
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) errs.email = 'Email invalide';
    if (!motDePasse) errs.motDePasse = 'Mot de passe requis';
    return errs;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }
    setLoginError('');
    setLoading(true);
    try {
      // 1. Essai login client boutique
      try {
        const res = await clientService.loginClient(email, motDePasse);
        loginShop(res.data);
        navigate(from, { replace: true });
        return;
      } catch {
        // Pas un client — on essaie le compte back-office
      }

      // 2. Essai login admin / employé
      try {
        const userData = await login(email, motDePasse);
        if (userData.role === 'ADMIN' || userData.role === 'EMPLOYE') {
          navigate('/articles', { replace: true });
          return;
        }
      } catch {
        // Pas un compte back-office non plus
      }

      setLoginError('Email ou mot de passe incorrect');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="xs" sx={{ py: 8 }}>
      {/* Logo */}
      <Box sx={{ textAlign: 'center', mb: 4 }}>
        <Box
          component={Link}
          to="/boutique"
          sx={{ display: 'inline-flex', alignItems: 'center', gap: 1, textDecoration: 'none', color: 'primary.main' }}
        >
          <WineBarIcon sx={{ fontSize: 36 }} />
          <Typography variant="h5" fontWeight={800} color="primary.dark">
            NÉGOSUD
          </Typography>
        </Box>
        <Typography variant="body2" color="text.secondary" mt={1}>
          Connectez-vous à votre espace client
        </Typography>
      </Box>

      <Paper variant="outlined" sx={{ p: 4 }}>
        <Typography variant="h6" fontWeight={700} gutterBottom>
          Connexion
        </Typography>
        <Divider sx={{ mb: 3 }} />

        {loginError && (
          <Alert severity="error" sx={{ mb: 2 }}>{loginError}</Alert>
        )}

        <Box component="form" onSubmit={handleSubmit} noValidate>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
            <TextField
              label="Email"
              type="email"
              value={email}
              onChange={(e) => { setEmail(e.target.value); setErrors((err) => ({ ...err, email: '' })); }}
              error={!!errors.email}
              helperText={errors.email}
              fullWidth
              size="small"
              autoFocus
              autoComplete="email"
            />
            <TextField
              label="Mot de passe"
              type={showPwd ? 'text' : 'password'}
              value={motDePasse}
              onChange={(e) => { setMotDePasse(e.target.value); setErrors((err) => ({ ...err, motDePasse: '' })); }}
              error={!!errors.motDePasse}
              helperText={errors.motDePasse}
              fullWidth
              size="small"
              autoComplete="current-password"
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton size="small" onClick={() => setShowPwd((s) => !s)}>
                      {showPwd ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />

            <Button
              type="submit"
              variant="contained"
              fullWidth
              disabled={loading}
              startIcon={loading ? <CircularProgress size={16} color="inherit" /> : null}
              sx={{ mt: 1 }}
            >
              {loading ? 'Connexion…' : 'Se connecter'}
            </Button>
          </Box>
        </Box>

        <Divider sx={{ my: 3 }}>
          <Typography variant="caption" color="text.secondary">pas encore de compte ?</Typography>
        </Divider>

        <Typography variant="body2" color="text.secondary" textAlign="center">
          Un compte est créé automatiquement lors de votre{' '}
          <MuiLink component={Link} to="/boutique/commande" color="primary">
            première commande
          </MuiLink>
          .
        </Typography>
      </Paper>

      <Box sx={{ textAlign: 'center', mt: 2 }}>
        <MuiLink component={Link} to="/boutique" variant="body2" color="text.secondary">
          ← Retour à la boutique
        </MuiLink>
      </Box>
    </Container>
  );
}
