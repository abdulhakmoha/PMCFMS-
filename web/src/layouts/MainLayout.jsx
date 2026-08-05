import { Outlet, Link } from 'react-router-dom';
import { Users, LogIn, Menu, X } from 'lucide-react';
import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function MainLayout() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen flex flex-col font-sans">
      <nav className="glass sticky top-0 z-50 px-4 py-3 sm:px-6 lg:px-8 border-b border-slate-200/50">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <Link to="/" className="flex items-center gap-2 group">
            <div className="bg-[var(--color-primary)] p-2 rounded-xl text-white group-hover:scale-105 transition-transform">
              <Users size={24} />
            </div>
            <span className="font-bold text-xl tracking-tight text-slate-900">
              PMCFMS
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-6">
            <Link to="/about" className="text-slate-600 hover:text-slate-900 font-medium transition-colors">
              About
            </Link>
            <Link to="/forums" className="text-slate-600 hover:text-slate-900 font-medium transition-colors">
              Forums
            </Link>
            <div className="h-6 w-px bg-slate-200"></div>
            <Link to="/login" className="flex items-center gap-2 text-slate-600 hover:text-[var(--color-primary)] font-medium transition-colors">
              <LogIn size={18} />
              Sign In
            </Link>
            <Link to="/register" className="bg-[var(--color-primary)] hover:bg-[var(--color-primary-hover)] text-white px-5 py-2.5 rounded-xl font-medium transition-all hover:shadow-lg hover:shadow-emerald-500/30 hover:-translate-y-0.5">
              Get Started
            </Link>
          </div>

          {/* Mobile Menu Button */}
          <button 
            className="md:hidden p-2 text-slate-600 hover:text-slate-900 hover:bg-slate-100 rounded-lg transition-colors"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
          >
            {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
          </button>
        </div>
      </nav>

      {/* Mobile Navigation */}
      <AnimatePresence>
        {isMobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden glass border-b border-slate-200/50 overflow-hidden"
          >
            <div className="px-4 py-4 flex flex-col gap-4">
              <Link to="/about" className="text-slate-600 hover:text-slate-900 font-medium py-2">About</Link>
              <Link to="/forums" className="text-slate-600 hover:text-slate-900 font-medium py-2">Forums</Link>
              <hr className="border-slate-200" />
              <Link to="/login" className="text-slate-600 hover:text-[var(--color-primary)] font-medium py-2 flex items-center gap-2">
                <LogIn size={18} /> Sign In
              </Link>
              <Link to="/register" className="bg-[var(--color-primary)] text-white px-5 py-2.5 rounded-xl font-medium text-center">
                Get Started
              </Link>
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      <main className="flex-grow">
        <Outlet />
      </main>

      <footer className="glass border-t border-slate-200/50 py-8 mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-slate-500">
          <p>&copy; {new Date().getFullYear()} PMCFMS. All rights reserved.</p>
        </div>
      </footer>
    </div>
  );
}
