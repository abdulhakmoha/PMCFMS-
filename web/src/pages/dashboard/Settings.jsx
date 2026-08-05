import { useState, useContext } from 'react';
import { motion } from 'framer-motion';
import { Settings as SettingsIcon, User, Lock, Mail, Phone, MapPin, Save, Shield, CheckCircle } from 'lucide-react';
import api from '../../services/api';
import { AuthContext } from '../../context/AuthContext';

const D = {
  bg:      'var(--color-bg-elevated)',
  surface: 'var(--color-bg-surface)',
  border:  'var(--color-border)',
  text:    'var(--color-text)',
  muted:   'var(--color-text-muted)',
  subtle:  'var(--color-text-subtle)',
  primary: 'var(--color-primary)',
};

const inputStyle = {
  background: 'var(--color-bg-surface)',
  border: '1px solid var(--color-border)',
  color: 'var(--color-text)',
  borderRadius: '12px',
  padding: '10px 12px 10px 36px',
  width: '100%',
  outline: 'none',
  transition: 'border-color 0.2s, box-shadow 0.2s',
};

function DarkInput({ icon, ...props }) {
  return (
    <div className="relative">
      <span style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: D.subtle }}>{icon}</span>
      <input
        {...props}
        style={inputStyle}
        onFocus={e => { e.target.style.borderColor = '#10B981'; e.target.style.boxShadow = '0 0 0 3px rgba(16,185,129,0.18)'; }}
        onBlur={e => { e.target.style.borderColor = D.border; e.target.style.boxShadow = 'none'; }}
      />
    </div>
  );
}

