const express = require('express');
const router = express.Router();
const {
  getAnnouncements,
  createAnnouncement,
  deleteAnnouncement
} = require('../controllers/announcementController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getAnnouncements)
  .post(protect, authorize('admin', 'moderator'), createAnnouncement);

router.route('/:id')
  .delete(protect, authorize('admin', 'moderator'), deleteAnnouncement);

module.exports = router;
