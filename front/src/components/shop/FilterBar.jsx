import React from 'react';
import {
  Box, Chip, Select, MenuItem, FormControl, InputLabel,
  TextField, InputAdornment, Paper,
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';

const FAMILLES = [
  { label: 'Tous les vins', value: '' },
  { label: 'Rouge', value: 'ROUGE' },
  { label: 'Rosé', value: 'ROSE' },
  { label: 'Blanc', value: 'BLANC' },
  { label: 'Pétillant', value: 'PETILLANT' },
  { label: 'Digestif', value: 'DIGESTIF' },
];

const SORT_OPTIONS = [
  { label: 'Nom A → Z', value: 'nom_asc' },
  { label: 'Nom Z → A', value: 'nom_desc' },
  { label: 'Prix croissant', value: 'prix_asc' },
  { label: 'Prix décroissant', value: 'prix_desc' },
];

export default function FilterBar({ filters, onChange }) {
  const { famille, sort, maison, annee } = filters;

  const set = (key, value) => onChange({ ...filters, [key]: value });

  return (
    <Paper variant="outlined" sx={{ p: 2, mb: 3, borderRadius: 2 }}>
      {/* Filtres par type de vin */}
      <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2 }}>
        {FAMILLES.map((f) => (
          <Chip
            key={f.value}
            label={f.label}
            onClick={() => set('famille', f.value)}
            variant={famille === f.value ? 'filled' : 'outlined'}
            color={famille === f.value ? 'primary' : 'default'}
            sx={{ fontWeight: famille === f.value ? 700 : 400 }}
          />
        ))}
      </Box>

      {/* Recherche textuelle + millésime + tri */}
      <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
        <TextField
          size="small"
          placeholder="Maison / domaine…"
          value={maison}
          onChange={(e) => set('maison', e.target.value)}
          sx={{ flex: '1 1 200px' }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon fontSize="small" />
              </InputAdornment>
            ),
          }}
        />
        <TextField
          size="small"
          label="Millésime"
          type="number"
          value={annee}
          onChange={(e) => set('annee', e.target.value)}
          sx={{ flex: '0 1 130px' }}
          inputProps={{ min: 1900, max: new Date().getFullYear() }}
        />
        <FormControl size="small" sx={{ flex: '0 1 200px' }}>
          <InputLabel>Trier par</InputLabel>
          <Select
            value={sort}
            label="Trier par"
            onChange={(e) => set('sort', e.target.value)}
          >
            {SORT_OPTIONS.map((o) => (
              <MenuItem key={o.value} value={o.value}>
                {o.label}
              </MenuItem>
            ))}
          </Select>
        </FormControl>
      </Box>
    </Paper>
  );
}
