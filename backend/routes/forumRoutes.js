const express = require('express');
const {
  getForums,
  getForum,
  createForum,
  approveForum,
  deleteForum,
  addComment,
  upvoteForum,
  downvoteForum
} = require('../controllers/forumController');

const router = express.Router();
const { protect, authorize } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

// Optional auth middleware helper to populate req.user but not block if no token
const optionalAuth = async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
    try {
      const jwt = require('jsonwebtoken');
      const User = require('../models/User');
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      req.user = await User.findById(decoded.id).select('-password');
    } catch (err) {
      // Ignore token errors for optional auth
    }
  }
  next();
};

router
  .route('/')
  .get(optionalAuth, getForums)
  .post(protect, upload.array('images', 5), createForum);

router
  .route('/:id')
  .get(optionalAuth, getForum)
  .delete(protect, authorize('admin', 'moderator'), deleteForum);

router
  .route('/:id/approve')
  .put(protect, authorize('admin', 'moderator'), approveForum);

router
  .route('/:id/comments')
  .post(protect, addComment);

router.route('/:id/upvote').put(protect, upvoteForum);
router.route('/:id/downvote').put(protect, downvoteForum);

module.exports = router;
