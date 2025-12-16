-- MySQL dump 10.13  Distrib 9.3.0, for macos15.2 (arm64)
--
-- Host: localhost    Database: mrbs
-- ------------------------------------------------------
-- Server version	9.3.0

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
-- Table structure for table `mrbs_area`
--

DROP TABLE IF EXISTS `mrbs_area`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_area` (
  `id` int NOT NULL AUTO_INCREMENT,
  `disabled` tinyint NOT NULL DEFAULT '0',
  `area_name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_key` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `timezone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `area_admin_email` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `resolution` int DEFAULT NULL,
  `default_duration` int DEFAULT NULL,
  `default_duration_all_day` tinyint NOT NULL DEFAULT '0',
  `morningstarts` int DEFAULT NULL,
  `morningstarts_minutes` int DEFAULT NULL,
  `eveningends` int DEFAULT NULL,
  `eveningends_minutes` int DEFAULT NULL,
  `private_enabled` tinyint DEFAULT NULL,
  `private_default` tinyint DEFAULT NULL,
  `private_mandatory` tinyint DEFAULT NULL,
  `private_override` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `min_create_ahead_enabled` tinyint DEFAULT NULL,
  `min_create_ahead_secs` int DEFAULT NULL,
  `max_create_ahead_enabled` tinyint DEFAULT NULL,
  `max_create_ahead_secs` int DEFAULT NULL,
  `min_delete_ahead_enabled` tinyint DEFAULT NULL,
  `min_delete_ahead_secs` int DEFAULT NULL,
  `max_delete_ahead_enabled` tinyint DEFAULT NULL,
  `max_delete_ahead_secs` int DEFAULT NULL,
  `max_per_day_enabled` tinyint NOT NULL DEFAULT '0',
  `max_per_day` int NOT NULL DEFAULT '0',
  `max_per_week_enabled` tinyint NOT NULL DEFAULT '0',
  `max_per_week` int NOT NULL DEFAULT '0',
  `max_per_month_enabled` tinyint NOT NULL DEFAULT '0',
  `max_per_month` int NOT NULL DEFAULT '0',
  `max_per_year_enabled` tinyint NOT NULL DEFAULT '0',
  `max_per_year` int NOT NULL DEFAULT '0',
  `max_per_future_enabled` tinyint NOT NULL DEFAULT '0',
  `max_per_future` int NOT NULL DEFAULT '0',
  `max_secs_per_day_enabled` tinyint NOT NULL DEFAULT '0',
  `max_secs_per_day` int NOT NULL DEFAULT '0',
  `max_secs_per_week_enabled` tinyint NOT NULL DEFAULT '0',
  `max_secs_per_week` int NOT NULL DEFAULT '0',
  `max_secs_per_month_enabled` tinyint NOT NULL DEFAULT '0',
  `max_secs_per_month` int NOT NULL DEFAULT '0',
  `max_secs_per_year_enabled` tinyint NOT NULL DEFAULT '0',
  `max_secs_per_year` int NOT NULL DEFAULT '0',
  `max_secs_per_future_enabled` tinyint NOT NULL DEFAULT '0',
  `max_secs_per_future` int NOT NULL DEFAULT '0',
  `max_duration_enabled` tinyint NOT NULL DEFAULT '0',
  `max_duration_secs` int NOT NULL DEFAULT '0',
  `max_duration_periods` int NOT NULL DEFAULT '0',
  `custom_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approval_enabled` tinyint DEFAULT NULL,
  `reminders_enabled` tinyint DEFAULT NULL,
  `enable_periods` tinyint DEFAULT NULL,
  `periods` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `confirmation_enabled` tinyint DEFAULT NULL,
  `confirmed_default` tinyint DEFAULT NULL,
  `times_along_top` tinyint NOT NULL DEFAULT '0',
  `default_type` char(1) NOT NULL DEFAULT 'E',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_area_name` (`area_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_area`
--

LOCK TABLES `mrbs_area` WRITE;
/*!40000 ALTER TABLE `mrbs_area` DISABLE KEYS */;
INSERT INTO `mrbs_area` VALUES (1,0,'Area52','Area52','Europe/Berlin',NULL,1800,3600,0,7,0,18,30,0,0,0,'none',0,0,0,604800,0,0,0,604800,0,1,0,5,0,10,0,50,0,100,0,7200,0,36000,0,90000,0,360000,0,360000,0,7200,2,NULL,0,1,0,'[\"Period 1\",\"Period 2\"]',1,1,0,'I');
/*!40000 ALTER TABLE `mrbs_area` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_entry`
--

