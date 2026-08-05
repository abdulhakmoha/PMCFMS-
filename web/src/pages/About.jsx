import { motion } from 'framer-motion';

export default function About() {
  const fadeIn = {
    hidden: { opacity: 0, y: 20 },
    visible: { opacity: 1, y: 0, transition: { duration: 0.6 } }
  };

  return (
    <div className="flex flex-col min-h-screen pt-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto w-full">
        <motion.div initial="hidden" animate="visible" variants={fadeIn}>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-tight mb-6">
            <span style={{ color: 'var(--color-text)' }}>About</span> <span className="text-transparent bg-clip-text bg-gradient-to-r from-indigo-400 to-sky-400">PMCFMS</span>
          </h1>
          
          <div style={{ background: 'var(--color-bg-elevated)', border: '1px solid var(--color-border)', borderRadius: '24px' }} className="p-8 mt-8">
            <h2 style={{ color: 'var(--color-text)' }} className="text-2xl font-bold mb-4">Our Mission</h2>
            <p style={{ color: 'var(--color-text-muted)', fontSize: '18px', lineHeight: 1.8 }} className="mb-6">
              The Public Meeting & Community Forum Management System (PMCFMS) is designed to bridge the gap between citizens and decision-makers. Our goal is to foster transparent, inclusive, and efficient community engagement through accessible digital tools.
            </p>

            <h2 style={{ color: 'var(--color-text)' }} className="text-2xl font-bold mb-4 mt-8">What We Do</h2>
            <ul style={{ color: 'var(--color-text-muted)', fontSize: '18px', lineHeight: 1.8 }} className="list-disc list-inside space-y-3">
              <li>Facilitate virtual and hybrid public meetings.</li>
              <li>Provide secure and moderated community forums.</li>
              <li>Ensure transparent record-keeping and archiving.</li>
              <li>Empower citizens to have a voice in local governance.</li>
            </ul>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
