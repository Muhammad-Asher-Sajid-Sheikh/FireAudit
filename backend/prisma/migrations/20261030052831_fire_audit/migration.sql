-- CreateTable
CREATE TABLE "FireExtinguisher" (
    "batchId" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "expiryDate" TIMESTAMP(3) NOT NULL,
    "isExpired" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FireExtinguisher_pkey" PRIMARY KEY ("batchId")
);
