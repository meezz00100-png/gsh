const express = require('express');
const { body, validationResult, query } = require('express-validator');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const Report = require('../models/Report');
const { protect, checkOwnership } = require('../middleware/auth');

const router = express.Router();

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadPath = path.join(__dirname, '../uploads');
    try {
      await fs.mkdir(uploadPath, { recursive: true });
      cb(null, uploadPath);
    } catch (error) {
      cb(error);
    }
  },
  filename: (req, file, cb) => {
    // Generate unique filename
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|pdf|doc|docx|txt/i;
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = allowedTypes.test(file.mimetype);

  if (mimetype && extname) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file type. Only images, PDFs, and documents are allowed.'));
  }
};

const upload = multer({
  storage: storage,
  limits: {
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 10 * 1024 * 1024, // 10MB default
  },
  fileFilter: fileFilter
});

// Input validation
const validateReport = [
  body('name').optional().isLength({ min: 1, max: 200 }).withMessage('Name must be between 1 and 200 characters'),
  body('reportType').optional().isLength({ min: 1, max: 100 }).withMessage('Report type must be between 1 and 100 characters'),
  body('receiverName').optional().isLength({ min: 1, max: 100 }).withMessage('Receiver name must be between 1 and 100 characters'),
  body('objective').optional().isLength({ min: 1 }).withMessage('Objective is required'),
  body('description').optional().isLength({ min: 1 }).withMessage('Description is required'),
  body('approvingBody').optional().isLength({ max: 100 }).withMessage('Approving body must be less than 100 characters'),
  body('senderName').optional().isLength({ max: 100 }).withMessage('Sender name must be less than 100 characters'),
  body('role').optional().isLength({ max: 50 }).withMessage('Role must be less than 50 characters'),
  body('status').optional().isIn(['draft', 'completed']).withMessage('Status must be either draft or completed'),
];

// @route   GET /api/reports
// @desc    Get all reports for authenticated user
// @access  Private
router.get('/', protect, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 50;
    const status = req.query.status;
    const search = req.query.search || '';

    const skip = (page - 1) * limit;

    // Build query
    const query = { userId: req.user._id };

    if (status && ['draft', 'completed'].includes(status)) {
      query.status = status;
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { reportType: { $regex: search, $options: 'i' } },
        { receiverName: { $regex: search, $options: 'i' } },
        { objective: { $regex: search, $options: 'i' } },
        { description: { $regex: search, $options: 'i' } }
      ];
    }

    const reports = await Report.find(query)
      .populate('userId', 'email userMetadata')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Report.countDocuments(query);

    res.json({
      reports,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Get reports error:', error);
    res.status(500).json({
      message: 'Error fetching reports',
      error: error.message
    });
  }
});

// @route   GET /api/reports/:id
// @desc    Get single report by ID
// @access  Private
router.get('/:id', protect, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id).populate('userId', 'email userMetadata');

    if (!report) {
      return res.status(404).json({
        message: 'Report not found'
      });
    }

    // Check ownership - ensure the report belongs to the authenticated user
    if (report.userId._id.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        message: 'Not authorized to view this report'
      });
    }

    res.json({ report });
  } catch (error) {
    console.error('Get report error:', error);
    res.status(500).json({
      message: 'Error fetching report',
      error: error.message
    });
  }
});

// @route   POST /api/reports
// @desc    Create new report
// @access  Private
router.post('/', protect, validateReport, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const reportData = { ...req.body };
    reportData.userId = req.user._id;

    // Clean up the data - only convert empty strings to null for optional fields
    // Keep string fields as empty strings to match schema expectations
    const stringFields = ['name', 'reportType', 'type', 'receiverName', 'objective',
                         'description', 'importance', 'mainPoints', 'sources', 'roles',
                         'trends', 'themes', 'implications', 'scenarios', 'futurePlans',
                         'approvingBody', 'senderName', 'role', 'date', 'status'];

    Object.keys(reportData).forEach(key => {
      // Only convert to null if it's not a string field and is empty
      if (reportData[key] === '' && !stringFields.includes(key)) {
        reportData[key] = null;
      }
    });

    const report = new Report(reportData);
    await report.save();

    // Populate user data for response
    await report.populate('userId', 'email userMetadata');

    res.status(201).json({
      message: 'Report created successfully',
      report
    });
  } catch (error) {
    console.error('Create report error:', error);
    res.status(500).json({
      message: 'Error creating report',
      error: error.message
    });
  }
});

