-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: myschedule
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `id` int NOT NULL AUTO_INCREMENT,
  `date` datetime NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` text,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL,
  `color` varchar(20) NOT NULL,
  `email` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (36,'2026-03-09 00:00:00','ประชุม Google Meet','วิชา Project Management','08:00:00','12:00:00','#8db4b1','example@gmail.com'),(37,'2026-03-09 00:00:00','ออกกำลังกาย2','','16:00:00','17:00:00','#e91e63','example@gmail.com'),(38,'2026-03-10 00:00:00','รับเสื้อผ้าร้านรีด','ที่ร้านซักจัง ราคา 24 บาท','12:00:00','12:05:00','#2e671d','example@gmail.com'),(40,'2026-03-10 00:00:00','ทบทวนอ่านหนังสือ','','16:30:00','18:00:00','#e91e63','example@gmail.com'),(42,'2026-03-10 00:00:00','ดูหนัง','หนังเรื่อง Pacific Rim กับต้นกล้า','20:00:00','22:00:00','#2e671d','example@gmail.com'),(43,'2026-03-11 00:00:00','Eat Breakfast','','09:00:00','09:30:00','#8db4b1','example@gmail.com'),(44,'2026-03-11 00:00:00','Eat lunch','','12:00:00','12:15:00','#8db4b1','example@gmail.com'),(45,'2026-03-11 00:00:00','Eat Dinner','','18:00:00','18:05:00','#8db4b1','example@gmail.com'),(46,'2026-03-08 00:00:00','เที่ยววัดพระแก้ว','เดินทางด้วยbts อย่าลืมพกร่มไปด้วย','06:00:00','18:00:00','#e91e63','example@gmail.com'),(48,'2026-03-08 00:00:00','ซื้อของฝาก','ซื้อน้ำพริกให้แม่','18:00:00','18:05:00','#8db4b1','example@gmail.com'),(49,'2026-03-08 00:00:00','จ่ายค่าน้ำ','','20:00:00','21:00:00','#2e671d','example@gmail.com'),(50,'2026-03-07 00:00:00','จ่ายค่าไฟ','','09:00:00','10:00:00','#e91e63','example@gmail.com'),(52,'2026-03-07 00:00:00','จ่ายค่าหอ','','09:00:00','10:00:00','#e91e63','example@gmail.com'),(53,'2026-03-07 00:00:00','ซื้อของตุนเข้าหอ','','15:00:00','16:00:00','#8db4b1','example@gmail.com'),(54,'2026-03-08 00:00:00','ทำความสะอาดห้องน้ำ','','22:00:00','23:00:00','#e91e63','example@gmail.com'),(55,'2026-03-05 00:00:00','ทำงานกลุ่ม','วิชาmobile app ','16:00:00','18:00:00','#e91e63','example@gmail.com'),(56,'2026-03-05 00:00:00','ทำรายงาน','วิชาภาษาอังกฤษ','19:20:00','21:40:00','#8db4b1','example@gmail.com'),(57,'2026-03-05 00:00:00','ทิ้งขยะ','ก่อนนอน ลงไปทิ้งขยะด้วย','23:00:00','23:05:00','#8db4b1','example@gmail.com'),(58,'2026-03-06 00:00:00','วิ่ง','วิ่ง 5 โล','09:00:00','10:00:00','#2e671d','example@gmail.com'),(59,'2026-03-06 00:00:00','ถูพื้น','','20:00:00','20:20:00','#8db4b1','example@gmail.com'),(60,'2026-03-06 00:00:00','กวาดห้อง','','21:50:00','22:00:00','#8db4b1','example@gmail.com'),(61,'2026-03-09 00:00:00','วิ่งออกกำลังกาย','วิ่ง 10 โล','17:00:00','18:15:00','#2e671d','example2@gmail.com'),(62,'2026-03-09 00:00:00','ล้างจาน','','20:00:00','22:00:00','#8db4b1','example2@gmail.com'),(63,'2026-03-09 00:00:00','นอน','','23:00:00','23:59:00','#8db4b1','example2@gmail.com'),(64,'2026-03-10 00:00:00','ทำการบ้าน','','09:00:00','10:00:00','#e91e63','example2@gmail.com'),(65,'2026-03-09 00:00:00','ออกกำลังกายเพื่อสุขภาพ','','09:00:00','10:00:00','#2e671d','example2@gmail.com'),(66,'2026-03-10 00:00:00','ซื้อขนมตุนเข้าหอ','','09:00:00','10:00:00','#8db4b1','example2@gmail.com'),(67,'2026-03-10 00:00:00','ไปดูนิทรรศกาล','','09:00:00','10:00:00','#2e671d','example2@gmail.com'),(68,'2026-03-08 00:00:00','ทานอาหารกับครอบครัว','ที่ร้านประจำ ที่เดิม','09:00:00','10:00:00','#e91e63','example2@gmail.com'),(69,'2026-03-09 00:00:00','ซื้อเสื้อผ้า','','09:00:00','10:00:00','#8db4b1','example2@gmail.com'),(70,'2026-03-08 00:00:00','ไปเที่ยว','กับแฟน ที่ห้าง icon siam','09:00:00','10:00:00','#8db4b1','example2@gmail.com'),(71,'2026-03-12 00:00:00','eat icecream','','09:00:00','10:00:00','#2e671d','example@gmail.com');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_credentials`
--

DROP TABLE IF EXISTS `user_credentials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_credentials` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_UNIQUE` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_credentials`
--

LOCK TABLES `user_credentials` WRITE;
/*!40000 ALTER TABLE `user_credentials` DISABLE KEYS */;
INSERT INTO `user_credentials` VALUES (2,'example@gmail.com','$2b$10$V.w4JoOoguovvQPH.Xd0SOs4b78hS44xBOT8bjTF1xfmMr3.t3Dce'),(3,'abc@gmail.com','$2b$10$bCl8IlwIWjur0isCTCv.1.ILHN1ApoitaGFFv..hUwLZq8NTK9r2.'),(4,'example2@gmail.com','$2b$10$JiekE.c73yNe402e/vhCZOMHXyPtxJ/QKqgvg13vERWqkEPJyua5S');
/*!40000 ALTER TABLE `user_credentials` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-09  2:12:07
