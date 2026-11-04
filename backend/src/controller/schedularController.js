import { Queue, Worker, QueueEvents } from 'bullmq';
import {sendNotificationEmail} from '../services/mailer';

const connection = { 
  host: 'localhost', 
  port: 6379, 
  maxRetriesPerRequest: null 
};

const extinguisherQueue = new Queue('extinguisher-alerts', { connection });

const queueEvents = new QueueEvents('extinguisher-alerts', { connection });

export async function scheduleBatchAlert(batchId, expiryDate, isTestSeconds = false) {
  const jobId = `batch-alert-${batchId}`;

  // 1. CRITICAL: Remove any existing job with this ID so we don't get blocked by duplicates
  const existingJob = await extinguisherQueue.getJob(jobId);
  if (existingJob) {
    await existingJob.remove();
  }

  let delay;
  let alertTriggerTime;

  if (isTestSeconds) {
    delay = expiryDate * 1000; 
    alertTriggerTime = new Date(Date.now() + delay);
  } else {
    alertTriggerTime = new Date(expiryDate);
    alertTriggerTime.setDate(alertTriggerTime.getDate() - 7); 
    delay = alertTriggerTime.getTime() - Date.now();
  }

  console.log(`Scheduling alert for batch ${batchId} to trigger on ${alertTriggerTime} (in ${Math.round(delay / 1000)} seconds)`);

  if (delay > 0) {
    await extinguisherQueue.add(
      'send-extinguisher-warning',
      { batchId, expiryDate },
      {
        delay,
        jobId // Freshly replaced job ID
      }
    );
  }
  
  console.log(`Scheduler set for batch ${batchId}`);
}


export async function findBatchScheduler(batchId) {
  const jobId = `batch-alert-${batchId}`;
  const job = await extinguisherQueue.getJob(jobId);

  if (!job) {
    console.log(`No active schedule found for batch ${batchId}`);
    return null;
  }

  // Check job state (e.g., 'delayed', 'waiting', 'active', 'completed')
  const state = await job.getState();
  console.log(`Job found! State: ${state}, Timestamp: ${job.timestamp}`);
  return job;
}


export async function updateBatchExpiry(batchId, newExpiryDate) {
  const jobId = `batch-alert-${batchId}`;

  // Step 1: Find and remove the existing delayed job if it exists
  const existingJob = await extinguisherQueue.getJob(jobId);
  if (existingJob) {
    // If it's already delayed or waiting, remove it
    await existingJob.remove();
  }

  // Step 2: Calculate new delay based on updated expiry date
  const alertTriggerTime = new Date(newExpiryDate);
  alertTriggerTime.setDate(alertTriggerTime.getDate() - 7);
  const newDelay = alertTriggerTime.getTime() - Date.now();

  // Step 3: Re-add the job with the updated delay and same jobId
  if (newDelay > 0) {
    await extinguisherQueue.add(
      'send-extinguisher-warning',
      { batchId, expiryDate: newExpiryDate },
      {
        delay: newDelay,
        jobId: jobId // Keeps the same deterministic ID reference
      }
    );
    console.log(`Scheduler updated successfully for batch ${batchId}`);
  }
}


const extinguisherWorker = new Worker(
  'extinguisher-alerts', 
  async (job) => {
    // This block executes right when the delay timer hits zero
    const { batchId, expiryDate } = job.data;
    
    console.log(`[Execution Started] Processing expiration warning for batch: ${batchId}`);
    
    try {
      // Send the notification email
      await sendNotificationEmail("ashersajidpk2005@gmail.com", batchId, expiryDate);

      console.log(`[Success] Expiry alert successfully dispatched for batch ${batchId}`);
    } catch (error) {
      console.error(`[Error] Failed to process alert for batch ${batchId}:`, error);
      // Throwing an error here allows BullMQ to automatically retry the job if configured
      throw error; 
    }
  }, 
  { connection }
);
// Add these diagnostic listeners to your worker:
extinguisherWorker.on('ready', () => {
  console.log('✅ [Worker] Successfully connected to Redis and listening for jobs!');
});

extinguisherWorker.on('error', (err) => {
  console.error('❌ [Worker Error]', err);
});

extinguisherWorker.on('active', (job) => {
  console.log(`🔄 [Worker] Job ${job.id} has started processing...`);
});

extinguisherWorker.on('completed', (job) => {
  console.log(`✨ [Worker] Job ID ${job.id} finished successfully.`);
});

extinguisherWorker.on('failed', (job, err) => {
  console.log(`💥 [Worker] Job ID ${job?.id} failed with error: ${err.message}`);
});


queueEvents.on('delayed', ({ jobId }) => {
  console.log(`[QueueEvent] Job ${jobId} delay timer started.`);
});

queueEvents.on('waiting', ({ jobId }) => {
  console.log(`[QueueEvent] Job ${jobId} promoted to waiting queue!`);
});