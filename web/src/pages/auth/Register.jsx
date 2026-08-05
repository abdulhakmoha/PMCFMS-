import { useState, useContext } from 'react';
import { motion } from 'framer-motion';
import { User, Mail, Lock, Phone, MapPin, ArrowRight } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../../context/AuthContext';

export default function Register() {
  const [formData, setFormData] = useState({
    name: '',
    district: '',
    phone: '',
    email: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { registerUser } = useContext(AuthContext);
  const navigate = useNavigate();

  const slideIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.4 } },
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    const result = await registerUser({
      ...formData
    });

    if (result.success) {
      navigate('/dashboard');
    } else {
      setError(result.error);
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-[calc(100vh-64px)] flex items-center justify-center p-4 py-12">
      {/* Background decoration */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-4xl h-full pointer-events-none opacity-40 -z-10">
        <div className="absolute top-10 right-10 w-80 h-80 bg-rose-500/10 rounded-full mix-blend-multiply filter blur-3xl opacity-60 animate-blob"></div>
        <div className="absolute bottom-10 left-10 w-80 h-80 bg-emerald-500/10 rounded-full mix-blend-multiply filter blur-3xl opacity-60 animate-blob animation-delay-2000"></div>
      </div>

      <div style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)' }} className="glass w-full max-w-2xl p-8 sm:p-10 rounded-3xl relative overflow-hidden">
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-emerald-400 via-indigo-500 to-rose-500"></div>
        
        <div className="text-center mb-8">
          <h2 style={{ color: 'var(--color-text)' }} className="text-3xl font-extrabold tracking-tight mb-2">
            Create Your Account
          </h2>
          <p style={{ color: 'var(--color-text-muted)' }} className="font-medium">
            Join the community and start participating.
          </p>
        </div>

        {error && (
          <div style={{ background: 'rgba(239,68,68,0.12)', border: '1px solid rgba(239,68,68,0.3)', color: '#EF4444', borderRadius: '12px' }} className="mb-6 p-4 text-sm font-medium">
            {error}
          </div>
        )}

        <motion.form variants={slideIn} initial="hidden" animate="visible" className="space-y-5" onSubmit={handleSubmit}>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
            <div>
              <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">Full Name</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <User size={18} style={{ color: 'var(--color-text-subtle)' }} />
                </div>
                <input type="text" name="name" value={formData.name} onChange={handleInputChange} required
                  style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                  className="block w-full pl-10 pr-3 py-3 rounded-xl focus:ring-2 focus:ring-[var(--color-primary)] outline-none transition-all placeholder-slate-500" placeholder="John Doe" />
              </div>
            </div>

            <div>
              <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">District / Location</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MapPin size={18} style={{ color: 'var(--color-text-subtle)' }} />
                </div>
                <select name="district" value={formData.district} onChange={handleInputChange} required
                  style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                  className="block w-full pl-10 pr-3 py-3 rounded-xl focus:ring-2 focus:ring-[var(--color-primary)] outline-none transition-all appearance-none cursor-pointer">
                  <option value="" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Select your district...</option>
                  <option value="Banadir" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Banadir</option>
                  <option value="Hargeisa" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Hargeisa</option>
                  <option value="Garowe" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Garowe</option>
                  <option value="Kismayo" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Kismayo</option>
                  <option value="Baidoa" style={{ background: 'var(--color-bg-surface)', color: 'var(--color-text)' }}>Baidoa</option>
                </select>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
            <div>
              <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">Phone Number (Optional)</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Phone size={18} style={{ color: 'var(--color-text-subtle)' }} />
                </div>
                <input type="tel" name="phone" value={formData.phone} onChange={handleInputChange}
                  style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                  className="block w-full pl-10 pr-3 py-3 rounded-xl focus:ring-2 focus:ring-[var(--color-primary)] outline-none transition-all placeholder-slate-500" placeholder="+252 61..." />
              </div>
            </div>

            <div>
              <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">Email Address</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <Mail size={18} style={{ color: 'var(--color-text-subtle)' }} />
                </div>
                <input type="email" name="email" value={formData.email} onChange={handleInputChange} required
                  style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                  className="block w-full pl-10 pr-3 py-3 rounded-xl focus:ring-2 focus:ring-[var(--color-primary)] outline-none transition-all placeholder-slate-500" placeholder="you@example.com" />
              </div>
            </div>
          </div>

          <div>
            <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">Password</label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Lock size={18} style={{ color: 'var(--color-text-subtle)' }} />
              </div>
              <input type="password" name="password" value={formData.password} onChange={handleInputChange} required minLength="6"
                style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                className="block w-full pl-10 pr-3 py-3 rounded-xl focus:ring-2 focus:ring-[var(--color-primary)] outline-none transition-all placeholder-slate-500" placeholder="••••••••" />
            </div>
          </div>

          <div className="pt-4 flex justify-end">
            <button 
              type="submit"
              disabled={isSubmitting}
              style={{ background: 'linear-gradient(135deg,#10B981,#059669)', boxShadow: '0 4px 16px rgba(16,185,129,0.3)', borderRadius: '12px', color: '#fff', fontWeight: 700 }}
              className={`w-full sm:w-auto flex items-center justify-center gap-2 py-3 px-8 transition-all hover:-translate-y-0.5 disabled:opacity-50`}
            >
              {isSubmitting ? 'Registering...' : 'Create Account'} <ArrowRight size={18} />
            </button>
          </div>
        </motion.form>

        <div className="mt-8 text-center">
          <p style={{ color: 'var(--color-text-muted)' }} className="font-medium text-sm">
            Already have an account?{' '}
            <Link to="/login" style={{ color: 'var(--color-primary)' }} className="font-bold hover:opacity-80 transition-opacity">
              Sign in here
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