export default function Settings() {
  const { user, updateUser } = useContext(AuthContext);
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState('profile');

  const [profileData, setProfileData] = useState({
    name: user?.name || '',
    email: user?.email || '',
    phone: user?.phone || '',
    district: user?.district || '',
  });

  const [passwordData, setPasswordData] = useState({
    newPassword: '',
    confirmPassword: '',
  });

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    setLoading(true); setSuccess(''); setError('');
    try {
      const res = await api.put('/users/profile', profileData);
      updateUser(res.data.data);
      setSuccess('Profile updated successfully!');
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update profile');
    } finally {
      setLoading(false);
    }
  };

  const handleUpdatePassword = async (e) => {
    e.preventDefault();
    if (passwordData.newPassword !== passwordData.confirmPassword) return setError('Passwords do not match');
    setLoading(true); setSuccess(''); setError('');
    try {
      await api.put('/users/profile', { password: passwordData.newPassword });
      setSuccess('Password updated successfully!');
      setPasswordData({ newPassword: '', confirmPassword: '' });
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to update password');
    } finally {
      setLoading(false);
    }
  };

  const tabs = [
    { id: 'profile', label: 'Profile Information', icon: <User size={17} /> },
    { id: 'security', label: 'Security', icon: <Lock size={17} /> },
    { id: 'preferences', label: 'Preferences', icon: <SettingsIcon size={17} /> },
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-6">

      {/* Header */}
      <div className="mb-6">
        <h1 style={{ color: D.text }} className="text-2xl font-bold tracking-tight">Account Settings</h1>
        <p style={{ color: D.muted }} className="mt-1 text-sm">Manage your profile information and security settings.</p>
      </div>

      {/* Status Messages */}
      {success && (
        <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}
          style={{ background: 'rgba(16,185,129,0.12)', border: '1px solid rgba(16,185,129,0.3)', color: '#10B981', borderRadius: '12px' }}
          className="p-4 text-sm font-medium flex items-center gap-2">
          <CheckCircle size={17} /> {success}
        </motion.div>
      )}
      {error && (
        <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }}
          style={{ background: 'rgba(239,68,68,0.12)', border: '1px solid rgba(239,68,68,0.3)', color: '#EF4444', borderRadius: '12px' }}
          className="p-4 text-sm font-medium flex items-center gap-2">
          <Shield size={17} /> {error}
        </motion.div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">

        {/* Sidebar Tabs */}
        <div className="space-y-1">
          {tabs.map(tab => (
            <button key={tab.id} onClick={() => setActiveTab(tab.id)}
              style={activeTab === tab.id
                ? { background: 'linear-gradient(135deg,rgba(16,185,129,0.15),rgba(139,92,246,0.1))', border: '1px solid rgba(16,185,129,0.3)', color: '#10B981', borderRadius: '12px', width: '100%', textAlign: 'left', padding: '12px 16px', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer' }
                : { background: 'transparent', border: '1px solid transparent', color: D.muted, borderRadius: '12px', width: '100%', textAlign: 'left', padding: '12px 16px', fontWeight: 500, display: 'flex', alignItems: 'center', gap: '10px', cursor: 'pointer', transition: 'all 0.15s' }}
              onMouseEnter={e => { if (activeTab !== tab.id) { e.currentTarget.style.background = D.surface; e.currentTarget.style.color = D.text; }}}
              onMouseLeave={e => { if (activeTab !== tab.id) { e.currentTarget.style.background = 'transparent'; e.currentTarget.style.color = D.muted; }}}>
              {tab.icon} {tab.label}
            </button>
          ))}
        </div>

        {/* Content */}
        <div className="md:col-span-2 space-y-6">

          {/* Profile Form */}
          {activeTab === 'profile' && (
            <div style={{ background: D.bg, border: `1px solid ${D.border}`, borderRadius: '16px' }} className="p-6">
              <h3 style={{ color: D.text }} className="text-lg font-bold mb-6 flex items-center gap-2">
                <User size={19} color={D.primary} /> General Information
              </h3>
              <form onSubmit={handleUpdateProfile} className="space-y-4">
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">Full Name</label>
                    <DarkInput icon={<User size={15} />} type="text" value={profileData.name} onChange={e => setProfileData({...profileData, name: e.target.value})} />
                  </div>
                  <div>
                    <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">Email Address</label>
                    <DarkInput icon={<Mail size={15} />} type="email" value={profileData.email} onChange={e => setProfileData({...profileData, email: e.target.value})} />
                  </div>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">Phone Number</label>
                    <DarkInput icon={<Phone size={15} />} type="text" value={profileData.phone} onChange={e => setProfileData({...profileData, phone: e.target.value})} />
                  </div>
                  <div>
                    <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">District</label>
                    <DarkInput icon={<MapPin size={15} />} type="text" value={profileData.district} onChange={e => setProfileData({...profileData, district: e.target.value})} />
                  </div>
                </div>
                <div className="pt-2">
                  <button type="submit" disabled={loading}
                    style={{ background: 'linear-gradient(135deg,#10B981,#059669)', color: '#fff', borderRadius: '12px', padding: '10px 20px', fontWeight: 700, border: 'none', cursor: loading ? 'not-allowed' : 'pointer', opacity: loading ? 0.7 : 1, display: 'flex', alignItems: 'center', gap: '8px', boxShadow: '0 4px 12px rgba(16,185,129,0.3)' }}>
                    <Save size={17} /> {loading ? 'Saving...' : 'Save Changes'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Password Form */}
          {activeTab === 'security' && (
            <div style={{ background: D.bg, border: `1px solid ${D.border}`, borderRadius: '16px' }} className="p-6">
              <h3 style={{ color: D.text }} className="text-lg font-bold mb-6 flex items-center gap-2">
                <Lock size={19} color="#EF4444" /> Change Password
              </h3>
              <form onSubmit={handleUpdatePassword} className="space-y-4">
                <div>
                  <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">New Password</label>
                  <div className="relative">
                    <span style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: D.subtle }}><Lock size={15} /></span>
                    <input type="password" required value={passwordData.newPassword}
                      onChange={e => setPasswordData({...passwordData, newPassword: e.target.value})}
                      placeholder="At least 6 characters"
                      style={{ ...inputStyle }}
                      onFocus={e => { e.target.style.borderColor = '#10B981'; e.target.style.boxShadow = '0 0 0 3px rgba(16,185,129,0.18)'; }}
                      onBlur={e => { e.target.style.borderColor = D.border; e.target.style.boxShadow = 'none'; }} />
                  </div>
                </div>
                <div>
                  <label style={{ color: D.muted }} className="block text-sm font-semibold mb-1">Confirm New Password</label>
                  <div className="relative">
                    <span style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: D.subtle }}><Lock size={15} /></span>
                    <input type="password" required value={passwordData.confirmPassword}
                      onChange={e => setPasswordData({...passwordData, confirmPassword: e.target.value})}
                      style={{ ...inputStyle }}
                      onFocus={e => { e.target.style.borderColor = '#10B981'; e.target.style.boxShadow = '0 0 0 3px rgba(16,185,129,0.18)'; }}
                      onBlur={e => { e.target.style.borderColor = D.border; e.target.style.boxShadow = 'none'; }} />
                  </div>
                </div>
                <div className="pt-2">
                  <button type="submit" disabled={loading}
                    style={{ background: 'linear-gradient(135deg,#EF4444,#DC2626)', color: '#fff', borderRadius: '12px', padding: '10px 20px', fontWeight: 700, border: 'none', cursor: loading ? 'not-allowed' : 'pointer', opacity: loading ? 0.7 : 1, boxShadow: '0 4px 12px rgba(239,68,68,0.3)' }}>
                    {loading ? 'Updating...' : 'Update Password'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Preferences placeholder */}
          {activeTab === 'preferences' && (
            <div style={{ background: D.bg, border: `1px solid ${D.border}`, borderRadius: '16px' }} className="p-6">
              <h3 style={{ color: D.text }} className="text-lg font-bold mb-4 flex items-center gap-2">
                <SettingsIcon size={19} color={D.primary} /> Preferences
              </h3>
              <p style={{ color: D.muted, fontSize: '14px' }}>Preference settings coming soon.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
