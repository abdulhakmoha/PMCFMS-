const User = require('../models/User');
const Meeting = require('../models/Meeting');
const Forum = require('../models/Forum');
const Comment = require('../models/Comment');

// @desc    Get dashboard statistics
// @route   GET /api/dashboard/stats
// @access  Private
exports.getDashboardStats = async (req, res) => {
  try {
    // Basic counts
    const totalUsers = await User.countDocuments();
    const activeMeetings = await Meeting.countDocuments({ status: { $in: ['upcoming', 'ongoing'] } });
    const openForums = await Forum.countDocuments({ isApproved: true });
    const totalComments = await Comment.countDocuments();

    // Recent Activity (aggregate recent meetings and forums)
    const recentMeetings = await Meeting.find()
      .sort({ createdAt: -1 })
      .limit(3)
      .select('title createdAt')
      .lean();

    const recentForums = await Forum.find()
      .sort({ createdAt: -1 })
      .limit(3)
      .select('title createdAt')
      .lean();

    // Format recent activity
    let recentActivity = [];
    
    recentMeetings.forEach(m => {
      recentActivity.push({
        id: `m_${m._id}`,
        type: 'meeting',
        action: 'New public meeting scheduled',
        details: m.title,
        createdAt: m.createdAt
      });
    });

    recentForums.forEach(f => {
      recentActivity.push({
        id: `f_${f._id}`,
        type: 'forum',
        action: 'Forum topic created',
        details: f.title,
        createdAt: f.createdAt
      });
    });

    // Sort combined activity by date descending and take top 4
    recentActivity.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    recentActivity = recentActivity.slice(0, 4);

    // Format time difference nicely (e.g., "2 hours ago")
    const timeSince = (date) => {
      const seconds = Math.floor((new Date() - new Date(date)) / 1000);
      let interval = seconds / 86400;
      if (interval > 1) return Math.floor(interval) + " days ago";
      interval = seconds / 3600;
      if (interval > 1) return Math.floor(interval) + " hours ago";
      interval = seconds / 60;
      if (interval > 1) return Math.floor(interval) + " minutes ago";
      return "just now";
    };

    recentActivity = recentActivity.map(item => ({
      ...item,
      time: timeSince(item.createdAt)
    }));

    // Analytics: Users per District
    const usersByDistrict = await User.aggregate([
      { $group: { _id: "$district", count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Analytics: Forums per Category
    const forumsByCategory = await Forum.aggregate([
      { $group: { _id: "$category", count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Analytics: Monthly Growth (Meetings scheduled per month)
    const monthlyMeetings = await Meeting.aggregate([
      {
        $group: {
          _id: { $month: "$createdAt" },
          count: { $sum: 1 }
        }
      },
      { $sort: { "_id": 1 } }
    ]);

    res.status(200).json({
      success: true,
      data: {
        totalUsers,
        activeMeetings,
        openForums,
        totalComments,
        recentActivity,
        analytics: {
          usersByDistrict,
          forumsByCategory,
          monthlyMeetings
        }
      }
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error in getting dashboard stats'
    });
  }
};
