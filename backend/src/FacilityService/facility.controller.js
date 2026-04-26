const facilityService = require('./facility.service');

class FacilityController {
    // ใช้ => เพื่อล็อคขอบเขตฟังก์ชัน
    getFacilities = async (req, res) => {
        try {
            const data = await facilityService.getAllFacilities();
            res.json(data);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "ดึงข้อมูลสถานที่ล้มเหลว" });
        }
    };

    bookFacility = async (req, res) => {
        try {
            const booking = await facilityService.createBooking(req.body);
            res.status(201).json({ message: "จองสำเร็จ", data: booking });
        } catch (error) {
            res.status(400).json({ error: "การจองผิดพลาด", details: error.message });
        }
    };

    getMyBookings = async (req, res) => {
        try {
            const data = await facilityService.getResidentBookings(req.params.residentId);
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: "ดึงประวัติการจองล้มเหลว" });
        }
    };

    deleteBooking = async (req, res) => {
        try {
            await facilityService.deleteBooking(req.params.bookingId);
            res.json({ message: 'ลบการจองสำเร็จ' });
        } catch (error) {
            res.status(400).json({ error: error.message });
        }
    };

    cancelBooking = async (req, res) => {
        try {
            const data = await facilityService.cancelBooking(req.params.bookingId);
            res.json({ message: 'ยกเลิกการจองสำเร็จ', data });
        } catch (error) {
            res.status(400).json({ error: 'ยกเลิกการจองล้มเหลว', details: error.message });
        }
    };

    getFacilityBookings = async (req, res) => {
        try {
            const data = await facilityService.getFacilityBookings(req.params.facilityId, req.query.date);
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: "ดึงข้อมูลการจองล้มเหลว" });
        }
    };
}

module.exports = new FacilityController();