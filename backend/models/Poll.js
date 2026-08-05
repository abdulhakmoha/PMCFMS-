const mongoose = require('mongoose');

const PollSchema = new mongoose.Schema({
  meeting: {
    type: mongoose.Schema.ObjectId,
    ref: 'Meeting',
    required: false
  },
  creator: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  question: {
    type: String,
    required: [true, 'Please add a question'],
    trim: true
  },
  options: [
    {
      text: {
        type: String,
        required: true
      },
      votes: {
        type: Number,
        default: 0
      }
    }
  ],
  voters: [
    {
      type: mongoose.Schema.ObjectId,
      ref: 'User'
    }
  ],
  status: {
    type: String,
    enum: ['open', 'closed'],
    default: 'open'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Poll', PollSchema);
