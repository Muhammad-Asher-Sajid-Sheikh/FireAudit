import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});

export const createPO = async (req, res) => {
  try {
    const { poNumber, date } = req.body;

    // Validation
    if (!poNumber || !date) {
      return res.status(400).json({ error: 'poNumber and date are required fields.' });
    }

    const newPO = await prisma.purchaseOrder.create({
      data: {
        poNumber,
        date: new Date(date), // Ensures proper DateTime parsing
      },
    });

    return res.status(201).json({
      message: 'Purchase Order created successfully',
      data: newPO,
    });
  } catch (error) {
    console.error('Error creating PO:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'A Purchase Order with this poNumber already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. Read All Purchase Orders
export const getAllPOs = async (req, res) => {
  try {
    const purchaseOrders = await prisma.purchaseOrder.findMany({
      orderBy: { date: 'desc' },
    });

    return res.status(200).json({
      success: true,
      count: purchaseOrders.length,
      data: purchaseOrders,
    });
  } catch (error) {
    console.error('Error fetching POs:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 3. Read Purchase Order by ID
export const getPOById = async (req, res) => {
  try {
    const { id } = req.params;

    const purchaseOrder = await prisma.purchaseOrder.findUnique({
      where: { id },
    });

    if (!purchaseOrder) {
      return res.status(404).json({ error: 'Purchase Order not found' });
    }

    return res.status(200).json({
      success: true,
      data: purchaseOrder,
    });
  } catch (error) {
    console.error('Error fetching PO by ID:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 4. Edit / Update a Purchase Order
export const updatePO = async (req, res) => {
  try {
    const { id } = req.params;
    const { poNumber, date } = req.body;

    // Check if PO exists first
    const existingPO = await prisma.purchaseOrder.findUnique({
      where: { id },
    });

    if (!existingPO) {
      return res.status(404).json({ error: 'Purchase Order not found' });
    }

    const updatedPO = await prisma.purchaseOrder.update({
      where: { id },
      data: {
        ...(poNumber && { poNumber }),
        ...(date && { date: new Date(date) }),
      },
    });

    return res.status(200).json({
      message: 'Purchase Order updated successfully',
      data: updatedPO,
    });
  } catch (error) {
    console.error('Error updating PO:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'Another Purchase Order with this poNumber already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};