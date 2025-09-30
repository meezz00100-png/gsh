# Mongoose Report Schema for Express.js + MongoDB Backend
# This is the MongoDB schema equivalent to the previous Postgres table
# Use this in your Express server with Mongoose

const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  // References to User model
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },

  // Basic report information
  name: { type: String, default: '' },
  reportType: { type: String, default: '' },
  type: { type: String, default: '' },
  receiverName: { type: String, default: '' },
  objective: { type: String, default: '' },
  description: { type: String, default: '' },

  // Report content fields
  importance: { type: String, default: '' },
  mainPoints: { type: String, default: '' },
  sources: { type: String, default: '' },
  roles: { type: String, default: '' },
  trends: { type: String, default: '' },
  themes: { type: String, default: '' },
  implications: { type: String, default: '' },
  scenarios: { type: String, default: '' },
  futurePlans: { type: String, default: '' },

  // Report metadata
  approvingBody: { type: String, default: '' },
  senderName: { type: String, default: '' },
  role: { type: String, default: '' },
  date: { type: String, default: '' },

  // Attachments (stored as array of file URLs or IDs)
  attachments: [{ type: String }],
  linkAttachment: { type: String },

  // Status and timestamps
  status: {
    type: String,
    enum: ['draft', 'completed'],
    default: 'draft',
  },
}, {
  timestamps: { createdAt: 'createdAt', updatedAt: 'updatedAt' },
});

// Create indexes for better query performance
reportSchema.index({ userId: 1 });
reportSchema.index({ status: 1 });
reportSchema.index({ createdAt: -1 });
reportSchema.index({ userId: 1, status: 1 });

module.exports = mongoose.model('Report', reportSchema);

// Example Express route usage:
// GET /api/reports - fetch user reports with query params
// POST /api/reports - create new report
// PUT /api/reports/:id - update report
// DELETE /api/reports/:id - delete report

# File uploads can be handled via multer middleware
# JWT authentication middleware ensures userId matches token
