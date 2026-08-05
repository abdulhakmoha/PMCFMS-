import { useState, useContext } from 'react';
import { motion } from 'framer-motion';
import { Mail, Lock, ArrowRight } from 'lucide-react';
import { Link, useNavigate } from 'react-router-dom';
import { AuthContext } from '../../context/AuthContext';

export default function Login() {
  const [formData, setFormData] = useState({
    email: '',
    password: ''
  });
  const [error, setError] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const { loginUser } = useContext(AuthContext);
  const navigate = useNavigate();

  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  };

  const handleInputChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
    if (error) setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsSubmitting(true);

    const result = await loginUser(formData.email, formData.password);

    if (result.success) {
      navigate('/dashboard');
    } else {
      setError(result.error);
      setIsSubmitting(false);
    }
  };

  return (
    <div className="min-h-[calc(100vh-64px)] flex items-center justify-center p-4">
      {/* Background decoration */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-full max-w-3xl h-full pointer-events-none opacity-40 -z-10">
        <div className="absolute top-0 left-0 w-72 h-72 bg-emerald-400 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob"></div>
        <div className="absolute top-0 right-0 w-72 h-72 bg-emerald-400 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob animation-delay-2000"></div>
      </div>

      <motion.div 
        initial="hidden" animate="visible" variants={fadeIn}
        className="glass w-full max-w-md p-8 rounded-3xl relative overflow-hidden"
      >
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-emerald-500 to-emerald-500"></div>
        
        <div className="text-center mb-8">
          <h2 style={{ color: 'var(--color-text)' }} className="text-3xl font-extrabold tracking-tight mb-2">Welcome Back</h2>
          <p style={{ color: 'var(--color-text-muted)' }} className="font-medium">Sign in to your PMCFMS account</p>
        </div>

        {error && (
          <div style={{ background: 'rgba(239,68,68,0.12)', border: '1px solid rgba(239,68,68,0.3)', color: '#EF4444', borderRadius: '12px' }} className="mb-6 p-4 text-sm font-medium">
            {error}
          </div>
        )}

        <form className="space-y-5" onSubmit={handleSubmit}>
          <div>
            <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold mb-1.5">Email Address</label>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Mail size={18} style={{ color: 'var(--color-text-subtle)' }} />
              </div>
              <input 
                type="email" 
                name="email"
                value={formData.email}
                onChange={handleInputChange}
                required
                style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                className="block w-full pl-10 pr-3 py-3 rounded-xl placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent transition-all"
                placeholder="Enter your email"
              />
            </div>
          </div>

          <div>
            <div className="flex justify-between items-center mb-1.5">
              <label style={{ color: 'var(--color-text-muted)' }} className="block text-sm font-semibold">Password</label>
              <a href="#" style={{ color: 'var(--color-primary)' }} className="text-sm font-medium hover:opacity-80 transition-opacity">Forgot password?</a>
            </div>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                <Lock size={18} style={{ color: 'var(--color-text-subtle)' }} />
              </div>
              <input 
                type="password" 
                name="password"
                value={formData.password}
                onChange={handleInputChange}
                required
                style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
                className="block w-full pl-10 pr-3 py-3 rounded-xl placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-[var(--color-primary)] focus:border-transparent transition-all"
                placeholder="••••••••"
              />
            </div>
          </div>

          <button 
            type="submit"
            disabled={isSubmitting}
            className={`w-full flex items-center justify-center gap-2 py-3 px-4 text-white rounded-xl font-bold transition-all shadow-lg mt-2 ${
              isSubmitting ? 'bg-emerald-400 cursor-not-allowed' : 'bg-[var(--color-primary)] hover:bg-[var(--color-primary-hover)] shadow-emerald-500/30 hover:-translate-y-0.5'
            }`}
          >
            {isSubmitting ? 'Signing In...' : 'Sign In'} <ArrowRight size={18} />
          </button>
        </form>

        <div className="mt-8 text-center">
          <p style={{ color: 'var(--color-text-muted)' }} className="font-medium text-sm">
            Don't have an account?{' '}
            <Link to="/register" style={{ color: 'var(--color-primary)' }} className="font-bold hover:opacity-80 transition-opacity">
              Create one now
            </Link>
          </p>
        </div>
      </motion.div>
    </div>
  );
}
