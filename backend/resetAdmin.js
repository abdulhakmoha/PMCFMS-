const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/pmcfms';

mongoose.connect(MONGO_URI).then(async () => {
  const salt = await bcrypt.genSalt(10);
  const hashed = await bcrypt.hash('Admin@1234', salt);

  const result = await mongoose.connection.db.collection('users').updateOne(
    { email: 'admin@pmcfms.com' },
    { $set: { password: hashed } }
  );

  console.log('Password reset done. Updated:', result.modifiedCount, 'user(s)');
  console.log('New credentials => Email: admin@pmcfms.com | Password: Admin@1234');
  process.exit(0);
}).catch(e => {
  console.error('Error:', e.message);
  process.exit(1);
});
