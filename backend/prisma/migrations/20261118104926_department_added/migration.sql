-- CreateTable
CREATE TABLE "Department" (
    "id" TEXT NOT NULL,
    "deptName" TEXT NOT NULL,
    "focalPerson" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Department_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Department_deptName_key" ON "Department"("deptName");
