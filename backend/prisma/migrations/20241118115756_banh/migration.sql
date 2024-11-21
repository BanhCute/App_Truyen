/*
  Warnings:

  - Added the required column `userId` to the `Novel` table without a default value. This is not possible if the table is not empty.
  - Added the required column `content` to the `Rating` table without a default value. This is not possible if the table is not empty.
  - Added the required column `isBanned` to the `User` table without a default value. This is not possible if the table is not empty.
  - Added the required column `isDeleted` to the `User` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Novel" ADD COLUMN     "userId" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "Rating" ADD COLUMN     "content" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "isBanned" BOOLEAN NOT NULL,
ADD COLUMN     "isDeleted" BOOLEAN NOT NULL;

-- AddForeignKey
ALTER TABLE "Novel" ADD CONSTRAINT "Novel_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
