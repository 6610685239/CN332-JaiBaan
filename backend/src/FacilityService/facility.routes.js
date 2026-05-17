
const express = require('express');
const router = express.Router();
const facilityController = require('./facility.controller');
const upload = require('../middleware/upload');

// Photo upload / delete
router.post('/upload-photo', upload.single('file'), facilityController.uploadPhoto);
router.delete('/photo', facilityController.removePhoto);

// Specific paths must come before parameterized /:id routes
router.get('/', facilityController.getFacilities);
router.post('/', facilityController.createFacility);
router.get('/reservations', facilityController.getAllReservations);
router.post('/book', facilityController.bookFacility);
router.get('/my-bookings/:residentId', facilityController.getMyBookings);
router.patch('/reservations/:bookingId/cancel', facilityController.cancelBooking);
router.delete('/reservations/:bookingId', facilityController.deleteBooking);

// Parameterized routes last
router.get('/:id', facilityController.getFacilityById);
router.put('/:id', facilityController.updateFacility);
router.delete('/:id', facilityController.deleteFacility);
router.get('/:facilityId/bookings', facilityController.getFacilityBookings);

module.exports = router;
