const mongoose = require('mongoose');

const DocumentSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Please add a title']
  },
  description: {
    type: String
  },
  fileUrl: {
    type: String,
    required: [true, 'Please add a file URL']
  },
  fileSize: {
    type: String,
    default: '0 KB'
  },
  category: {
    type: String,
    enum: ['Budget', 'Minutes', 'Policy', 'Other'],
    default: 'Other'
  },
  uploadedBy: {
    type: mongoose.Schema.ObjectId,
    ref: 'User',
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Document', DocumentSchema);
