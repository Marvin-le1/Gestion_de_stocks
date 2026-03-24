import React, { useEffect, useState, useCallback } from 'react';
import { Box, Button, TextField, Typography, Stack, IconButton, Tooltip } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { clientService } from '../../services/clientService';
import { validate, rules, hasErrors } from '../../utils/validate';

const EMPTY_FORM = { nom: '', prenom: '', email: '', telephone: '', adresse: '', ville: '', codePostal: '' };

const SCHEMA = {
  nom:       [rules.required('Le nom')],
  prenom:    [rules.required('Le prénom')],
  email:     [rules.required("L'email"), rules.email],
  telephone: [rules.phone],
  codePostal:[rules.postalCode],
};

export default function Clients() {
  const notify = useNotification();
  const [rows, setRows] = useState([]);
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
      const res = await clientService.findAll();
      setRows(res.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const openCreate = () => { setEditId(null); setForm(EMPTY_FORM); setErrors({}); setDialogOpen(true); };
  const openEdit = (row) => {
    setEditId(row.id);
    setForm({ nom: row.nom, prenom: row.prenom, email: row.email, telephone: row.telephone || '', adresse: row.adresse || '', ville: row.ville || '', codePostal: row.codePostal || '' });
    setErrors({});
    setDialogOpen(true);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((f) => ({ ...f, [name]: value }));
    setErrors((err) => ({ ...err, [name]: undefined }));
  };

  const handleSubmit = async () => {
    const errs = validate(form, SCHEMA);
    if (hasErrors(errs)) { setErrors(errs); return; }
    setSaving(true);
    try {
      if (editId) { await clientService.update(editId, form); notify('Client mis à jour'); }
      else { await clientService.create(form); notify('Client créé'); }
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
      await clientService.delete(deleteId);
      notify('Client supprimé');
      setDeleteId(null);
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  const columns = [
    { field: 'nom', headerName: 'Nom', width: 140 },
    { field: 'prenom', headerName: 'Prénom', width: 140 },
    { field: 'email', headerName: 'Email', flex: 1 },
    { field: 'telephone', headerName: 'Téléphone', width: 140 },
    { field: 'ville', headerName: 'Ville', width: 140 },
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

  const f = (name) => ({ error: Boolean(errors[name]), helperText: errors[name] });

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Clients</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openCreate}>Nouveau client</Button>
      </Stack>
      <DataTable rows={rows} columns={columns} loading={loading} />

      <FormDialog open={dialogOpen} title={editId ? 'Modifier le client' : 'Nouveau client'} onClose={() => setDialogOpen(false)} onSubmit={handleSubmit} loading={saving}>
        <Stack spacing={2} mt={1}>
          <Stack direction="row" spacing={2}>
            <TextField name="nom" label="Nom *" value={form.nom} onChange={handleChange} size="small" fullWidth {...f('nom')} />
            <TextField name="prenom" label="Prénom *" value={form.prenom} onChange={handleChange} size="small" fullWidth {...f('prenom')} />
          </Stack>
          <TextField name="email" label="Email *" value={form.email} onChange={handleChange} size="small" fullWidth {...f('email')} />
          <TextField name="telephone" label="Téléphone" placeholder="06 12 34 56 78" value={form.telephone} onChange={handleChange} size="small" fullWidth {...f('telephone')} />
          <TextField name="adresse" label="Adresse" value={form.adresse} onChange={handleChange} size="small" fullWidth />
          <Stack direction="row" spacing={2}>
            <TextField name="ville" label="Ville" value={form.ville} onChange={handleChange} size="small" fullWidth />
            <TextField name="codePostal" label="Code postal" placeholder="75001" value={form.codePostal} onChange={handleChange} size="small" fullWidth {...f('codePostal')} />
          </Stack>
        </Stack>
      </FormDialog>

      <ConfirmDialog open={Boolean(deleteId)} title="Supprimer le client" message="Confirmer la suppression ?" onConfirm={handleDelete} onCancel={() => setDeleteId(null)} />
    </Box>
  );
}
