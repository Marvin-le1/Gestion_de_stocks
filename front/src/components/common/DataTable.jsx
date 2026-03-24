import React from 'react';
import { DataGrid } from '@mui/x-data-grid';
import { Box, Paper } from '@mui/material';

export default function DataTable({ rows, columns, loading = false, height = 520, ...props }) {
  return (
    <Paper elevation={0} variant="outlined" sx={{ borderRadius: 2 }}>
      <Box sx={{ height }}>
        <DataGrid
          rows={rows}
          columns={columns}
          loading={loading}
          pageSizeOptions={[25, 50, 100]}
          initialState={{ pagination: { paginationModel: { pageSize: 25 } } }}
          disableRowSelectionOnClick
          sx={{ border: 'none' }}
          {...props}
        />
      </Box>
    </Paper>
  );
}
