import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

//import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});


export const createOrderForm = async (req, res) => {
  try {
    const { poId, foType, unit, quantity, location } = req.body;

    // Validation
    if (!poId || !foType || !unit || quantity === undefined || !location) {
      return res.status(400).json({ error: 'All fields (poId, foType, unit, quantity, location) are required.' });
    }

    // Verify if the parent Purchase Order exists
    const parentPO = await prisma.purchaseOrder.findUnique({
      where: { id: poId },
    });

    if (!parentPO) {
      return res.status(404).json({ error: 'Associated Purchase Order (poId) not found.' });
    }

    const newOrderForm = await prisma.orderForm.create({
      data: {
        poId,
        foType,
        unit,
        quantity: Number(quantity),
        location,
      },
    });

    return res.status(201).json({
      message: 'Order Form created successfully',
      data: newOrderForm,
    });
  } catch (error) {
    console.error('Error creating Order Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. Read All Order Forms (Supports optional query filtering by ?poId=...)
export const getAllOrderForms = async (req, res) => {
  try {
    const { poId } = req.query;

    const orderForms = await prisma.orderForm.findMany({
      where: poId ? { poId } : {},
      include: {
        purchaseOrder: true, // Optionally populate parent PO details
      },
      orderBy: { createdAt: 'desc' },
    });

    return res.status(200).json({
      success: true,
      count: orderForms.length,
      data: orderForms,
    });
  } catch (error) {
    console.error('Error fetching Order Forms:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 3. Read Order Form by ID
export const getOrderFormById = async (req, res) => {
  try {
    const { id } = req.params;

    const orderForm = await prisma.orderForm.findUnique({
      where: { id },
      include: {
        purchaseOrder: true,
      },
    });

    if (!orderForm) {
      return res.status(404).json({ error: 'Order Form not found' });
    }

    return res.status(200).json({
      success: true,
      data: orderForm,
    });
  } catch (error) {
    console.error('Error fetching Order Form by ID:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 4. Update / Edit an Order Form
export const updateOrderForm = async (req, res) => {
  try {
    const { id } = req.params;
    const { poId, foType, unit, quantity, location } = req.body;

    // Check if Order Form exists
    const existingOrderForm = await prisma.orderForm.findUnique({
      where: { id },
    });

    if (!existingOrderForm) {
      return res.status(404).json({ error: 'Order Form not found' });
    }

    // If poId is being updated, verify new parent PO exists
    if (poId && poId !== existingOrderForm.poId) {
      const parentPO = await prisma.purchaseOrder.findUnique({ where: { id: poId } });
      if (!parentPO) {
        return res.status(404).json({ error: 'New associated Purchase Order (poId) not found.' });
      }
    }

    const updatedOrderForm = await prisma.orderForm.update({
      where: { id },
      data: {
        ...(poId && { poId }),
        ...(foType && { foType }),
        ...(unit && { unit }),
        ...(quantity !== undefined && { quantity: Number(quantity) }),
        ...(location && { location }),
      },
    });

    return res.status(200).json({
      message: 'Order Form updated successfully',
      data: updatedOrderForm,
    });
  } catch (error) {
    console.error('Error updating Order Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 5. Delete an Order Form
export const deleteOrderForm = async (req, res) => {
  try {
    const { id } = req.params;

    const existingOrderForm = await prisma.orderForm.findUnique({
      where: { id },
    });

    if (!existingOrderForm) {
      return res.status(404).json({ error: 'Order Form not found' });
    }

    await prisma.orderForm.delete({
      where: { id },
    });

    return res.status(200).json({
      message: 'Order Form deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting Order Form:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};