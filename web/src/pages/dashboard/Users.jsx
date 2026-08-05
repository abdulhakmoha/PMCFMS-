import { useState, useEffect, useContext } from 'react';
import { motion } from 'framer-motion';
import { Users as UsersIcon, Search, Trash2, Shield, UserCheck, Mail, Phone, MapPin, AlertCircle } from 'lucide-react';
import api from '../../services/api';
import { mediaUrl } from '../../services/mediaUrl';
import { AuthContext } from '../../context/AuthContext';

export default function Users() {
  const { user: currentUser } = useContext(AuthContext);
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setErrorMsg('');
      setLoading(true);
      const res = await api.get('/users');
      setUsers(res.data.data || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching users:', error);
      setErrorMsg(error.response?.data?.message || error.message || 'Failed to fetch users');
      setLoading(false);
    }
  };

  const handleUpdateRole = async (id, newRole) => {
    try {
      await api.put(`/users/${id}/role`, { role: newRole });
      fetchUsers(); // Refresh
    } catch (error) {
      console.error('Error updating role:', error);
      alert('Failed to update user role');
    }
  };

  const handleDeleteUser = async (id) => {
    if (!id) {
      alert('Error: User ID is missing');
      return;
    }

    if (window.confirm('Are you sure you want to delete this user? This action cannot be undone.')) {
      try {
        console.log(`🗑️ Sending delete request for ID: ${id}`);
        const res = await api.delete(`/users/${id}`);
        console.log('✅ Delete response:', res.data);
        alert('User deleted successfully!');
        fetchUsers(); // Refresh
      } catch (error) {
        console.error('❌ Error deleting user:', error.response?.data || error.message);
        const errorMsg = error.response?.data?.message || 'Failed to delete user. Make sure you are authorized.';
        alert(errorMsg);
      }
    }
  };

  // Safe checks for potentially missing or undefined properties
  const filteredUsers = users.filter(user => 
    (user.name || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (user.email || '').toLowerCase().includes(searchTerm.toLowerCase()) ||
    (user.district || '').toLowerCase().includes(searchTerm.toLowerCase())
  );

  const canManage = currentUser?.role === 'admin';
  const canView = currentUser?.role === 'admin' || currentUser?.role === 'moderator';

  if (!canView) {
    return (
      <div className="flex flex-col items-center justify-center py-20 text-center">
        <Shield size={64} style={{ color: 'rgba(239,68,68,0.4)' }} className="mb-4" />
        <h2 style={{ color: 'var(--color-text)' }} className="text-2xl font-bold">Access Denied</h2>
        <p style={{ color: 'var(--color-text-muted)' }} className="max-w-md mt-2">You do not have the necessary permissions to view this page. Only administrators and moderators can view users.</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
        <div>
          <h1 style={{ color: 'var(--color-text)' }} className="text-2xl font-bold tracking-tight">User Management</h1>
          <p style={{ color: 'var(--color-text-muted)' }} className="mt-1 text-sm">Manage community members and their access levels.</p>
        </div>
        
        <div style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', borderRadius: '12px' }} className="px-4 py-2 shadow-sm flex items-center gap-2">
          <UsersIcon size={18} style={{ color: 'var(--color-primary)' }} />
          <span style={{ color: 'var(--color-text)' }} className="text-sm font-bold">{users.length} Total Users</span>
        </div>
      </div>

      {/* Search & Filter */}
      <div className="relative max-w-md">
        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Search size={18} style={{ color: 'var(--color-text-subtle)' }} />
        </div>
        <input 
          type="text" 
          placeholder="Search by name, email or district..." 
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
          className="block w-full pl-10 pr-3 py-2.5 rounded-xl leading-5 placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent transition-all"
        />
      </div>

      {/* Loading state */}
      {loading ? (
        <div className="flex items-center justify-center py-16">
          <div style={{ borderTopColor: 'var(--color-primary)' }} className="w-8 h-8 border-2 border-transparent rounded-full animate-spin" />
        </div>
      ) : errorMsg ? (
        /* Error Alert State */
        <div style={{ background: 'rgba(239,68,68,0.08)', border: '1px solid rgba(239,68,68,0.25)', borderRadius: '16px' }} className="p-6 text-center max-w-xl mx-auto space-y-3">
          <AlertCircle size={40} className="mx-auto text-rose-500" />
          <h3 style={{ color: 'var(--color-text)' }} className="text-lg font-bold">Failed to load users</h3>
          <p style={{ color: 'var(--color-text-muted)' }} className="text-sm">{errorMsg}</p>
          <button 
            onClick={fetchUsers}
            style={{ background: 'linear-gradient(135deg,#EF4444,#DC2626)', color: '#fff', borderRadius: '10px' }}
            className="px-4 py-2 font-bold text-xs transition-opacity hover:opacity-90 shadow-md"
          >
            Try Again
          </button>
        </div>
      ) : filteredUsers.length === 0 ? (
        /* Empty State */
        <div style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)', borderRadius: '16px' }} className="p-12 text-center space-y-2">
          <UsersIcon size={48} style={{ color: 'var(--color-text-subtle)', margin: '0 auto 12px' }} />
          <h3 style={{ color: 'var(--color-text)', fontWeight: 700 }}>No users found</h3>
          <p style={{ color: 'var(--color-text-muted)', fontSize: '14px' }}>Try adjusting your search criteria or check back later.</p>
        </div>
      ) : (
        /* Users Table/Grid */
        <div className="grid grid-cols-1 gap-4">
          <div style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)', borderRadius: '16px' }} className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr style={{ background: 'var(--color-bg-surface)', borderBottom: '1px solid var(--color-border)' }}>
                  <th style={{ color: 'var(--color-text-subtle)' }} className="px-6 py-4 text-xs font-bold uppercase tracking-wider">User</th>
                  <th style={{ color: 'var(--color-text-subtle)' }} className="px-6 py-4 text-xs font-bold uppercase tracking-wider">Contact &amp; Location</th>
                  <th style={{ color: 'var(--color-text-subtle)' }} className="px-6 py-4 text-xs font-bold uppercase tracking-wider">Role</th>
                  <th style={{ color: 'var(--color-text-subtle)' }} className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.map((user) => (
                  <motion.tr 
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    key={user._id} 
                    style={{ borderBottom: '1px solid var(--color-border)' }}
                    className="transition-colors"
                    onMouseEnter={e => e.currentTarget.style.background = 'var(--color-bg-hover)'}
                    onMouseLeave={e => e.currentTarget.style.background = 'transparent'}
                  >
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center gap-3">
                        <div style={{ background: 'rgba(16,185,129,0.15)', color: '#10B981', border: '1px solid rgba(16,185,129,0.3)' }} className="w-10 h-10 rounded-full flex items-center justify-center font-bold overflow-hidden shrink-0">
                          {user.profilePicture ? <img src={mediaUrl(user.profilePicture)} className="w-full h-full object-cover" alt="" /> : (user.name || 'U').charAt(0)}
                        </div>
                        <div>
                          <p style={{ color: 'var(--color-text)' }} className="font-bold">{user.name}</p>
                          <p style={{ color: 'var(--color-text-subtle)' }} className="text-xs">Joined {user.createdAt ? new Date(user.createdAt).toLocaleDateString() : 'N/A'}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="space-y-1">
                        <div style={{ color: 'var(--color-text-muted)' }} className="flex items-center text-xs">
                          <Mail size={12} className="mr-1.5" style={{ color: 'var(--color-text-subtle)' }} /> {user.email || 'N/A'}
                        </div>
                        <div style={{ color: 'var(--color-text-muted)' }} className="flex items-center text-xs">
                          <Phone size={12} className="mr-1.5" style={{ color: 'var(--color-text-subtle)' }} /> {user.phone || 'N/A'}
                        </div>
                        <div style={{ color: 'var(--color-text-muted)' }} className="flex items-center text-xs">
                          <MapPin size={12} className="mr-1.5" style={{ color: 'var(--color-text-subtle)' }} /> {user.district || 'N/A'}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <select 
                        value={user.role}
                        onChange={(e) => handleUpdateRole(user._id, e.target.value)}
                        disabled={!canManage}
                        style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)', border: '1px solid var(--color-border)' }}
                        className={`text-xs font-bold px-2.5 py-1.5 rounded-lg focus:ring-2 focus:ring-[var(--color-primary)] outline-none appearance-none cursor-pointer disabled:cursor-not-allowed disabled:opacity-60 ${
                          user.role === 'admin' ? 'text-violet-400 border-violet-500/30' :
                          user.role === 'moderator' ? 'text-sky-400 border-sky-500/30' :
                          'text-emerald-400 border-emerald-500/30'
                        }`}
                      >
                        <option value="citizen" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Citizen</option>
                        <option value="moderator" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Moderator</option>
                        <option value="admin" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Admin</option>
                      </select>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-right">
                      <button 
                        onClick={() => handleDeleteUser(user._id)}
                        disabled={!canManage || user._id === currentUser._id}
                        className="p-2 text-slate-400 hover:text-rose-600 hover:bg-rose-50/10 rounded-lg transition-all disabled:opacity-30 disabled:hover:bg-transparent disabled:cursor-not-allowed"
                        title={canManage ? "Delete User" : "Only admins can delete users"}
                      >
                        <Trash2 size={18} />
                      </button>
                    </td>
                  </motion.tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
