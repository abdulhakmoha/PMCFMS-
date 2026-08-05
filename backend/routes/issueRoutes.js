const express = require('express');
const router = express.Router();
const {
  getIssues,
  getMyIssues,
  createIssue,
  updateIssueStatus,
  deleteIssue,
  addIssueComment
} = require('../controllers/issueController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.route('/')
  .get(protect, getIssues)
  .post(protect, createIssue);

router.route('/my')
  .get(protect, getMyIssues);

router.route('/:id/status')
  .put(protect, authorize('admin', 'moderator'), updateIssueStatus);

router.route('/:id/comments')
  .post(protect, addIssueComment);

router.route('/:id')
  .delete(protect, authorize('admin', 'moderator'), deleteIssue);

module.exports = router;