DROP TABLE IF EXISTS `mrbs_entry`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_entry` (
  `id` int NOT NULL AUTO_INCREMENT,
  `start_time` int NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `end_time` int NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `entry_type` int NOT NULL DEFAULT '0',
  `repeat_id` int DEFAULT NULL,
  `room_id` int NOT NULL DEFAULT '1',
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `modified_by` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `type` char(1) NOT NULL DEFAULT 'E',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint unsigned NOT NULL DEFAULT '0',
  `reminded` int DEFAULT NULL,
  `info_time` int DEFAULT NULL,
  `info_user` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `info_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ical_uid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `ical_sequence` smallint NOT NULL DEFAULT '0',
  `ical_recur_id` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `allow_registration` tinyint NOT NULL DEFAULT '0',
  `registrant_limit` int NOT NULL DEFAULT '0',
  `registrant_limit_enabled` tinyint NOT NULL DEFAULT '1',
  `registration_opens` int NOT NULL DEFAULT '1209600' COMMENT 'Seconds before the start time',
  `registration_opens_enabled` tinyint NOT NULL DEFAULT '0',
  `registration_closes` int NOT NULL DEFAULT '0' COMMENT 'Seconds before the start_time',
  `registration_closes_enabled` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `repeat_id` (`repeat_id`),
  KEY `idxStartTime` (`start_time`),
  KEY `idxEndTime` (`end_time`),
  KEY `idxRoomStartEnd` (`room_id`,`start_time`,`end_time`),
  CONSTRAINT `mrbs_entry_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `mrbs_room` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `mrbs_entry_ibfk_2` FOREIGN KEY (`repeat_id`) REFERENCES `mrbs_repeat` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_entry`
--

