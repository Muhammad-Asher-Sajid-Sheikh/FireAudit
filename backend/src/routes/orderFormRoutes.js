import { Router } from 'express';
import { 
  createOrderForm, 
  getAllOrderForms, 
  getOrderFormById, 
  updateOrderForm, 
  deleteOrderForm 
} from '../controllers/orderFormController.js';

const router = Router();

router.post('/', createOrderForm);          // Create Order Form
router.get('/', getAllOrderForms);          // Read All Order Forms (Supports ?poId=xyz filter)
router.get('/:id', getOrderFormById);       // Read Order Form by ID
router.put('/:id', updateOrderForm);        // Update Order Form by ID
router.delete('/:id', deleteOrderForm);     // Delete Order Form by ID

export default router;