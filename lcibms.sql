-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: lcibms_database
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `menu_categories`
--

DROP TABLE IF EXISTS `menu_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_categories`
--

LOCK TABLES `menu_categories` WRITE;
/*!40000 ALTER TABLE `menu_categories` DISABLE KEYS */;
INSERT INTO `menu_categories` VALUES (1,'Foods','2026-04-25 09:15:12','2026-04-25 09:15:12'),(2,'Party Tray','2026-04-25 09:15:12','2026-04-25 09:15:12'),(3,'Waffles','2026-04-25 09:15:12','2026-04-25 09:15:12'),(4,'Coffee','2026-04-25 09:15:12','2026-04-25 09:15:12'),(5,'Non-Coffee','2026-04-25 09:15:12','2026-04-25 09:15:12'),(6,'Frappe','2026-04-25 09:15:12','2026-04-25 09:15:12'),(10,'Beer','2026-04-25 13:17:57','2026-04-25 13:17:57');
/*!40000 ALTER TABLE `menu_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_items`
--

DROP TABLE IF EXISTS `menu_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` text,
  `image_url` text,
  `price` decimal(10,2) DEFAULT '0.00',
  `is_available` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_category` (`category_id`),
  CONSTRAINT `fk_category` FOREIGN KEY (`category_id`) REFERENCES `menu_categories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_items`
--

LOCK TABLES `menu_items` WRITE;
/*!40000 ALTER TABLE `menu_items` DISABLE KEYS */;
INSERT INTO `menu_items` VALUES (1,1,'Chicken Burger','This is a description.','temp.png',199.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(2,1,'Cheese Burger','This is a description.','temp.png',199.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(3,1,'Hawaiian Burger','This is a description.','temp.png',199.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(4,2,'Barkada Platter','Good for 5ΓÇô6 persons.','temp.png',599.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(5,3,'Classic Waffle','Crispy golden waffle.','temp.png',149.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(6,3,'Choco Waffle','With rich chocolate drizzle.','temp.png',169.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(7,4,'Americano','Bold and smooth espresso.','temp.png',99.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(8,4,'Cappuccino','Espresso with steamed milk.','temp.png',119.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(9,5,'Matcha Latte','Premium Japanese matcha.','temp.png',129.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12'),(10,6,'Mocha Frappe','Chilled mocha bliss.','temp.png',139.00,1,'2026-04-25 09:15:12','2026-04-25 09:15:12');
/*!40000 ALTER TABLE `menu_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `firebase_uid` varchar(128) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `role` enum('admin','cashier','rider','customer') NOT NULL DEFAULT 'customer',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `profile_picture` text,
  `provider` varchar(20) DEFAULT 'email',
  PRIMARY KEY (`id`),
  UNIQUE KEY `firebase_uid` (`firebase_uid`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'gBqy8eecFggkWdD1ZsjX2nrlBE32','Admin','admin@gmail.com','admin','2026-04-15 05:52:07','2026-04-15 05:52:07',NULL,'email'),(2,'0BNQr0ULp9e6COsGXLJ6Q8eoUa73','Cashier','cashier@gmail.com','cashier','2026-04-15 05:52:07','2026-04-15 05:52:07',NULL,'email'),(3,'CaWVecyXF6VMbfl27asnnprxuDl2','Customer','customer@gmail.com','customer','2026-04-15 05:52:07','2026-04-15 05:52:07',NULL,'email'),(4,'nkKSjg1MXUR8bMOzUgvKor3Cdju1','Rider','rider@gmail.com','rider','2026-04-15 05:58:23','2026-04-15 05:58:23',NULL,'email'),(5,'ocrSqNxpSneFPS2s0LBEmchvcF02','Kelly Ydrhan Alojepan','kellyydrhan.alojepan@wvsu.edu.ph','customer','2026-04-21 04:44:02','2026-04-21 04:44:02',NULL,'email'),(6,'8OpG0RIemBZknJA0hdvlBXj8ORp2','Kelly Ydrhan Alojepan','kellyydrhan.alojepan@wvsu.edu.ph','customer','2026-04-23 19:41:58','2026-04-23 19:41:58','https://lh3.googleusercontent.com/a/ACg8ocKvVkeq3hTqQYAH32wYstz7zqh_QtE1GbFKH5tPg1GoCGWRpw=s96-c','google.com'),(7,'1CfFEKKrDYYOUeSBYaZK1DImTpF2','Kelly Ydrhan Alojepan','kellyydrhan.alojepan@wvsu.edu.ph','customer','2026-04-23 19:42:35','2026-04-23 19:42:35','https://lh3.googleusercontent.com/a/ACg8ocKvVkeq3hTqQYAH32wYstz7zqh_QtE1GbFKH5tPg1GoCGWRpw=s96-c','google.com'),(8,'t1Gw6mhGHVYnsx6LuLWhX3wTfPQ2','Kelly Ydrhan Alojepan','kellyydrhan.alojepan@wvsu.edu.ph','customer','2026-04-23 19:50:58','2026-04-23 19:50:58','https://lh3.googleusercontent.com/a/ACg8ocKvVkeq3hTqQYAH32wYstz7zqh_QtE1GbFKH5tPg1GoCGWRpw=s96-c','google.com'),(9,'GXSgCUXbgHcnO6eGT03vJktj3IS2','Kelly Ydrhan Alojepan','kellyydrhan@gmail.com','customer','2026-04-24 14:00:15','2026-04-24 14:00:15','https://graph.facebook.com/4289736464633442/picture','facebook.com'),(10,'pzJ3KTAtsvVHgWWBlyLibi8His52','Rbin','bearnezaarvin19@gmail.com','customer','2026-04-25 06:57:23','2026-04-25 06:57:23','https://lh3.googleusercontent.com/a/ACg8ocII9BxTrGH4tqahXtR_vN3oBF0kC0nzvuak3D_10s9_nKwXcxNJ=s96-c','google.com');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-25 21:35:02