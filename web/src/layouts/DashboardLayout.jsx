import { Outlet, Navigate } from 'react-router-dom';
import { useState, useContext } from 'react';
import Sidebar from '../components/dashboard/Sidebar';
import Topbar from '../components/dashboard/Topbar';
import { AuthContext } from '../context/AuthContext';

export default function DashboardLayout() {
  const [isMobileOpen, setIsMobileOpen] = useState(false);
  const { user, token, loading } = useContext(AuthContext);

  // Show nothing while auth is loading
  if (loading) {
    return (
      <div style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        height: '100vh',
        background: 'var(--color-bg-base)',
      }}>
        <div style={{
          width: '40px',
          height: '40px',
          border: '3px solid var(--color-border)',
          borderTop: '3px solid #10B981',
          borderRadius: '50%',
          animation: 'spin 0.8s linear infinite',
        }} />
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    );
  }

  // If not logged in, redirect to login WITHOUT page reload (React Router Navigate)
  if (!user || !token) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div style={{ background: 'var(--color-bg-base)', color: 'var(--color-text)' }} className="flex h-screen font-sans overflow-hidden">
      <Sidebar isMobileOpen={isMobileOpen} setIsMobileOpen={setIsMobileOpen} />
      
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Topbar setIsMobileOpen={setIsMobileOpen} />
        
        <main style={{ background: 'var(--color-bg-base)' }} className="flex-1 overflow-y-auto">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}
