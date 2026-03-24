import React, { useEffect, useState, useCallback } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import {
  Box, Button, Typography, Stack, Chip, Paper,
  TextField, MenuItem, IconButton, Tooltip, Divider,
  Table, TableBody, TableCell, TableHead, TableRow, Alert,
} from '@mui/material';
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import AddIcon from '@mui/icons-material/Add';
import DeleteIcon from '@mui/icons-material/Delete';
import FormDialog from '../../components/common/FormDialog';
import ConfirmDialog from '../../components/common/ConfirmDialog';
import { useNotification } from '../../contexts/NotificationContext';
import { commandeFournisseurService } from '../../services/commandeFournisseurService';
import { articleService } from '../../services/articleService';

const STATUT_COLORS = { EN_ATTENTE: 'warning', VALIDEE: 'info', LIVREE: 'success', ANNULEE: 'error' };
const STATUTS = ['EN_ATTENTE', 'VALIDEE', 'LIVREE', 'ANNULEE'];

export default function CommandeFournisseurDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const notify = useNotification();
  const [commande, setCommande] = useState(null);
  const [articles, setArticles] = useState([]);
  const [ligneDialog, setLigneDialog] = useState(false);
  const [ligneSaving, setLigneSaving] = useState(false);
  const [ligneForm, setLigneForm] = useState({ articleId: '', quantite: 1 });
  const [confirmStatut, setConfirmStatut] = useState(null);

  const load = useCallback(async () => {
    try {
      const [cmdRes, artRes] = await Promise.all([
        commandeFournisseurService.findById(id),
        articleService.findAll(),
      ]);
      setCommande(cmdRes.data);
      setArticles(artRes.data);
    } catch {
      notify('Erreur lors du chargement', 'error');
    }
  }, [id, notify]);

  useEffect(() => { load(); }, [load]);

  const handleStatut = async (statut) => {
    try {
      await commandeFournisseurService.changerStatut(id, statut);
      if (statut === 'LIVREE') {
        notify('Commande marquée livrée — stocks mis à jour automatiquement', 'success');
      } else {
        notify('Statut mis à jour');
      }
      setConfirmStatut(null);
      load();
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur', 'error');
    }
  };

  const handleAjouterLigne = async () => {
    setLigneSaving(true);
    try {
      await commandeFournisseurService.ajouterLigne(id, {
        articleId: Number(ligneForm.articleId),
        quantite: Number(ligneForm.quantite),
      });
      notify('Ligne ajoutée');
      setLigneDialog(false);
      load();
    } catch (err) {
      notify(err.response?.data?.message || 'Erreur', 'error');
    } finally {
      setLigneSaving(false);
    }
  };

  const handleSupprimerLigne = async (ligneId) => {
    try {
      await commandeFournisseurService.supprimerLigne(id, ligneId);
      notify('Ligne supprimée');
      load();
    } catch {
      notify('Erreur lors de la suppression', 'error');
    }
  };

  if (!commande) return null;

  const total = commande.lignes?.reduce((sum, l) => sum + l.quantite * Number(l.prixUnitaire), 0) || 0;
  const isEditable = commande.statut === 'EN_ATTENTE';

  return (
    <Box>
      <Stack direction="row" alignItems="center" spacing={1} mb={2}>
        <IconButton onClick={() => navigate('/commandes-fournisseurs')}><ArrowBackIcon /></IconButton>
        <Typography variant="h5">Bon de commande #{commande.id}</Typography>
        <Chip label={commande.statut} color={STATUT_COLORS[commande.statut] || 'default'} size="small" />
        {commande.genereeAutomatiquement && <Chip label="Généré auto" size="small" color="secondary" />}
      </Stack>

      {commande.statut === 'EN_ATTENTE' && (
        <Alert severity="info" sx={{ mb: 2 }}>
          Passer ce bon de commande à <strong>LIVREE</strong> mettra à jour le stock automatiquement.
        </Alert>
      )}

      <Paper variant="outlined" sx={{ p: 2, mb: 2, borderRadius: 2 }}>
        <Stack direction="row" spacing={4}>
          <Box>
            <Typography variant="caption" color="text.secondary">Fournisseur</Typography>
            <Typography>{commande.fournisseur?.nom}</Typography>
          </Box>
          <Box>
            <Typography variant="caption" color="text.secondary">Date</Typography>
            <Typography>{new Date(commande.dateCommande).toLocaleString('fr-FR')}</Typography>
          </Box>
          {commande.commentaire && (
            <Box>
              <Typography variant="caption" color="text.secondary">Commentaire</Typography>
              <Typography>{commande.commentaire}</Typography>
            </Box>
          )}
        </Stack>
      </Paper>

      {isEditable && (
        <Stack direction="row" spacing={1} alignItems="center" mb={2}>
          <Typography variant="subtitle2">Changer le statut :</Typography>
          {STATUTS.filter((s) => s !== commande.statut).map((s) => (
            <Button
              key={s}
              size="small"
              variant={s === 'LIVREE' ? 'contained' : 'outlined'}
              color={s === 'LIVREE' ? 'success' : 'inherit'}
              onClick={() => s === 'LIVREE' ? setConfirmStatut(s) : handleStatut(s)}
            >
              {s}
            </Button>
          ))}
        </Stack>
      )}

      <Stack direction="row" justifyContent="space-between" alignItems="center" mb={1}>
        <Typography variant="h6">Lignes de commande</Typography>
        {isEditable && (
          <Button size="small" variant="contained" startIcon={<AddIcon />} onClick={() => { setLigneForm({ articleId: '', quantite: 1 }); setLigneDialog(true); }}>
            Ajouter un article
          </Button>
        )}
      </Stack>

      <Paper variant="outlined" sx={{ borderRadius: 2 }}>
        <Table size="small">
          <TableHead>
            <TableRow sx={{ backgroundColor: '#F0EBE3' }}>
              <TableCell>Article</TableCell>
              <TableCell>Référence</TableCell>
              <TableCell align="right">Quantité</TableCell>
              <TableCell align="right">Prix unit.</TableCell>
              <TableCell align="right">Sous-total</TableCell>
              {isEditable && <TableCell />}
            </TableRow>
          </TableHead>
          <TableBody>
            {commande.lignes?.map((ligne) => (
              <TableRow key={ligne.id}>
                <TableCell>{ligne.article?.designation}</TableCell>
                <TableCell>{ligne.article?.reference}</TableCell>
                <TableCell align="right">{ligne.quantite}</TableCell>
                <TableCell align="right">{Number(ligne.prixUnitaire).toFixed(2)} €</TableCell>
                <TableCell align="right">{(ligne.quantite * Number(ligne.prixUnitaire)).toFixed(2)} €</TableCell>
                {isEditable && (
                  <TableCell align="right">
                    <Tooltip title="Supprimer">
                      <IconButton size="small" color="error" onClick={() => handleSupprimerLigne(ligne.id)}>
                        <DeleteIcon fontSize="small" />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
        <Divider />
        <Box sx={{ p: 2, textAlign: 'right' }}>
          <Typography variant="subtitle1" fontWeight={600}>Total : {total.toFixed(2)} €</Typography>
        </Box>
      </Paper>

      <FormDialog open={ligneDialog} title="Ajouter un article" onClose={() => setLigneDialog(false)} onSubmit={handleAjouterLigne} loading={ligneSaving}>
        <Stack spacing={2} mt={1}>
          <TextField select name="articleId" label="Article *" value={ligneForm.articleId} onChange={(e) => setLigneForm((f) => ({ ...f, articleId: e.target.value }))} size="small" fullWidth>
            {articles.map((a) => (
              <MenuItem key={a.id} value={a.id}>{a.designation} ({a.reference})</MenuItem>
            ))}
          </TextField>
          <TextField name="quantite" label="Quantité *" type="number" value={ligneForm.quantite} onChange={(e) => setLigneForm((f) => ({ ...f, quantite: e.target.value }))} size="small" fullWidth inputProps={{ min: 1 }} />
        </Stack>
      </FormDialog>

      <ConfirmDialog
        open={Boolean(confirmStatut)}
        title="Marquer comme livrée"
        message="Cette action va mettre à jour les stocks automatiquement. Confirmer ?"
        onConfirm={() => handleStatut(confirmStatut)}
        onCancel={() => setConfirmStatut(null)}
      />
    </Box>
  );
}
