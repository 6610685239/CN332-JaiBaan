const prisma = require('../../db');

class FacilityService {
    // ดึงสถานที่ทั้งหมด
    async getAllFacilities() {
        return await prisma.facility.findMany();
    }

    // ดึงสถานที่ตาม ID
    async getFacilityById(id) {
        return await prisma.facility.findUnique({ where: { id: parseInt(id) } });
    }

    // สร้างการจองใหม่
    async createBooking(bookingData) {
        return await prisma.reservation.create({
            data: {
                bookingCode: `BK-${Math.random().toString(36).substring(2, 9).toUpperCase()}`,
                residentId: bookingData.residentId,
                facilityId: bookingData.facilityId,
                startTime: new Date(bookingData.startTime),
                endTime: new Date(bookingData.endTime),
                pax: bookingData.pax,
                status: "CONFIRMED"
            }
        });
    }

    async getResidentBookings(residentId) {
        return await prisma.reservation.findMany({
            where: { residentId: parseInt(residentId) },
            include: { facility: true }
        });
    }

    async cancelBooking(bookingId) {
        return await prisma.reservation.update({
            where: { id: parseInt(bookingId) },
            data: { status: 'CANCELLED' }
        });
    }

    async deleteBooking(bookingId) {
        const reservation = await prisma.reservation.findUnique({
            where: { id: parseInt(bookingId) }
        });
        if (!reservation) throw new Error('ไม่พบการจองนี้');
        if (reservation.status !== 'CANCELLED') throw new Error('สามารถลบได้เฉพาะการจองที่ยกเลิกแล้วเท่านั้น');
        return await prisma.reservation.delete({
            where: { id: parseInt(bookingId) }
        });
    }

    async createFacility(data) {
        return await prisma.facility.create({ data });
    }

    async updateFacility(id, data) {
        return await prisma.facility.update({ where: { id: parseInt(id) }, data });
    }

    async deleteFacility(id) {
        return await prisma.facility.delete({ where: { id: parseInt(id) } });
    }

    async getAllReservations() {
        return await prisma.reservation.findMany({
            include: { facility: true, resident: true },
            orderBy: { createdAt: 'desc' },
        });
    }

    async getFacilityBookings(facilityId, date) {
        const dayStart = new Date(date);
        dayStart.setHours(0, 0, 0, 0);
        const dayEnd = new Date(date);
        dayEnd.setHours(23, 59, 59, 999);
        return await prisma.reservation.findMany({
            where: {
                facilityId: parseInt(facilityId),
                startTime: { gte: dayStart, lte: dayEnd },
                status: 'CONFIRMED',
            },
            select: { startTime: true, endTime: true }
        });
    }
}
module.exports = new FacilityService();