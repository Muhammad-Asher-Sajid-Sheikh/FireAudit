-- CreateTable
CREATE TABLE "Types" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "specialInstructions" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Types_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Types_name_key" ON "Types"("name");
