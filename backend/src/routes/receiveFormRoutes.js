import { Router } from 'express';
import { 
  createReceiveForm, 
  getAllReceiveForms, 
  getReceiveFormById, 
  updateReceiveForm, 
  deleteReceiveForm 
} from '../controllers/receiveFormController.js';

const router = Router();

router.post('/', createReceiveForm);          // Create (Pending instructions)
router.get('/', getAllReceiveForms);          // Read All (Supports ?poId=xyz and ?ofId=abc filters)
router.get('/:id', getReceiveFormById);       // Read by ID
router.put('/:id', updateReceiveForm);        // Update (Pending instructions)
router.delete('/:id', deleteReceiveForm);     // Delete (Pending instructions)

export default router;