/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.14-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: agencyservice
-- ------------------------------------------------------
-- Server version	10.11.14-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Sequence structure for `sequence_agency`
--

DROP SEQUENCE IF EXISTS `sequence_agency`;
CREATE SEQUENCE `sequence_agency` start with 0 minvalue 0 maxvalue 9223372036854775806 increment by 1 cache 10 nocycle ENGINE=InnoDB;
DO SETVAL(`sequence_agency`, 170, 0);

--
-- Sequence structure for `sequence_agency_postcode_range`
--

DROP SEQUENCE IF EXISTS `sequence_agency_postcode_range`;
CREATE SEQUENCE `sequence_agency_postcode_range` start with 0 minvalue 0 maxvalue 9223372036854775806 increment by 1 cache 10 nocycle ENGINE=InnoDB;
DO SETVAL(`sequence_agency_postcode_range`, 140, 0);

--
-- Sequence structure for `sequence_agency_topic`
--

DROP SEQUENCE IF EXISTS `sequence_agency_topic`;
CREATE SEQUENCE `sequence_agency_topic` start with 0 minvalue 0 maxvalue 9223372036854775806 increment by 1 cache 10 nocycle ENGINE=InnoDB;
DO SETVAL(`sequence_agency_topic`, 240, 0);

--
-- Sequence structure for `sequence_diocese`
--

DROP SEQUENCE IF EXISTS `sequence_diocese`;
CREATE SEQUENCE `sequence_diocese` start with 0 minvalue 0 maxvalue 9223372036854775806 increment by 1 nocache nocycle ENGINE=InnoDB;
DO SETVAL(`sequence_diocese`, 0, 0);

--
-- Table structure for table `DATABASECHANGELOG`
--

