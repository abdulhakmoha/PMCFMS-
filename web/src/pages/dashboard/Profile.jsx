import { useState, useContext, useRef } from 'react';
import { motion } from 'framer-motion';
import { User, Mail, Phone, MapPin, Lock, Save, Camera } from 'lucide-react';
import { AuthContext } from '../../context/AuthContext';
import api from '../../services/api';
import { mediaUrl } from '../../services/mediaUrl';

export default function Profile() {
  const { user, updateUser } = useContext(AuthContext);
  const [formData, setFormData] = useState({
    name: user?.name || '',
    email: user?.email || '',
    phone: user?.phone || '',
    district: user?.district || '',
    password: '',
    confirmPassword: ''
  });
  const [profilePicture, setProfilePicture] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const fileInputRef = useRef(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleImageChange = (e) => {
    const file = e.target.files[0];
    if (file) {
      setProfilePicture(file);
      setPreviewUrl(URL.createObjectURL(file));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (formData.password && formData.password !== formData.confirmPassword) {
      return setMessage({ type: 'error', text: 'Passwords do not match' });
    }

    setLoading(true);
    setMessage({ type: '', text: '' });

    try {
      const submitData = new FormData();
      submitData.append('name', formData.name);
      submitData.append('email', formData.email);
      submitData.append('phone', formData.phone);
      submitData.append('district', formData.district);
      if (formData.password) submitData.append('password', formData.password);
      if (profilePicture) submitData.append('profilePicture', profilePicture);

      const res = await api.put('/users/profile', submitData);
      if (res.data.success) {
        // Update local storage and context
        updateUser(res.data.data);
        setMessage({ type: 'success', text: 'Profile updated successfully!' });
      }
    } catch (error) {
      setMessage({ type: 'error', text: error.response?.data?.message || 'Error updating profile' });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      <motion.div 
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)', borderRadius: '24px' }}
        className="overflow-hidden"
      >
        {/* Header/Banner */}
        <div className="h-32 bg-gradient-to-r from-emerald-600 to-teal-600 relative">
          <div className="absolute -bottom-16 left-8">
            <div className="relative group">
              <div style={{ background: 'var(--color-bg-elevated)', border: '2px solid var(--color-border)', borderRadius: '24px', padding: '4px' }} className="w-32 h-32 shadow-xl">
                <div style={{ background: 'var(--color-bg-surface)', borderRadius: '20px', width: '100%', height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', overflow: 'hidden', color: 'var(--color-text-subtle)' }}>
                  {previewUrl || user?.profilePicture ? (
                    <img 
                      src={previewUrl || mediaUrl(user.profilePicture)} 
                      alt="Profile" 
                      className="w-full h-full object-cover" 
                    />
                  ) : (
                    <User size={64} />
                  )}
                </div>
              </div>
              <button 
                onClick={() => fileInputRef.current.click()}
                className="absolute bottom-2 right-2 p-2 bg-emerald-600 text-white rounded-xl shadow-lg hover:bg-emerald-700 transition-colors"
              >
                <Camera size={18} />
              </button>
              <input 
                type="file" 
                accept="image/*" 
                className="hidden" 
                ref={fileInputRef} 
                onChange={handleImageChange} 
              />
            </div>
          </div>
        </div>

        <div className="pt-20 px-8 pb-8">
          <div className="mb-8">
            <h1 style={{ color: 'var(--color-text)' }} className="text-3xl font-bold">{user?.name}</h1>
            <p style={{ color: 'var(--color-primary)' }} className="capitalize">{user?.role} Account</p>
          </div>

          {message.text && (
            <div style={{ background: message.type === 'success' ? 'rgba(16,185,129,0.12)' : 'rgba(239,68,68,0.12)', border: `1px solid ${message.type === 'success' ? 'rgba(16,185,129,0.3)' : 'rgba(239,68,68,0.3)'}`, color: message.type === 'success' ? '#10B981' : '#EF4444', borderRadius: '16px' }} className="p-4 mb-6 text-sm font-medium">
              {message.text}
            </div>
          )}

          <form onSubmit={handleSubmit} className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Personal Info */}
            <div className="space-y-4">
              <h2 style={{ color: 'var(--color-text)' }} className="text-lg font-bold flex items-center gap-2 mb-4">
                <div style={{ background: 'linear-gradient(135deg,#10B981,#059669)', borderRadius: '4px' }} className="w-1 h-6"></div>
                Personal Information
              </h2>
              
              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">Full Name</label>
                <div className="relative">
                  <User className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="text" name="name" value={formData.name} onChange={handleChange}
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">Email Address</label>
                <div className="relative">
                  <Mail className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="email" name="email" value={formData.email} onChange={handleChange}
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">Phone Number</label>
                <div className="relative">
                  <Phone className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="text" name="phone" value={formData.phone} onChange={handleChange}
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">District</label>
                <div className="relative">
                  <MapPin className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="text" name="district" value={formData.district} onChange={handleChange}
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>
            </div>

            {/* Security Section */}
            <div className="space-y-4">
              <h2 style={{ color: 'var(--color-text)' }} className="text-lg font-bold flex items-center gap-2 mb-4">
                <div style={{ background: 'linear-gradient(135deg,#8B5CF6,#6D28D9)', borderRadius: '4px' }} className="w-1 h-6"></div>
                Security
              </h2>

              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">New Password (Optional)</label>
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="password" name="password" value={formData.password} onChange={handleChange}
                    placeholder="Leave blank to keep current"
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="space-y-2">
                <label style={{ color: 'var(--color-text-muted)' }} className="text-sm font-semibold ml-1">Confirm New Password</label>
                <div className="relative">
                  <Lock className="absolute left-4 top-1/2 -translate-y-1/2" size={18} style={{ color: 'var(--color-text-subtle)' }} />
                  <input 
                    type="password" name="confirmPassword" value={formData.confirmPassword} onChange={handleChange}
                    style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                    className="w-full pl-12 pr-4 py-3 rounded-2xl focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent outline-none transition-all"
                  />
                </div>
              </div>

              <div className="pt-8">
                <button 
                  type="submit"
                  disabled={loading}
                  style={{ background: 'linear-gradient(135deg,#10B981,#059669)', color: '#fff', borderRadius: '16px', padding: '16px', fontWeight: 700, border: 'none', cursor: loading ? 'not-allowed' : 'pointer', opacity: loading ? 0.7 : 1, boxShadow: '0 6px 20px rgba(16,185,129,0.4)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '8px', width: '100%', transition: 'opacity 0.2s' }}
                >
                  {loading ? 'Saving Changes...' : (
                    <>
                      <Save size={20} />
                      Save Profile Changes
                    </>
                  )}
                </button>
              </div>
            </div>
          </form>
        </div>
      </motion.div>
    </div>
  );
}
