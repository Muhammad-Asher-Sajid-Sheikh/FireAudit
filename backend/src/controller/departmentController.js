import { PrismaClient } from '../generated/client.js';
import { PrismaPg } from '@prisma/adapter-pg';
import 'dotenv/config';

//import { scheduleBatchAlert, findBatchScheduler } from './schedularController.js'; // Import the scheduling function

const prisma = new PrismaClient({
    adapter: new PrismaPg({
        connectionString: process.env.DATABASE_URL,
    }),
});


// 1. Create a Department
export const createDepartment = async (req, res) => {
  try {
    const { deptName, focalPerson } = req.body;

    // Validation
    if (!deptName || !focalPerson) {
      return res.status(400).json({ error: 'Both deptName and focalPerson are required fields.' });
    }

    const newDepartment = await prisma.department.create({
      data: {
        deptName,
        focalPerson,
      },
    });

    return res.status(201).json({
      message: 'Department created successfully',
      data: newDepartment,
    });
  } catch (error) {
    console.error('Error creating Department:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'A department with this name already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 2. Read All Departments
export const getAllDepartments = async (req, res) => {
  try {
    const departments = await prisma.department.findMany({
      orderBy: { deptName: 'asc' },
    });

    return res.status(200).json({
      success: true,
      count: departments.length,
      data: departments,
    });
  } catch (error) {
    console.error('Error fetching Departments:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 3. Read Department by ID
export const getDepartmentById = async (req, res) => {
  try {
    const { id } = req.params;

    const department = await prisma.department.findUnique({
      where: { id },
    });

    if (!department) {
      return res.status(404).json({ error: 'Department not found' });
    }

    return res.status(200).json({
      success: true,
      data: department,
    });
  } catch (error) {
    console.error('Error fetching Department by ID:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 4. Update / Edit a Department
export const updateDepartment = async (req, res) => {
  try {
    const { id } = req.params;
    const { deptName, focalPerson } = req.body;

    // Check if Department exists
    const existingDepartment = await prisma.department.findUnique({
      where: { id },
    });

    if (!existingDepartment) {
      return res.status(404).json({ error: 'Department not found' });
    }

    const updatedDepartment = await prisma.department.update({
      where: { id },
      data: {
        ...(deptName && { deptName }),
        ...(focalPerson && { focalPerson }),
      },
    });

    return res.status(200).json({
      message: 'Department updated successfully',
      data: updatedDepartment,
    });
  } catch (error) {
    console.error('Error updating Department:', error);
    if (error.code === 'P2002') {
      return res.status(409).json({ error: 'Another department with this name already exists.' });
    }
    return res.status(500).json({ error: 'Internal server error' });
  }
};

// 5. Delete a Department
export const deleteDepartment = async (req, res) => {
  try {
    const { id } = req.params;

    const existingDepartment = await prisma.department.findUnique({
      where: { id },
    });

    if (!existingDepartment) {
      return res.status(404).json({ error: 'Department not found' });
    }

    await prisma.department.delete({
      where: { id },
    });

    return res.status(200).json({
      message: 'Department deleted successfully',
    });
  } catch (error) {
    console.error('Error deleting Department:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};