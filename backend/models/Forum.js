const mongoose = require('mongoose');

const ForumSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a forum title'],
    trim: true,
    maxlength: [150, 'Title cannot be more than 150 characters']
  },
  description: {
    type: String,
    required: [true, 'Please add a description']
  },
  category: {
    type: String,
    default: 'General'
  },
  images: [{
    type: String
  }],
  author: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  isApproved: {
    type: Boolean,
    default: false // Requires admin/moderator approval before becoming public
  },
  status: {
    type: String,
    enum: ['open', 'closed'],
    default: 'open'
  },
  upvotes: [{
    type: mongoose.Schema.ObjectId,
    ref: 'User'
  }],
  downvotes: [{
    type: mongoose.Schema.ObjectId,
    ref: 'User'
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Forum', ForumSchema);
