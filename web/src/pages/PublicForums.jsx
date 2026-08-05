import { motion } from 'framer-motion';
import { Link } from 'react-router-dom';
import { MessageSquare, LogIn } from 'lucide-react';

export default function PublicForums() {
  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  };

  return (
    <div className="flex flex-col min-h-screen pt-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto w-full">
        <motion.div initial="hidden" animate="visible" variants={fadeIn}>
          <div className="flex items-center justify-between mb-8">
            <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight text-slate-900">
              Community <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-600 to-emerald-500">Forums</span>
            </h1>
          </div>
          
          <div className="glass p-8 rounded-3xl text-center py-16">
            <div className="w-20 h-20 bg-emerald-50 rounded-full flex items-center justify-center mx-auto mb-6">
              <MessageSquare className="w-10 h-10 text-emerald-500" />
            </div>
            <h2 className="text-2xl font-bold text-slate-800 mb-4">Join the Conversation</h2>
            <p className="text-slate-600 text-lg max-w-2xl mx-auto mb-8">
              Discover what your community is talking about. To participate in discussions, vote on topics, or create your own threads, please sign in to your account.
            </p>
            
            <Link 
              to="/login" 
              className="inline-flex items-center gap-2 bg-[var(--color-primary)] text-white px-8 py-3 rounded-xl font-bold text-lg hover:-translate-y-1 transition-all shadow-lg shadow-emerald-500/30"
            >
              <LogIn size={20} />
              Sign In to View Forums
            </Link>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
