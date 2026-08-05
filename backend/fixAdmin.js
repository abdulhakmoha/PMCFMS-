// Fix admin role script - run once with: node fixAdmin.js
const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/User');

async function fixAdmin() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    // Find user by email and set role to admin
    const result = await User.updateMany(
      { email: /admin/i },
      { $set: { role: 'admin' } }
    );
    console.log('Updated by email match:', result.modifiedCount, 'users');

    // Also set ALL users with name containing "admin" (case-insensitive)
    const result2 = await User.updateMany(
      { name: /admin/i },
      { $set: { role: 'admin' } }
    );
    console.log('Updated by name match:', result2.modifiedCount, 'users');

    // List all users
    const users = await User.find({}).select('name email role');
    console.log('\nAll users:');
    users.forEach(u => console.log(`  ${u.name} | ${u.email} | role: ${u.role}`));

    await mongoose.connection.close();
    console.log('\nDone! Now logout and login again in the browser.');
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

fixAdmin();
