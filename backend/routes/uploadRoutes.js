const express = require('express');
const router = express.Router();
const upload = require('../middleware/uploadMiddleware');
const { protect } = require('../middleware/authMiddleware');

// @route   POST /api/upload
// @desc    Upload a file and get the URL
// @access  Private
router.post('/', protect, upload.single('file'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  // Generate URL for the uploaded file
  const protocol = req.protocol === 'http' && req.get('host').includes('localhost') ? 'http' : 'https';
  // On local, we use http. If there's a proxy, we trust req.protocol if configured.
  // We'll just construct a relative or absolute URL based on the server setup.
  // The simplest is just returning the path relative to the domain.
  const fileUrl = `/uploads/${req.file.filename}`;

  res.status(200).json({
    message: 'File uploaded successfully',
    fileUrl: fileUrl,
    filename: req.file.filename,
    mimetype: req.file.mimetype,
    size: req.file.size
  });
});

module.exports = router;
