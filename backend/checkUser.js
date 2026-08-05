const mongoose = require('mongoose');
require('dotenv').config();

const User = require('./models/User');

async function check() {
  await mongoose.connect(process.env.MONGO_URI);
  const user = await User.findOne({ email: 'admin@pmcfms.com' });
  console.log('EXACT USER IN MONGODB:', user);
  await mongoose.connection.close();
}

check();
