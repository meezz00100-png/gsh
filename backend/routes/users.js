const express = require('express');
const User = require('../models/User');
const { protect, checkOwnership } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/users/me
// @desc    Get current user profile
// @access  Private
router.get('/me', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({
        message: 'User not found'
      });
    }

    res.json({
      user: {
        id: user._id,
        email: user.email,
        userMetadata: user.userMetadata,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      message: 'Error fetching user profile',
      error: error.message
    });
  }
});

// @route   PUT /api/users/me
// @desc    Update current user profile
// @access  Private
router.put('/me', protect, async (req, res) => {
  try {
    const { userMetadata } = req.body;

    const updateData = {};

    if (userMetadata) {
      updateData.userMetadata = { ...req.user.userMetadata, ...userMetadata };
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      message: 'Profile updated successfully',
      user: {
        id: user._id,
        email: user.email,
        userMetadata: user.userMetadata,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });
  } catch (error) {
    console.error('Update user profile error:', error);
    res.status(500).json({
      message: 'Error updating profile',
      error: error.message
    });
  }
});

// @route   DELETE /api/users/me
// @desc    Delete current user account
// @access  Private
router.delete('/me', protect, async (req, res) => {
  try {
    // Delete user (this should cascade delete their reports via database policies)
    await User.findByIdAndDelete(req.user._id);

    res.json({
      message: 'Account deleted successfully'
    });
  } catch (error) {
    console.error('Delete user account error:', error);
    res.status(500).json({
      message: 'Error deleting account',
      error: error.message
    });
  }
});

// @route   GET /api/users/:id
// @desc    Get user by ID (for admin purposes)
// @access  Private (Admin only - not implemented yet)
router.get('/:id', protect, async (req, res) => {
  // For now, only allow users to view their own profile
  // In the future, this could be expanded for admin users
  if (req.params.id !== req.user._id.toString()) {
    return res.status(403).json({
      message: 'Not authorized to view this user'
    });
  }

  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        message: 'User not found'
      });
    }

    res.json({
      user: {
        id: user._id,
        email: user.email,
        userMetadata: user.userMetadata,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt
      }
    });
  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({
      message: 'Error fetching user',
      error: error.message
    });
  }
});

module.exports = router;
