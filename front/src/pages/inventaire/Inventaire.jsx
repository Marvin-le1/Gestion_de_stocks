import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Button, Typography, Stack, Chip, Paper,
  Table, TableBody, TableCell, TableHead, TableRow,
  TextField, IconButton, Tooltip, Alert,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import VisibilityIcon from '@mui/icons-material/Visibility';
import DataTable from '../../components/common/DataTable';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { inventaireService } from '../../services/inventaireService';
import { articleService } from '../../services/articleService';

export default function Inventaire() {
  const notify = useNotification();
  const [inventaires, setInventaires] = useState([]);
  const [loading, setLoading] = useState(true);
  // Nouvel inventaire en cours de saisie
  const [createDialog, setCreateDialog] = useState(false);
  const [commentaire, setCommentaire] = useState('');
  const [articles, setArticles] = useState([]);
  const [lignes, setLignes] = useState([]); // [{ articleId, quantiteConstatee }]
  const [saving, setSaving] = useState(false);
  // Détail d'un inventaire existant
  const [detail, setDetail] = useState(null);
  const [confirmRegul, setConfirmRegul] = useState(null);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [invRes, artRes] = await Promise.all([
        inventaireService.findAll(),
        articleService.findAll(),
      ]);
      setInventaires(invRes.data);
      setArticles(artRes.data);
      // Initialiser les lignes avec tous les articles
      setLignes(artRes.data.map((a) => ({ articleId: a.id, quantiteConstatee: a.quantiteStock, article: a })));
    } catch {
      notify('Erreur lors du chargement', 'error');
    } finally {
      setLoading(false);
    }
  }, [notify]);

  useEffect(() => { load(); }, [load]);

  const handleQuantiteChange = (articleId, value) => {
    setLignes((prev) => prev.map((l) => l.articleId === articleId ? { ...l, quantiteConstatee: Number(value) } : l));
  };

  const handleCreate = async () => {
    setSaving(true);
    try {
      const payload = {
        commentaire,
        lignes: lignes.map((l) => ({ articleId: l.articleId, quantiteConstatee: l.quantiteConstatee })),
      };
      const res = await inventaireService.create(payload);
      notify('Inventaire créé');
      setCreateDialog(false);
      setDetail(res.data);
      load();
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur lors de la création', 'error');
    } finally {
      setSaving(false);
    }
  };

  const handleRegulariser = async () => {
    try {
      await inventaireService.regulariser(confirmRegul);
      notify('Stock régularisé avec succès', 'success');
      setConfirmRegul(null);
      const res = await inventaireService.findById(confirmRegul);
      setDetail(res.data);
      load();
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur lors de la régularisation', 'error');
    }
  };

  const handleVoirDetail = async (id) => {
    try {
      const res = await inventaireService.findById(id);
      setDetail(res.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    }
  };

  const columns = [
    { field: 'id', headerName: 'N°', width: 70 },
    {
      field: 'dateInventaire',
      headerName: 'Date',
      width: 180,
      valueFormatter: (value) => value ? new Date(value).toLocaleString('fr-FR') : '',
    },
    { field: 'commentaire', headerName: 'Commentaire', flex: 1 },
    {
      field: 'regularise',
      headerName: 'Statut',
      width: 140,
      renderCell: ({ value }) => (
        <Chip label={value ? 'Régularisé' : 'En attente'} color={value ? 'success' : 'warning'} size="small" />
      ),
    },
    {
      field: 'actions', headerName: '', width: 90, sortable: false,
      renderCell: ({ row }) => (
        <Tooltip title="Voir détail">
          <IconButton size="small" onClick={() => handleVoirDetail(row.id)}>
            <VisibilityIcon fontSize="small" />
          </IconButton>
        </Tooltip>
      ),
    },
  ];

  return (
    <Box>
      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={2}>
        <Typography variant="h5">Inventaire</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => {
            setCommentaire('');
            setLignes(articles.map((a) => ({ articleId: a.id, quantiteConstatee: a.quantiteStock, article: a })));
            setCreateDialog(true);
          }}
        >
          Nouvel inventaire
        </Button>
      </Stack>

      <DataTable rows={inventaires} columns={columns} loading={loading} height={300} />

      {detail && (
        <Box mt={3}>
          <Stack direction="row" justifyContent="space-between" alignItems="center" mb={1}>
            <Stack direction="row" alignItems="center" spacing={1}>
              <Typography variant="h6">Inventaire #{detail.id}</Typography>
              <Chip label={detail.regularise ? 'Régularisé' : 'En attente'} color={detail.regularise ? 'success' : 'warning'} size="small" />
            </Stack>
            {!detail.regularise && (
              <Button
                variant="contained"
                color="success"
                startIcon={<CheckCircleIcon />}
                onClick={() => setConfirmRegul(detail.id)}
              >
                Régulariser le stock
              </Button>
            )}
          </Stack>

          {!detail.regularise && (
            <Alert severity="warning" sx={{ mb: 2 }}>
              La régularisation applique les quantités constatées comme stock réel. Cette action est <strong>irréversible</strong>.
            </Alert>
          )}

          <Paper variant="outlined" sx={{ borderRadius: 2 }}>
            <Table size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#F0EBE3' }}>
                  <TableCell>Article</TableCell>
                  <TableCell align="right">Stock théorique</TableCell>
                  <TableCell align="right">Quantité constatée</TableCell>
                  <TableCell align="right">Écart</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {detail.lignes?.map((l) => {
                  const ecartColor = l.ecart > 0 ? 'success.main' : l.ecart < 0 ? 'error.main' : 'text.primary';
                  return (
                    <TableRow key={l.id}>
                      <TableCell>{l.article?.designation}</TableCell>
                      <TableCell align="right">{l.quantiteAvantRegularisation}</TableCell>
                      <TableCell align="right">{l.quantiteConstatee}</TableCell>
                      <TableCell align="right">
                        <Typography variant="body2" color={ecartColor} fontWeight={l.ecart !== 0 ? 600 : 400}>
                          {l.ecart > 0 ? `+${l.ecart}` : l.ecart}
                        </Typography>
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </Paper>
        </Box>
      )}

      {/* Dialog saisie inventaire */}
      <FormDialog
        open={createDialog}
        title="Saisie de l'inventaire"
        onClose={() => setCreateDialog(false)}
        onSubmit={handleCreate}
        loading={saving}
        maxWidth="md"
      >
        <Stack spacing={2} mt={1}>
          <TextField
            label="Commentaire"
            value={commentaire}
            onChange={(e) => setCommentaire(e.target.value)}
            size="small"
            fullWidth
            multiline
            rows={2}
          />
          <Typography variant="subtitle2">Saisir les quantités constatées :</Typography>
          <Paper variant="outlined" sx={{ borderRadius: 2 }}>
            <Table size="small">
              <TableHead>
                <TableRow sx={{ backgroundColor: '#F0EBE3' }}>
                  <TableCell>Article</TableCell>
                  <TableCell align="right">Stock actuel</TableCell>
                  <TableCell align="right" width={150}>Quantité constatée</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {lignes.map((l) => (
                  <TableRow key={l.articleId}>
                    <TableCell>{l.article?.designation}</TableCell>
                    <TableCell align="right">{l.article?.quantiteStock}</TableCell>
                    <TableCell align="right">
                      <TextField
                        type="number"
                        size="small"
                        value={l.quantiteConstatee}
                        onChange={(e) => handleQuantiteChange(l.articleId, e.target.value)}
                        inputProps={{ min: 0, style: { textAlign: 'right', width: 80 } }}
                        variant="outlined"
                      />
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Paper>
        </Stack>
      </FormDialog>

      <ConfirmDialog
        open={Boolean(confirmRegul)}
        title="Régulariser le stock"
        message="Cette action est irréversible. Les stocks seront mis à jour avec les quantités constatées. Confirmer ?"
        onConfirm={handleRegulariser}
        onCancel={() => setConfirmRegul(null)}
      />
    </Box>
  );
}
