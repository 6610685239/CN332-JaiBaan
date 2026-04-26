
const express = require('express');
const router = express.Router();
const facilityController = require('./facility.controller');
console.log("Controller Check:", facilityController);

router.get('/', facilityController.getFacilities);
router.post('/book', facilityController.bookFacility);
router.get('/my-bookings/:residentId', facilityController.getMyBookings);
router.patch('/reservations/:bookingId/cancel', facilityController.cancelBooking);
router.delete('/reservations/:bookingId', facilityController.deleteBooking);
router.get('/:facilityId/bookings', facilityController.getFacilityBookings);

module.exports = router;
