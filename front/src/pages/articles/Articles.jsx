import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, TextField, MenuItem, Typography, Chip,
  Stack, IconButton, Tooltip, Switch, FormControlLabel,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { articleService } from '../../services/articleService';
import { familleService } from '../../services/familleService';
import { fournisseurService } from '../../services/fournisseurService';
import { validate, rules, hasErrors } from '../../utils/validate';

const EMPTY_FORM = {
  reference: '', designation: '', description: '', maison: '', annee: '',
  prixUnitaire: '', prixCarton: '', quantiteStock: 0, seuilMinimum: 0,
  reapprovisionnementAuto: true, familleId: '', fournisseurId: '',
};

const SCHEMA = {
  reference:    [rules.required('La référence')],
  designation:  [rules.required('La désignation')],
  prixUnitaire: [rules.required('Le prix unitaire'), rules.positiveNumber('Le prix unitaire')],
  prixCarton:   [rules.positiveNumber('Le prix carton')],
  quantiteStock:[rules.nonNegativeNumber('Le stock')],
  seuilMinimum: [rules.nonNegativeNumber('Le seuil minimum')],
  annee:        [rules.year],
  familleId:    [rules.required('La famille')],
  fournisseurId:[rules.required('Le fournisseur')],
};

export default function Articles() {
  const notify = useNotification();
  const [rows, setRows] = useState([]);
  const [familles, setFamilles] = useState([]);
  const [fournisseurs, setFournisseurs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [editId, setEditId] = useState(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [errors, setErrors] = useState({});
  const [deleteId, setDeleteId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [artRes, famRes, fourRes] = await Promise.all([
        articleService.findAll(),
        familleService.findAll(),
        fournisseurService.findAll(),
      ]);
      setRows(artRes.data);
      setFamilles(famRes.data);
      setFournisseurs(fourRes.data);
    } catch {
      notify('Erreur lors du chargement des articles', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const openCreate = () => { setEditId(null); setForm(EMPTY_FORM); setErrors({}); setDialogOpen(true); };
  const openEdit = (row) => {
    setEditId(row.id);
    setForm({
      reference: row.reference,
      designation: row.designation,
      description: row.description || '',
      maison: row.maison || '',
      annee: row.annee || '',
      prixUnitaire: row.prixUnitaire,
      prixCarton: row.prixCarton || '',
      quantiteStock: row.quantiteStock,
      seuilMinimum: row.seuilMinimum,
      reapprovisionnementAuto: row.reapprovisionnementAuto,
      familleId: row.famille?.id || '',
      fournisseurId: row.fournisseur?.id || '',
    });
    setErrors({});
    setDialogOpen(true);
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((f) => ({ ...f, [name]: type === 'checkbox' ? checked : value }));
    setErrors((err) => ({ ...err, [name]: undefined }));
  };

  const handleSubmit = async () => {
    const errs = validate(form, SCHEMA);
    if (hasErrors(errs)) { setErrors(errs); return; }
    setSaving(true);
    try {
      const payload = {
        ...form,
        annee: form.annee ? Number(form.annee) : null,
        prixUnitaire: Number(form.prixUnitaire),
        prixCarton: form.prixCarton ? Number(form.prixCarton) : null,
        quantiteStock: Number(form.quantiteStock),
        seuilMinimum: Number(form.seuilMinimum),
        familleId: Number(form.familleId),
        fournisseurId: Number(form.fournisseurId),
      };
      if (editId) {
        await articleService.update(editId, payload);
        notify('Article mis à jour');
      } else {
        await articleService.create(payload);
        notify('Article créé');
      }
      setDialogOpen(false);
      load();
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur lors de la sauvegarde', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await articleService.delete(deleteId);
      notify('Article supprimé');
      setDeleteId(null);
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  const f = (name) => ({ error: Boolean(errors[name]), helperText: errors[name] });

  const columns = [
    { field: 'reference', headerName: 'Référence', width: 120 },
    { field: 'designation', headerName: 'Désignation', flex: 1 },
    { field: 'maison', headerName: 'Maison', width: 140 },
    { field: 'annee', headerName: 'Année', width: 80 },
    { field: 'famille', headerName: 'Famille', width: 110, valueGetter: (_, row) => row.famille?.type || '' },
    { field: 'prixUnitaire', headerName: 'Prix unit.', width: 100, valueFormatter: (value) => value != null ? `${Number(value).toFixed(2)} €` : '' },
    {
      field: 'quantiteStock', headerName: 'Stock', width: 90,
      renderCell: ({ row }) => {
        const sousMin = row.quantiteStock <= row.seuilMinimum;
        return (
          <Stack direction="row" alignItems="center" spacing={0.5}>
            {sousMin && <WarningAmberIcon color="warning" fontSize="small" />}
            <Typography variant="body2" color={sousMin ? 'warning.main' : 'inherit'}>{row.quantiteStock}</Typography>
          </Stack>
        );
      },
    },
    { field: 'seuilMinimum', headerName: 'Seuil min.', width: 100 },
    {
      field: 'reapprovisionnementAuto', headerName: 'Réappro. auto', width: 130,
      renderCell: ({ value }) => <Chip label={value ? 'Actif' : 'Inactif'} color={value ? 'success' : 'default'} size="small" />,
    },
    {
      field: 'actions', headerName: '', width: 90, sortable: false,
      renderCell: ({ row }) => (
        <>
          <Tooltip title="Modifier"><IconButton size="small" onClick={() => openEdit(row)}><EditIcon fontSize="small" /></IconButton></Tooltip>
          <Tooltip title="Supprimer"><IconButton size="small" color="error" onClick={() => setDeleteId(row.id)}><DeleteIcon fontSize="small" /></IconButton></Tooltip>
        </>
      ),
    },
  ];

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Articles</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openCreate}>Nouvel article</Button>
      </Stack>

      <DataTable rows={rows} columns={columns} loading={loading} />

      <FormDialog
        open={dialogOpen}
        title={editId ? "Modifier l'article" : 'Nouvel article'}
        onClose={() => setDialogOpen(false)}
        onSubmit={handleSubmit}
        loading={saving}
        maxWidth="md"
      >
        <Stack spacing={2} mt={1}>
          <Stack direction="row" spacing={2}>
            <TextField name="reference" label="Référence *" value={form.reference} onChange={handleChange} size="small" fullWidth {...f('reference')} />
            <TextField name="designation" label="Désignation *" value={form.designation} onChange={handleChange} size="small" fullWidth {...f('designation')} />
          </Stack>
          <Stack direction="row" spacing={2}>
            <TextField name="maison" label="Maison" value={form.maison} onChange={handleChange} size="small" fullWidth />
            <TextField name="annee" label="Année" type="number" value={form.annee} onChange={handleChange} size="small" fullWidth {...f('annee')} />
          </Stack>
          <TextField name="description" label="Description" value={form.description} onChange={handleChange} size="small" fullWidth multiline rows={2} />
          <Stack direction="row" spacing={2}>
            <TextField name="prixUnitaire" label="Prix unitaire * (€)" type="number" inputProps={{ min: 0.01, step: 0.01 }} value={form.prixUnitaire} onChange={handleChange} size="small" fullWidth {...f('prixUnitaire')} />
            <TextField name="prixCarton" label="Prix carton (€)" type="number" inputProps={{ min: 0.01, step: 0.01 }} value={form.prixCarton} onChange={handleChange} size="small" fullWidth {...f('prixCarton')} />
          </Stack>
          <Stack direction="row" spacing={2}>
            <TextField name="quantiteStock" label="Quantité en stock" type="number" inputProps={{ min: 0 }} value={form.quantiteStock} onChange={handleChange} size="small" fullWidth {...f('quantiteStock')} />
            <TextField name="seuilMinimum" label="Seuil minimum" type="number" inputProps={{ min: 0 }} value={form.seuilMinimum} onChange={handleChange} size="small" fullWidth {...f('seuilMinimum')} />
          </Stack>
          <Stack direction="row" spacing={2}>
            <Box flex={1}>
              <TextField select name="familleId" label="Famille *" value={form.familleId} onChange={handleChange} size="small" fullWidth {...f('familleId')}>
                {familles.map((fam) => <MenuItem key={fam.id} value={fam.id}>{fam.type}</MenuItem>)}
              </TextField>
            </Box>
            <Box flex={1}>
              <TextField select name="fournisseurId" label="Fournisseur *" value={form.fournisseurId} onChange={handleChange} size="small" fullWidth {...f('fournisseurId')}>
                {fournisseurs.map((four) => <MenuItem key={four.id} value={four.id}>{four.nom}</MenuItem>)}
              </TextField>
            </Box>
          </Stack>
          <FormControlLabel
            control={<Switch name="reapprovisionnementAuto" checked={form.reapprovisionnementAuto} onChange={handleChange} color="primary" />}
            label="Réapprovisionnement automatique"
          />
        </Stack>
      </FormDialog>

      <ConfirmDialog
        open={Boolean(deleteId)}
        title="Supprimer l'article"
        message="Cette action est irréversible. Confirmer la suppression ?"
        onConfirm={handleDelete}
        onCancel={() => setDeleteId(null)}
      />
    </Box>
  );
}
