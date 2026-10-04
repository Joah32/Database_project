-- MySQL dump 10.13  Distrib 8.4.11, for Linux (aarch64)
--
-- Host: localhost    Database: pantry
-- ------------------------------------------------------
-- Server version	8.4.11-0ubuntu0.26.04.1

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
-- Table structure for table `Batch`
--

DROP TABLE IF EXISTS `Batch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Batch` (
  `recipe_id` int unsigned NOT NULL,
  `batch_number` int unsigned NOT NULL,
  `batch_date` date NOT NULL,
  `scale_factor` decimal(4,2) NOT NULL DEFAULT '1.00',
  `outcome` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`recipe_id`,`batch_number`),
  CONSTRAINT `fk_batch_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `Recipe` (`recipe_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Batch`
--

LOCK TABLES `Batch` WRITE;
/*!40000 ALTER TABLE `Batch` DISABLE KEYS */;
INSERT INTO `Batch` VALUES (1,1,'2026-08-02',1.00,'Good spread, slightly overbaked at 12 minutes'),(1,2,'2026-08-16',2.00,'Double batch, needed a second pan, even bake'),(2,1,'2026-08-23',1.00,'Dense crumb, proofed too short'),(2,2,'2026-09-06',1.00,'Good rise and crust'),(3,1,'2026-09-13',0.50,'Half batch in a small loaf pan, moist');
/*!40000 ALTER TABLE `Batch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Equipment`
--

DROP TABLE IF EXISTS `Equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Equipment` (
  `equipment_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `equipment_type` varchar(50) NOT NULL,
  `size_or_capacity` varchar(50) NOT NULL,
  PRIMARY KEY (`equipment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Equipment`
--

LOCK TABLES `Equipment` WRITE;
/*!40000 ALTER TABLE `Equipment` DISABLE KEYS */;
INSERT INTO `Equipment` VALUES (1,'Half sheet pan','pan','18x13 in'),(2,'Loaf pan','pan','9x5 in'),(3,'Stand mixer','mixer','5 qt'),(4,'Digital scale','scale','5 kg'),(5,'Cooling rack','rack','12x17 in');
/*!40000 ALTER TABLE `Equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Ingredient`
--

DROP TABLE IF EXISTS `Ingredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Ingredient` (
  `ingredient_id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `category` varchar(50) NOT NULL,
  `base_unit` varchar(10) NOT NULL DEFAULT 'g',
  `contains_gluten` tinyint(1) NOT NULL,
  PRIMARY KEY (`ingredient_id`),
  UNIQUE KEY `uq_ingredient_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Ingredient`
--

LOCK TABLES `Ingredient` WRITE;
/*!40000 ALTER TABLE `Ingredient` DISABLE KEYS */;
INSERT INTO `Ingredient` VALUES (1,'All-purpose flour','flour','g',1),(2,'Granulated sugar','sweetener','g',0),(3,'Unsalted butter','dairy','g',0),(4,'Egg','dairy','g',0),(5,'Baking soda','leavening','g',0),(6,'Semisweet chocolate chips','chocolate','g',0),(7,'Active dry yeast','leavening','g',0),(8,'Salt','seasoning','g',0);
/*!40000 ALTER TABLE `Ingredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `PantryStock`
--

DROP TABLE IF EXISTS `PantryStock`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `PantryStock` (
  `stock_id` int unsigned NOT NULL AUTO_INCREMENT,
  `ingredient_id` int unsigned NOT NULL,
  `quantity_on_hand` decimal(10,2) NOT NULL,
  `storage_location` varchar(50) NOT NULL,
  `reorder_threshold` decimal(10,2) NOT NULL,
  PRIMARY KEY (`stock_id`),
  KEY `fk_stock_ingredient` (`ingredient_id`),
  CONSTRAINT `fk_stock_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `Ingredient` (`ingredient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `PantryStock`
--

LOCK TABLES `PantryStock` WRITE;
/*!40000 ALTER TABLE `PantryStock` DISABLE KEYS */;
INSERT INTO `PantryStock` VALUES (1,1,2500.00,'pantry',1000.00),(2,1,900.00,'freezer',0.00),(3,2,400.00,'pantry',500.00),(4,3,450.00,'fridge',250.00),(5,4,300.00,'fridge',200.00),(6,5,120.00,'pantry',50.00),(7,6,150.00,'pantry',200.00),(8,7,28.00,'fridge',14.00),(9,8,1000.00,'pantry',250.00);
/*!40000 ALTER TABLE `PantryStock` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Recipe`
--

DROP TABLE IF EXISTS `Recipe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Recipe` (
  `recipe_id` int unsigned NOT NULL AUTO_INCREMENT,
  `equipment_id` int unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `recipe_category` varchar(50) NOT NULL,
  `prep_time_min` smallint unsigned NOT NULL,
  `bake_time_min` smallint unsigned NOT NULL,
  `bake_temp_F` smallint unsigned NOT NULL,
  PRIMARY KEY (`recipe_id`),
  UNIQUE KEY `uq_recipe_name` (`name`),
  KEY `fk_recipe_equipment` (`equipment_id`),
  CONSTRAINT `fk_recipe_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `Equipment` (`equipment_id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Recipe`
--

LOCK TABLES `Recipe` WRITE;
/*!40000 ALTER TABLE `Recipe` DISABLE KEYS */;
INSERT INTO `Recipe` VALUES (1,1,'Chocolate chip cookies','cookie',20,11,375),(2,2,'Sandwich bread','bread',30,35,375),(3,2,'Vanilla pound cake','cake',25,60,325);
/*!40000 ALTER TABLE `Recipe` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RecipeIngredient`
--

DROP TABLE IF EXISTS `RecipeIngredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RecipeIngredient` (
  `recipe_id` int unsigned NOT NULL,
  `ingredient_id` int unsigned NOT NULL,
  `quantity_needed` decimal(10,2) NOT NULL,
  PRIMARY KEY (`recipe_id`,`ingredient_id`),
  KEY `fk_ri_ingredient` (`ingredient_id`),
  CONSTRAINT `fk_ri_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `Ingredient` (`ingredient_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_ri_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `Recipe` (`recipe_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RecipeIngredient`
--

LOCK TABLES `RecipeIngredient` WRITE;
/*!40000 ALTER TABLE `RecipeIngredient` DISABLE KEYS */;
INSERT INTO `RecipeIngredient` VALUES (1,1,280.00),(1,2,200.00),(1,3,227.00),(1,4,100.00),(1,5,4.00),(1,6,340.00),(1,8,5.00),(2,1,500.00),(2,2,15.00),(2,3,30.00),(2,7,7.00),(2,8,10.00),(3,1,300.00),(3,2,300.00),(3,3,227.00),(3,4,200.00),(3,8,3.00);
/*!40000 ALTER TABLE `RecipeIngredient` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-04 17:55:11
