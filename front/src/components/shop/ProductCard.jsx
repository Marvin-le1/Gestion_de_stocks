import React from 'react';
import {
  Card, CardContent, CardActions, Typography, Box, Chip, Button,
  Tooltip, IconButton,
} from '@mui/material';
import AddShoppingCartIcon from '@mui/icons-material/AddShoppingCart';
import InfoOutlinedIcon from '@mui/icons-material/InfoOutlined';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';

export const FAMILLE_COLORS = {
  ROUGE:     { bg: '#F9E8E8', text: '#7B1212', label: 'Rouge' },
  ROSE:      { bg: '#FDE8F0', text: '#A01F5A', label: 'Rosé' },
  BLANC:     { bg: '#FEFCE8', text: '#856A0A', label: 'Blanc' },
  PETILLANT: { bg: '#E8F4FC', text: '#1565A0', label: 'Pétillant' },
  DIGESTIF:  { bg: '#F5EDD8', text: '#7A4F1D', label: 'Digestif' },
};

export default function ProductCard({ article }) {
  const navigate = useNavigate();
  const { addItem } = useCart();

  const type = article.famille?.type || 'ROUGE';
  const colors = FAMILLE_COLORS[type] || FAMILLE_COLORS.ROUGE;
  const inStock = article.quantiteStock > 0;

  const handleAddToCart = (e) => {
    e.stopPropagation();
    if (inStock) addItem(article, 1);
  };

  return (
    <Card
      sx={{
        height: '100%',
        display: 'flex',
        flexDirection: 'column',
        cursor: 'pointer',
        transition: 'transform 0.15s, box-shadow 0.15s',
        '&:hover': { transform: 'translateY(-2px)', boxShadow: 4 },
      }}
      onClick={() => navigate(`/boutique/${article.id}`)}
    >
      {/* Bande colorée selon le type de vin */}
      <Box sx={{ height: 6, backgroundColor: colors.text }} />

      <CardContent sx={{ flexGrow: 1, pb: 0 }}>
        {/* Badge famille + indicateur stock */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1.5 }}>
          <Chip
            label={colors.label}
            size="small"
            sx={{
              backgroundColor: colors.bg,
              color: colors.text,
              fontWeight: 600,
              fontSize: '0.7rem',
            }}
          />
          {!inStock && (
            <Chip
              label="Rupture"
              size="small"
              color="error"
              variant="outlined"
              sx={{ fontSize: '0.7rem' }}
            />
          )}
          {inStock && article.quantiteStock <= 6 && (
            <Chip
              label={`${article.quantiteStock} restant${article.quantiteStock > 1 ? 's' : ''}`}
              size="small"
              color="warning"
              variant="outlined"
              sx={{ fontSize: '0.7rem' }}
            />
          )}
        </Box>

        {/* Désignation */}
        <Typography
          variant="subtitle1"
          fontWeight={700}
          color="text.primary"
          sx={{ mb: 0.5, lineHeight: 1.3, minHeight: '2.6em' }}
        >
          {article.designation}
        </Typography>

        {/* Maison & Millésime */}
        {article.maison && (
          <Typography variant="body2" color="text.secondary" noWrap>
            {article.maison}
          </Typography>
        )}
        {article.annee && (
          <Typography variant="body2" color="text.secondary">
            Millésime {article.annee}
          </Typography>
        )}

        {/* Prix */}
        <Box sx={{ mt: 2 }}>
          <Typography variant="h6" color="primary.main" fontWeight={700} lineHeight={1.2}>
            {Number(article.prixUnitaire).toFixed(2)} €
            <Typography
              component="span"
              variant="caption"
              color="text.secondary"
              sx={{ ml: 0.5 }}
            >
              / bouteille
            </Typography>
          </Typography>
          {article.prixCarton && (
            <Typography variant="body2" color="text.secondary" sx={{ mt: 0.25 }}>
              {Number(article.prixCarton).toFixed(2)} € / carton
            </Typography>
          )}
        </Box>
      </CardContent>

      <CardActions sx={{ px: 2, pb: 2, pt: 1, gap: 1 }}>
        <Button
          variant="contained"
          size="small"
          startIcon={<AddShoppingCartIcon />}
          onClick={handleAddToCart}
          disabled={!inStock}
          fullWidth
        >
          {inStock ? 'Ajouter' : 'Indisponible'}
        </Button>
        <Tooltip title="Voir le détail">
          <IconButton
            size="small"
            color="primary"
            onClick={(e) => {
              e.stopPropagation();
              navigate(`/boutique/${article.id}`);
            }}
          >
            <InfoOutlinedIcon fontSize="small" />
          </IconButton>
        </Tooltip>
      </CardActions>
    </Card>
  );
}
