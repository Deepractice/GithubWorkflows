/**
 * JWT Authentication Module
 * Handles user authentication using JSON Web Tokens
 */

const jwt = require('jsonwebtoken');

class JWTAuth {
  constructor(secret, options = {}) {
    this.secret = secret;
    this.options = {
      expiresIn: options.expiresIn || '24h',
      algorithm: options.algorithm || 'HS256'
    };
  }

  /**
   * Generate a JWT token for a user
   * @param {Object} payload - User data to encode
   * @returns {String} JWT token
   */
  generateToken(payload) {
    return jwt.sign(payload, this.secret, this.options);
  }

  /**
   * Verify and decode a JWT token
   * @param {String} token - JWT token to verify
   * @returns {Object} Decoded payload
   */
  verifyToken(token) {
    try {
      return jwt.verify(token, this.secret);
    } catch (error) {
      throw new Error('Invalid or expired token');
    }
  }

  /**
   * Refresh an existing token
   * @param {String} token - Current JWT token
   * @returns {String} New JWT token
   */
  refreshToken(token) {
    const payload = this.verifyToken(token);
    delete payload.iat;
    delete payload.exp;
    return this.generateToken(payload);
  }
}

module.exports = JWTAuth;