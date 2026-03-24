import React from 'react';
import {
  Drawer, Box, Typography, Divider, IconButton, List, ListItem,
  Button, Badge, TextField,
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';

export default function CartDrawer() {
  const { items, removeItem, updateQty, cartTotal, drawerOpen, setDrawerOpen } = useCart();
  const navigate = useNavigate();

  const goTo = (path) => {
    setDrawerOpen(false);
    navigate(path);
  };

  const totalItems = items.reduce((s, i) => s + i.quantite, 0);

  return (
    <Drawer
      anchor="right"
      open={drawerOpen}
      onClose={() => setDrawerOpen(false)}
      PaperProps={{ sx: { width: { xs: '100vw', sm: 420 } } }}
    >
      <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
        {/* Header */}
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            px: 2,
            py: 1.5,
            borderBottom: 1,
            borderColor: 'divider',
          }}
        >
          <Badge badgeContent={totalItems} color="primary">
            <ShoppingCartIcon color="action" />
          </Badge>
          <Typography variant="h6" fontWeight={600} sx={{ ml: 1.5, flexGrow: 1 }}>
            Mon panier
          </Typography>
          <IconButton size="small" onClick={() => setDrawerOpen(false)}>
            <CloseIcon />
          </IconButton>
        </Box>

        {/* Liste des articles */}
        <Box sx={{ flexGrow: 1, overflow: 'auto' }}>
          {items.length === 0 ? (
            <Box sx={{ p: 4, textAlign: 'center' }}>
              <ShoppingCartIcon sx={{ fontSize: 48, color: 'text.disabled', mb: 1 }} />
              <Typography color="text.secondary">Votre panier est vide</Typography>
              <Button
                variant="outlined"
                size="small"
                sx={{ mt: 2 }}
                onClick={() => goTo('/boutique')}
              >
                Découvrir nos vins
              </Button>
            </Box>
          ) : (
            <List disablePadding>
              {items.map(({ article, quantite }) => (
                <React.Fragment key={article.id}>
                  <ListItem sx={{ px: 2, py: 1.5, alignItems: 'flex-start' }}>
                    <Box sx={{ flexGrow: 1 }}>
                      <Typography variant="subtitle2" fontWeight={600}>
                        {article.designation}
                      </Typography>
                      <Typography variant="body2" color="text.secondary">
                        {[article.maison, article.annee].filter(Boolean).join(' · ')}
                      </Typography>
                      <Box sx={{ display: 'flex', alignItems: 'center', mt: 1, gap: 1 }}>
                        <TextField
                          type="number"
                          value={quantite}
                          onChange={(e) =>
                            updateQty(article.id, parseInt(e.target.value, 10))
                          }
                          inputProps={{
                            min: 1,
                            max: article.quantiteStock,
                            style: { textAlign: 'center', padding: '4px 6px' },
                          }}
                          size="small"
                          sx={{ width: 70 }}
                        />
                        <Typography
                          variant="body2"
                          color="primary.main"
                          fontWeight={600}
                          sx={{ ml: 'auto' }}
                        >
                          {(Number(article.prixUnitaire) * quantite).toFixed(2)} €
                        </Typography>
                        <IconButton
                          size="small"
                          color="error"
                          onClick={() => removeItem(article.id)}
                          aria-label="Supprimer"
                        >
                          <DeleteOutlineIcon fontSize="small" />
                        </IconButton>
                      </Box>
                    </Box>
                  </ListItem>
                  <Divider />
                </React.Fragment>
              ))}
            </List>
          )}
        </Box>

        {/* Footer avec total et actions */}
        {items.length > 0 && (
          <Box sx={{ p: 2, borderTop: 1, borderColor: 'divider' }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 2 }}>
              <Typography variant="subtitle1" fontWeight={600}>
                Total ({totalItems} article{totalItems > 1 ? 's' : ''})
              </Typography>
              <Typography variant="subtitle1" fontWeight={700} color="primary.main">
                {cartTotal.toFixed(2)} €
              </Typography>
            </Box>
            <Button
              variant="contained"
              fullWidth
              size="large"
              onClick={() => goTo('/boutique/commande')}
              sx={{ mb: 1 }}
            >
              Commander
            </Button>
            <Button variant="outlined" fullWidth onClick={() => goTo('/boutique/panier')}>
              Voir le panier
            </Button>
          </Box>
        )}
      </Box>
    </Drawer>
  );
}
