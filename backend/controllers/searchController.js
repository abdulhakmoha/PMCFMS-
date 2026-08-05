const Meeting = require('../models/Meeting');
const Forum = require('../models/Forum');
const User = require('../models/User');

exports.globalSearch = async (req, res) => {
  try {
    const { q } = req.query;
    console.log(`🔎 Global Search Request: "${q}"`);

    if (q === 'all') {
      const allMeetings = await Meeting.find({}).limit(10);
      return res.json({ success: true, data: { meetings: allMeetings, forums: [], users: [] } });
    }

    if (!q || q.length < 2) {
      return res.json({ success: true, data: { meetings: [], forums: [], users: [] } });
    }

    // Search Meetings
    const meetings = await Meeting.find({
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { location: { $regex: q, $options: 'i' } }
      ]
    }).limit(5).select('title date location');

    // Search Forums
    const forums = await Forum.find({
      $or: [
        { title: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
        { category: { $regex: q, $options: 'i' } }
      ]
    }).limit(5).select('title category');

    // Search Users
    let users = [];
    if (req.user && (req.user.role === 'admin' || req.user.role === 'moderator')) {
      users = await User.find({
        $or: [
          { name: { $regex: q, $options: 'i' } },
          { email: { $regex: q, $options: 'i' } },
          { district: { $regex: q, $options: 'i' } }
        ]
      }).limit(5).select('name role email');
    }

    console.log(`✅ Results: Meetings(${meetings.length}), Forums(${forums.length}), Users(${users.length})`);

    res.json({
      success: true,
      data: { meetings, forums, users }
    });
  } catch (error) {
    console.error('❌ Search Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
