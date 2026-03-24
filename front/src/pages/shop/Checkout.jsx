import React, { useState } from 'react';
import {
  Container, Stepper, Step, StepLabel, Typography, Box, Button,
  TextField, Grid, Paper, Divider, CircularProgress, Alert,
} from '@mui/material';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';
import { clientService } from '../../services/clientService';
import { commandeClientService } from '../../services/commandeClientService';

const STEPS = ['Récapitulatif', 'Vos coordonnées', 'Confirmation'];

const EMPTY_FORM = {
  nom: '',
  prenom: '',
  email: '',
  telephone: '',
  adresse: '',
  ville: '',
  codePostal: '',
  pays: 'France',
};

const FIELDS = [
  { name: 'prenom', label: 'Prénom', required: true, xs: 6 },
  { name: 'nom',    label: 'Nom',    required: true, xs: 6 },
  { name: 'email',  label: 'Email',  required: true, xs: 12, type: 'email' },
  { name: 'telephone', label: 'Téléphone', xs: 12 },
  { name: 'adresse',   label: 'Adresse',   xs: 12 },
  { name: 'ville',     label: 'Ville',     xs: 6 },
  { name: 'codePostal', label: 'Code postal', xs: 3 },
  { name: 'pays',      label: 'Pays',      xs: 3 },
];

export default function Checkout() {
  const { items, cartTotal, clearCart } = useCart();
  const navigate = useNavigate();
  const [step, setStep] = useState(0);
  const [form, setForm] = useState(EMPTY_FORM);
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);
  const [submitError, setSubmitError] = useState('');

  if (items.length === 0) {
    navigate('/boutique/panier');
    return null;
  }

  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: '' }));
  };

  const validate = () => {
    const errs = {};
    if (!form.prenom.trim()) errs.prenom = 'Obligatoire';
    if (!form.nom.trim()) errs.nom = 'Obligatoire';
    if (!form.email || !/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Email invalide';
    return errs;
  };

  const handleNext = () => {
    if (step === 1) {
      const errs = validate();
      if (Object.keys(errs).length) {
        setErrors(errs);
        return;
      }
    }
    setStep((s) => s + 1);
  };

  const handleConfirm = async () => {
    setLoading(true);
    setSubmitError('');
    try {
      const clientRes = await clientService.findOrCreate(form);
      const clientId = clientRes.data.id;

      const lignes = items.map((i) => ({
        articleId: i.article.id,
        quantite: i.quantite,
      }));
      const cmdRes = await commandeClientService.create({ clientId, lignes });
      const commandeId = cmdRes.data.id;

      clearCart();
      navigate(`/boutique/confirmation?commande=${commandeId}&prenom=${encodeURIComponent(form.prenom)}`);
    } catch (err) {
      setSubmitError(
        err.response?.data?.message || 'Une erreur est survenue. Veuillez réessayer.'
      );
      setStep(1);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
        Votre commande
      </Typography>

      <Stepper activeStep={step} sx={{ mb: 4 }}>
        {STEPS.map((label) => (
          <Step key={label}>
            <StepLabel>{label}</StepLabel>
          </Step>
        ))}
      </Stepper>

      {/* Étape 0 — Récapitulatif panier */}
      {step === 0 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" fontWeight={700} gutterBottom>
            Articles commandés
          </Typography>
          <Divider sx={{ mb: 2 }} />
          {items.map(({ article, quantite }) => (
            <Box
              key={article.id}
              sx={{ display: 'flex', justifyContent: 'space-between', py: 1 }}
            >
              <Box>
                <Typography variant="subtitle2" fontWeight={600}>
                  {article.designation}
                </Typography>
                <Typography variant="caption" color="text.secondary">
                  {[article.maison, article.annee].filter(Boolean).join(' · ')} × {quantite}
                </Typography>
              </Box>
              <Typography fontWeight={600}>
                {(Number(article.prixUnitaire) * quantite).toFixed(2)} €
              </Typography>
            </Box>
          ))}
          <Divider sx={{ my: 2 }} />
          <Box sx={{ display: 'flex', justifyContent: 'space-between' }}>
            <Typography variant="h6" fontWeight={700}>
              Total
            </Typography>
            <Typography variant="h6" fontWeight={700} color="primary.main">
              {cartTotal.toFixed(2)} €
            </Typography>
          </Box>
        </Paper>
      )}

      {/* Étape 1 — Formulaire client */}
      {step === 1 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" fontWeight={700} gutterBottom>
            Vos coordonnées
          </Typography>
          <Divider sx={{ mb: 3 }} />
          {submitError && (
            <Alert severity="error" sx={{ mb: 2 }}>
              {submitError}
            </Alert>
          )}
          <Grid container spacing={2}>
            {FIELDS.map(({ name, label, required, xs, type = 'text' }) => (
              <Grid item xs={xs} key={name}>
                <TextField
                  name={name}
                  label={label}
                  type={type}
                  value={form[name]}
                  onChange={handleChange}
                  error={!!errors[name]}
                  helperText={errors[name]}
                  required={required}
                  fullWidth
                  size="small"
                />
              </Grid>
            ))}
          </Grid>
        </Paper>
      )}

      {/* Étape 2 — Confirmation */}
      {step === 2 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Box sx={{ textAlign: 'center', mb: 3 }}>
            <CheckCircleOutlineIcon sx={{ fontSize: 48, color: 'success.main', mb: 1 }} />
            <Typography variant="h6" fontWeight={700}>
              Récapitulatif final
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Vérifiez vos informations avant de confirmer.
            </Typography>
          </Box>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Livraison à
              </Typography>
              <Typography fontWeight={600}>
                {form.prenom} {form.nom}
              </Typography>
              <Typography variant="body2">{form.email}</Typography>
              {form.telephone && (
                <Typography variant="body2">{form.telephone}</Typography>
              )}
              {form.adresse && (
                <Typography variant="body2">{form.adresse}</Typography>
              )}
              {(form.ville || form.codePostal) && (
                <Typography variant="body2">
                  {form.codePostal} {form.ville}
                </Typography>
              )}
              <Typography variant="body2">{form.pays}</Typography>
            </Grid>
            <Grid item xs={12} md={6}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Commande ({items.reduce((s, i) => s + i.quantite, 0)} articles)
              </Typography>
              {items.map(({ article, quantite }) => (
                <Typography key={article.id} variant="body2">
                  {article.designation} × {quantite}
                </Typography>
              ))}
              <Typography fontWeight={700} color="primary.main" variant="subtitle1" sx={{ mt: 1.5 }}>
                Total : {cartTotal.toFixed(2)} €
              </Typography>
            </Grid>
          </Grid>
          {submitError && (
            <Alert severity="error" sx={{ mt: 2 }}>
              {submitError}
            </Alert>
          )}
        </Paper>
      )}

      {/* Navigation */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', gap: 2 }}>
        <Button
          variant="outlined"
          onClick={() => (step === 0 ? navigate('/boutique/panier') : setStep((s) => s - 1))}
          disabled={loading}
        >
          Retour
        </Button>
        {step < 2 ? (
          <Button variant="contained" onClick={handleNext}>
            Suivant
          </Button>
        ) : (
          <Button
            variant="contained"
            color="success"
            onClick={handleConfirm}
            disabled={loading}
            startIcon={loading ? <CircularProgress size={18} color="inherit" /> : null}
          >
            {loading ? 'Envoi en cours…' : 'Confirmer la commande'}
          </Button>
        )}
      </Box>
    </Container>
  );
}
