const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Protect routes
exports.protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Get token from header
      token = req.headers.authorization.split(' ')[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from the token
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({ message: 'Not authorized, user not found' });
      }

      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Not authorized, no token' });
  }
};

// Grant access to specific roles
exports.authorize = (...roles) => {
  return (req, res, next) => {
    console.log(`🔐 Authorization Check - User Role: ${req.user ? req.user.role : 'unknown'}, Required Roles: ${roles}`);
    if (!req.user || !roles.includes(req.user.role)) {
      console.warn(`❌ Access Denied for role: ${req.user ? req.user.role : 'unknown'}`);
      return res.status(403).json({
        message: `User role ${req.user ? req.user.role : 'unknown'} is not authorized to access this route`
      });
    }
    next();
  };
};

// Admin middleware
exports.admin = (req, res, next) => {
  console.log('🛡️ Admin Middleware Check - User:', req.user ? { id: req.user._id, name: req.user.name, role: req.user.role } : 'None');
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    console.warn(`❌ Admin Access Denied for: ${req.user ? req.user.name : 'Unknown'} with role: ${req.user ? req.user.role : 'None'}`);
    res.status(401).json({ message: 'Not authorized as an admin' });
  }
};
