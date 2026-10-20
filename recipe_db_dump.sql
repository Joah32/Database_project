-- MySQL dump 10.13  Distrib 8.4.11, for Linux (aarch64)
--
-- Host: localhost    Database: recipe_db
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Ingredient`
--

LOCK TABLES `Ingredient` WRITE;
/*!40000 ALTER TABLE `Ingredient` DISABLE KEYS */;
INSERT INTO `Ingredient` VALUES (1,'All-purpose flour','flour','g',1),(2,'Granulated sugar','sweetener','g',0),(3,'Unsalted butter','dairy','g',0),(4,'Egg','dairy','g',0),(5,'Baking soda','leavening','g',0),(6,'Chocolate chips','chocolate','g',0),(7,'Active dry yeast','leavening','g',0),(8,'Salt','seasoning','g',0),(9,'Brown Sugar','sugar','g',0);
/*!40000 ALTER TABLE `Ingredient` ENABLE KEYS */;
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
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_recipe_before_delete` BEFORE DELETE ON `Recipe` FOR EACH ROW DELETE FROM StepIngredient WHERE recipe_id = OLD.recipe_id */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `RecipeIngredient`
--

DROP TABLE IF EXISTS `RecipeIngredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RecipeIngredient` (
  `recipe_id` int unsigned NOT NULL,
  `ingredient_id` int unsigned NOT NULL,
  PRIMARY KEY (`recipe_id`,`ingredient_id`),
  KEY `fk_ri_ingredient` (`ingredient_id`),
  CONSTRAINT `fk_recipeingredient_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `Ingredient` (`ingredient_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_recipeingredient_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `Recipe` (`recipe_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RecipeIngredient`
--

LOCK TABLES `RecipeIngredient` WRITE;
/*!40000 ALTER TABLE `RecipeIngredient` DISABLE KEYS */;
INSERT INTO `RecipeIngredient` VALUES (1,1),(2,1),(3,1),(1,2),(2,2),(3,2),(1,3),(2,3),(3,3),(1,4),(3,4),(1,5),(1,6),(2,7),(1,8),(2,8),(3,8);
/*!40000 ALTER TABLE `RecipeIngredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `RecipeStep`
--

DROP TABLE IF EXISTS `RecipeStep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `RecipeStep` (
  `recipe_id` int unsigned NOT NULL,
  `step_number` smallint unsigned NOT NULL,
  `instruction` varchar(1000) NOT NULL,
  `duration_min` smallint unsigned DEFAULT NULL,
  `target_temp_F` smallint unsigned DEFAULT NULL,
  `equipment_id` int unsigned DEFAULT NULL,
  `is_make_ahead` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`recipe_id`,`step_number`),
  KEY `fk_recipestep_equipment` (`equipment_id`),
  CONSTRAINT `fk_recipestep_equipment` FOREIGN KEY (`equipment_id`) REFERENCES `Equipment` (`equipment_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_recipestep_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `Recipe` (`recipe_id`) ON DELETE CASCADE,
  CONSTRAINT `chk_recipestep_duration` CHECK (((`duration_min` is null) or (`duration_min` > 0))),
  CONSTRAINT `chk_recipestep_step_number` CHECK ((`step_number` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `RecipeStep`
--

LOCK TABLES `RecipeStep` WRITE;
/*!40000 ALTER TABLE `RecipeStep` DISABLE KEYS */;
INSERT INTO `RecipeStep` VALUES (1,1,'Step 1',NULL,NULL,NULL,0),(1,2,'Step 2',NULL,NULL,NULL,0),(1,3,'Step 3',NULL,NULL,NULL,0),(2,1,'Step 1',NULL,NULL,NULL,0),(2,2,'Step 2',NULL,NULL,NULL,0),(2,3,'Step 3',NULL,NULL,NULL,0),(3,1,'Step 1',NULL,NULL,NULL,0),(3,2,'Step 2',NULL,NULL,NULL,0),(3,3,'Step 3',NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `RecipeStep` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `StepIngredient`
--

DROP TABLE IF EXISTS `StepIngredient`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `StepIngredient` (
  `recipe_id` int unsigned NOT NULL,
  `step_number` smallint unsigned NOT NULL,
  `ingredient_id` int unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  PRIMARY KEY (`recipe_id`,`step_number`,`ingredient_id`),
  KEY `fk_stepingredient_recipeingredient` (`recipe_id`,`ingredient_id`),
  CONSTRAINT `fk_stepingredient_recipeingredient` FOREIGN KEY (`recipe_id`, `ingredient_id`) REFERENCES `RecipeIngredient` (`recipe_id`, `ingredient_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_stepingredient_step` FOREIGN KEY (`recipe_id`, `step_number`) REFERENCES `RecipeStep` (`recipe_id`, `step_number`) ON DELETE CASCADE,
  CONSTRAINT `chk_stepingredient_quantity` CHECK ((`quantity` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `StepIngredient`
--

LOCK TABLES `StepIngredient` WRITE;
/*!40000 ALTER TABLE `StepIngredient` DISABLE KEYS */;
INSERT INTO `StepIngredient` VALUES (1,1,1,280.00),(1,1,2,200.00),(1,1,3,227.00),(1,1,4,100.00),(1,1,5,4.00),(1,1,6,340.00),(1,1,8,5.00),(2,1,1,500.00),(2,1,2,15.00),(2,1,3,30.00),(2,1,7,7.00),(2,1,8,10.00),(3,1,1,300.00),(3,1,2,300.00),(3,1,3,227.00),(3,1,4,200.00),(3,1,8,3.00);
/*!40000 ALTER TABLE `StepIngredient` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `recipe_ingredient_total`
--

DROP TABLE IF EXISTS `recipe_ingredient_total`;
/*!50001 DROP VIEW IF EXISTS `recipe_ingredient_total`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `recipe_ingredient_total` AS SELECT 
 1 AS `recipe_id`,
 1 AS `ingredient_id`,
 1 AS `total_quantity`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'recipe_db'
--

--
-- Final view structure for view `recipe_ingredient_total`
--

/*!50001 DROP VIEW IF EXISTS `recipe_ingredient_total`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `recipe_ingredient_total` AS select `ri`.`recipe_id` AS `recipe_id`,`ri`.`ingredient_id` AS `ingredient_id`,sum(`si`.`quantity`) AS `total_quantity` from (`RecipeIngredient` `ri` left join `StepIngredient` `si` on(((`si`.`recipe_id` = `ri`.`recipe_id`) and (`si`.`ingredient_id` = `ri`.`ingredient_id`)))) group by `ri`.`recipe_id`,`ri`.`ingredient_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-19 18:27:26
