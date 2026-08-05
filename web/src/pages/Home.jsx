import { motion } from 'framer-motion';
import { ArrowRight, MessageSquare, Calendar, Shield } from 'lucide-react';
import { Link } from 'react-router-dom';

export default function Home() {
  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  };

  const staggerContainer = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.2 }
    }
  };

  return (
    <div className="flex flex-col">
      {/* Hero Section */}
      <section className="relative pt-20 pb-32 px-4 sm:px-6 lg:px-8 overflow-hidden">
        {/* Decorative background blobs */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-5xl h-full pointer-events-none opacity-40">
          <div className="absolute top-20 left-10 w-72 h-72 bg-emerald-500/10 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob"></div>
          <div className="absolute top-20 right-10 w-72 h-72 bg-emerald-500/10 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob animation-delay-2000"></div>
          <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 w-72 h-72 bg-pink-500/10 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-blob animation-delay-4000"></div>
        </div>

        <div className="relative max-w-7xl mx-auto text-center z-10">
          <motion.div initial="hidden" animate="visible" variants={fadeIn}>
            <span style={{ background: 'rgba(16,185,129,0.12)', color: '#10B981', border: '1px solid rgba(16,185,129,0.25)' }} className="inline-block py-1.5 px-4 rounded-full font-semibold text-sm mb-6 shadow-sm">
              Welcome to the future of community engagement
            </span>
          </motion.div>
          
          <motion.h1 
            initial="hidden" animate="visible" variants={fadeIn}
            className="text-5xl md:text-7xl font-extrabold tracking-tight mb-8"
          >
            <span style={{ color: 'var(--color-text)' }}>Empower Your</span> <br className="hidden md:block" />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-400 via-sky-400 to-emerald-400">
              Community Voice
            </span>
          </motion.h1>

          <motion.p 
            initial="hidden" animate="visible" variants={fadeIn}
            style={{ color: 'var(--color-text-muted)' }}
            className="mt-4 text-xl md:text-2xl max-w-3xl mx-auto mb-10 leading-relaxed"
          >
            The modern platform for public meetings, transparent discussions, and collaborative civic engagement.
          </motion.p>

          <motion.div 
            initial="hidden" animate="visible" variants={fadeIn}
            className="flex flex-col sm:flex-row justify-center gap-4"
          >
            <Link to="/register" style={{ background: 'linear-gradient(135deg,#10B981,#059669)', color: '#fff', borderRadius: '16px' }} className="group relative px-8 py-4 font-bold text-lg overflow-hidden shadow-xl shadow-emerald-500/20 hover:-translate-y-1 transition-transform">
              <div className="absolute inset-0 w-full h-full bg-gradient-to-r from-transparent via-white/20 to-transparent -translate-x-full group-hover:animate-shimmer"></div>
              <span className="flex items-center justify-center gap-2">
                Get Started Now <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
              </span>
            </Link>
            <Link to="/about" 
              style={{ background: 'var(--color-bg-surface)', border: '1px solid var(--color-border)', color: 'var(--color-text)' }}
              className="px-8 py-4 rounded-2xl font-bold text-lg hover:-translate-y-1 transition-all shadow-sm hover:shadow-md">
              Learn More
            </Link>
          </motion.div>
        </div>
      </section>

      {/* Features Section */}
      <section style={{ background: 'var(--color-bg-surface)', borderTop: '1px solid var(--color-border)', borderBottom: '1px solid var(--color-border)' }} className="py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 style={{ color: 'var(--color-text)' }} className="text-3xl font-bold">Everything you need to run a community</h2>
            <p style={{ color: 'var(--color-text-muted)' }} className="mt-4 text-lg">Powerful tools designed for transparency and engagement.</p>
          </div>

          <motion.div 
            initial="hidden" whileInView="visible" viewport={{ once: true, margin: "-100px" }} variants={staggerContainer}
            className="grid grid-cols-1 md:grid-cols-3 gap-8"
          >
            {[
              { icon: <Calendar className="w-8 h-8 text-sky-400" />, title: "Public Meetings", desc: "Schedule, stream, and archive public meetings with ease.", color: 'rgba(16,185,129,0.12)' },
              { icon: <MessageSquare className="w-8 h-8 text-emerald-400" />, title: "Open Forums", desc: "Facilitate structured, moderated discussions on key topics.", color: 'rgba(16,185,129,0.12)' },
              { icon: <Shield className="w-8 h-8 text-rose-400" />, title: "Secure & Transparent", desc: "Built with security and public accountability in mind.", color: 'rgba(244,63,94,0.12)' }
            ].map((feature, idx) => (
              <motion.div key={idx} variants={fadeIn} 
                style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)', borderRadius: '24px' }}
                className="p-8 hover:-translate-y-1.5 transition-all">
                <div style={{ background: feature.color }} className="w-14 h-14 rounded-2xl flex items-center justify-center mb-6 shadow-sm border border-white/5">
                  {feature.icon}
                </div>
                <h3 style={{ color: 'var(--color-text)' }} className="text-xl font-bold mb-3">{feature.title}</h3>
                <p style={{ color: 'var(--color-text-muted)' }} className="leading-relaxed">{feature.desc}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </section>
    </div>
  );
}
