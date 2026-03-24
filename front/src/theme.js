import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: {
      main: '#5C2E2E',       // bordeaux profond
      light: '#8A5252',
      dark: '#3A1A1A',
      contrastText: '#FFFFFF',
    },
    secondary: {
      main: '#C8A96E',       // doré cave à vins
      light: '#E0C896',
      dark: '#9C7A42',
      contrastText: '#FFFFFF',
    },
    background: {
      default: '#F5F2EE',
      paper: '#FFFFFF',
    },
    success: { main: '#2E7D32' },
    warning: { main: '#ED6C02' },
    error:   { main: '#D32F2F' },
    text: {
      primary: '#2C1810',
      secondary: '#6B4C3B',
    },
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h5: { fontWeight: 600 },
    h6: { fontWeight: 600 },
  },
  shape: { borderRadius: 8 },
  components: {
    MuiAppBar: {
      styleOverrides: {
        root: { boxShadow: '0 1px 4px rgba(0,0,0,0.15)' },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: { textTransform: 'none', fontWeight: 500 },
      },
    },
    MuiDataGrid: {
      styleOverrides: {
        root: { border: 'none' },
        columnHeaders: { backgroundColor: '#F0EBE3' },
      },
    },
  },
});

export default theme;
