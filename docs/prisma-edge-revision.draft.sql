-- CreateEnum
CREATE TYPE "CoffeeClass" AS ENUM ('good', 'shell', 'full_black', 'hull_husk', 'broken_chipped_cut', 'parchment', 'immature_unripe');

-- CreateEnum
CREATE TYPE "ImageType" AS ENUM ('source', 'crop');

-- DropForeignKey
ALTER TABLE "Detection" DROP CONSTRAINT "Detection_eventId_fkey";

-- DropForeignKey
ALTER TABLE "Measurement" DROP CONSTRAINT "Measurement_eventId_fkey";

-- DropIndex
DROP INDEX "DetectionEvent_batchId_capturedAt_idx";

-- DropIndex
DROP INDEX "DetectionEvent_lotId_capturedAt_idx";

-- DropIndex
DROP INDEX "DetectionEvent_deviceId_capturedAt_idx";

-- DropIndex
DROP INDEX "Detection_eventId_className_idx";

-- DropIndex
DROP INDEX "Detection_eventId_detectionId_key";

-- DropIndex
DROP INDEX "Measurement_batchId_measuredAt_idx";

-- DropIndex
DROP INDEX "Measurement_lotId_measuredAt_idx";

-- DropIndex
DROP INDEX "Measurement_eventId_idx";

-- AlterTable
ALTER TABLE "DetectionEvent" DROP COLUMN "capturedAt",
DROP COLUMN "classMapVersion",
DROP COLUMN "countScope",
DROP COLUMN "modelVersion",
DROP COLUMN "payloadFingerprint",
DROP COLUMN "processingStatus",
DROP COLUMN "receivedAt",
DROP COLUMN "schemaVersion",
DROP COLUMN "sourceImageHeight",
DROP COLUMN "sourceImageWidth",
ADD COLUMN     "createdAt" TIMESTAMPTZ(3) NOT NULL,
ADD COLUMN     "imageId" TEXT;

-- AlterTable
ALTER TABLE "Detection" DROP COLUMN "calibrationId",
DROP COLUMN "cropBytes",
DROP COLUMN "cropHeight",
DROP COLUMN "cropMimeType",
DROP COLUMN "cropObjectKey",
DROP COLUMN "cropSha256",
DROP COLUMN "cropWidth",
DROP COLUMN "eventId",
DROP COLUMN "modelClassId",
DROP COLUMN "sizeMethod",
DROP COLUMN "trackId",
ADD COLUMN     "cropImageId" TEXT NOT NULL,
ADD COLUMN     "imageId" TEXT,
DROP COLUMN "className",
ADD COLUMN     "className" "CoffeeClass" NOT NULL;

-- AlterTable
ALTER TABLE "Measurement" DROP COLUMN "calibrationId",
DROP COLUMN "eventId",
DROP COLUMN "kind",
DROP COLUMN "measuredAt",
DROP COLUMN "method",
DROP COLUMN "notes",
DROP COLUMN "receivedAt",
DROP COLUMN "sensorId",
DROP COLUMN "status",
DROP COLUMN "unit",
ADD COLUMN     "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- CreateTable
CREATE TABLE "LotImage" (
    "id" TEXT NOT NULL,
    "lotId" TEXT NOT NULL,
    "imageType" "ImageType" NOT NULL,
    "jpegBase64" TEXT NOT NULL,
    "detectionEventId" TEXT,
    "createdAt" TIMESTAMPTZ(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "LotImage_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "LotImage_lotId_createdAt_idx" ON "LotImage"("lotId", "createdAt");

-- CreateIndex
CREATE INDEX "LotImage_detectionEventId_idx" ON "LotImage"("detectionEventId");

-- CreateIndex
CREATE INDEX "DetectionEvent_batchId_createdAt_idx" ON "DetectionEvent"("batchId", "createdAt");

-- CreateIndex
CREATE INDEX "DetectionEvent_lotId_createdAt_idx" ON "DetectionEvent"("lotId", "createdAt");

-- CreateIndex
CREATE INDEX "DetectionEvent_deviceId_createdAt_idx" ON "DetectionEvent"("deviceId", "createdAt");

-- CreateIndex
CREATE INDEX "DetectionEvent_imageId_idx" ON "DetectionEvent"("imageId");

-- CreateIndex
CREATE UNIQUE INDEX "Detection_cropImageId_key" ON "Detection"("cropImageId");

-- CreateIndex
CREATE INDEX "Detection_imageId_className_idx" ON "Detection"("imageId", "className");

-- CreateIndex
CREATE INDEX "Measurement_batchId_createdAt_idx" ON "Measurement"("batchId", "createdAt");

-- CreateIndex
CREATE INDEX "Measurement_lotId_createdAt_idx" ON "Measurement"("lotId", "createdAt");

-- AddForeignKey
ALTER TABLE "LotImage" ADD CONSTRAINT "LotImage_lotId_fkey" FOREIGN KEY ("lotId") REFERENCES "Lot"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LotImage" ADD CONSTRAINT "LotImage_detectionEventId_fkey" FOREIGN KEY ("detectionEventId") REFERENCES "DetectionEvent"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DetectionEvent" ADD CONSTRAINT "DetectionEvent_imageId_fkey" FOREIGN KEY ("imageId") REFERENCES "LotImage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Detection" ADD CONSTRAINT "Detection_imageId_fkey" FOREIGN KEY ("imageId") REFERENCES "LotImage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Detection" ADD CONSTRAINT "Detection_cropImageId_fkey" FOREIGN KEY ("cropImageId") REFERENCES "LotImage"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
