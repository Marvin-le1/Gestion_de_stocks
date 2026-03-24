import React, { useEffect, useState, useCallback } from 'react';
import { Box, Button, TextField, Typography, Stack, IconButton, Tooltip } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { fournisseurService } from '../../services/fournisseurService';

const EMPTY_FORM = { nom: '', adresse: '', ville: '', codePostal: '', telephone: '', email: '', contactNom: '' };

export default function Fournisseurs() {
  const notify = useNotification();
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [editId, setEditId] = useState(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [deleteId, setDeleteId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await fournisseurService.findAll();
      setRows(res.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const openCreate = () => { setEditId(null); setForm(EMPTY_FORM); setDialogOpen(true); };
  const openEdit = (row) => {
    setEditId(row.id);
    setForm({ nom: row.nom, adresse: row.adresse || '', ville: row.ville || '', codePostal: row.codePostal || '', telephone: row.telephone || '', email: row.email || '', contactNom: row.contactNom || '' });
    setDialogOpen(true);
  };
  const handleChange = (e) => setForm((f) => ({ ...f, [e.target.name]: e.target.value }));

  const handleSubmit = async () => {
    setSaving(true);
    try {
      if (editId) { await fournisseurService.update(editId, form); notify('Fournisseur mis à jour'); }
      else { await fournisseurService.create(form); notify('Fournisseur créé'); }
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
      await fournisseurService.delete(deleteId);
      notify('Fournisseur supprimé');
      setDeleteId(null);
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  const columns = [
    { field: 'nom', headerName: 'Nom', flex: 1 },
    { field: 'ville', headerName: 'Ville', width: 140 },
    { field: 'telephone', headerName: 'Téléphone', width: 140 },
    { field: 'email', headerName: 'Email', width: 200 },
    { field: 'contactNom', headerName: 'Contact', width: 160 },
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
        <Typography variant="h5">Fournisseurs</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openCreate}>Nouveau fournisseur</Button>
      </Stack>
      <DataTable rows={rows} columns={columns} loading={loading} />

      <FormDialog open={dialogOpen} title={editId ? 'Modifier le fournisseur' : 'Nouveau fournisseur'} onClose={() => setDialogOpen(false)} onSubmit={handleSubmit} loading={saving}>
        <Stack spacing={2} mt={1}>
          <TextField name="nom" label="Nom *" value={form.nom} onChange={handleChange} size="small" fullWidth />
          <TextField name="contactNom" label="Nom du contact" value={form.contactNom} onChange={handleChange} size="small" fullWidth />
          <TextField name="adresse" label="Adresse" value={form.adresse} onChange={handleChange} size="small" fullWidth />
          <Stack direction="row" spacing={2}>
            <TextField name="ville" label="Ville" value={form.ville} onChange={handleChange} size="small" fullWidth />
            <TextField name="codePostal" label="Code postal" value={form.codePostal} onChange={handleChange} size="small" fullWidth />
          </Stack>
          <Stack direction="row" spacing={2}>
            <TextField name="telephone" label="Téléphone" value={form.telephone} onChange={handleChange} size="small" fullWidth />
            <TextField name="email" label="Email" type="email" value={form.email} onChange={handleChange} size="small" fullWidth />
          </Stack>
        </Stack>
      </FormDialog>

      <ConfirmDialog open={Boolean(deleteId)} title="Supprimer le fournisseur" message="Confirmer la suppression ?" onConfirm={handleDelete} onCancel={() => setDeleteId(null)} />
    </Box>
  );
}
