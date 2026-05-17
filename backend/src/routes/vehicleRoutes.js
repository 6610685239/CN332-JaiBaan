const express = require('express');
const router = express.Router();
const prisma = require('../../db');
const { sendPushNotification } = require('../services/notificationService');

// GET /api/vehicles?residentId=1
router.get('/', async (req, res) => {
  try {
    const { residentId } = req.query;
    const vehicles = await prisma.vehicle.findMany({
      where: residentId ? { residentId: parseInt(residentId) } : undefined,
      orderBy: { createdAt: 'desc' },
    });
    res.json(vehicles);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

// POST /api/vehicles  { plate, province, residentId }
router.post('/', async (req, res) => {
  try {
    const { plate, province, residentId } = req.body;
    const vehicle = await prisma.vehicle.create({
      data: { plate, province, residentId: parseInt(residentId) },
    });
    res.status(201).json(vehicle);
  } catch (err) {
    console.error('Save vehicle error:', err.message);
    res.status(500).json({ error: 'Failed to save vehicle', detail: err.message });
  }
});

// DELETE /api/vehicles/:id
router.delete('/:id', async (req, res) => {
  try {
    await prisma.vehicle.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete vehicle' });
  }
});

// GET /api/vehicles/visitor-passes?residentId=1
router.get('/visitor-passes', async (req, res) => {
  try {
    const { residentId } = req.query;
    const passes = await prisma.visitorPass.findMany({
      where: residentId ? { residentId: parseInt(residentId) } : undefined,
      orderBy: { createdAt: 'desc' },
    });
    res.json(passes);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch visitor passes' });
  }
});

// POST /api/vehicles/visitor-passes  { plate, province, residentId, expiresAt? }
router.post('/visitor-passes', async (req, res) => {
  try {
    const { plate, province, residentId, expiresAt } = req.body;
    const expiry = expiresAt ? new Date(expiresAt) : new Date(Date.now() + 48 * 60 * 60 * 1000);
    const pass = await prisma.visitorPass.create({
      data: { plate, province, residentId: parseInt(residentId), expiresAt: expiry },
    });
    res.status(201).json(pass);
  } catch (err) {
    res.status(500).json({ error: 'Failed to save visitor pass' });
  }
});

// PATCH /api/vehicles/visitor-passes/:id  { isActive }
router.patch('/visitor-passes/:id', async (req, res) => {
  try {
    const pass = await prisma.visitorPass.update({
      where: { id: parseInt(req.params.id) },
      data: { isActive: req.body.isActive },
    });
    res.json(pass);
  } catch (err) {
    res.status(500).json({ error: 'Failed to update visitor pass' });
  }
});

// DELETE /api/vehicles/visitor-passes/:id
router.delete('/visitor-passes/:id', async (req, res) => {
  try {
    await prisma.visitorPass.delete({ where: { id: parseInt(req.params.id) } });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete visitor pass' });
  }
});

// POST /api/vehicles/gate/check  { plate }  — used by LPR at gate
router.post('/gate/check', async (req, res) => {
  try {
    const { plate } = req.body;
    const normalized = plate.replace(/\s+/g, '').toUpperCase();

    const vehicle = await prisma.vehicle.findFirst({
      where: { plate: { contains: normalized, mode: 'insensitive' } },
      include: { resident: { include: { User: true } } },
    });

    if (vehicle) {
      const residentToken = vehicle.resident.User.fcmToken;
      if (residentToken) {
        sendPushNotification(residentToken, '🚗 Vehicle Detected', `Your vehicle ${vehicle.plate} entered the premises.`, { type: 'GATE_ENTRY' });
      }
      return res.json({
        allowed: true,
        type: 'resident',
        unit: vehicle.resident.unitNumber,
        owner: `${vehicle.resident.User.firstName} ${vehicle.resident.User.lastName}`,
        plate: vehicle.plate,
      });
    }

    const now = new Date();
    const pass = await prisma.visitorPass.findFirst({
      where: {
        plate: { contains: normalized, mode: 'insensitive' },
        isActive: true,
        expiresAt: { gt: now },
      },
      include: { resident: { include: { User: true } } },
    });

    if (pass) {
      const residentToken = pass.resident.User.fcmToken;
      if (residentToken) {
        sendPushNotification(residentToken, '👤 Visitor Arrived', `Your visitor (${pass.plate}) has entered the premises.`, { type: 'VISITOR_ARRIVED' });
      }
      return res.json({
        allowed: true,
        type: 'visitor',
        unit: pass.resident.unitNumber,
        owner: `${pass.resident.User.firstName} ${pass.resident.User.lastName}`,
        plate: pass.plate,
      });
    }

    // Unknown plate — notify all guards
    const guards = await prisma.user.findMany({
      where: { role: 'guard', fcmToken: { not: null } },
      select: { fcmToken: true },
    });
    for (const g of guards) {
      sendPushNotification(g.fcmToken, '🚨 Unknown Plate', `Unregistered vehicle detected: ${plate}`, { type: 'UNKNOWN_PLATE', plate });
    }

    res.json({ allowed: false, plate });
  } catch (err) {
    res.status(500).json({ error: 'Gate check failed' });
  }
});

module.exports = router;
