import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, TextField, MenuItem, Typography, Stack,
  IconButton, Tooltip, Chip,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import VisibilityIcon from '@mui/icons-material/Visibility';
import DeleteIcon from '@mui/icons-material/Delete';
import { useNavigate } from 'react-router-dom';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { commandeFournisseurService } from '../../services/commandeFournisseurService';
import { fournisseurService } from '../../services/fournisseurService';
import { validate, rules, hasErrors } from '../../utils/validate';

const STATUT_COLORS = { EN_ATTENTE: 'warning', VALIDEE: 'info', LIVREE: 'success', ANNULEE: 'error' };
const EMPTY_FORM = { fournisseurId: '', commentaire: '' };
const SCHEMA = { fournisseurId: [rules.required('Le fournisseur')] };

export default function CommandesFournisseurs() {
  const notify = useNotification();
  const navigate = useNavigate();
  const [rows, setRows] = useState([]);
  const [fournisseurs, setFournisseurs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [errors, setErrors] = useState({});
  const [deleteId, setDeleteId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [cmdRes, fourRes] = await Promise.all([
        commandeFournisseurService.findAll(),
        fournisseurService.findAll(),
      ]);
      setRows(cmdRes.data);
      setFournisseurs(fourRes.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: undefined }));
  };

  const handleCreate = async () => {
    const errs = validate(form, SCHEMA);
    if (hasErrors(errs)) { setErrors(errs); return; }
    setSaving(true);
    try {
      const res = await commandeFournisseurService.create({ fournisseurId: Number(form.fournisseurId), commentaire: form.commentaire, lignes: [] });
      notify('Bon de commande créé');
      setDialogOpen(false);
      navigate(`/commandes-fournisseurs/${res.data.id}`);
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur lors de la création', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await commandeFournisseurService.delete(deleteId);
      notify('Bon de commande supprimé');
      setDeleteId(null);
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  const columns = [
    { field: 'id', headerName: 'N°', width: 70 },
    {
      field: 'dateCommande',
      headerName: 'Date',
      width: 170,
      valueFormatter: (value) => value ? new Date(value).toLocaleString('fr-FR') : '',
    },
    {
      field: 'fournisseur',
      headerName: 'Fournisseur',
      flex: 1,
      valueGetter: (_, row) => row.fournisseur?.nom || '',
    },
    {
      field: 'statut',
      headerName: 'Statut',
      width: 130,
      renderCell: ({ value }) => <Chip label={value} color={STATUT_COLORS[value] || 'default'} size="small" />,
    },
    {
      field: 'genereeAutomatiquement',
      headerName: 'Auto',
      width: 90,
      renderCell: ({ value }) => value ? <Chip label="Auto" size="small" color="secondary" /> : null,
    },
    {
      field: 'actions', headerName: '', width: 90, sortable: false,
      renderCell: ({ row }) => (
        <>
          <Tooltip title="Voir détail">
            <IconButton size="small" onClick={() => navigate(`/commandes-fournisseurs/${row.id}`)}>
              <VisibilityIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          {row.statut === 'EN_ATTENTE' && (
            <Tooltip title="Supprimer">
              <IconButton size="small" color="error" onClick={() => setDeleteId(row.id)}>
                <DeleteIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </>
      ),
    },
  ];

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Commandes fournisseurs</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => { setForm(EMPTY_FORM); setErrors({}); setDialogOpen(true); }}>
          Nouveau bon de commande
        </Button>
      </Stack>
      <DataTable rows={rows} columns={columns} loading={loading} />

      <FormDialog open={dialogOpen} title="Nouveau bon de commande" onClose={() => setDialogOpen(false)} onSubmit={handleCreate} loading={saving}>
        <Stack spacing={2} mt={1}>
          <TextField select name="fournisseurId" label="Fournisseur *" value={form.fournisseurId} onChange={handleChange} size="small" fullWidth error={Boolean(errors.fournisseurId)} helperText={errors.fournisseurId}>
            {fournisseurs.map((f) => <MenuItem key={f.id} value={f.id}>{f.nom}</MenuItem>)}
          </TextField>
          <TextField name="commentaire" label="Commentaire" value={form.commentaire} onChange={handleChange} size="small" fullWidth multiline rows={2} />
        </Stack>
      </FormDialog>

      <ConfirmDialog open={Boolean(deleteId)} title="Supprimer le bon de commande" message="Confirmer la suppression ?" onConfirm={handleDelete} onCancel={() => setDeleteId(null)} />
    </Box>
  );
}
