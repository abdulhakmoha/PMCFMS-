const mongoose = require('mongoose');
require('dotenv').config();
const User = require('./models/User');

async function fix() {
  await mongoose.connect(process.env.MONGO_URI);
  await User.updateOne({ email: 'admin@pmcfms.com' }, { $set: { role: 'admin' } });
  console.log('Role updated to admin');
  await mongoose.connection.close();
}

fix();
