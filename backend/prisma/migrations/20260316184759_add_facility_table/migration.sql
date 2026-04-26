-- CreateTable
CREATE TABLE "Facility" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "imageUrl" TEXT,
    "capacityMin" INTEGER,
    "capacityMax" INTEGER,
    "openTime" TEXT,
    "closeTime" TEXT,
    "description" TEXT,

    CONSTRAINT "Facility_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Reservation" (
    "id" SERIAL NOT NULL,
    "bookingCode" TEXT NOT NULL,
    "residentId" INTEGER NOT NULL,
    "facilityId" INTEGER NOT NULL,
    "startTime" TIMESTAMP(3) NOT NULL,
    "endTime" TIMESTAMP(3) NOT NULL,
    "pax" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'CONFIRMED',
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Reservation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Reservation_bookingCode_key" ON "Reservation"("bookingCode");

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_residentId_fkey" FOREIGN KEY ("residentId") REFERENCES "Resident"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Reservation" ADD CONSTRAINT "Reservation_facilityId_fkey" FOREIGN KEY ("facilityId") REFERENCES "Facility"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
