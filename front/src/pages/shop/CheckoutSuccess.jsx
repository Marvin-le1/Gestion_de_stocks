import React from 'react';
import { Container, Box, Typography, Button, Paper } from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import WineBarIcon from '@mui/icons-material/WineBar';
import { useNavigate, useSearchParams } from 'react-router-dom';

export default function CheckoutSuccess() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const commandeId = searchParams.get('commande');
  const prenom = searchParams.get('prenom');

  return (
    <Container maxWidth="sm" sx={{ py: 8 }}>
      <Paper
        elevation={0}
        sx={{
          p: { xs: 4, md: 6 },
          borderRadius: 3,
          border: '1px solid',
          borderColor: 'success.light',
          textAlign: 'center',
        }}
      >
        <CheckCircleIcon sx={{ fontSize: 72, color: 'success.main', mb: 2 }} />

        <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
          Merci {prenom ? prenom : ''} !
        </Typography>

        <Typography variant="body1" color="text.secondary" sx={{ mb: 1 }}>
          Votre commande a été enregistrée avec succès.
        </Typography>

        {commandeId && (
          <Typography variant="body1" sx={{ mb: 3 }}>
            Référence :{' '}
            <Box component="span" fontWeight={700} color="primary.main">
              #{commandeId}
            </Box>
          </Typography>
        )}

        <Typography variant="body2" color="text.secondary" sx={{ mb: 4 }}>
          Notre équipe vous contactera sous 24h pour confirmer et organiser
          la livraison de votre commande.
        </Typography>

        <Button
          variant="contained"
          size="large"
          startIcon={<WineBarIcon />}
          onClick={() => navigate('/boutique')}
        >
          Continuer mes achats
        </Button>
      </Paper>
    </Container>
  );
}
