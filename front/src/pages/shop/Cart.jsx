import React from 'react';
import {
  Container, Typography, Box, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Paper, IconButton,
  TextField, Button, Divider,
} from '@mui/material';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import ArrowForwardIcon from '@mui/icons-material/ArrowForward';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';

export default function Cart() {
  const { items, removeItem, updateQty, cartTotal } = useCart();
  const navigate = useNavigate();

  if (items.length === 0) {
    return (
      <Container maxWidth="md" sx={{ py: 10, textAlign: 'center' }}>
        <ShoppingCartIcon sx={{ fontSize: 64, color: 'text.disabled', mb: 2 }} />
        <Typography variant="h5" fontWeight={700} gutterBottom>
          Votre panier est vide
        </Typography>
        <Typography color="text.secondary" sx={{ mb: 3 }}>
          Découvrez notre sélection de vins du terroir gascon.
        </Typography>
        <Button variant="contained" size="large" onClick={() => navigate('/boutique')}>
          Voir la boutique
        </Button>
      </Container>
    );
  }

  const totalItems = items.reduce((s, i) => s + i.quantite, 0);

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
        Mon panier
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        {totalItems} article{totalItems > 1 ? 's' : ''}
      </Typography>

      <Box sx={{ display: 'flex', gap: 4, flexDirection: { xs: 'column', md: 'row' } }}>
        {/* Tableau des articles */}
        <Box sx={{ flexGrow: 1 }}>
          <TableContainer component={Paper} variant="outlined">
            <Table>
              <TableHead>
                <TableRow sx={{ '& th': { fontWeight: 700 } }}>
                  <TableCell>Article</TableCell>
                  <TableCell align="right">Prix unit.</TableCell>
                  <TableCell align="center">Quantité</TableCell>
                  <TableCell align="right">Total</TableCell>
                  <TableCell />
                </TableRow>
              </TableHead>
              <TableBody>
                {items.map(({ article, quantite }) => (
                  <TableRow key={article.id}>
                    <TableCell>
                      <Typography
                        variant="subtitle2"
                        fontWeight={600}
                        sx={{ cursor: 'pointer', '&:hover': { color: 'primary.main' } }}
                        onClick={() => navigate(`/boutique/${article.id}`)}
                      >
                        {article.designation}
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        {[article.maison, article.annee].filter(Boolean).join(' · ')}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      {Number(article.prixUnitaire).toFixed(2)} €
                    </TableCell>
                    <TableCell align="center">
                      <TextField
                        type="number"
                        value={quantite}
                        onChange={(e) =>
                          updateQty(article.id, parseInt(e.target.value, 10))
                        }
                        inputProps={{
                          min: 1,
                          max: article.quantiteStock,
                          style: { textAlign: 'center' },
                        }}
                        size="small"
                        sx={{ width: 80 }}
                      />
                    </TableCell>
                    <TableCell align="right">
                      <Typography fontWeight={600}>
                        {(Number(article.prixUnitaire) * quantite).toFixed(2)} €
                      </Typography>
                    </TableCell>
                    <TableCell>
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => removeItem(article.id)}
                        aria-label="Supprimer"
                      >
                        <DeleteOutlineIcon />
                      </IconButton>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
        </Box>

        {/* Résumé de commande */}
        <Box sx={{ width: { xs: '100%', md: 320 }, flexShrink: 0 }}>
          <Paper variant="outlined" sx={{ p: 3 }}>
            <Typography variant="h6" fontWeight={700} gutterBottom>
              Récapitulatif
            </Typography>
            <Divider sx={{ mb: 2 }} />

            {items.map(({ article, quantite }) => (
              <Box
                key={article.id}
                sx={{ display: 'flex', justifyContent: 'space-between', mb: 1 }}
              >
                <Typography variant="body2" noWrap sx={{ maxWidth: 180 }}>
                  {article.designation} ×{quantite}
                </Typography>
                <Typography variant="body2">
                  {(Number(article.prixUnitaire) * quantite).toFixed(2)} €
                </Typography>
              </Box>
            ))}

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
              <Typography fontWeight={700}>Total</Typography>
              <Typography fontWeight={700} color="primary.main" variant="h6">
                {cartTotal.toFixed(2)} €
              </Typography>
            </Box>

            <Button
              variant="contained"
              fullWidth
              size="large"
              endIcon={<ArrowForwardIcon />}
              onClick={() => navigate('/boutique/commande')}
            >
              Passer la commande
            </Button>
            <Button
              variant="text"
              fullWidth
              sx={{ mt: 1, color: 'text.secondary' }}
              onClick={() => navigate('/boutique')}
            >
              Continuer mes achats
            </Button>
          </Paper>
        </Box>
      </Box>
    </Container>
  );
}
