const mongoose = require('mongoose');
const dotenv = require('dotenv');
const Meeting = require('./models/Meeting');
const Forum = require('./models/Forum');
const Comment = require('./models/Comment');

dotenv.config();

const clearData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB for clearing...');

    await Meeting.deleteMany({});
    await Forum.deleteMany({});
    await Comment.deleteMany({});

    console.log('✅ Meetings, Forums, and Comments have been cleared!');
    process.exit();
  } catch (error) {
    console.error('Error clearing data:', error);
    process.exit(1);
  }
};

clearData();
