import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions,
  Button, IconButton, CircularProgress,
} from '@mui/material';
import CloseIcon from '@mui/icons-material/Close';

export default function FormDialog({ open, title, onClose, onSubmit, loading = false, children, maxWidth = 'sm' }) {
  return (
    <Dialog open={open} onClose={onClose} maxWidth={maxWidth} fullWidth>
      <DialogTitle sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        {title}
        <IconButton onClick={onClose} size="small">
          <CloseIcon />
        </IconButton>
      </DialogTitle>
      <DialogContent dividers>{children}</DialogContent>
      <DialogActions>
        <Button onClick={onClose} disabled={loading}>
          Annuler
        </Button>
        <Button
          onClick={onSubmit}
          variant="contained"
          disabled={loading}
          startIcon={loading ? <CircularProgress size={16} color="inherit" /> : null}
        >
          Enregistrer
        </Button>
      </DialogActions>
    </Dialog>
  );
}
