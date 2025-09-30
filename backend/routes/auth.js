const express = require('express');
const bcrypt = require('bcryptjs');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const { generateTokens, verifyRefreshToken } = require('../utils/jwt');
const { protect } = require('../middleware/auth');
const { sendWelcomeEmail, sendPasswordResetEmail, sendEmailVerification } = require('../utils/email');

const router = express.Router();

// Input validation middleware
const validateSignup = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long'),
];

const validateSignin = [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email'),
  body('password')
    .notEmpty()
    .withMessage('Password is required'),
];

// @route   POST /api/auth/signup
// @desc    Register user
// @access  Public
router.post('/signup', validateSignup, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, password, userMetadata } = req.body;

    // Check if user already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({
        message: 'User with this email already exists'
      });
    }

    // Create user
    const user = new User({
      email,
      password,
      userMetadata: userMetadata || {}
    });

    await user.save();

    // Generate tokens
    const tokens = generateTokens(user);

    // Store refresh token in database
    user.refreshTokens.push({ token: tokens.refreshToken });
    await user.save();

    // Send welcome email (don't wait for it)
    sendWelcomeEmail(user.email, user.userMetadata?.name).catch(console.error);

    // Send email verification (don't wait for it)
    const verificationToken = user.createEmailVerificationToken();
    await user.save();
    sendEmailVerification(user.email, verificationToken).catch(console.error);

    res.status(201).json({
      message: 'User created successfully',
      user: {
        id: user._id,
        email: user.email,
        userMetadata: user.userMetadata,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt
      },
      session: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt
      }
    });
  } catch (error) {
    console.error('Signup error:', error);
    res.status(500).json({
      message: 'Error creating user',
      error: error.message
    });
  }
});

// @route   POST /api/auth/signin
// @desc    Authenticate user & get token
// @access  Public
router.post('/signin', validateSignin, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email, password } = req.body;

    // Check if user exists
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        message: 'Account is deactivated'
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        message: 'Invalid email or password'
      });
    }

    // Generate tokens
    const tokens = generateTokens(user);

    // Store refresh token in database
    user.refreshTokens.push({ token: tokens.refreshToken });
    await user.save();

    res.json({
      message: 'Sign in successful',
      user: {
        id: user._id,
        email: user.email,
        userMetadata: user.userMetadata,
        isEmailVerified: user.isEmailVerified,
        createdAt: user.createdAt
      },
      session: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt
      }
    });
  } catch (error) {
    console.error('Signin error:', error);
    res.status(500).json({
      message: 'Error signing in',
      error: error.message
    });
  }
});

// @route   POST /api/auth/signout
// @desc    Sign out user (invalidate refresh token)
// @access  Private
router.post('/signout', protect, async (req, res) => {
  try {
    const { refreshToken } = req.body;

    if (refreshToken) {
      // Remove refresh token from database
      req.user.refreshTokens = req.user.refreshTokens.filter(
        token => token.token !== refreshToken
      );
      await req.user.save();
    }

    res.json({
      message: 'Sign out successful'
    });
  } catch (error) {
    console.error('Signout error:', error);
    res.status(500).json({
      message: 'Error signing out',
      error: error.message
    });
  }
});

// @route   POST /api/auth/refresh
// @desc    Refresh access token using refresh token
// @access  Public (with valid refresh token)
router.post('/refresh', async (req, res) => {
  try {
    const { refresh_token } = req.body;

    if (!refresh_token) {
      return res.status(400).json({
        message: 'Refresh token is required'
      });
    }

    // Verify refresh token
    const decoded = verifyRefreshToken(refresh_token);

    // Find user and check if refresh token exists
    const user = await User.findById(decoded.id);
    if (!user || !user.refreshTokens.some(token => token.token === refresh_token)) {
      return res.status(401).json({
        message: 'Invalid refresh token'
      });
    }

    // Remove old refresh token and generate new tokens
    user.refreshTokens = user.refreshTokens.filter(token => token.token !== refresh_token);
    const tokens = generateTokens(user);
    user.refreshTokens.push({ token: tokens.refreshToken });
    await user.save();

    res.json({
      message: 'Token refreshed successfully',
      session: {
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt
      }
    });
  } catch (error) {
    console.error('Token refresh error:', error);
    res.status(401).json({
      message: 'Invalid refresh token'
    });
  }
});

// @route   POST /api/auth/reset-password
// @desc    Request password reset
// @access  Public
router.post('/reset-password', [
  body('email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { email } = req.body;

    // Find user
    const user = await User.findOne({ email });
    if (!user) {
      // Don't reveal if email exists or not for security
      return res.json({
        message: 'If an account with this email exists, a password reset link has been sent'
      });
    }

    // Generate reset token
    const resetToken = user.createPasswordResetToken();
    await user.save();

    // Send reset email
    await sendPasswordResetEmail(user.email, resetToken);

    res.json({
      message: 'If an account with this email exists, a password reset link has been sent'
    });
  } catch (error) {
    console.error('Password reset request error:', error);
    res.status(500).json({
      message: 'Error processing password reset request',
      error: error.message
    });
  }
});

// @route   PUT /api/auth/reset-password/:token
// @desc    Reset password with token
// @access  Public
router.put('/reset-password/:token', [
  body('password')
    .isLength({ min: 6 })
    .withMessage('Password must be at least 6 characters long')
], async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const { token } = req.params;
    const { password } = req.body;

    // Hash token for comparison
    const hashedToken = require('crypto')
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Find user with valid reset token
    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({
        message: 'Invalid or expired reset token'
      });
    }

    // Update password and clear reset token
    user.password = password;
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;
    await user.save();

    res.json({
      message: 'Password reset successfully'
    });
  } catch (error) {
    console.error('Password reset error:', error);
    res.status(500).json({
      message: 'Error resetting password',
      error: error.message
    });
  }
});

// @route   PUT /api/auth/update-user
// @desc    Update user profile
// @access  Private
router.put('/update-user', protect, async (req, res) => {
  try {
    const { userMetadata, password } = req.body;

    const updateData = {};

    if (userMetadata) {
      updateData.userMetadata = { ...req.user.userMetadata, ...userMetadata };
    }

    if (password) {
      updateData.password = password;
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      updateData,
      { new: true, runValidators: true }
    );

    res.json({
      message: 'User updated successfully',
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
    console.error('User update error:', error);
    res.status(500).json({
      message: 'Error updating user',
      error: error.message
    });
  }
});

module.exports = router;
