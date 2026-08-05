const User = require('../models/User');
const Meeting = require('../models/Meeting');
const sendEmail = require('../utils/sendEmail');
const sendSMS = require('../utils/sendSMS');

// @desc    Send notification to all users about a meeting
// @route   POST /api/notifications/meeting/:id
// @access  Private/Admin
exports.notifyUsersAboutMeeting = async (req, res) => {
  console.log(`🔔 Notification request received for Meeting ID: ${req.params.id}`);
  try {
    const meeting = await Meeting.findById(req.params.id);
    if (!meeting) {
      return res.status(404).json({ success: false, message: 'Meeting not found' });
    }

    const users = await User.find({ role: 'citizen' });
    
    const notificationPromises = users.map(async (user) => {
      console.log(`📧 Sending notification to user: ${user.name} (${user.email})`);
      // 1. Send Email
      if (user.email) {
        await sendEmail({
          email: user.email,
          subject: `Urgent: Public Meeting - ${meeting.title}`,
          message: `Dear ${user.name},\n\nYou are invited to a public meeting: ${meeting.title}.\nDate: ${new Date(meeting.date).toLocaleString()}\nLocation: ${meeting.location}\n\nPlease join us to share your thoughts.\n\nBest regards,\nPMCFMS Team`,
          html: `
            <div style="font-family: sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
              <h2 style="color: #4f46e5;">Public Meeting Invitation</h2>
              <p>Dear <strong>${user.name}</strong>,</p>
              <p>You are invited to participate in an upcoming public meeting:</p>
              <div style="background: #f8fafc; padding: 15px; border-left: 4px solid #4f46e5; margin: 20px 0;">
                <h3 style="margin-top: 0;">${meeting.title}</h3>
                <p><strong>Date:</strong> ${new Date(meeting.date).toLocaleString()}</p>
                <p><strong>Location:</strong> ${meeting.location}</p>
              </div>
              <p>Your voice matters to our community. We hope to see you there!</p>
              <br>
              <p style="font-size: 12px; color: #64748b;">PMCFMS - Community Management System</p>
            </div>
          `
        });
      }

      // 2. Send SMS
      if (user.phone) {
        const smsMessage = `PMCFMS Alert: Meeting "${meeting.title}" on ${new Date(meeting.date).toLocaleDateString()} at ${meeting.location}. Your participation is needed!`;
        await sendSMS(user.phone, smsMessage);
      }
    });

    await Promise.all(notificationPromises);

    res.status(200).json({
      success: true,
      message: `Notifications sent to ${users.length} citizens successfully.`
    });
  } catch (error) {
    console.error('Notification Error:', error);
    res.status(500).json({ success: false, message: 'Error sending notifications' });
  }
};

// @desc    Get all notifications for logged in user
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
  try {
    const Notification = require('../models/Notification');
    const notifications = await Notification.find({ recipient: req.user.id })
      .sort('-createdAt')
      .limit(50);
    res.status(200).json({ success: true, data: notifications });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Mark all user notifications as read
// @route   PUT /api/notifications/read-all
// @access  Private
exports.readAllNotifications = async (req, res) => {
  try {
    const Notification = require('../models/Notification');
    await Notification.updateMany({ recipient: req.user.id }, { isRead: true });
    res.status(200).json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};
