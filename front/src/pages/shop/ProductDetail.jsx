import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Container, Grid, Box, Typography, Chip, Button, CircularProgress,
  Alert, Divider, TextField, Breadcrumbs, Link as MuiLink, Paper,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import WineBarIcon from '@mui/icons-material/WineBar';
import { articleService } from '../../services/articleService';
import { useCart } from '../../contexts/CartContext';
import { FAMILLE_COLORS } from '../../components/shop/ProductCard';

export default function ProductDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { addItem } = useCart();
  const [article, setArticle] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [qty, setQty] = useState(1);
  const [added, setAdded] = useState(false);

  useEffect(() => {
    articleService
      .findById(id)
      .then((res) => setArticle(res.data))
      .catch(() => setError('Article introuvable.'))
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
        <CircularProgress />
      </Box>
    );
  }
  if (error || !article) {
    return (
      <Container sx={{ py: 4 }}>
        <Alert severity="error">{error || 'Article introuvable'}</Alert>
      </Container>
    );
  }

  const type = article.famille?.type || 'ROUGE';
  const colors = FAMILLE_COLORS[type] || FAMILLE_COLORS.ROUGE;
  const inStock = article.quantiteStock > 0;
  const maxQty = article.quantiteStock;

  const handleAddToCart = () => {
    addItem(article, qty);
    setAdded(true);
    setTimeout(() => setAdded(false), 2000);
  };

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      {/* Fil d'Ariane */}
      <Breadcrumbs sx={{ mb: 2 }}>
        <MuiLink
          component="button"
          onClick={() => navigate('/boutique')}
          underline="hover"
          color="inherit"
          sx={{ cursor: 'pointer', background: 'none', border: 'none', font: 'inherit' }}
        >
          Boutique
        </MuiLink>
        <Typography color="text.primary">{article.designation}</Typography>
      </Breadcrumbs>

      <Button
        startIcon={<ArrowBackIcon />}
        onClick={() => navigate(-1)}
        sx={{ mb: 3, color: 'text.secondary' }}
      >
        Retour
      </Button>

      <Grid container spacing={4}>
        {/* Illustration du vin */}
        <Grid item xs={12} md={4}>
          <Paper
            elevation={0}
            sx={{
              aspectRatio: '3/4',
              backgroundColor: colors.bg,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              borderRadius: 3,
              border: '2px solid',
              borderColor: colors.text + '30',
            }}
          >
            <WineBarIcon sx={{ fontSize: 80, color: colors.text, opacity: 0.5, mb: 2 }} />
            <Chip
              label={colors.label}
              sx={{ backgroundColor: colors.bg, color: colors.text, fontWeight: 700 }}
            />
          </Paper>
        </Grid>

        {/* Détails */}
        <Grid item xs={12} md={8}>
          <Chip
            label={colors.label}
            size="small"
            sx={{ backgroundColor: colors.bg, color: colors.text, fontWeight: 700, mb: 2 }}
          />

          <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
            {article.designation}
          </Typography>

          {article.maison && (
            <Typography variant="h6" color="text.secondary" gutterBottom>
              {article.maison}
            </Typography>
          )}

          {article.annee && (
            <Typography variant="subtitle1" color="text.secondary" sx={{ mb: 2 }}>
              Millésime {article.annee}
            </Typography>
          )}

          {article.description && (
            <Typography variant="body1" color="text.secondary" sx={{ mb: 3, lineHeight: 1.8 }}>
              {article.description}
            </Typography>
          )}

          <Divider sx={{ my: 2 }} />

          {/* Prix */}
          <Box sx={{ mb: 3 }}>
            <Typography variant="h4" color="primary.main" fontWeight={800}>
              {Number(article.prixUnitaire).toFixed(2)} €
              <Typography component="span" variant="body1" color="text.secondary" sx={{ ml: 1 }}>
                / bouteille
              </Typography>
            </Typography>
            {article.prixCarton && (
              <Typography variant="subtitle1" color="secondary.dark" fontWeight={600} sx={{ mt: 0.5 }}>
                {Number(article.prixCarton).toFixed(2)} € / carton
              </Typography>
            )}
          </Box>

          {/* Disponibilité */}
          <Box sx={{ mb: 3 }}>
            {inStock ? (
              <Typography variant="body2" color="success.main" fontWeight={600}>
                En stock — {article.quantiteStock} bouteille
                {article.quantiteStock > 1 ? 's' : ''} disponible
                {article.quantiteStock > 1 ? 's' : ''}
              </Typography>
            ) : (
              <Typography variant="body2" color="error.main" fontWeight={600}>
                Rupture de stock
              </Typography>
            )}
          </Box>

          {/* Ajout au panier */}
          <Box sx={{ display: 'flex', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
            <TextField
              type="number"
              label="Quantité"
              value={qty}
              onChange={(e) =>
                setQty(Math.max(1, Math.min(maxQty, parseInt(e.target.value) || 1)))
              }
              inputProps={{ min: 1, max: maxQty }}
              size="small"
              sx={{ width: 110 }}
              disabled={!inStock}
            />
            <Button
              variant="contained"
              size="large"
              startIcon={<AddShoppingCartIcon />}
              onClick={handleAddToCart}
              disabled={!inStock}
              color={added ? 'success' : 'primary'}
              sx={{ px: 4 }}
            >
              {added ? 'Ajouté !' : 'Ajouter au panier'}
            </Button>
          </Box>

          {/* Caractéristiques */}
          <Divider sx={{ my: 3 }} />
          <Box
            sx={{
              display: 'grid',
              gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))',
              gap: 2,
            }}
          >
            {[
              { label: 'Référence', value: article.reference },
              { label: 'Famille', value: article.famille?.type },
              { label: 'Maison', value: article.maison },
              { label: 'Millésime', value: article.annee },
            ]
              .filter((i) => i.value)
              .map((item) => (
                <Box key={item.label}>
                  <Typography
                    variant="caption"
                    color="text.secondary"
                    textTransform="uppercase"
                    letterSpacing={0.5}
                    display="block"
                  >
                    {item.label}
                  </Typography>
                  <Typography variant="body2" fontWeight={600}>
                    {item.value}
                  </Typography>
                </Box>
              ))}
          </Box>
        </Grid>
      </Grid>
    </Container>
  );
}
