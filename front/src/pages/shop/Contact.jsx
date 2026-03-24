import React, { useState } from 'react';
import {
  Container, Typography, Box, Grid, TextField, Button, Paper,
  Alert, Divider,
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import EmailIcon from '@mui/icons-material/Email';
import PhoneIcon from '@mui/icons-material/Phone';

const CONTACT_INFO = [
  { icon: <LocationOnIcon />, text: 'Route des Vins, 32000 Auch, Gers' },
  { icon: <EmailIcon />,     text: 'contact@negosud.fr' },
  { icon: <PhoneIcon />,     text: '+33 5 62 00 00 00' },
];

export default function Contact() {
  const [form, setForm] = useState({ nom: '', email: '', sujet: '', message: '' });
  const [errors, setErrors] = useState({});
  const [sent, setSent] = useState(false);

  const handleChange = (e) => {
    setForm((f) => ({ ...f, [e.target.name]: e.target.value }));
    setErrors((err) => ({ ...err, [e.target.name]: '' }));
  };

  const validate = () => {
    const errs = {};
    if (!form.nom.trim()) errs.nom = 'Obligatoire';
    if (!form.email || !/\S+@\S+\.\S+/.test(form.email)) errs.email = 'Email invalide';
    if (!form.message.trim()) errs.message = 'Obligatoire';
    return errs;
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const errs = validate();
    if (Object.keys(errs).length) {
      setErrors(errs);
      return;
    }
    setSent(true);
  };

  return (
    <Container maxWidth="lg" sx={{ py: 4 }}>
      <Typography variant="h4" fontWeight={800} color="primary.dark" gutterBottom>
        Nous contacter
      </Typography>
      <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
        Une question sur nos vins, une commande spéciale ? Notre équipe vous répond
        dans les meilleurs délais.
      </Typography>

      <Grid container spacing={4}>
        {/* Formulaire */}
        <Grid item xs={12} md={7}>
          {sent ? (
            <Alert severity="success" sx={{ borderRadius: 2 }}>
              <Typography fontWeight={600}>Message envoyé !</Typography>
              Merci de nous avoir contactés. Nous vous répondrons dans les 48h.
            </Alert>
          ) : (
            <Paper variant="outlined" sx={{ p: 3 }}>
              <form onSubmit={handleSubmit} noValidate>
                <Grid container spacing={2}>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      name="nom"
                      label="Nom complet"
                      value={form.nom}
                      onChange={handleChange}
                      error={!!errors.nom}
                      helperText={errors.nom}
                      fullWidth
                      size="small"
                      required
                    />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      name="email"
                      label="Email"
                      type="email"
                      value={form.email}
                      onChange={handleChange}
                      error={!!errors.email}
                      helperText={errors.email}
                      fullWidth
                      size="small"
                      required
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      name="sujet"
                      label="Sujet (optionnel)"
                      value={form.sujet}
                      onChange={handleChange}
                      fullWidth
                      size="small"
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <TextField
                      name="message"
                      label="Votre message"
                      value={form.message}
                      onChange={handleChange}
                      error={!!errors.message}
                      helperText={errors.message}
                      fullWidth
                      multiline
                      rows={5}
                      required
                    />
                  </Grid>
                  <Grid item xs={12}>
                    <Button
                      type="submit"
                      variant="contained"
                      endIcon={<SendIcon />}
                      sx={{ px: 4 }}
                    >
                      Envoyer
                    </Button>
                  </Grid>
                </Grid>
              </form>
            </Paper>
          )}
        </Grid>

        {/* Coordonnées */}
        <Grid item xs={12} md={5}>
          <Paper
            sx={{
              p: 3,
              backgroundColor: 'primary.dark',
              color: 'white',
              borderRadius: 2,
            }}
          >
            <Typography variant="h6" fontWeight={700} gutterBottom>
              NÉGOSUD
            </Typography>
            <Typography variant="body2" sx={{ opacity: 0.8, mb: 2, lineHeight: 1.7 }}>
              Négociant en vins du terroir gascon. Venez nous rendre visite
              ou contactez-nous par téléphone ou email.
            </Typography>
            <Divider sx={{ borderColor: 'rgba(255,255,255,0.2)', mb: 2 }} />
            {CONTACT_INFO.map(({ icon, text }) => (
              <Box key={text} sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 2 }}>
                <Box sx={{ color: 'secondary.main', display: 'flex', flexShrink: 0 }}>
                  {icon}
                </Box>
                <Typography variant="body2">{text}</Typography>
              </Box>
            ))}
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
}
