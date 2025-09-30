const nodemailer = require('nodemailer');

// Create transporter
const createTransporter = () => {
  return nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: process.env.EMAIL_PORT,
    secure: process.env.EMAIL_SECURE === 'true',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });
};

// Send password reset email
const sendPasswordResetEmail = async (email, resetToken) => {
  // Skip email sending if disabled
  if (process.env.DISABLE_EMAIL === 'true') {
    console.log(`Email sending disabled - would send password reset to ${email}`);
    return;
  }

  const transporter = createTransporter();

  const resetURL = `${process.env.FRONTEND_URL}/reset-password/${resetToken}`;

  const mailOptions = {
    from: `"Harari Prosperity" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Password Reset Request',
    html: `
      <div style="max-width: 600px; margin: 0 auto; font-family: Arial, sans-serif;">
        <h2 style="color: #1E88E5;">Password Reset Request</h2>
        <p>You requested a password reset for your Harari Prosperity account.</p>
        <p>Please click the link below to reset your password:</p>
        <a href="${resetURL}" style="background-color: #1E88E5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;">
          Reset Password
        </a>
        <p><strong>This link will expire in 10 minutes.</strong></p>
        <p>If you didn't request this password reset, please ignore this email.</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          This is an automated message from Harari Prosperity. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `
      Password Reset Request

      You requested a password reset for your Harari Prosperity account.

      Please visit this link to reset your password: ${resetURL}

      This link will expire in 10 minutes.

      If you didn't request this password reset, please ignore this email.
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Password reset email sent to ${email}`);
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw new Error('Failed to send password reset email');
  }
};

// Send welcome email
const sendWelcomeEmail = async (email, userName) => {
  // Skip email sending if disabled
  if (process.env.DISABLE_EMAIL === 'true') {
    console.log(`Email sending disabled - would send welcome email to ${email}`);
    return;
  }

  const transporter = createTransporter();

  const mailOptions = {
    from: `"Harari Prosperity" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Welcome to Harari Prosperity',
    html: `
      <div style="max-width: 600px; margin: 0 auto; font-family: Arial, sans-serif;">
        <h2 style="color: #1E88E5;">Welcome to Harari Prosperity!</h2>
        <p>Dear ${userName || 'User'},</p>
        <p>Thank you for joining Harari Prosperity! Your account has been successfully created.</p>
        <p>You can now:</p>
        <ul>
          <li>Create and manage prosperity reports</li>
          <li>Track your progress and achievements</li>
          <li>Access personalized insights and recommendations</li>
        </ul>
        <p>Get started by logging in to your account and creating your first report!</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          This is an automated message from Harari Prosperity. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `
      Welcome to Harari Prosperity!

      Dear ${userName || 'User'},

      Thank you for joining Harari Prosperity! Your account has been successfully created.

      You can now:
      - Create and manage prosperity reports
      - Track your progress and achievements
      - Access personalized insights and recommendations

      Get started by logging in to your account and creating your first report!

      Best regards,
      Harari Prosperity Team
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Welcome email sent to ${email}`);
  } catch (error) {
    console.error('Error sending welcome email:', error);
    // Don't throw error for welcome emails to avoid registration failures
  }
};

// Send email verification
const sendEmailVerification = async (email, verificationToken) => {
  // Skip email sending if disabled
  if (process.env.DISABLE_EMAIL === 'true') {
    console.log(`Email sending disabled - would send verification email to ${email}`);
    return;
  }

  const transporter = createTransporter();

  const verificationURL = `${process.env.FRONTEND_URL}/verify-email/${verificationToken}`;

  const mailOptions = {
    from: `"Harari Prosperity" <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Verify Your Email Address',
    html: `
      <div style="max-width: 600px; margin: 0 auto; font-family: Arial, sans-serif;">
        <h2 style="color: #1E88E5;">Verify Your Email</h2>
        <p>Thank you for registering with Harari Prosperity!</p>
        <p>Please click the link below to verify your email address:</p>
        <a href="${verificationURL}" style="background-color: #1E88E5; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block; margin: 10px 0;">
          Verify Email
        </a>
        <p><strong>This link will expire in 24 hours.</strong></p>
        <p>If you didn't create an account, please ignore this email.</p>
        <hr>
        <p style="font-size: 12px; color: #666;">
          This is an automated message from Harari Prosperity. Please do not reply to this email.
        </p>
      </div>
    `,
    text: `
      Verify Your Email

      Thank you for registering with Harari Prosperity!

      Please visit this link to verify your email address: ${verificationURL}

      This link will expire in 24 hours.

      If you didn't create an account, please ignore this email.
    `
  };

  try {
    await transporter.sendMail(mailOptions);
    console.log(`Email verification sent to ${email}`);
  } catch (error) {
    console.error('Error sending email verification:', error);
    // Don't throw error for verification emails to avoid registration failures
  }
};

module.exports = {
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendEmailVerification
};
