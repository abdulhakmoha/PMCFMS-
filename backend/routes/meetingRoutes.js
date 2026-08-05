const express = require('express');
const {
  getMeetings,
  getMeeting,
  createMeeting,
  joinMeeting,
  deleteMeeting,
  updateMeeting
} = require('../controllers/meetingController');

const router = express.Router();
console.log('✅ Meeting Routes Loaded');
const { protect, authorize } = require('../middleware/authMiddleware');

router
  .route('/')
  .get(getMeetings)
  .post(protect, authorize('admin', 'moderator'), createMeeting);

router
  .route('/:id')
  .get(getMeeting)
  .put(protect, authorize('admin', 'moderator'), updateMeeting)
  .delete(protect, authorize('admin'), deleteMeeting);

router
  .route('/:id/join')
  .post(protect, joinMeeting);

module.exports = router;
