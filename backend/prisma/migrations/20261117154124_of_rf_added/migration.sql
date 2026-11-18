-- CreateTable
CREATE TABLE "OrderForm" (
    "id" TEXT NOT NULL,
    "poId" TEXT NOT NULL,
    "foType" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "location" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "OrderForm_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RecieveForm" (
    "id" TEXT NOT NULL,
    "poId" TEXT NOT NULL,
    "ofId" TEXT NOT NULL,
    "foType" TEXT NOT NULL,
    "unit" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL,
    "date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RecieveForm_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "OrderForm" ADD CONSTRAINT "OrderForm_poId_fkey" FOREIGN KEY ("poId") REFERENCES "PurchaseOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RecieveForm" ADD CONSTRAINT "RecieveForm_poId_fkey" FOREIGN KEY ("poId") REFERENCES "PurchaseOrder"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RecieveForm" ADD CONSTRAINT "RecieveForm_ofId_fkey" FOREIGN KEY ("ofId") REFERENCES "OrderForm"("id") ON DELETE CASCADE ON UPDATE CASCADE;
