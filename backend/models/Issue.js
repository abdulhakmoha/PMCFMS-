const mongoose = require('mongoose');

const IssueCommentSchema = new mongoose.Schema({
  author: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  authorName: {
    type: String,
    required: true
  },
  text: {
    type: String,
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const IssueSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title']
  },
  description: {
    type: String,
    required: [true, 'Please add a description']
  },
  district: {
    type: String,
    required: [true, 'Please add a district']
  },
  status: {
    type: String,
    enum: ['Pending', 'Under Review', 'Resolved', 'Rejected'],
    default: 'Pending'
  },
  imageUrl: {
    type: String,
    default: ''
  },
  citizen: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  adminNotes: {
    type: String,
    default: ''
  },
  comments: [IssueCommentSchema],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Issue', IssueSchema);
