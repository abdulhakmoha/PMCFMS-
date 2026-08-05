const Issue = require('../models/Issue');

// @desc    Get all issues (Admins see all, citizens see all public ones)
// @route   GET /api/issues
// @access  Private
exports.getIssues = async (req, res) => {
  try {
    let query;
    // Populate citizen and comment authors
    query = Issue.find().populate('citizen', 'name role').populate('comments.author', 'name role').sort('-createdAt');
    const issues = await query;
    res.status(200).json({ success: true, count: issues.length, data: issues });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// @desc    Get my reported issues
// @route   GET /api/issues/my
// @access  Private
exports.getMyIssues = async (req, res) => {
  try {
    const issues = await Issue.find({ citizen: req.user._id })
      .populate('citizen', 'name role')
      .populate('comments.author', 'name role')
      .sort('-createdAt');
    res.status(200).json({ success: true, count: issues.length, data: issues });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error: ' + error.message });
  }
};

// @desc    Create new issue (Report issue)
// @route   POST /api/issues
// @access  Private
exports.createIssue = async (req, res) => {
  try {
    const { title, description, district, imageUrl } = req.body;

    const issue = await Issue.create({
      title,
      description,
      district,
      imageUrl: imageUrl || '',
      citizen: req.user._id
    });

    const populated = await Issue.findById(issue._id).populate('citizen', 'name role');

    res.status(201).json({ success: true, data: populated });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// @desc    Update issue status (Admin/Moderator only)
// @route   PUT /api/issues/:id/status
// @access  Private (Admin/Moderator)
exports.updateIssueStatus = async (req, res) => {
  try {
    const { status, adminNotes } = req.body;
    let issue = await Issue.findById(req.params.id);

    if (!issue) {
      return res.status(404).json({ success: false, message: 'Issue not found' });
    }

    if (issue.status === 'Resolved' || issue.status === 'Rejected') {
      return res.status(400).json({ success: false, message: 'Cannot modify status of a resolved or rejected issue' });
    }

    issue.status = status || issue.status;
    if (adminNotes !== undefined) {
      issue.adminNotes = adminNotes;
    }

    await issue.save();
    const populated = await Issue.findById(issue._id)
      .populate('citizen', 'name role')
      .populate('comments.author', 'name role');

    res.status(200).json({ success: true, data: populated });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

// @desc    Delete issue
// @route   DELETE /api/issues/:id
// @access  Private (Admin/Moderator)
exports.deleteIssue = async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id);

    if (!issue) {
      return res.status(404).json({ success: false, message: 'Issue not found' });
    }

    await Issue.findByIdAndDelete(req.params.id);
    res.status(200).json({ success: true, data: {} });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// @desc    Add comment to issue
// @route   POST /api/issues/:id/comments
// @access  Private
exports.addIssueComment = async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id);

    if (!issue) {
      return res.status(404).json({ success: false, message: 'Issue not found' });
    }

    if (issue.status === 'Under Review') {
      return res.status(400).json({ success: false, message: 'Comments are not allowed during Under Review status' });
    }

    const { text } = req.body;
    if (!text) {
      return res.status(400).json({ success: false, message: 'Comment text is required' });
    }

    issue.comments.push({
      author: req.user._id,
      authorName: req.user.name,
      text
    });

    await issue.save();
    const populated = await Issue.findById(issue._id)
      .populate('citizen', 'name role')
      .populate('comments.author', 'name role');

    res.status(201).json({ success: true, data: populated });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};