LOCK TABLES `mrbs_entry` WRITE;
/*!40000 ALTER TABLE `mrbs_entry` DISABLE KEYS */;
INSERT INTO `mrbs_entry` VALUES (1,1739007000,1739010600,0,NULL,1,'2025-02-08 16:09:44','user1','','New Booking','I','',0,NULL,NULL,NULL,NULL,'MRBS-67a781c873e6b-bc5ee809@localhost',0,NULL,0,0,0,1209600,0,0,0),(2,1740925800,1740929400,0,NULL,1,'2025-03-02 13:57:22','user1','','Foo','I','',0,NULL,NULL,NULL,NULL,'MRBS-67c463c2a69ac-563af5ce@localhost',0,NULL,0,0,0,1209600,0,0,0),(3,1751716800,1751720400,0,NULL,1,'2025-07-05 12:00:57','user1','','asf','I','ads',0,NULL,NULL,NULL,NULL,'MRBS-686913f92b02d-35159257@localhost',0,NULL,0,0,0,1209600,0,0,0),(5,1751724000,1751727600,0,NULL,1,'2025-07-05 14:03:57','user1','','16','I','16',0,NULL,NULL,NULL,NULL,'MRBS-686930cdc19d4-2972f589@localhost',0,NULL,0,0,0,1209600,0,0,0),(6,1751729400,1751731200,0,NULL,1,'2025-07-05 15:31:08','user1','','Asd','I','asd',0,NULL,NULL,NULL,NULL,'MRBS-6869453caf419-728a6f20@localhost',0,NULL,0,0,0,1209600,0,0,0),(7,1751727600,1751729400,0,NULL,1,'2025-07-05 15:31:18','user1','','as','I','sdas',0,NULL,NULL,NULL,NULL,'MRBS-6869454687ebb-e7faab61@localhost',0,NULL,0,0,0,1209600,0,0,0),(8,1751733000,1751734800,0,NULL,3,'2025-07-05 16:50:01','admin','','asd','I','ads',0,NULL,NULL,NULL,NULL,'MRBS-686957b99383b-6cc901df@localhost',0,NULL,0,0,1,1209600,0,0,0),(9,1751812200,1751815800,0,NULL,1,'2025-07-06 14:46:23','admin','','Example Booking','I','',0,NULL,NULL,NULL,NULL,'MRBS-686a8c3f1c5da-c7d7f339@localhost',0,NULL,0,0,1,1209600,0,0,0),(10,1751812200,1751815800,0,NULL,3,'2025-07-06 14:47:20','user1','','Example Booking','I','',0,NULL,NULL,NULL,NULL,'MRBS-686a8c78235dd-15ea7660@localhost',0,NULL,0,0,0,1209600,0,0,0),(11,1761231600,1761238800,0,NULL,1,'2025-10-23 15:16:23','admin','','ad','I','',0,NULL,NULL,NULL,NULL,'MRBS-68fa46c72baaf-171a329c@localhost',0,NULL,0,0,1,1209600,0,0,0);
/*!40000 ALTER TABLE `mrbs_entry` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_participants`
--

DROP TABLE IF EXISTS `mrbs_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_participants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `entry_id` int NOT NULL,
  `username` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `create_by` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `registered` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_entryid_username` (`entry_id`,`username`),
  CONSTRAINT `mrbs_participants_ibfk_1` FOREIGN KEY (`entry_id`) REFERENCES `mrbs_entry` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_participants`
--

LOCK TABLES `mrbs_participants` WRITE;
/*!40000 ALTER TABLE `mrbs_participants` DISABLE KEYS */;
/*!40000 ALTER TABLE `mrbs_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_repeat`
--

DROP TABLE IF EXISTS `mrbs_repeat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_repeat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `start_time` int NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `end_time` int NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `rep_type` int NOT NULL DEFAULT '0',
  `end_date` int NOT NULL DEFAULT '0' COMMENT 'Unix timestamp',
  `rep_opt` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `room_id` int NOT NULL DEFAULT '1',
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `create_by` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `modified_by` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `type` char(1) NOT NULL DEFAULT 'E',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `rep_interval` smallint NOT NULL DEFAULT '1',
  `month_absolute` smallint DEFAULT NULL,
  `month_relative` varchar(4) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint unsigned NOT NULL DEFAULT '0',
  `reminded` int DEFAULT NULL,
  `info_time` int DEFAULT NULL,
  `info_user` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `info_text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `ical_uid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `ical_sequence` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `mrbs_repeat_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `mrbs_room` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_repeat`
--

LOCK TABLES `mrbs_repeat` WRITE;
/*!40000 ALTER TABLE `mrbs_repeat` DISABLE KEYS */;
/*!40000 ALTER TABLE `mrbs_repeat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_room`
--

DROP TABLE IF EXISTS `mrbs_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_room` (
  `id` int NOT NULL AUTO_INCREMENT,
  `disabled` tinyint NOT NULL DEFAULT '0',
  `area_id` int NOT NULL DEFAULT '0',
  `room_name` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `sort_key` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `capacity` int NOT NULL DEFAULT '0',
  `room_admin_email` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `invalid_types` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'JSON encoded',
  `custom_html` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_room_name` (`area_id`,`room_name`),
  KEY `idxSortKey` (`sort_key`),
  CONSTRAINT `mrbs_room_ibfk_1` FOREIGN KEY (`area_id`) REFERENCES `mrbs_area` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_room`
--

LOCK TABLES `mrbs_room` WRITE;
/*!40000 ALTER TABLE `mrbs_room` DISABLE KEYS */;
INSERT INTO `mrbs_room` VALUES (1,0,1,'Room One','002A20C9AEDCC9','',0,'','[]',NULL),(2,0,1,'Room Two','Room Two','',0,'',NULL,NULL),(3,0,1,'Room Three','Room Three','Foo',23,'',NULL,NULL);
/*!40000 ALTER TABLE `mrbs_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_sessions`
--

DROP TABLE IF EXISTS `mrbs_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_sessions` (
  `id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `access` int unsigned DEFAULT NULL COMMENT 'Unix timestamp',
  `data` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `idxAccess` (`access`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_sessions`
--

LOCK TABLES `mrbs_sessions` WRITE;
/*!40000 ALTER TABLE `mrbs_sessions` DISABLE KEYS */;
INSERT INTO `mrbs_sessions` VALUES ('23db88a7cb344ef7d6bfd2aaca517f80',1751814004,'last_page|s:70:\"/favicon.ico?view=day&view_all=1&year=2025&month=7&day=6&area=1&room=3\";this_page|s:12:\"/favicon.ico\";csrf_token|s:64:\"9cd20b99b52db97941b794ffaafa3a366204b88ade52df3a746d317ef53cafb5\";user|O:9:\"MRBS\\User\":5:{s:8:\"username\";s:5:\"user1\";s:12:\"display_name\";s:13:\"User Usermann\";s:5:\"email\";s:12:\"affe@affe.de\";s:5:\"level\";i:1;s:7:\"\0*\0data\";a:6:{s:2:\"id\";i:2;s:13:\"password_hash\";s:60:\"$2y$12$VN05xy.OlrRAGY.GlEDcXOOtw.QlUe6gZDi/X7RCcy4eK.1MX9oz.\";s:9:\"timestamp\";s:19:\"2025-07-05 17:37:56\";s:10:\"last_login\";i:1751813217;s:14:\"reset_key_hash\";N;s:16:\"reset_key_expiry\";i:0;}}'),('4ea4080ba5daf3ff0b623f9544ea01a6',1739030985,'last_page|s:77:\"/index.php?view=day&view_all=1&year=2025&month=2&day=8&area=1&room=1&top=11.5\";this_page|s:60:\"/view_entry.php?view=day&year=2025&month=2&day=8&area=1&id=1\";csrf_token|s:64:\"97d37ec02737db032264b9a1fb0561a4903bb4f00677dc607acb294bcf2419c9\";user|O:9:\"MRBS\\User\":5:{s:8:\"username\";s:5:\"user1\";s:12:\"display_name\";s:5:\"user1\";s:5:\"email\";s:0:\"\";s:5:\"level\";i:1;s:7:\"\0*\0data\";a:6:{s:2:\"id\";i:2;s:13:\"password_hash\";s:60:\"$2y$12$VN05xy.OlrRAGY.GlEDcXOOtw.QlUe6gZDi/X7RCcy4eK.1MX9oz.\";s:9:\"timestamp\";s:19:\"2025-02-08 17:05:20\";s:10:\"last_login\";i:1739030814;s:14:\"reset_key_hash\";N;s:16:\"reset_key_expiry\";i:0;}}'),('7c4a7852d909dee7ee063ff83da099b5',1740938653,'last_page|s:15:\"/view_entry.php\";this_page|s:12:\"/favicon.ico\";csrf_token|s:64:\"80fd103b3dc812085c3c6f46ef1462ed35a7e94aa0bb2b0a83a24a42f94fd7ca\";user|O:9:\"MRBS\\User\":5:{s:8:\"username\";s:5:\"user1\";s:12:\"display_name\";s:5:\"user1\";s:5:\"email\";s:0:\"\";s:5:\"level\";i:1;s:7:\"\0*\0data\";a:6:{s:2:\"id\";i:2;s:13:\"password_hash\";s:60:\"$2y$12$VN05xy.OlrRAGY.GlEDcXOOtw.QlUe6gZDi/X7RCcy4eK.1MX9oz.\";s:9:\"timestamp\";s:19:\"2025-02-08 17:05:20\";s:10:\"last_login\";i:1740923833;s:14:\"reset_key_hash\";N;s:16:\"reset_key_expiry\";i:0;}}'),('a1866f63aa956e6dcb7f45a4cfb4f7f6',1761232583,'last_page|s:23:\"/edit_entry_handler.php\";this_page|s:70:\"/index.php?view=day&view_all=1&year=2025&month=10&day=23&area=1&room=1\";csrf_token|s:64:\"d7da92835e629d0d807fe14a0ece48e951bc70b3692486fb7474c3c01e5461fe\";user|O:9:\"MRBS\\User\":5:{s:8:\"username\";s:5:\"admin\";s:12:\"display_name\";s:5:\"admin\";s:5:\"email\";s:15:\"admin@admin.foo\";s:5:\"level\";i:2;s:7:\"\0*\0data\";a:6:{s:2:\"id\";i:1;s:13:\"password_hash\";s:60:\"$2y$12$tU2FeyXWsxdwvLD3zWLQA.JjeodZb4HuDPK1T9o81Erl/cwmK8/OC\";s:9:\"timestamp\";s:19:\"2025-02-08 17:04:55\";s:10:\"last_login\";i:1761232552;s:14:\"reset_key_hash\";N;s:16:\"reset_key_expiry\";i:0;}}');
/*!40000 ALTER TABLE `mrbs_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_users`
--

DROP TABLE IF EXISTS `mrbs_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `level` smallint NOT NULL DEFAULT '0',
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(75) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login` int NOT NULL DEFAULT '0',
  `reset_key_hash` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reset_key_expiry` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_users`
--

LOCK TABLES `mrbs_users` WRITE;
/*!40000 ALTER TABLE `mrbs_users` DISABLE KEYS */;
INSERT INTO `mrbs_users` VALUES (1,2,'admin','admin','$2y$12$tU2FeyXWsxdwvLD3zWLQA.JjeodZb4HuDPK1T9o81Erl/cwmK8/OC','admin@admin.foo','2025-02-08 16:04:55',1761232552,NULL,0),(2,1,'user1','User Usermann','$2y$12$VN05xy.OlrRAGY.GlEDcXOOtw.QlUe6gZDi/X7RCcy4eK.1MX9oz.','affe@affe.de','2025-07-05 15:37:56',1751813217,NULL,0);
/*!40000 ALTER TABLE `mrbs_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_variables`
--

DROP TABLE IF EXISTS `mrbs_variables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_variables` (
  `id` int NOT NULL AUTO_INCREMENT,
  `variable_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `variable_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_variable_name` (`variable_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_variables`
--

LOCK TABLES `mrbs_variables` WRITE;
/*!40000 ALTER TABLE `mrbs_variables` DISABLE KEYS */;
INSERT INTO `mrbs_variables` VALUES (1,'db_version','82'),(2,'local_db_version','1');
/*!40000 ALTER TABLE `mrbs_variables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mrbs_zoneinfo`
--

DROP TABLE IF EXISTS `mrbs_zoneinfo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mrbs_zoneinfo` (
  `id` int NOT NULL AUTO_INCREMENT,
  `timezone` varchar(127) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `outlook_compatible` tinyint unsigned NOT NULL DEFAULT '0',
  `vtimezone` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_updated` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_timezone` (`timezone`,`outlook_compatible`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mrbs_zoneinfo`
--

LOCK TABLES `mrbs_zoneinfo` WRITE;
/*!40000 ALTER TABLE `mrbs_zoneinfo` DISABLE KEYS */;
INSERT INTO `mrbs_zoneinfo` VALUES (1,'Europe/Berlin',1,'BEGIN:VTIMEZONE\r\nTZID:Europe/Berlin\r\nLAST-MODIFIED:20221013T075636Z\r\nTZURL:http://tzurl.org/zoneinfo-outlook/Europe/Berlin\r\nX-LIC-LOCATION:Europe/Berlin\r\nBEGIN:DAYLIGHT\r\nTZNAME:CEST\r\nTZOFFSETFROM:+0100\r\nTZOFFSETTO:+0200\r\nDTSTART:19700329T020000\r\nRRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=-1SU\r\nEND:DAYLIGHT\r\nBEGIN:STANDARD\r\nTZNAME:CET\r\nTZOFFSETFROM:+0200\r\nTZOFFSETTO:+0100\r\nDTSTART:19701025T030000\r\nRRULE:FREQ=YEARLY;BYMONTH=10;BYDAY=-1SU\r\nEND:STANDARD\r\nEND:VTIMEZONE',1740926207);
/*!40000 ALTER TABLE `mrbs_zoneinfo` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-02 18:06:35
