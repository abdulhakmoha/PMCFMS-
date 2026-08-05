const express = require('express');
const router = express.Router();
const { getUsers, updateUserRole, deleteUser, updateProfile } = require('../controllers/userController');
const { protect, admin } = require('../middleware/authMiddleware');
const upload = require('../middleware/uploadMiddleware');

router.route('/')
  .get(protect, admin, getUsers);

router.route('/profile')
  .put(protect, upload.single('profilePicture'), updateProfile);

router.route('/:id')
  .delete(protect, admin, deleteUser);

router.route('/:id/role')
  .put(protect, admin, updateUserRole);

module.exports = router;
