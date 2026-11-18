import { Router } from 'express';
import { 
  createType, 
  getAllTypes, 
  getTypeById, 
  updateType, 
  deleteType 
} from '../controller/typesController.js';

const router = Router();

router.post('/', createType);          // Create Type
router.get('/', getAllTypes);          // Read All Types
router.get('/:id', getTypeById);       // Read Type by ID
router.put('/:id', updateType);        // Update Type by ID
router.delete('/:id', deleteType);     // Delete Type by ID

export default router;