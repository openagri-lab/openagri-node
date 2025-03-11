-- CreateTable
CREATE TABLE "Greenhouse" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "Greenhouse_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Greenhouse_name_key" ON "Greenhouse"("name");
