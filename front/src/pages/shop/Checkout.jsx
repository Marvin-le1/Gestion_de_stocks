import React, { useState } from 'react';
import {
  Container, Stepper, Step, StepLabel, Typography, Box, Button,
  TextField, Grid, Paper, Divider, CircularProgress, Alert, Chip,
  InputAdornment, IconButton,
} from '@mui/material';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutline';
import PersonIcon from '@mui/icons-material/Person';
import PersonAddIcon from '@mui/icons-material/PersonAdd';
import Visibility from '@mui/icons-material/Visibility';
import VisibilityOff from '@mui/icons-material/VisibilityOff';
import { useNavigate } from 'react-router-dom';
import { useCart } from '../../contexts/CartContext';
import { useShopAuth } from '../../contexts/ShopAuthContext';
import { clientService } from '../../services/clientService';
import { commandeClientService } from '../../services/commandeClientService';

// ── Constantes ───────────────────────────────────────────────────────────────

const STEPS = ['Récapitulatif', 'Identification', 'Vos coordonnées', 'Confirmation'];

const EMPTY_FORM = {
  nom: '', prenom: '', email: '',
  telephone: '', adresse: '', ville: '', codePostal: '', pays: 'France',
  motDePasse: '', confirmMotDePasse: '',
};

// ── Composant ────────────────────────────────────────────────────────────────

