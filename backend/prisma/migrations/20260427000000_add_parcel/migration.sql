-- CreateEnum
CREATE TYPE "ParcelStatus" AS ENUM ('ARRIVED', 'PICKED_UP', 'RETURNED');

-- CreateTable
CREATE TABLE "Parcel" (
    "id" SERIAL NOT NULL,
    "trackingNumber" TEXT NOT NULL,
    "carrier" TEXT NOT NULL,
    "unitNumber" TEXT NOT NULL,
    "storageLocation" TEXT,
    "photoUrl" TEXT,
    "status" "ParcelStatus" NOT NULL DEFAULT 'ARRIVED',
    "arrivedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "pickedUpAt" TIMESTAMP(3),
    "returnedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Parcel_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Parcel_trackingNumber_key" ON "Parcel"("trackingNumber");

-- CreateIndex
CREATE INDEX "Parcel_unitNumber_idx" ON "Parcel"("unitNumber");

-- CreateIndex
CREATE INDEX "Parcel_status_idx" ON "Parcel"("status");
