const mongoose = require('mongoose');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
const Meeting = require('./models/Meeting');
const Forum = require('./models/Forum');

// Load env vars
dotenv.config();

// Connect to DB
mongoose.connect(process.env.MONGO_URI);

const seedData = async () => {
  try {
    // Clear existing data (Optional, but good for a fresh start)
    await User.deleteMany();
    await Meeting.deleteMany();
    await Forum.deleteMany();

    console.log('🗑️ Existing data cleared...');

    // Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash('password123', salt);

    // 1. Create Admin
    const admin = await User.create({
      name: 'System Admin',
      email: 'admin@pmcfms.com',
      password: hashedPassword,
      phone: '+252610000000',
      district: 'Banadir',
      role: 'admin'
    });
    console.log('🚀 Admin User Created!');

    console.log('✅ Seeding Completed Successfully! Only Admin remains.');
    process.exit();
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
};

seedData();

