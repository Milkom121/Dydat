'use client';

export function TutorDashboard() {
  return (
    <div style={{ 
      padding: '20px', 
      backgroundColor: '#f59e0b', 
      color: 'white', 
      borderRadius: '10px',
      margin: '20px'
    }}>
      <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>
        🔥 COMPONENTE TUTOR AGGIORNATO! 🔥
      </h1>
      <p style={{ marginTop: '10px' }}>
        Se vedi questo messaggio, il componente è stato caricato correttamente!
      </p>
      <p style={{ marginTop: '10px', fontSize: '14px' }}>
        Timestamp: {new Date().toLocaleString()}
      </p>
    </div>
  );
} 