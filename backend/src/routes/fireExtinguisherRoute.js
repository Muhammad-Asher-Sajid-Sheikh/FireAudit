import { Router } from 'express';
import {
    createExtinguisher,
    getAllExtinguishers,
    getExtinguisherById,
    updateExtinguisher,
    deleteExtinguisher
} from '../controller/fireExtinguisherController.js';
// import { verifyToken } from '../middleware/authMiddleware.js'; // Optional: Use your auth middleware here

const router = Router();

// Apply auth middleware to protect these routes if needed (e.g., router.use(verifyToken))

router.post('/', createExtinguisher);
router.get('/', getAllExtinguishers);
router.get('/:id', getExtinguisherById);
router.put('/:id', updateExtinguisher);
router.delete('/:id', deleteExtinguisher);

export default router;