// @route   PUT /api/reports/:id
// @desc    Update report
// @access  Private
router.put('/:id', protect, validateReport, async (req, res) => {
  try {
    // Check for validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        message: 'Validation failed',
        errors: errors.array()
      });
    }

    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({
        message: 'Report not found'
      });
    }

    // Check ownership - ensure the report belongs to the authenticated user
    if (report.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        message: 'Not authorized to update this report'
      });
    }

    const updateData = { ...req.body };

    // Clean up the data - only convert empty strings to null for optional fields
    // Keep string fields as empty strings to match schema expectations
    const stringFields = ['name', 'reportType', 'type', 'receiverName', 'objective',
                         'description', 'importance', 'mainPoints', 'sources', 'roles',
                         'trends', 'themes', 'implications', 'scenarios', 'futurePlans',
                         'approvingBody', 'senderName', 'role', 'date', 'status'];

    Object.keys(updateData).forEach(key => {
      // Only convert to null if it's not a string field and is empty
      if (updateData[key] === '' && !stringFields.includes(key)) {
        updateData[key] = null;
      }
    });

    // Update the report
    const updatedReport = await Report.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    ).populate('userId', 'email userMetadata');

    res.json({
      message: 'Report updated successfully',
      report: updatedReport
    });
  } catch (error) {
    console.error('Update report error:', error);
    res.status(500).json({
      message: 'Error updating report',
      error: error.message
    });
  }
});

// @route   DELETE /api/reports/:id
// @desc    Delete report
// @access  Private
router.delete('/:id', protect, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({
        message: 'Report not found'
      });
    }

    // Check ownership - ensure the report belongs to the authenticated user
    if (report.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        message: 'Not authorized to delete this report'
      });
    }

    // Delete associated files
    if (report.attachments && report.attachments.length > 0) {
      const deletePromises = report.attachments.map(async (attachment) => {
        try {
          const filePath = path.join(__dirname, '../uploads', path.basename(attachment));
          await fs.unlink(filePath);
        } catch (error) {
          console.error('Error deleting attachment:', error);
        }
      });
      await Promise.all(deletePromises);
    }

    await Report.findByIdAndDelete(req.params.id);

    res.json({
      message: 'Report deleted successfully'
    });
  } catch (error) {
    console.error('Delete report error:', error);
    res.status(500).json({
      message: 'Error deleting report',
      error: error.message
    });
  }
});

// @route   POST /api/reports/:id/attachments
// @desc    Upload attachments for report
// @access  Private
router.post('/:id/attachments', protect, upload.array('attachments', 10), async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({
        message: 'Report not found'
      });
    }

    // Check ownership - ensure the report belongs to the authenticated user
    if (report.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        message: 'Not authorized to upload to this report'
      });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        message: 'No files uploaded'
      });
    }

    // Create file URLs
    const newAttachments = req.files.map(file => `/uploads/${file.filename}`);

    // Update report attachments
    const updatedReport = await Report.findByIdAndUpdate(
      req.params.id,
      {
        $push: { attachments: { $each: newAttachments } }
      },
      { new: true }
    ).populate('userId', 'email userMetadata');

    res.json({
      message: 'Attachments uploaded successfully',
      report: updatedReport
    });
  } catch (error) {
    console.error('Upload attachments error:', error);

    // Clean up uploaded files if error occurs
    if (req.files) {
      req.files.forEach(async (file) => {
        try {
          await fs.unlink(file.path);
        } catch (cleanupError) {
          console.error('Error cleaning up file:', cleanupError);
        }
      });
    }

    res.status(500).json({
      message: 'Error uploading attachments',
      error: error.message
    });
  }
});

// @route   DELETE /api/reports/:id/attachments/:filename
// @desc    Delete attachment from report
// @access  Private
router.delete('/:id/attachments/:filename', protect, async (req, res) => {
  try {
    const report = await Report.findById(req.params.id);

    if (!report) {
      return res.status(404).json({
        message: 'Report not found'
      });
    }

    // Check ownership - ensure the report belongs to the authenticated user
    if (report.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        message: 'Not authorized to delete from this report'
      });
    }

    const { filename } = req.params;
    const attachmentUrl = `/uploads/${filename}`;

    // Check if attachment exists in report
    if (!report.attachments.includes(attachmentUrl)) {
      return res.status(404).json({
        message: 'Attachment not found in report'
      });
    }

    // Remove file from filesystem
    try {
      const filePath = path.join(__dirname, '../uploads', filename);
      await fs.unlink(filePath);
    } catch (fileError) {
      console.error('Error deleting file from filesystem:', fileError);
      // Continue with removing from database
    }

    // Remove from report attachments
    const updatedReport = await Report.findByIdAndUpdate(
      req.params.id,
      {
        $pull: { attachments: attachmentUrl }
      },
      { new: true }
    ).populate('userId', 'email userMetadata');

    res.json({
      message: 'Attachment deleted successfully',
      report: updatedReport
    });
  } catch (error) {
    console.error('Delete attachment error:', error);
    res.status(500).json({
      message: 'Error deleting attachment',
      error: error.message
    });
  }
});

module.exports = router;
