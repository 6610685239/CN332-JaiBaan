const facilityService = require('./facility.service');
const { saveFacilityPhoto, deleteFacilityPhoto } = require('../services/facilityFileService');

class FacilityController {
    uploadPhoto = async (req, res) => {
        try {
            if (!req.file) return res.status(400).json({ success: false, message: 'ไม่พบไฟล์' });
            const url = await saveFacilityPhoto(req.file);
            res.json({ success: true, url });
        } catch (err) {
            res.status(500).json({ success: false, message: err.message });
        }
    };

    removePhoto = async (req, res) => {
        try {
            const { filename } = req.body;
            if (!filename) return res.status(400).json({ success: false, message: 'ไม่พบชื่อไฟล์' });
            await deleteFacilityPhoto(filename);
            res.json({ success: true });
        } catch (err) {
            res.status(500).json({ success: false, message: err.message });
        }
    };
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

    getFacilityById = async (req, res) => {
        try {
            const data = await facilityService.getFacilityById(req.params.id);
            if (!data) return res.status(404).json({ error: 'ไม่พบสถานที่' });
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: 'ดึงข้อมูลสถานที่ล้มเหลว' });
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

    createFacility = async (req, res) => {
        try {
            const { name, description, capacityMin, capacityMax, openTime, closeTime, imageUrl } = req.body;
            if (!name) return res.status(400).json({ error: 'ชื่อสถานที่ห้ามว่าง' });
            const data = await facilityService.createFacility({
                name,
                description: description || null,
                capacityMin: capacityMin ? parseInt(capacityMin) : null,
                capacityMax: capacityMax ? parseInt(capacityMax) : null,
                openTime: openTime || null,
                closeTime: closeTime || null,
                imageUrl: imageUrl || null,
            });
            res.status(201).json(data);
        } catch (error) {
            res.status(500).json({ error: 'สร้างสถานที่ล้มเหลว', details: error.message });
        }
    };

    updateFacility = async (req, res) => {
        try {
            const { name, description, capacityMin, capacityMax, openTime, closeTime, imageUrl } = req.body;
            const data = await facilityService.updateFacility(req.params.id, {
                name,
                description: description || null,
                capacityMin: capacityMin ? parseInt(capacityMin) : null,
                capacityMax: capacityMax ? parseInt(capacityMax) : null,
                openTime: openTime || null,
                closeTime: closeTime || null,
                imageUrl: imageUrl || null,
            });
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: 'แก้ไขสถานที่ล้มเหลว', details: error.message });
        }
    };

    deleteFacility = async (req, res) => {
        try {
            await facilityService.deleteFacility(req.params.id);
            res.json({ message: 'ลบสถานที่สำเร็จ' });
        } catch (error) {
            res.status(500).json({ error: 'ลบสถานที่ล้มเหลว', details: error.message });
        }
    };

    getAllReservations = async (req, res) => {
        try {
            const data = await facilityService.getAllReservations();
            res.json(data);
        } catch (error) {
            res.status(500).json({ error: 'ดึงข้อมูลการจองล้มเหลว' });
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