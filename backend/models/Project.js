const mongoose = require('mongoose');

const ProjectCommentSchema = new mongoose.Schema({
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

const ProjectSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title']
  },
  description: {
    type: String,
    required: [true, 'Please add a description']
  },
  status: {
    type: String,
    enum: ['Planning', 'In Progress', 'Completed'],
    default: 'Planning'
  },
  budget: {
    type: Number,
    required: [true, 'Please add a budget']
  },
  progress: {
    type: Number,
    min: 0,
    max: 100,
    default: 0
  },
  location: {
    type: String,
    required: [true, 'Please add a location/district']
  },
  imageUrl: {
    type: String,
    default: ''
  },
  comments: [ProjectCommentSchema],
  progressImages: [{
    url: String,
    status: {
      type: String,
      enum: ['In Progress', 'Completed'],
      default: 'In Progress'
    },
    uploadedAt: {
      type: Date,
      default: Date.now
    }
  }],
  creator: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Project', ProjectSchema);
