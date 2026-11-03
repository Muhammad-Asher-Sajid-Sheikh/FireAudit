import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});

// Helper function to extract client IP safely
const getClientIP = (req) => {
    return req.headers['x-forwarded-for'] || req.socket.remoteAddress || null;
};

/**
 * 1. CREATE a new fire extinguisher + Audit Log
 * POST /api/extinguishers
 */
export const createExtinguisher = async (req, res) => {
    try {
        const { model, expiryDate, batchSize, isExpired } = req.body;
        const userId = req.user?.id || "99630e85-0a0f-4819-8083-18fa62d12357"; // Assumes auth middleware sets req.user

        if (!model || !expiryDate || !batchSize) {
            return res.status(400).json({
                success: false,
                message: "Model and expiryDate and batchSize are required fields.",
            });
        }

        if (!userId) {
            return res.status(401).json({ success: false, message: "Unauthorized user." });
        }

        const newExtinguisher = await prisma.fireExtinguisher.create({
            data: {
                model,
                expiryDate: new Date(expiryDate),
                batchSize,
                isExpired: isExpired ?? false,
            },
        });

        const testBatchId = 'extinguisher-batch-001';
  
        console.log(`[Test Start] Admin is creating batch ${testBatchId}...`);
        await scheduleBatchAlert(testBatchId, 8, true);
        setTimeout(async () => {
    console.log(`[Diagnostic Check at +2 seconds]:`);
    await findBatchScheduler(testBatchId);
}, 2000);

// Check again after the 8 seconds have passed
setTimeout(async () => {
    console.log(`[Diagnostic Check at +10 seconds]:`);
    await findBatchScheduler(testBatchId);
}, 10000);
        console.log(`[Test Waiting] Schedulers are set. Sit back and watch the console...`);

        // Fill the Audit Log
        await prisma.auditLog.create({
            data: {
                userId,
                actionType: 'EXTINGUISHER_CREATED',
                actionDetails: JSON.stringify({ batchId: newExtinguisher.batchId, model }),
                performedBy: userId,
                ipAddress: getClientIP(req),
            },
        });

        return res.status(201).json({
            success: true,
            message: "Fire extinguisher registered successfully.",
            data: newExtinguisher,
        });
    } catch (error) {
        console.error("Error creating fire extinguisher:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while creating the extinguisher.",
        });
    }
};

/**
 * 2. READ ALL fire extinguishers
 * GET /api/extinguishers
 */
export const getAllExtinguishers = async (req, res) => {
    try {
        const extinguishers = await prisma.fireExtinguisher.findMany({
            orderBy: { createdAt: 'desc' },
        });

        return res.status(200).json({
            success: true,
            count: extinguishers.length,
            data: extinguishers,
        });
    } catch (error) {
        console.error("Error fetching fire extinguishers:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while fetching extinguishers.",
        });
    }
};

/**
 * 3. READ a single fire extinguisher by ID (batchId)
 * GET /api/extinguishers/:id
 */
export const getExtinguisherById = async (req, res) => {
    try {
        const { id } = req.params;

        const extinguisher = await prisma.fireExtinguisher.findUnique({
            where: { batchId: id },
        });

        if (!extinguisher) {
            return res.status(404).json({
                success: false,
                message: "Fire extinguisher not found.",
            });
        }

        return res.status(200).json({
            success: true,
            data: extinguisher,
        });
    } catch (error) {
        console.error("Error fetching fire extinguisher:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while fetching the extinguisher.",
        });
    }
};

/**
 * 4. UPDATE a fire extinguisher + Audit Log
 * PUT /api/extinguishers/:id
 */
export const updateExtinguisher = async (req, res) => {
    try {
        const { id } = req.params;
        const { model, expiryDate, batchSize, isExpired } = req.body;
        const userId = req.user?.id || "99630e85-0a0f-4819-8083-18fa62d12357";

        if (!userId) {
            return res.status(401).json({ success: false, message: "Unauthorized user." });
        }

        const existing = await prisma.fireExtinguisher.findUnique({
            where: { batchId: id },
        });

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: "Fire extinguisher not found for update.",
            });
        }

        const updatedExtinguisher = await prisma.fireExtinguisher.update({
            where: { batchId: id },
            data: {
                ...(model && { model }),
                ...(expiryDate && { expiryDate: new Date(expiryDate) }),
                ...(batchSize && { batchSize }),
                ...(isExpired !== undefined && { isExpired }),
            },
        });

        // Fill the Audit Log
        await prisma.auditLog.create({
            data: {
                userId,
                actionType: 'EXTINGUISHER_UPDATED',
                actionDetails: JSON.stringify({ batchId: id, updatedFields: req.body }),
                performedBy: userId,
                ipAddress: getClientIP(req),
            },
        });

        return res.status(200).json({
            success: true,
            message: "Fire extinguisher updated successfully.",
            data: updatedExtinguisher,
        });
    } catch (error) {
        console.error("Error updating fire extinguisher:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while updating the extinguisher.",
        });
    }
};

/**
 * 5. DELETE a fire extinguisher + Audit Log
 * DELETE /api/extinguishers/:id
 */
export const deleteExtinguisher = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user?.id || "99630e85-0a0f-4819-8083-18fa62d12357";

        if (!userId) {
            return res.status(401).json({ success: false, message: "Unauthorized user." });
        }

        const existing = await prisma.fireExtinguisher.findUnique({
            where: { batchId: id },
        });

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: "Fire extinguisher not found for deletion.",
            });
        }

        await prisma.fireExtinguisher.delete({
            where: { batchId: id },
        });

        // Fill the Audit Log
        await prisma.auditLog.create({
            data: {
                userId,
                actionType: 'EXTINGUISHER_DELETED',
                actionDetails: JSON.stringify({ batchId: id, model: existing.model }),
                performedBy: userId,
                ipAddress: getClientIP(req),
            },
        });

        return res.status(200).json({
            success: true,
            message: "Fire extinguisher deleted successfully.",
        });
    } catch (error) {
        console.error("Error deleting fire extinguisher:", error);
        return res.status(500).json({
            success: false,
            message: "Internal server error while deleting the extinguisher.",
        });
    }
};