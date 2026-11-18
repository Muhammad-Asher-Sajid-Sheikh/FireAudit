import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

//import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});


// 1. Create a Type
export const createType = async (req, res) => {
  try {
    const { name, specialInstructions } = req.body;

    // Validation
    if (!name || !specialInstructions) {
      return res.status(400).json({ error: 'Both name and specialInstructions are required fields.' });
    }

    const newType = await prisma.types.create({
      data: {
        name,
        specialInstructions,
      },
    });

    return res.status(201).json({
      message: 'Type created successfully',
      data: newType,
    });
  } catch (error) {
    console.error('Error creating Type:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'A Type with this name already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. Read All Types
export const getAllTypes = async (req, res) => {
  try {
    const types = await prisma.types.findMany({
      orderBy: { name: 'asc' },
    });

    return res.status(200).json({
      success: true,
      count: types.length,
      data: types,
    });
  } catch (error) {
    console.error('Error fetching Types:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 3. Read Type by ID
export const getTypeById = async (req, res) => {
  try {
    const { id } = req.params;

    const type = await prisma.types.findUnique({
      where: { id },
    });

    if (!type) {
      return res.status(404).json({ error: 'Type not found' });
    }

    return res.status(200).json({
      success: true,
      data: type,
    });
  } catch (error) {
    console.error('Error fetching Type by ID:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 4. Update / Edit a Type
export const updateType = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, specialInstructions } = req.body;

    // Check if Type exists
    const existingType = await prisma.types.findUnique({
      where: { id },
    });

    if (!existingType) {
      return res.status(404).json({ error: 'Type not found' });
    }

    const updatedType = await prisma.types.update({
      where: { id },
      data: {
        ...(name && { name }),
        ...(specialInstructions && { specialInstructions }),
      },
    });

    return res.status(200).json({
      message: 'Type updated successfully',
      data: updatedType,
    });
  } catch (error) {
    console.error('Error updating Type:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'Another Type with this name already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 5. Delete a Type
export const deleteType = async (req, res) => {
  try {
    const { id } = req.params;

    const existingType = await prisma.types.findUnique({
      where: { id },
    });

    if (!existingType) {
      return res.status(404).json({ error: 'Type not found' });
    }

    await prisma.types.delete({
      where: { id },
    });

    return res.status(200).json({
      message: 'Type deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting Type:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};