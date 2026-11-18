import { Router } from 'express';
import { 
  createDepartment, 
  getAllDepartments, 
  getDepartmentById, 
  updateDepartment, 
  deleteDepartment 
} from '../controllers/departmentController.js';

const router = Router();

router.post('/', createDepartment);          // Create Department
router.get('/', getAllDepartments);          // Read All Departments
router.get('/:id', getDepartmentById);       // Read Department by ID
router.put('/:id', updateDepartment);        // Update Department by ID
router.delete('/:id', deleteDepartment);     // Delete Department by ID

export default router;