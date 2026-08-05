const express = require('express');
const router = express.Router();
const { 
  notifyUsersAboutMeeting, 
  getNotifications, 
  readAllNotifications 
} = require('../controllers/notificationController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/', protect, getNotifications);
router.put('/read-all', protect, readAllNotifications);
router.post('/meeting/:id', protect, authorize('admin'), notifyUsersAboutMeeting);

module.exports = router;
