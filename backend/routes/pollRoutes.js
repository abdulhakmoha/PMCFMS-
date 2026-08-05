const express = require('express');
const router = express.Router();
const { 
  createPoll, 
  getMeetingPolls,
  getAllPolls,
  voteInPoll, 
  togglePollStatus, 
  deletePoll 
} = require('../controllers/pollController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getAllPolls)
  .post(protect, authorize('admin', 'moderator'), createPoll);

router.route('/meeting/:meetingId')
  .get(protect, getMeetingPolls);

router.route('/:id/vote')
  .put(protect, voteInPoll);

router.route('/:id/status')
  .put(protect, authorize('admin', 'moderator'), togglePollStatus);

router.route('/:id')
  .delete(protect, authorize('admin', 'moderator'), deletePoll);

module.exports = router;