export default function Checkout() {
  const { items, cartTotal, clearCart } = useCart();
  const { shopClient } = useShopAuth();
  const navigate = useNavigate();

  // Si le client est déjà connecté, on pré-remplit et on saute l'étape 1
  const [step, setStep] = useState(shopClient ? 0 : 0);
  const [form, setForm] = useState(
    shopClient
      ? {
          nom: shopClient.nom ?? '', prenom: shopClient.prenom ?? '',
          email: shopClient.email ?? '', telephone: shopClient.telephone ?? '',
          adresse: shopClient.adresse ?? '', ville: shopClient.ville ?? '',
          codePostal: shopClient.codePostal ?? '', pays: shopClient.pays ?? 'France',
          motDePasse: '', confirmMotDePasse: '',
        }
      : EMPTY_FORM
  );
  const [errors, setErrors]       = useState({});
  const [loading, setLoading]     = useState(false);
  const [submitError, setSubmitError] = useState('');

  // Statut compte pour l'étape identification
  // Si déjà connecté via la navbar → on considère "existing_no_pwd" pour skip l'étape
  const initialAccountStatus = shopClient ? 'existing_no_pwd' : null;

  // Identification step
  const [emailInput, setEmailInput]     = useState(shopClient?.email ?? '');
  const [emailError, setEmailError]     = useState('');
  const [emailChecked, setEmailChecked] = useState(!!shopClient);
  const [accountStatus, setAccountStatus] = useState(initialAccountStatus);
  const [passwordInput, setPasswordInput] = useState('');
  const [showPassword, setShowPassword]   = useState(false);
  const [loginError, setLoginError]       = useState('');
  const [createAccount, setCreateAccount] = useState(false); // pour nouveau client
  const [showConfirmPwd, setShowConfirmPwd] = useState(false);

  if (items.length === 0) {
    navigate('/boutique/panier');
    return null;
  }

  // ── Étape 1 : vérification email ──────────────────────────────────────────

  const handleCheckEmail = async () => {
    if (!emailInput || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(emailInput)) {
      setEmailError('Email invalide');
      return;
    }
    setEmailError('');
    setLoading(true);
    try {
      const res = await clientService.hasPassword(emailInput);
      const { exists, hasPassword } = res.data;
      setEmailChecked(true);

      if (!exists) {
        setAccountStatus('new');
        setForm((f) => ({ ...f, email: emailInput }));
      } else if (hasPassword) {
        setAccountStatus('existing_pwd');
      } else {
        // Compte existant sans mot de passe → on pré-remplit
        setAccountStatus('existing_no_pwd');
        const clientRes = await clientService.findByEmail(emailInput);
        const c = clientRes.data;
        setForm({
          nom: c.nom ?? '', prenom: c.prenom ?? '', email: c.email ?? '',
          telephone: c.telephone ?? '', adresse: c.adresse ?? '',
          ville: c.ville ?? '', codePostal: c.codePostal ?? '',
          pays: c.pays ?? 'France',
          motDePasse: '', confirmMotDePasse: '',
        });
      }
    } catch {
      setEmailError('Impossible de vérifier l\'email. Réessayez.');
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = async () => {
    if (!passwordInput) { setLoginError('Mot de passe requis'); return; }
    setLoginError('');
    setLoading(true);
    try {
      const res = await clientService.loginClient(emailInput, passwordInput);
      const c = res.data;
      setForm({
        nom: c.nom ?? '', prenom: c.prenom ?? '', email: c.email ?? '',
        telephone: c.telephone ?? '', adresse: c.adresse ?? '',
        ville: c.ville ?? '', codePostal: c.codePostal ?? '',
        pays: c.pays ?? 'France',
        motDePasse: '', confirmMotDePasse: '',
      });
      setStep(2);
    } catch (err) {
      setLoginError(err.response?.data || 'Mot de passe incorrect');
    } finally {
      setLoading(false);
    }
  };

  const handleContinueWithEmail = () => {
    // Compte existant sans mdp ou nouveau client → aller au formulaire
    setStep(2);
  };

  const handleResetEmail = () => {
    setEmailInput('');
    setEmailChecked(false);
    setAccountStatus(null);
    setPasswordInput('');
    setLoginError('');
    setEmailError('');
    setCreateAccount(false);
  };

  // ── Étape 2 : validation formulaire ──────────────────────────────────────

  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: '' }));
  };

  const validate = () => {
    const errs = {};
    if (!form.prenom.trim()) errs.prenom = 'Obligatoire';
    if (!form.nom.trim())    errs.nom    = 'Obligatoire';
    if (!form.email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email))
      errs.email = 'Email invalide';
    if (createAccount && accountStatus === 'new') {
      if (!form.motDePasse || form.motDePasse.length < 6)
        errs.motDePasse = '6 caractères minimum';
      if (form.motDePasse !== form.confirmMotDePasse)
        errs.confirmMotDePasse = 'Les mots de passe ne correspondent pas';
    }
    return errs;
  };

  const handleNextFromForm = () => {
    const errs = validate();
    if (Object.keys(errs).length) { setErrors(errs); return; }
    setStep(3);
  };

  // ── Confirmation finale ───────────────────────────────────────────────────

  const handleConfirm = async () => {
    setLoading(true);
    setSubmitError('');
    try {
      const payload = {
        nom: form.nom, prenom: form.prenom, email: form.email,
        telephone: form.telephone, adresse: form.adresse,
        ville: form.ville, codePostal: form.codePostal, pays: form.pays,
      };
      if (createAccount && accountStatus === 'new' && form.motDePasse) {
        payload.motDePasse = form.motDePasse;
      }

      const clientRes = await clientService.findOrCreate(payload);
      const clientId  = clientRes.data.id;

      const lignes = items.map((i) => ({
        articleId: i.article.id,
        quantite:  i.quantite,
      }));
      const cmdRes = await commandeClientService.create({ clientId, lignes });

      clearCart();
      navigate(
        `/boutique/confirmation?commande=${cmdRes.data.id}&prenom=${encodeURIComponent(form.prenom)}`
      );
    } catch (err) {
      setSubmitError(
        err.response?.data?.message || 'Une erreur est survenue. Veuillez réessayer.'
      );
      setStep(2);
    } finally {
      setLoading(false);
    }
  };

  // ── Rendu ─────────────────────────────────────────────────────────────────

  return (
    <Container maxWidth="md" sx={{ py: 4 }}>
      <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
        Votre commande
      </Typography>

      <Stepper activeStep={step} sx={{ mb: 4 }}>
        {STEPS.map((label) => (
          <Step key={label}><StepLabel>{label}</StepLabel></Step>
        ))}
      </Stepper>

      {/* ── Étape 0 : Récapitulatif panier ── */}
      {step === 0 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" fontWeight={700} gutterBottom>Articles commandés</Typography>
          <Divider sx={{ mb: 2 }} />
          {items.map(({ article, quantite }) => (
            <Box key={article.id} sx={{ display: 'flex', justifyContent: 'space-between', py: 1 }}>
              <Box>
                <Typography variant="subtitle2" fontWeight={600}>{article.designation}</Typography>
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
            <Typography variant="h6" fontWeight={700}>Total</Typography>
            <Typography variant="h6" fontWeight={700} color="primary.main">
              {cartTotal.toFixed(2)} €
            </Typography>
          </Box>
        </Paper>
      )}

      {/* ── Étape 1 : Identification ── */}
      {step === 1 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" fontWeight={700} gutterBottom>Identification</Typography>
          <Divider sx={{ mb: 3 }} />

          {!emailChecked ? (
            /* Saisie email */
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, maxWidth: 440 }}>
              <Typography variant="body2" color="text.secondary">
                Entrez votre email pour continuer. Si vous avez déjà commandé chez nous,
                nous récupèrerons vos informations automatiquement.
              </Typography>
              <TextField
                label="Votre email"
                type="email"
                value={emailInput}
                onChange={(e) => { setEmailInput(e.target.value); setEmailError(''); }}
                onKeyDown={(e) => e.key === 'Enter' && handleCheckEmail()}
                error={!!emailError}
                helperText={emailError}
                fullWidth
                size="small"
                autoFocus
              />
              <Button
                variant="contained"
                onClick={handleCheckEmail}
                disabled={loading}
                startIcon={loading ? <CircularProgress size={16} color="inherit" /> : null}
              >
                {loading ? 'Vérification…' : 'Continuer'}
              </Button>
            </Box>
          ) : (
            <>
              {/* Email vérifié — affichage du statut */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 3 }}>
                <Typography variant="body2" color="text.secondary">Email :</Typography>
                <Typography fontWeight={600}>{emailInput}</Typography>
                <Button size="small" onClick={handleResetEmail} sx={{ ml: 1 }}>Modifier</Button>
              </Box>

              {/* Nouveau client */}
              {accountStatus === 'new' && (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <PersonAddIcon color="primary" />
                    <Typography fontWeight={600}>Première commande</Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    Bienvenue ! Remplissez vos coordonnées à l'étape suivante.
                  </Typography>
                  <Button variant="contained" onClick={handleContinueWithEmail} sx={{ alignSelf: 'flex-start' }}>
                    Continuer
                  </Button>
                </Box>
              )}

              {/* Client existant sans mot de passe */}
              {accountStatus === 'existing_no_pwd' && (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <PersonIcon color="success" />
                    <Typography fontWeight={600} color="success.main">
                      Nous vous reconnaissons !
                    </Typography>
                    <Chip label="Déjà client" color="success" size="small" variant="outlined" />
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    Vos coordonnées ont été pré-remplies. Vous pouvez les vérifier à l'étape suivante.
                  </Typography>
                  <Button variant="contained" onClick={handleContinueWithEmail} sx={{ alignSelf: 'flex-start' }}>
                    Continuer avec mes informations
                  </Button>
                </Box>
              )}

              {/* Client existant avec mot de passe */}
              {accountStatus === 'existing_pwd' && (
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, maxWidth: 440 }}>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <PersonIcon color="primary" />
                    <Typography fontWeight={600}>Connexion à votre compte</Typography>
                  </Box>
                  <Typography variant="body2" color="text.secondary">
                    Entrez votre mot de passe pour récupérer vos informations.
                  </Typography>
                  {loginError && <Alert severity="error">{loginError}</Alert>}
                  <TextField
                    label="Mot de passe"
                    type={showPassword ? 'text' : 'password'}
                    value={passwordInput}
                    onChange={(e) => { setPasswordInput(e.target.value); setLoginError(''); }}
                    onKeyDown={(e) => e.key === 'Enter' && handleLogin()}
                    error={!!loginError}
                    fullWidth
                    size="small"
                    autoFocus
                    InputProps={{
                      endAdornment: (
                        <InputAdornment position="end">
                          <IconButton size="small" onClick={() => setShowPassword((s) => !s)}>
                            {showPassword ? <VisibilityOff /> : <Visibility />}
                          </IconButton>
                        </InputAdornment>
                      ),
                    }}
                  />
                  <Button
                    variant="contained"
                    onClick={handleLogin}
                    disabled={loading}
                    startIcon={loading ? <CircularProgress size={16} color="inherit" /> : null}
                    sx={{ alignSelf: 'flex-start' }}
                  >
                    {loading ? 'Connexion…' : 'Se connecter'}
                  </Button>
                </Box>
              )}
            </>
          )}
        </Paper>
      )}

      {/* ── Étape 2 : Formulaire coordonnées ── */}
      {step === 2 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Typography variant="h6" fontWeight={700} gutterBottom>Vos coordonnées</Typography>
          <Divider sx={{ mb: 3 }} />
          {submitError && <Alert severity="error" sx={{ mb: 2 }}>{submitError}</Alert>}
          <Grid container spacing={2}>
            <Grid item xs={6}>
              <TextField name="prenom" label="Prénom" required value={form.prenom}
                onChange={handleChange} error={!!errors.prenom} helperText={errors.prenom}
                fullWidth size="small" />
            </Grid>
            <Grid item xs={6}>
              <TextField name="nom" label="Nom" required value={form.nom}
                onChange={handleChange} error={!!errors.nom} helperText={errors.nom}
                fullWidth size="small" />
            </Grid>
            <Grid item xs={12}>
              <TextField name="email" label="Email" type="email" required value={form.email}
                onChange={handleChange} error={!!errors.email} helperText={errors.email}
                fullWidth size="small" />
            </Grid>
            <Grid item xs={12}>
              <TextField name="telephone" label="Téléphone" value={form.telephone}
                onChange={handleChange} fullWidth size="small" />
            </Grid>
            <Grid item xs={12}>
              <TextField name="adresse" label="Adresse" value={form.adresse}
                onChange={handleChange} fullWidth size="small" />
            </Grid>
            <Grid item xs={6}>
              <TextField name="ville" label="Ville" value={form.ville}
                onChange={handleChange} fullWidth size="small" />
            </Grid>
            <Grid item xs={3}>
              <TextField name="codePostal" label="Code postal" value={form.codePostal}
                onChange={handleChange} fullWidth size="small" />
            </Grid>
            <Grid item xs={3}>
              <TextField name="pays" label="Pays" value={form.pays}
                onChange={handleChange} fullWidth size="small" />
            </Grid>

            {/* Option création de compte — uniquement pour les nouveaux clients */}
            {accountStatus === 'new' && (
              <>
                <Grid item xs={12}>
                  <Divider sx={{ my: 1 }}>
                    <Typography variant="caption" color="text.secondary">
                      Créer un compte pour commander plus facilement (optionnel)
                    </Typography>
                  </Divider>
                </Grid>
                <Grid item xs={12}>
                  <Box sx={{ display: 'flex', gap: 1, mb: 1 }}>
                    <Button
                      size="small"
                      variant={createAccount ? 'contained' : 'outlined'}
                      onClick={() => setCreateAccount(true)}
                    >
                      Oui, créer mon compte
                    </Button>
                    <Button
                      size="small"
                      variant={!createAccount ? 'contained' : 'outlined'}
                      onClick={() => setCreateAccount(false)}
                    >
                      Non, continuer en invité
                    </Button>
                  </Box>
                </Grid>
                {createAccount && (
                  <>
                    <Grid item xs={6}>
                      <TextField
                        name="motDePasse"
                        label="Mot de passe"
                        type={showConfirmPwd ? 'text' : 'password'}
                        value={form.motDePasse}
                        onChange={handleChange}
                        error={!!errors.motDePasse}
                        helperText={errors.motDePasse || '6 caractères minimum'}
                        fullWidth size="small"
                        InputProps={{
                          endAdornment: (
                            <InputAdornment position="end">
                              <IconButton size="small" onClick={() => setShowConfirmPwd((s) => !s)}>
                                {showConfirmPwd ? <VisibilityOff /> : <Visibility />}
                              </IconButton>
                            </InputAdornment>
                          ),
                        }}
                      />
                    </Grid>
                    <Grid item xs={6}>
                      <TextField
                        name="confirmMotDePasse"
                        label="Confirmer le mot de passe"
                        type={showConfirmPwd ? 'text' : 'password'}
                        value={form.confirmMotDePasse}
                        onChange={handleChange}
                        error={!!errors.confirmMotDePasse}
                        helperText={errors.confirmMotDePasse}
                        fullWidth size="small"
                      />
                    </Grid>
                  </>
                )}
              </>
            )}
          </Grid>
        </Paper>
      )}

      {/* ── Étape 3 : Confirmation ── */}
      {step === 3 && (
        <Paper variant="outlined" sx={{ p: 3, mb: 3 }}>
          <Box sx={{ textAlign: 'center', mb: 3 }}>
            <CheckCircleOutlineIcon sx={{ fontSize: 48, color: 'success.main', mb: 1 }} />
            <Typography variant="h6" fontWeight={700}>Récapitulatif final</Typography>
            <Typography variant="body2" color="text.secondary">
              Vérifiez vos informations avant de confirmer.
            </Typography>
          </Box>
          <Grid container spacing={3}>
            <Grid item xs={12} md={6}>
              <Typography variant="subtitle2" color="text.secondary" gutterBottom>
                Livraison à
              </Typography>
              <Typography fontWeight={600}>{form.prenom} {form.nom}</Typography>
              <Typography variant="body2">{form.email}</Typography>
              {form.telephone && <Typography variant="body2">{form.telephone}</Typography>}
              {form.adresse   && <Typography variant="body2">{form.adresse}</Typography>}
              {(form.ville || form.codePostal) && (
                <Typography variant="body2">{form.codePostal} {form.ville}</Typography>
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
          {submitError && <Alert severity="error" sx={{ mt: 2 }}>{submitError}</Alert>}
        </Paper>
      )}

      {/* ── Navigation ── */}
      <Box sx={{ display: 'flex', justifyContent: 'space-between', gap: 2 }}>
        <Button
          variant="outlined"
          disabled={loading}
          onClick={() => {
            if (step === 0) navigate('/boutique/panier');
            else if (step === 2 && accountStatus === 'existing_pwd') setStep(1); // retour login
            else setStep((s) => s - 1);
          }}
        >
          Retour
        </Button>

        {step === 0 && (
          <Button variant="contained" onClick={() => setStep(shopClient ? 2 : 1)}>
            Suivant
          </Button>
        )}

        {/* Étape 1 : pas de bouton "Suivant" ici, géré dans le contenu */}

        {step === 2 && (
          <Button variant="contained" onClick={handleNextFromForm}>
            Vérifier ma commande
          </Button>
        )}

        {step === 3 && (
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