DROP TABLE IF EXISTS `DATABASECHANGELOG`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `DATABASECHANGELOG` (
  `ID` varchar(255) NOT NULL,
  `AUTHOR` varchar(255) NOT NULL,
  `FILENAME` varchar(255) NOT NULL,
  `DATEEXECUTED` datetime NOT NULL,
  `ORDEREXECUTED` int(11) NOT NULL,
  `EXECTYPE` varchar(10) NOT NULL,
  `MD5SUM` varchar(35) DEFAULT NULL,
  `DESCRIPTION` varchar(255) DEFAULT NULL,
  `COMMENTS` varchar(255) DEFAULT NULL,
  `TAG` varchar(255) DEFAULT NULL,
  `LIQUIBASE` varchar(20) DEFAULT NULL,
  `CONTEXTS` varchar(255) DEFAULT NULL,
  `LABELS` varchar(255) DEFAULT NULL,
  `DEPLOYMENT_ID` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DATABASECHANGELOG`
--

LOCK TABLES `DATABASECHANGELOG` WRITE;
/*!40000 ALTER TABLE `DATABASECHANGELOG` DISABLE KEYS */;
INSERT INTO `DATABASECHANGELOG` VALUES
('initSql-tables','initialSetup','db/changelog/changeset/0001_initsql/initSql.xml','2025-09-06 14:49:14',1,'EXECUTED','9:fcd26225fa81c17ee81b0b1facacfcac','sqlFile path=db/changelog/changeset/0001_initsql/initTables.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('initSql-trigger','initialSetup','db/changelog/changeset/0001_initsql/initSql.xml','2025-09-06 14:49:14',2,'EXECUTED','9:19a49921f540a2937d3bb360b39b4c69','sqlFile path=db/changelog/changeset/0001_initsql/initTrigger.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('COBH-1413-agency_id_old_null','COBH-1413','db/changelog/changeset/0002_agency_id_old_null/0002_changeSet.xml','2025-09-06 14:49:14',3,'EXECUTED','9:8cf4b52eaafcbc4535b3e74156e70794','sqlFile path=db/changelog/changeset/0002_agency_id_old_null/agenyIdOldNull.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('COBH-1395-agency_consulting_type','COBH-1395','db/changelog/changeset/0003_agency_consulting_type/0003_changeSet.xml','2025-09-06 14:49:14',4,'EXECUTED','9:ea60e25cfc91a86b0d354f1b96b10e5a','sqlFile path=db/changelog/changeset/0003_agency_consulting_type/agencyConsultingType.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('COBH-1411-agency_offline','COBH-1411','db/changelog/changeset/0004_agency_offline/0004_changeSet.xml','2025-09-06 14:49:14',5,'EXECUTED','9:2f1b412f597e1c0932120998b14209a3','sqlFile path=db/changelog/changeset/0004_agency_offline/agencyOffline.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('COBH-2387-agency-delete-flag','COBH-2387','db/changelog/changeset/0005_agency_delete_flag/0005_changeSet.xml','2025-09-06 14:49:14',6,'EXECUTED','9:1b6d12b210017c23a5d54cd7ec50c2bc','sqlFile path=db/changelog/changeset/0005_agency_delete_flag/agencyDeleteFlag.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agency-url-and-external-flag','daho4b','db/changelog/changeset/0006_agency_url_and_external_flag/0006_changeSet.xml','2025-09-06 14:49:14',7,'EXECUTED','9:61030918861edf7a6330ee8af4591748','sqlFile path=db/changelog/changeset/0006_agency_url_and_external_flag/agencyUrlAndExternalFlag.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('tenantId','aalicic','db/changelog/changeset/0007_tenant_id/0007_changeSet.xml','2025-09-06 14:49:14',8,'EXECUTED','9:c59544648035248bf5ba5101918fd8c1','sqlFile path=db/changelog/changeset/0007_tenant_id/tenant_id.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('tenantIdRemoveDiocese','aalicic','db/changelog/changeset/0008_tenant_id_remove/0008_changeSet.xml','2025-09-06 14:49:15',9,'EXECUTED','9:9897d54c5f115db122051f601c57a97f','sqlFile path=db/changelog/changeset/0008_tenant_id_remove/tenant_id.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyTopic','patric-dosch-vi','db/changelog/changeset/0009_agency_topic/0009_changeSet.xml','2025-09-06 14:49:15',10,'EXECUTED','9:8c32fed41b8f93a49da2d7609f884fe9','sqlFile path=db/changelog/changeset/0009_agency_topic/agencyTopic.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyTopic-trigger','patric-dosch-vi','db/changelog/changeset/0009_agency_topic/0009_changeSet.xml','2025-09-06 14:49:15',11,'EXECUTED','9:4ffa52a9dc2b30fb99ae99bb32ac61e8','sqlFile path=db/changelog/changeset/0009_agency_topic/agencyTopicTrigger.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyDemographics','tkuzynow','db/changelog/changeset/0010_agency_demographics/0010_changeSet.xml','2025-09-06 14:49:15',12,'EXECUTED','9:ae4a6f04451030882866fb96039e7c38','sqlFile path=db/changelog/changeset/0010_agency_demographics/agencyDemographics.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyDemographics','tkuzynow','db/changelog/changeset/0011_agency_demographics_gender_column_change/0011_changeSet.xml','2025-09-06 14:49:15',13,'EXECUTED','9:d941dbba4926fc3cc8dce996f113f7f1','sqlFile path=db/changelog/changeset/0011_agency_demographics_gender_column_change/genderColumn-rename.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyDemographics','tkuzynow','db/changelog/changeset/0012_agency_counseling_relations/0012_changeSet.xml','2025-09-06 14:49:15',14,'EXECUTED','9:2792ff873df23a337b48162fcc5ee304','sqlFile path=db/changelog/changeset/0012_agency_counseling_relations/agencyCounselingRelations.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('agencyDemographics','tkuzynow','db/changelog/changeset/0013_make_diocese_nullable/0013_changeSet.xml','2025-09-06 14:49:15',15,'EXECUTED','9:6bed217b60b39fe6e47c21295a1d5084','sqlFile path=db/changelog/changeset/0013_make_diocese_nullable/makeDioceseNullable.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('changeConsultingTypeColumnType','tkuzynow','db/changelog/changeset/0015_change_consultingtype_column_type/0015_changeSet.xml','2025-09-06 14:49:15',16,'EXECUTED','9:5e06facd246f84f2f45a64c591fb066f','sqlFile path=db/changelog/changeset/0015_change_consultingtype_column_type/changeConsultingtypeColumnType.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('addDataProtectionAttributes','tkuzynow','db/changelog/changeset/0016_add_data_protection_attributes/0016_changeSet.xml','2025-09-06 14:49:15',17,'EXECUTED','9:5528d4cf29047d993cc713a45400b30a','sqlFile path=db/changelog/changeset/0016_add_data_protection_attributes/addDataProtectionAttributes.sql','',NULL,'4.23.2',NULL,NULL,'7170154528'),
('addAgencyLogo','tkuzynow','db/changelog/changeset/0017_add_agency_logo/0017_changeSet.xml','2025-09-06 14:49:15',18,'EXECUTED','9:9bab7e43e5612b1271bf85ba6faf0d6a','sqlFile path=db/changelog/changeset/0017_add_agency_logo/addAgencyLogo.sql','',NULL,'4.23.2',NULL,NULL,'7170154528');
/*!40000 ALTER TABLE `DATABASECHANGELOG` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DATABASECHANGELOGLOCK`
--

DROP TABLE IF EXISTS `DATABASECHANGELOGLOCK`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `DATABASECHANGELOGLOCK` (
  `ID` int(11) NOT NULL,
  `LOCKED` bit(1) NOT NULL,
  `LOCKGRANTED` datetime DEFAULT NULL,
  `LOCKEDBY` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DATABASECHANGELOGLOCK`
--

LOCK TABLES `DATABASECHANGELOGLOCK` WRITE;
/*!40000 ALTER TABLE `DATABASECHANGELOGLOCK` DISABLE KEYS */;
INSERT INTO `DATABASECHANGELOGLOCK` VALUES
(1,'\0',NULL,NULL);
/*!40000 ALTER TABLE `DATABASECHANGELOGLOCK` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agency`
--

DROP TABLE IF EXISTS `agency`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency` (
  `id` bigint(21) NOT NULL,
  `tenant_id` bigint(21) DEFAULT NULL,
  `diocese_id` int(11) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `postcode` varchar(5) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `is_team_agency` tinyint(4) NOT NULL DEFAULT 0,
  `consulting_type` int(11) DEFAULT NULL,
  `is_offline` tinyint(4) NOT NULL DEFAULT 0,
  `url` varchar(500) DEFAULT NULL,
  `is_external` tinyint(4) NOT NULL DEFAULT 0,
  `age_from` smallint(6) DEFAULT NULL,
  `age_to` smallint(6) DEFAULT NULL,
  `genders` varchar(50) DEFAULT NULL,
  `id_old` bigint(21) DEFAULT NULL,
  `create_date` datetime NOT NULL DEFAULT utc_timestamp(),
  `update_date` datetime NOT NULL DEFAULT utc_timestamp(),
  `delete_date` datetime DEFAULT NULL,
  `counselling_relations` varchar(200) DEFAULT NULL,
  `data_protection_responsible_entity` varchar(100) DEFAULT NULL,
  `data_protection_alternative_contact` longtext DEFAULT NULL,
  `data_protection_officer_contact` longtext DEFAULT NULL,
  `data_protection_agency_contact` longtext DEFAULT NULL,
  `agency_logo` longtext DEFAULT NULL,
  `matrix_user_id` varchar(255) DEFAULT NULL,
  `matrix_password` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `diocese_id` (`diocese_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency`
--

LOCK TABLES `agency` WRITE;
/*!40000 ALTER TABLE `agency` DISABLE KEYS */;
INSERT INTO `agency` VALUES
(122,1,NULL,'Agency N1','','12345','City',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-07 15:44:08','2025-11-07 15:47:15',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-122-service:91.99.219.182','AP6MCXlT3kFQ58ZV958bhQoP'),
(143,1,NULL,'Agency N2','','12345','Sialkot',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-16 01:12:48','2025-11-16 01:14:38',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-143-service:91.99.219.182','qwFI-hyXe-edQ9D6_E3JesOM'),
(144,1,NULL,'Agency N3','','12345','City',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-16 07:44:53','2025-11-16 07:45:56',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-144-service:91.99.219.182','rOPj4N_hRPCapamEA8ALbMwz'),
(145,1,NULL,'Agency N4','','12345','berlin',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-16 16:22:52','2025-11-16 16:24:34',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-145-service:91.99.219.182','7bWsHe9mqFwKBJedNGc486VJ'),
(146,1,NULL,'agency 5','','12346','germany',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-16 16:34:43','2025-11-16 16:36:12',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-146-service:91.99.219.182','fFQPbCJ0P0qbcPn9-6Dd2yNe'),
(147,1,NULL,'ORISO Agency','Agency for ORISO.','12345','ORISO City',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-20 07:18:58','2025-11-20 07:52:46',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-147-service:91.99.219.182','GqRMqp4AEIT9vPtOLqFS7BSt'),
(148,1,NULL,'Caritas Agency','Caritas Testing Agency','12345','Frankenstein',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-23 17:01:43','2025-11-23 18:34:55',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-148-service:91.99.219.182','19QeuH7hh9AI5r5kG-84N6Ee'),
(149,1,NULL,'Neue Beratungsstelle','','99999','Neu-Stadt',0,1,1,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 08:56:35','2025-11-24 19:43:25',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-149-service:91.99.219.182','f7KtmFCyB_Ub7gNqGvTk18RP'),
(150,1,NULL,'agency 6','','12366','zuric',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 13:13:39','2025-11-24 13:19:05',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-150-service:91.99.219.182','F8v5_AFwkx93lD3H2Q7ipdGm'),
(151,1,NULL,'New Agency','','99999','New-Town',0,1,1,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 14:12:25','2025-11-24 14:12:26',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-151-service:91.99.219.182','GzXyK7fV2YUuR4Wqew_UURRZ'),
(152,1,NULL,'Agency Latest','Agency for Testing.','12345','City Latest',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 15:43:56','2025-11-24 15:49:50',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-152-service:91.99.219.182','826RNarenDwhPXdZ5wsBnIFt'),
(153,1,NULL,'Ratschlägerbande','Meine heiße Beratung für alle kalten Fälle, immer unaufgefordert, \"nur gut meinend\", und zeitnah. \n\nGerne auch umsonst und häufig. Einfach melden','12043','Berlin',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 15:49:23','2025-11-27 09:46:47',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-153-service:91.99.219.182','T7I1OLz2IDvKOGtjI2gk0E0Z'),
(154,1,NULL,'New Agency 12','','99999','New-Town',0,1,1,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 16:27:07','2025-11-24 16:27:07',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-154-service:91.99.219.182','WArb6BUs2dhREi1cupV7Mq1o'),
(155,1,NULL,'New Agency 13','','99999','New-Town',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-11-24 18:57:28','2025-11-24 21:52:44',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-155-service:91.99.219.182','mCW8zprOrpIG8dI89MPmfE0h'),
(160,1,NULL,'Testing-Agency','','22334','machester',0,1,1,NULL,0,NULL,NULL,NULL,NULL,'2025-12-06 05:57:35','2025-12-06 05:57:35',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-160-service:91.99.219.182','ejOjcxepXtljGyQ9n-WNUniI'),
(161,1,NULL,'BeratungsstelleDez7Test','','12043','Berlin',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-12-07 11:26:13','2025-12-07 11:49:15',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-161-service:91.99.219.182','9OzKiAhF_ttXRcGEB1N-CJC4'),
(162,1,NULL,'Beratung Dez8 test','Test Vorführung ','10965','Berlin',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-12-08 07:07:52','2025-12-08 07:10:25',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-162-service:91.99.219.182','zjfQ2iJvm5CkN20LNaCT7-Cm'),
(165,1,NULL,'Dez15BeratungsStelle','FinalerTest','50667','Köln',0,1,0,NULL,0,NULL,NULL,NULL,NULL,'2025-12-15 08:37:15','2025-12-15 08:41:18',NULL,'RELATIVE_COUNSELLING,SELF_COUNSELLING,PARENTAL_COUNSELLING',NULL,NULL,NULL,NULL,'','@agency-165-service:91.99.219.182','PVxrmmnQOo1KE5BzILYk8DGM');
/*!40000 ALTER TABLE `agency` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`agencyservice`@`%`*/ /*!50003 TRIGGER `agencyservice`.`agency_update` BEFORE UPDATE ON `agencyservice`.`agency` FOR EACH ROW BEGIN
set new.update_date=utc_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `agency_postcode_range`
--

DROP TABLE IF EXISTS `agency_postcode_range`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_postcode_range` (
  `id` bigint(21) NOT NULL,
  `tenant_id` bigint(21) DEFAULT NULL,
  `agency_id` bigint(21) NOT NULL,
  `postcode_from` varchar(5) NOT NULL,
  `postcode_to` varchar(5) NOT NULL,
  `create_date` datetime NOT NULL DEFAULT utc_timestamp(),
  `update_date` datetime NOT NULL DEFAULT utc_timestamp(),
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `agency_postcode_range_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `agency` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_postcode_range`
--

LOCK TABLES `agency_postcode_range` WRITE;
/*!40000 ALTER TABLE `agency_postcode_range` DISABLE KEYS */;
INSERT INTO `agency_postcode_range` VALUES
(79,1,122,'00000','99999','2025-11-07 15:47:16','2025-11-07 15:47:16'),
(84,1,143,'00000','99999','2025-11-16 01:14:39','2025-11-16 01:14:39'),
(86,1,144,'00000','99999','2025-11-16 07:45:56','2025-11-16 07:45:56'),
(88,1,145,'00000','99999','2025-11-16 16:24:35','2025-11-16 16:24:35'),
(90,1,146,'00000','99999','2025-11-16 16:36:12','2025-11-16 16:36:12'),
(92,1,147,'00000','99999','2025-11-20 07:52:46','2025-11-20 07:52:46'),
(94,1,148,'00000','99999','2025-11-23 18:34:57','2025-11-23 18:34:57'),
(98,1,150,'00000','99999','2025-11-24 13:19:05','2025-11-24 13:19:05'),
(99,1,151,'00000','99999','2025-11-24 14:12:26','2025-11-24 14:12:26'),
(104,1,152,'00000','99999','2025-11-24 15:49:52','2025-11-24 15:49:52'),
(107,1,154,'00000','99999','2025-11-24 16:27:07','2025-11-24 16:27:07'),
(112,1,149,'00000','99999','2025-11-24 19:43:26','2025-11-24 19:43:26'),
(121,1,155,'00000','99999','2025-11-24 21:52:45','2025-11-24 21:52:45'),
(123,1,153,'10000','15000','2025-11-27 09:46:47','2025-11-27 09:46:47'),
(124,1,160,'00000','99999','2025-12-06 05:57:35','2025-12-06 05:57:35'),
(126,1,161,'12040','12050','2025-12-07 11:49:15','2025-12-07 11:49:15'),
(128,1,162,'10900','11000','2025-12-08 07:10:25','2025-12-08 07:10:25'),
(136,1,165,'50600','50700','2025-12-15 08:41:19','2025-12-15 08:41:19');
/*!40000 ALTER TABLE `agency_postcode_range` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`agencyservice`@`%`*/ /*!50003 TRIGGER `agencyservice`.`agency_postcode_range_update` BEFORE UPDATE ON `agencyservice`.`agency_postcode_range` FOR EACH ROW BEGIN
set new.update_date=utc_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `agency_topic`
--

DROP TABLE IF EXISTS `agency_topic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `agency_topic` (
  `id` bigint(21) NOT NULL,
  `agency_id` bigint(21) NOT NULL,
  `topic_id` bigint(21) NOT NULL,
  `create_date` datetime NOT NULL DEFAULT utc_timestamp(),
  `update_date` datetime NOT NULL DEFAULT utc_timestamp(),
  PRIMARY KEY (`id`),
  KEY `agency_id` (`agency_id`),
  CONSTRAINT `agency_topic_ibfk_1` FOREIGN KEY (`agency_id`) REFERENCES `agency` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agency_topic`
--

LOCK TABLES `agency_topic` WRITE;
/*!40000 ALTER TABLE `agency_topic` DISABLE KEYS */;
INSERT INTO `agency_topic` VALUES
(137,122,3,'2025-11-07 15:47:15','2025-11-07 15:47:15'),
(160,143,3,'2025-11-16 01:14:38','2025-11-16 01:14:38'),
(162,144,3,'2025-11-16 07:45:56','2025-11-16 07:45:56'),
(164,145,1,'2025-11-16 16:24:34','2025-11-16 16:24:34'),
(168,146,1,'2025-11-16 16:36:12','2025-11-16 16:36:12'),
(169,146,3,'2025-11-16 16:36:12','2025-11-16 16:36:12'),
(170,146,2,'2025-11-16 16:36:12','2025-11-16 16:36:12'),
(172,147,3,'2025-11-20 07:52:46','2025-11-20 07:52:46'),
(174,148,3,'2025-11-23 18:34:55','2025-11-23 18:34:55'),
(182,150,3,'2025-11-24 13:19:05','2025-11-24 13:19:05'),
(183,151,3,'2025-11-24 14:12:25','2025-11-24 14:12:25'),
(185,152,3,'2025-11-24 15:49:50','2025-11-24 15:49:50'),
(188,154,1,'2025-11-24 16:27:07','2025-11-24 16:27:07'),
(197,149,1,'2025-11-24 19:43:25','2025-11-24 19:43:25'),
(198,149,3,'2025-11-24 19:43:25','2025-11-24 19:43:25'),
(199,149,2,'2025-11-24 19:43:25','2025-11-24 19:43:25'),
(215,155,1,'2025-11-24 21:52:44','2025-11-24 21:52:44'),
(216,155,2,'2025-11-24 21:52:44','2025-11-24 21:52:44'),
(217,155,3,'2025-11-24 21:52:44','2025-11-24 21:52:44'),
(220,153,1,'2025-11-27 09:46:47','2025-11-27 09:46:47'),
(221,153,2,'2025-11-27 09:46:47','2025-11-27 09:46:47'),
(222,161,1,'2025-12-07 11:49:15','2025-12-07 11:49:15'),
(223,161,3,'2025-12-07 11:49:15','2025-12-07 11:49:15'),
(224,161,2,'2025-12-07 11:49:15','2025-12-07 11:49:15'),
(227,162,3,'2025-12-08 07:10:25','2025-12-08 07:10:25'),
(228,162,2,'2025-12-08 07:10:25','2025-12-08 07:10:25'),
(237,165,1,'2025-12-15 08:41:18','2025-12-15 08:41:18');
/*!40000 ALTER TABLE `agency_topic` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`agencyservice`@`%`*/ /*!50003 TRIGGER `agencyservice`.`agency_topic_update` BEFORE UPDATE ON `agencyservice`.`agency_topic` FOR EACH ROW BEGIN
set new.update_date=utc_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `diocese`
--

DROP TABLE IF EXISTS `diocese`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `diocese` (
  `id` bigint(21) NOT NULL,
  `name` varchar(100) NOT NULL,
  `id_old` bigint(21) NOT NULL,
  `create_date` datetime NOT NULL DEFAULT utc_timestamp(),
  `update_date` datetime NOT NULL DEFAULT utc_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `diocese`
--

LOCK TABLES `diocese` WRITE;
/*!40000 ALTER TABLE `diocese` DISABLE KEYS */;
/*!40000 ALTER TABLE `diocese` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`agencyservice`@`%`*/ /*!50003 TRIGGER `agencyservice`.`diocese_update` BEFORE UPDATE ON `agencyservice`.`diocese` FOR EACH ROW BEGIN
set new.update_date=utc_timestamp();
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-15 20:21:58
