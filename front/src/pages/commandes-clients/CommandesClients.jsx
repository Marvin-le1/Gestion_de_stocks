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
import { commandeClientService } from '../../services/commandeClientService';
import { clientService } from '../../services/clientService';

const STATUT_COLORS = { EN_ATTENTE: 'warning', VALIDEE: 'info', LIVREE: 'success', ANNULEE: 'error' };
const EMPTY_FORM = { clientId: '', commentaire: '' };

export default function CommandesClients() {
  const notify = useNotification();
  const navigate = useNavigate();
  const [rows, setRows] = useState([]);
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [deleteId, setDeleteId] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [cmdRes, cliRes] = await Promise.all([
        commandeClientService.findAll(),
        clientService.findAll(),
      ]);
      setRows(cmdRes.data);
      setClients(cliRes.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const handleChange = (e) => setForm((f) => ({ ...f, [e.target.name]: e.target.value }));

  const handleCreate = async () => {
    setSaving(true);
    try {
      const res = await commandeClientService.create({ clientId: Number(form.clientId), commentaire: form.commentaire, lignes: [] });
      notify('Commande créée');
      setDialogOpen(false);
      navigate(`/commandes-clients/${res.data.id}`);
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur lors de la création', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await commandeClientService.delete(deleteId);
      notify('Commande supprimée');
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
      field: 'client',
      headerName: 'Client',
      flex: 1,
      valueGetter: (_, row) => row.client ? `${row.client.nom} ${row.client.prenom}` : '',
    },
    {
      field: 'statut',
      headerName: 'Statut',
      width: 130,
      renderCell: ({ value }) => (
        <Chip label={value} color={STATUT_COLORS[value] || 'default'} size="small" />
      ),
    },
    { field: 'commentaire', headerName: 'Commentaire', flex: 1 },
    {
      field: 'actions', headerName: '', width: 90, sortable: false,
      renderCell: ({ row }) => (
        <>
          <Tooltip title="Voir détail">
            <IconButton size="small" onClick={() => navigate(`/commandes-clients/${row.id}`)}>
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
        <Typography variant="h5">Commandes clients</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => { setForm(EMPTY_FORM); setDialogOpen(true); }}>
          Nouvelle commande
        </Button>
      </Stack>
      <DataTable rows={rows} columns={columns} loading={loading} />

      <FormDialog open={dialogOpen} title="Nouvelle commande client" onClose={() => setDialogOpen(false)} onSubmit={handleCreate} loading={saving}>
        <Stack spacing={2} mt={1}>
          <TextField select name="clientId" label="Client *" value={form.clientId} onChange={handleChange} size="small" fullWidth>
            {clients.map((c) => (
              <MenuItem key={c.id} value={c.id}>{c.nom} {c.prenom}</MenuItem>
            ))}
          </TextField>
          <TextField name="commentaire" label="Commentaire" value={form.commentaire} onChange={handleChange} size="small" fullWidth multiline rows={2} />
        </Stack>
      </FormDialog>

      <ConfirmDialog open={Boolean(deleteId)} title="Supprimer la commande" message="Confirmer la suppression ?" onConfirm={handleDelete} onCancel={() => setDeleteId(null)} />
    </Box>
  );
}
