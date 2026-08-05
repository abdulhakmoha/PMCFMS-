const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/User');

async function fix() {
  await mongoose.connect(process.env.MONGO_URI);
  
  // Set ALL users with email "admin@pmcfms.com" or name containing "Admin" to 'admin'
  const result = await User.updateMany(
    { $or: [ { email: 'admin@pmcfms.com' }, { name: /admin/i } ] },
    { $set: { role: 'admin' } }
  );
  console.log('Updated user count:', result.modifiedCount);

  const users = await User.find({});
  console.log('ALL USERS IN DB AFTER FIX:');
  users.forEach(u => {
    console.log(`- Name: ${u.name} | Email: ${u.email} | Role: ${u.role}`);
  });

  await mongoose.connection.close();
}

fix();
