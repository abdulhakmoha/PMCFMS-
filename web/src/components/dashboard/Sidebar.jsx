import { NavLink, useNavigate } from 'react-router-dom';
import { Home, Calendar, Users, MessageSquare, LogOut, User, Shield, BarChart3, Megaphone, FolderOpen, Briefcase, AlertCircle } from 'lucide-react';
import { useContext } from 'react';
import { AuthContext } from '../../context/AuthContext';
import { useLanguage } from '../../context/LanguageContext';
import { mediaUrl } from '../../services/mediaUrl';

export default function Sidebar({ isMobileOpen, setIsMobileOpen }) {
  const { logout, user } = useContext(AuthContext);
  const { t } = useLanguage();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const navItems = [
    { icon: <Home size={18} />, label: t('dashboard'), path: '/dashboard' },
    { icon: <Calendar size={18} />, label: t('meetings'), path: '/dashboard/meetings' },
    { icon: <MessageSquare size={18} />, label: t('forums'), path: '/dashboard/forums' },
    { icon: <BarChart3 size={18} />, label: 'Polls', path: '/dashboard/polls' },
    { icon: <Megaphone size={18} />, label: 'Announcements', path: '/dashboard/announcements' },
    { icon: <FolderOpen size={18} />, label: 'Documents', path: '/dashboard/documents' },
    { icon: <Briefcase size={18} />, label: 'Projects', path: '/dashboard/projects' },
    { icon: <AlertCircle size={18} />, label: 'Issues', path: '/dashboard/issues' },
    user?.role === 'admin' && { icon: <Users size={18} />, label: t('users'), path: '/dashboard/users' },
    { icon: <User size={18} />, label: 'Profile', path: '/dashboard/profile' },
  ].filter(Boolean);

  return (
    <>
      {/* Mobile overlay */}
      {isMobileOpen && (
        <div
          style={{ background: 'rgba(0,0,0,0.5)' }}
          className="fixed inset-0 backdrop-blur-sm z-30 md:hidden"
          onClick={() => setIsMobileOpen(false)}
        />
      )}

      <aside
        style={{
          background: 'var(--color-bg-elevated)',
          borderRight: '1px solid var(--color-border)',
          color: 'var(--color-text-muted)',
          boxShadow: '2px 0 12px rgba(0,0,0,0.08)',
        }}
        className={`fixed md:static inset-y-0 left-0 z-40 w-64 flex flex-col transition-transform duration-300 ease-in-out ${
          isMobileOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        }`}
      >
        {/* Brand */}
        <div
          style={{
            background: 'var(--color-bg-elevated)',
            borderBottom: '1px solid var(--color-border)',
          }}
          className="h-16 flex items-center px-5"
        >
          <div
            style={{
              background: 'linear-gradient(135deg, #10B981, #6366F1)',
              boxShadow: '0 4px 12px rgba(16,185,129,0.3)',
            }}
            className="w-8 h-8 rounded-lg flex items-center justify-center mr-3 shrink-0"
          >
            <Shield size={16} className="text-white" />
          </div>
          <div>
            <span className="font-bold text-sm tracking-tight block" style={{ color: 'var(--color-text)' }}>PMCFMS</span>
            <span style={{ color: 'var(--color-text-subtle)', fontSize: '10px' }}>Civic Platform</span>
          </div>
        </div>

        {/* User mini card */}
        <div
          style={{
            background: 'var(--color-bg-surface)',
            margin: '12px',
            borderRadius: '12px',
            border: '1px solid var(--color-border)',
          }}
          className="p-3 flex items-center gap-3"
        >
          <div
            style={{ background: 'linear-gradient(135deg, #10B981, #6366F1)', fontSize: '13px' }}
            className="w-9 h-9 rounded-full flex items-center justify-center text-white font-bold shrink-0 overflow-hidden"
          >
            {user?.profilePicture ? (
              <img src={mediaUrl(user.profilePicture)} alt="" className="w-full h-full object-cover" />
            ) : (
              user?.name?.charAt(0).toUpperCase() || 'U'
            )}
          </div>
          <div className="min-w-0">
            <p className="text-xs font-semibold truncate" style={{ color: 'var(--color-text)' }}>{user?.name}</p>
            <p style={{ color: '#10B981', fontSize: '10px' }} className="capitalize font-medium">{user?.role}</p>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 py-2 px-3 space-y-0.5 overflow-y-auto">
          <p style={{ color: 'var(--color-text-subtle)', fontSize: '10px', fontWeight: 700, letterSpacing: '1px' }} className="uppercase px-3 py-2">
            Menu
          </p>
          {navItems.map((item) => (
            <NavLink
              key={item.label}
              to={item.path}
              end={item.path === '/dashboard'}
              className="flex items-center px-3 py-2.5 rounded-xl font-medium text-sm transition-all relative"
              style={({ isActive }) => isActive
                ? {
                    background: 'rgba(16,185,129,0.12)',
                    color: '#10B981',
                    fontWeight: 600,
                  }
                : {
                    color: 'var(--color-text-muted)',
                  }
              }
            >
              {({ isActive }) => (
                <>
                  {/* Gradient left indicator bar for active item */}
                  {isActive && (
                    <span
                      style={{
                        position: 'absolute',
                        left: 0,
                        top: '20%',
                        bottom: '20%',
                        width: '3px',
                        background: 'linear-gradient(180deg, #10B981, #6366F1)',
                        borderRadius: '0 4px 4px 0',
                      }}
                    />
                  )}
                  <span
                    className="mr-3"
                    style={{ color: isActive ? '#10B981' : 'var(--color-text-subtle)' }}
                  >
                    {item.icon}
                  </span>
                  {item.label}
                </>
              )}
            </NavLink>
          ))}
        </nav>

        {/* Logout */}
        <div style={{ borderTop: '1px solid var(--color-border)', padding: '12px' }}>
          <button
            onClick={handleLogout}
            style={{ color: 'var(--color-text-subtle)' }}
            className="flex items-center w-full px-3 py-2.5 hover:text-red-500 rounded-xl transition-colors font-medium text-sm"
          >
            <LogOut size={18} className="mr-3" />
            Sign Out
          </button>
        </div>
      </aside>
    </>
  );
}
