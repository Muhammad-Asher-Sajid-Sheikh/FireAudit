import { Router } from 'express';
import {
  createPO, 
  getAllPOs, 
  getPOById, 
  updatePO
} from '../controller/fireExtinguisherController.js';
// import { verifyToken } from '../middleware/authMiddleware.js'; // Optional: Use your auth middleware here

const router = Router();

// Apply auth middleware to protect these routes if needed (e.g., router.use(verifyToken))

router.post('/', createPO);          // Create PO
router.get('/', getAllPOs);          // Read All POs
router.get('/:id', getPOById);       // Read PO by ID
router.put('/:id', updatePO);        // Edit PO by ID

export default router;