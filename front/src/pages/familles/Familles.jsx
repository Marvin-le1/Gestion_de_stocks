import React, { useEffect, useState, useCallback } from 'react';
import { Box, Button, TextField, MenuItem, Typography, Stack, IconButton, Tooltip } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { familleService } from '../../services/familleService';
import { validate, rules, hasErrors } from '../../utils/validate';

const TYPE_FAMILLE = ['ROUGE', 'ROSE', 'BLANC', 'PETILLANT', 'DIGESTIF'];
const EMPTY_FORM = { type: '', description: '' };
const SCHEMA = { type: [rules.required('Le type')] };

export default function Familles() {
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
      const res = await familleService.findAll();
      setRows(res.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const openCreate = () => { setEditId(null); setForm(EMPTY_FORM); setErrors({}); setDialogOpen(true); };
  const openEdit = (row) => { setEditId(row.id); setForm({ type: row.type, description: row.description || '' }); setErrors({}); setDialogOpen(true); };
  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: undefined }));
  };

  const handleSubmit = async () => {
    const errs = validate(form, SCHEMA);
    if (hasErrors(errs)) { setErrors(errs); return; }
    setSaving(true);
    try {
      if (editId) {
        await familleService.update(editId, form);
        notify('Famille mise à jour');
      } else {
        await familleService.create(form);
        notify('Famille créée');
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
      await familleService.delete(deleteId);
      notify('Famille supprimée');
      setDeleteId(null);
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  const columns = [
    { field: 'type', headerName: 'Type', width: 160 },
    { field: 'description', headerName: 'Description', flex: 1 },
    {
      field: 'actions', headerName: '', width: 90, sortable: false,
      renderCell: ({ row }) => (
        <>
          <Tooltip title="Modifier">
            <IconButton size="small" onClick={() => openEdit(row)}><EditIcon fontSize="small" /></IconButton>
          </Tooltip>
          <Tooltip title="Supprimer">
            <IconButton size="small" color="error" onClick={() => setDeleteId(row.id)}><DeleteIcon fontSize="small" /></IconButton>
          </Tooltip>
        </>
      ),
    },
  ];

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Familles de vins</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={openCreate}>Nouvelle famille</Button>
      </Stack>
      <DataTable rows={rows} columns={columns} loading={loading} height={400} />

      <FormDialog open={dialogOpen} title={editId ? 'Modifier la famille' : 'Nouvelle famille'} onClose={() => setDialogOpen(false)} onSubmit={handleSubmit} loading={saving}>
        <Stack spacing={2} mt={1}>
          <TextField select name="type" label="Type *" value={form.type} onChange={handleChange} size="small" fullWidth error={Boolean(errors.type)} helperText={errors.type}>
            {TYPE_FAMILLE.map((t) => <MenuItem key={t} value={t}>{t}</MenuItem>)}
          </TextField>
          <TextField name="description" label="Description" value={form.description} onChange={handleChange} size="small" fullWidth multiline rows={2} />
        </Stack>
      </FormDialog>

      <ConfirmDialog open={Boolean(deleteId)} title="Supprimer la famille" message="Confirmer la suppression ?" onConfirm={handleDelete} onCancel={() => setDeleteId(null)} />
    </Box>
  );
}
