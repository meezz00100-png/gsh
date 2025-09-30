const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { verifyAccessToken } = require('../utils/jwt');

// Protect routes - require authentication
const protect = async (req, res, next) => {
  try {
    let token;

    // Check for token in Authorization header
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        message: 'Access denied. No token provided.'
      });
    }

    // Verify token
    const decoded = verifyAccessToken(token);

    // Get user from database
    const user = await User.findById(decoded.id).select('-password');
    if (!user) {
      return res.status(401).json({
        message: 'Token is not valid - user not found'
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        message: 'User account is deactivated'
      });
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      message: 'Token is not valid',
      error: error.message
    });
  }
};

// Optional authentication - doesn't fail if no token
const optionalAuth = async (req, res, next) => {
  try {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (token) {
      const decoded = verifyAccessToken(token);
      const user = await User.findById(decoded.id).select('-password');
      if (user && user.isActive) {
        req.user = user;
      }
    }

    next();
  } catch (error) {
    // Continue without authentication
    next();
  }
};

// Check if user owns resource or is admin
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        message: 'Authentication required'
      });
    }

    // For now, we don't have roles implemented, but this allows future role-based access
    // if (!roles.includes(req.user.role)) {
    //   return res.status(403).json({
    //     message: 'Not authorized to access this resource'
    //   });
    // }

    next();
  };
};

// Verify resource ownership
const checkOwnership = (resourceField = 'userId') => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        message: 'Authentication required'
      });
    }

    // For reports and other resources where userId should match the authenticated user
    // This middleware assumes the resource ID is in req.params.id
    // The route handler should fetch the resource and check ownership
    req.resourceOwnerCheck = (resource) => {
      const resourceUserId = resource[resourceField]?.toString();
      const currentUserId = req.user._id.toString();

      return resourceUserId === currentUserId;
    };

    next();
  };
};

module.exports = {
  protect,
  optionalAuth,
  authorize,
  checkOwnership
};
