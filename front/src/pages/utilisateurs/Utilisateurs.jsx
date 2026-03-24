import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Chip, Dialog, DialogActions, DialogContent, DialogTitle,
  FormControl, IconButton, InputLabel, MenuItem, Paper, Select, Table,
  TableBody, TableCell, TableContainer, TableHead, TableRow, TextField,
  Tooltip, Typography, Alert, CircularProgress,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import PersonIcon from '@mui/icons-material/Person';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';
import { utilisateurService } from '../../services/utilisateurService';
import { useAuth } from '../../contexts/AuthContext';
import ConfirmDialog from '../../components/common/ConfirmDialog';

const EMPTY_FORM = { nom: '', email: '', motDePasse: '', role: 'EMPLOYE' };

const ROLE_CONFIG = {
  ADMIN:   { label: 'Admin',    color: 'error',   icon: <AdminPanelSettingsIcon fontSize="small" /> },
  EMPLOYE: { label: 'Employé',  color: 'primary',  icon: <PersonIcon fontSize="small" /> },
};

export default function Utilisateurs() {
  const { user: currentUser } = useAuth();

  const [rows, setRows]           = useState([]);
  const [loading, setLoading]     = useState(true);
  const [openDialog, setOpenDialog] = useState(false);
  const [form, setForm]           = useState(EMPTY_FORM);
  const [errors, setErrors]       = useState({});
  const [saving, setSaving]       = useState(false);
  const [saveError, setSaveError] = useState('');
  const [toDelete, setToDelete]   = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await utilisateurService.findAll();
      setRows(res.data);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  // ── Formulaire ──────────────────────────────────────────────────────────────
  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: '' }));
  };

  const validate = () => {
    const errs = {};
    if (!form.nom.trim())   errs.nom = 'Obligatoire';
    if (!form.email.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
      errs.email = 'Email invalide';
    if (!form.motDePasse || form.motDePasse.length < 6)
      errs.motDePasse = '6 caractères minimum';
    return errs;
  };

  const handleSave = async () => {
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }
    setSaving(true);
    setSaveError('');
    try {
      await utilisateurService.create(form);
      setOpenDialog(false);
      setForm(EMPTY_FORM);
      await load();
    } catch (err) {
      setSaveError(err.response?.data?.message || err.response?.data || 'Erreur lors de la création');
    } finally {
      setSaving(false);
    }
  };

  const handleClose = () => {
    setOpenDialog(false);
    setForm(EMPTY_FORM);
    setErrors({});
    setSaveError('');
  };

  // ── Suppression ─────────────────────────────────────────────────────────────
  const handleDeleteConfirm = async () => {
    try {
      await utilisateurService.delete(toDelete.id);
      setToDelete(null);
      await load();
    } catch {
      setToDelete(null);
    }
  };

  return (
    <Box>
      {/* En-tête */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
        <Box>
          <Typography variant="h5" fontWeight={700}>Utilisateurs</Typography>
          <Typography variant="body2" color="text.secondary">
            Gérez les comptes du back-office (admin et employés)
          </Typography>
        </Box>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => setOpenDialog(true)}
        >
          Nouvel utilisateur
        </Button>
      </Box>

      {/* Tableau */}
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 6 }}>
          <CircularProgress />
        </Box>
      ) : (
        <TableContainer component={Paper} variant="outlined">
          <Table size="small">
            <TableHead>
              <TableRow sx={{ backgroundColor: 'grey.50' }}>
                <TableCell sx={{ fontWeight: 700 }}>Nom</TableCell>
                <TableCell sx={{ fontWeight: 700 }}>Email</TableCell>
                <TableCell sx={{ fontWeight: 700 }}>Rôle</TableCell>
                <TableCell align="right" sx={{ fontWeight: 700 }}>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {rows.map((row) => {
                const cfg = ROLE_CONFIG[row.role] ?? { label: row.role, color: 'default', icon: null };
                const isMe = row.email === currentUser?.email;
                return (
                  <TableRow key={row.id} hover>
                    <TableCell>
                      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                        {row.nom}
                        {isMe && (
                          <Chip label="vous" size="small" variant="outlined" color="default" />
                        )}
                      </Box>
                    </TableCell>
                    <TableCell>{row.email}</TableCell>
                    <TableCell>
                      <Chip
                        icon={cfg.icon}
                        label={cfg.label}
                        color={cfg.color}
                        size="small"
                        variant="outlined"
                      />
                    </TableCell>
                    <TableCell align="right">
                      <Tooltip title={isMe ? 'Impossible de se supprimer soi-même' : 'Supprimer'}>
                        <span>
                          <IconButton
                            size="small"
                            color="error"
                            disabled={isMe}
                            onClick={() => setToDelete(row)}
                          >
                            <DeleteIcon fontSize="small" />
                          </IconButton>
                        </span>
                      </Tooltip>
                    </TableCell>
                  </TableRow>
                );
              })}
              {rows.length === 0 && (
                <TableRow>
                  <TableCell colSpan={4} align="center" sx={{ py: 4, color: 'text.secondary' }}>
                    Aucun utilisateur trouvé
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </TableContainer>
      )}

      {/* Dialog création */}
      <Dialog open={openDialog} onClose={handleClose} maxWidth="xs" fullWidth>
        <DialogTitle fontWeight={700}>Nouvel utilisateur</DialogTitle>
        <DialogContent dividers>
          {saveError && (
            <Alert severity="error" sx={{ mb: 2 }}>{saveError}</Alert>
          )}
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
            <TextField
              name="nom"
              label="Nom complet"
              value={form.nom}
              onChange={handleChange}
              error={!!errors.nom}
              helperText={errors.nom}
              required
              fullWidth
              size="small"
            />
            <TextField
              name="email"
              label="Email"
              type="email"
              value={form.email}
              onChange={handleChange}
              error={!!errors.email}
              helperText={errors.email}
              required
              fullWidth
              size="small"
            />
            <TextField
              name="motDePasse"
              label="Mot de passe"
              type="password"
              value={form.motDePasse}
              onChange={handleChange}
              error={!!errors.motDePasse}
              helperText={errors.motDePasse || '6 caractères minimum'}
              required
              fullWidth
              size="small"
            />
            <FormControl fullWidth size="small">
              <InputLabel>Rôle</InputLabel>
              <Select
                name="role"
                value={form.role}
                label="Rôle"
                onChange={handleChange}
              >
                <MenuItem value="EMPLOYE">Employé — accès complet sauf gestion utilisateurs</MenuItem>
                <MenuItem value="ADMIN">Administrateur — accès total</MenuItem>
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={handleClose} disabled={saving}>Annuler</Button>
          <Button
            variant="contained"
            onClick={handleSave}
            disabled={saving}
            startIcon={saving ? <CircularProgress size={16} color="inherit" /> : null}
          >
            {saving ? 'Création…' : 'Créer'}
          </Button>
        </DialogActions>
      </Dialog>

      {/* Confirm suppression */}
      <ConfirmDialog
        open={!!toDelete}
        title="Supprimer l'utilisateur"
        message={`Supprimer définitivement ${toDelete?.nom} (${toDelete?.email}) ?`}
        onConfirm={handleDeleteConfirm}
        onCancel={() => setToDelete(null)}
        confirmLabel="Supprimer"
        confirmColor="error"
      />
    </Box>
  );
}
