import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogContentText,
  DialogActions, Button,
} from '@mui/material';

export default function ConfirmDialog({ open, title, message, onConfirm, onCancel }) {
  return (
    <Dialog open={open} onClose={onCancel} maxWidth="xs" fullWidth>
      <DialogTitle>{title || 'Confirmation'}</DialogTitle>
      <DialogContent>
        <DialogContentText>{message}</DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button onClick={onCancel}>Annuler</Button>
        <Button onClick={onConfirm} color="error" variant="contained">
          Confirmer
        </Button>
      </DialogActions>
    </Dialog>
  );
}
