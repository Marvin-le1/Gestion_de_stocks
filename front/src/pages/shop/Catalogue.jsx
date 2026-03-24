import React, { useEffect, useState, useMemo } from 'react';
import {
  Container, Grid, Typography, Box, CircularProgress, Alert,
} from '@mui/material';
import { useSearchParams } from 'react-router-dom';
import { articleService } from '../../services/articleService';
import ProductCard from '../../components/shop/ProductCard';
import FilterBar from '../../components/shop/FilterBar';

const DEFAULT_FILTERS = { famille: '', sort: 'nom_asc', maison: '', annee: '' };

export default function Catalogue() {
  const [articles, setArticles] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchParams] = useSearchParams();
  const [filters, setFilters] = useState({
    ...DEFAULT_FILTERS,
    famille: searchParams.get('famille') || '',
  });

  useEffect(() => {
    articleService
      .findAll()
      .then((res) => setArticles(res.data))
      .catch(() => setError('Impossible de charger le catalogue. Veuillez réessayer.'))
      .finally(() => setLoading(false));
  }, []);

  const filtered = useMemo(() => {
    let result = [...articles];

    if (filters.famille) {
      result = result.filter((a) => a.famille?.type === filters.famille);
    }
    if (filters.maison) {
      const q = filters.maison.toLowerCase();
      result = result.filter(
        (a) =>
          (a.maison || '').toLowerCase().includes(q) ||
          (a.designation || '').toLowerCase().includes(q)
      );
    }
    if (filters.annee) {
      result = result.filter((a) => String(a.annee) === filters.annee);
    }

    switch (filters.sort) {
      case 'nom_desc':
        result.sort((a, b) => b.designation.localeCompare(a.designation, 'fr'));
        break;
      case 'prix_asc':
        result.sort((a, b) => Number(a.prixUnitaire) - Number(b.prixUnitaire));
        break;
      case 'prix_desc':
        result.sort((a, b) => Number(b.prixUnitaire) - Number(a.prixUnitaire));
        break;
      default:
        result.sort((a, b) => a.designation.localeCompare(b.designation, 'fr'));
    }

    return result;
  }, [articles, filters]);

  return (
    <Container maxWidth="xl" sx={{ py: 4 }}>
      {/* En-tête */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" fontWeight={800} color="primary.dark">
          Notre Boutique
        </Typography>
        <Typography variant="body1" color="text.secondary" sx={{ mt: 0.5 }}>
          Découvrez notre sélection de vins du terroir gascon
        </Typography>
      </Box>

      <FilterBar filters={filters} onChange={setFilters} />

      {loading && (
        <Box sx={{ display: 'flex', justifyContent: 'center', py: 10 }}>
          <CircularProgress color="primary" />
        </Box>
      )}

      {error && <Alert severity="error">{error}</Alert>}

      {!loading && !error && (
        <>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            {filtered.length} vin{filtered.length > 1 ? 's' : ''} trouvé
            {filtered.length > 1 ? 's' : ''}
          </Typography>

          {filtered.length === 0 ? (
            <Box sx={{ textAlign: 'center', py: 10 }}>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Aucun résultat
              </Typography>
              <Typography variant="body2" color="text.disabled">
                Essayez de modifier vos filtres de recherche.
              </Typography>
            </Box>
          ) : (
            <Grid container spacing={3}>
              {filtered.map((article) => (
                <Grid item key={article.id} xs={12} sm={6} md={4} lg={3}>
                  <ProductCard article={article} />
                </Grid>
              ))}
            </Grid>
          )}
        </>
      )}
    </Container>
  );
}
