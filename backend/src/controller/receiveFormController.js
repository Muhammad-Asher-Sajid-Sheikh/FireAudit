import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});

export const createReceiveForm = async (req, res) => {
  try {
    const { poId, ofId, foType, unit, quantity, date, expiryDate } = req.body;

    // Validation
    if (!poId || !ofId || !foType || !unit || quantity === undefined) {
      return res.status(400).json({ error: 'Required fields (poId, ofId, foType, unit, quantity) are missing.' });
    }

    // Verify parent PO exists
    const parentPO = await prisma.purchaseOrder.findUnique({ where: { id: poId } });
    if (!parentPO) {
      return res.status(404).json({ error: 'Associated Purchase Order (poId) not found.' });
    }

    // Verify parent OrderForm exists
    const parentOrderForm = await prisma.orderForm.findUnique({ where: { id: ofId } });
    if (!parentOrderForm) {
      return res.status(404).json({ error: 'Associated Order Form (ofId) not found.' });
    }

    // Create Receive Form record
    const newReceiveForm = await prisma.recieveForm.create({
      data: {
        poId,
        ofId,
        foType,
        unit,
        quantity: Number(quantity),
        date: date ? new Date(date) : new Date(),
      },
    });

    // Set up scheduler if an expiryDate is provided
    if (expiryDate) {
      await scheduleBatchAlert(newReceiveForm.id, new Date(expiryDate));
    }

    return res.status(201).json({
      message: 'Receive Form created and alert scheduled successfully',
      data: newReceiveForm,
    });
  } catch (error) {
    console.error('Error creating Receive Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. Read All Receive Forms
export const getAllReceiveForms = async (req, res) => {
  try {
    const { poId, ofId } = req.query;

    const receiveForms = await prisma.recieveForm.findMany({
      where: {
        ...(poId && { poId }),
        ...(ofId && { ofId }),
      },
      include: {
        purchaseOrder: true,
        orderForm: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    // Optionally attach scheduler info if needed
    const receiveFormsWithSchedule = await Promise.all(
      receiveForms.map(async (rf) => {
        const schedule = await findBatchScheduler(rf.id).catch(() => null);
        return { ...rf, schedule };
      })
    );

    return res.status(200).json({
      success: true,
      count: receiveFormsWithSchedule.length,
      data: receiveFormsWithSchedule,
    });
  } catch (error) {
    console.error('Error fetching Receive Forms:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 3. Read Receive Form by ID
export const getReceiveFormById = async (req, res) => {
  try {
    const { id } = req.params;

    const receiveForm = await prisma.recieveForm.findUnique({
      where: { id },
      include: {
        purchaseOrder: true,
        orderForm: true,
      },
    });

    if (!receiveForm) {
      return res.status(404).json({ error: 'Receive Form not found' });
    }

    // Fetch associated schedule details
    const schedule = await findBatchScheduler(id).catch(() => null);

    return res.status(200).json({
      success: true,
      data: {
        ...receiveForm,
        schedule,
      },
    });
  } catch (error) {
    console.error('Error fetching Receive Form by ID:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 4. Update / Edit Receive Form & Schedule
export const updateReceiveForm = async (req, res) => {
  try {
    const { id } = req.params;
    const { poId, ofId, foType, unit, quantity, date, expiryDate } = req.body;

    const existingReceiveForm = await prisma.recieveForm.findUnique({
      where: { id },
    });

    if (!existingReceiveForm) {
      return res.status(404).json({ error: 'Receive Form not found' });
    }

    // Optional foreign key validations if changed
    if (poId && poId !== existingReceiveForm.poId) {
      const parentPO = await prisma.purchaseOrder.findUnique({ where: { id: poId } });
      if (!parentPO) return res.status(404).json({ error: 'New Purchase Order not found.' });
    }

    if (ofId && ofId !== existingReceiveForm.ofId) {
      const parentOrderForm = await prisma.orderForm.findUnique({ where: { id: ofId } });
      if (!parentOrderForm) return res.status(404).json({ error: 'New Order Form not found.' });
    }

    // Perform database update
    const updatedReceiveForm = await prisma.recieveForm.update({
      where: { id },
      data: {
        ...(poId && { poId }),
        ...(ofId && { ofId }),
        ...(foType && { foType }),
        ...(unit && { unit }),
        ...(quantity !== undefined && { quantity: Number(quantity) }),
        ...(date && { date: new Date(date) }),
      },
    });

    // Update schedule if expiryDate is provided in the request body
    if (expiryDate) {
      const existingSchedule = await findBatchScheduler(id).catch(() => null);
      if (existingSchedule) {
        await updateBatchExpiry(id, new Date(expiryDate));
      } else {
        await scheduleBatchAlert(id, new Date(expiryDate));
      }
    }

    return res.status(200).json({
      message: 'Receive Form and schedule updated successfully',
      data: updatedReceiveForm,
    });
  } catch (error) {
    console.error('Error updating Receive Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 5. Delete Receive Form
export const deleteReceiveForm = async (req, res) => {
  try {
    const { id } = req.params;

    const existingReceiveForm = await prisma.recieveForm.findUnique({
      where: { id },
    });

    if (!existingReceiveForm) {
      return res.status(404).json({ error: 'Receive Form not found' });
    }

    // TODO: Run the delete schedule method here when created later, e.g.:
    // await deleteBatchScheduler(id);

    await prisma.recieveForm.delete({
      where: { id },
    });

    return res.status(200).json({
      message: 'Receive Form deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting Receive Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};