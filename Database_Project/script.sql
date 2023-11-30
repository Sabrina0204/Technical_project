CREATE TABLE `risk_information`(
`risk_id` int PRIMARY KEY,-- 1,2,3
`risk_level` CHAR(5) not null,-- high,mid,low
`risk_description` VARCHAR(255),
CONSTRAINT `risk_check`CHECK (`risk_level` IN ('high','mid','low'))-- To guarantee that the risk level is within the three options.
);
CREATE TABLE `cw3`.`Region`  (
  `name` varchar(255) NOT NULL,
	`discription` VARCHAR(255),
  PRIMARY KEY (`name`)
);

CREATE TABLE `District`(
`district_name` VARCHAR(255) PRIMARY KEY,
`region` VARCHAR(255) not null,
`risk_id` int  not null DEFAULT 3,-- All the districts at first are at low level.
`accumulated_cases` int not null DEFAULT 0,
CONSTRAINT `fk_region` FOREIGN KEY (`region`) REFERENCES `Region`(`name`),
CONSTRAINT `fk_risk` FOREIGN KEY (`risk_id`) REFERENCES `risk_information`(`risk_id`)
 );

CREATE TABLE `base_station`(
`bs_id` int PRIMARY KEY Auto_increment,
`GPS_longitude` FLOAT(6) not null,
`GPS_latitude` FLOAT(6) not null,
`district` VARCHAR(255) not null,
`signal_range` VARCHAR(255) not null,-- display the rough location of the citizen.
CONSTRAINT `fk_district` FOREIGN KEY (`district`) REFERENCES `District` (`district_name`)
)Auto_increment=1;
Create TABLE `Hospital`(
`hospital_name` VARCHAR(255) PRIMARY KEY,
`location` Varchar(255) NOT NULL,
`total_bednum` int(4),
 CONSTRAINT `fk_hos_location` FOREIGN KEY (`location`) REFERENCES `District`(`district_name`)
);
CREATE TABLE `Patient`(
`phone_number` int PRIMARY KEY,
`name` varchar(255) not null,
`sex` varchar(10)  not null,-- To guarantee that there is no input errors for sex information.
`age` int(3) not null,
`treatment_hospital` varchar(255) NULL,-- Use it to identify the patient is sick or not.
 CONSTRAINT `sex_check`   CHECK (`sex` IN('Female','Male')),
 CONSTRAINT `fk_treat_hos` FOREIGN KEY (`treatment_hospital`) REFERENCES `Hospital`(`hospital_name`)
);

CREATE TABLE `Virus`(
`sample_type` varchar(100) PRIMARY KEY,
`description` Varchar(255) 
);

CREATE TABLE `Hospital_Virus`(
`hospital_name` VARCHAR(100) not null,
`virus_type` varchar(100) not null,
PRIMARY KEY (`hospital_name`,`virus_type`),
CONSTRAINT `fk_virus` FOREIGN KEY (`virus_type`) REFERENCES `virus`(`sample_type`),
CONSTRAINT `fk_hospital` FOREIGN KEY (`hospital_name`) REFERENCES `Hospital`(`hospital_name`)
);

CREATE TABLE `Doctor`(
`doctor_phone_number` int PRIMARY KEY,
`doctor_name` varChar(100) not null,
`hospital` varCHAR(100) null,-- if the doctor is workless
CONSTRAINT `fk_work_hospital` FOREIGN KEY (`hospital`) REFERENCES `Hospital`(`hospital_name`)
);

CREATE TABLE `test_result`  (
  `patient_phone_number` int NOT NULL,
  `sample_type` char(255) not null,
  `collect_time` datetime NOT NULL,
  `test_time` datetime not null,
  `report_time` datetime not null,
  `test_hospital` char(255) not null,
  `test_doctor_phone` int not null,
  `result` tinyint(1) NOT NULL,
	CONSTRAINT `result_check`CHECK(`result` IN (1,0)),
  PRIMARY KEY (`patient_phone_number`, `collect_time`),
  CONSTRAINT `fk_phone_num` FOREIGN KEY (`patient_phone_number`) REFERENCES `cw3`.`patient` (`phone_number`),
  CONSTRAINT `fk_sample_type` FOREIGN KEY (`sample_type`) REFERENCES `cw3`.`virus` (`sample_type`),
  CONSTRAINT `fk_test_hos` FOREIGN KEY (`test_hospital`) REFERENCES `cw3`.`hospital` (`hospital_name`),
  CONSTRAINT `fk_test_doc` FOREIGN KEY (`test_doctor_phone`) REFERENCES `cw3`.`doctor` (`doctor_phone_number`)
);
CREATE TABLE `Travel_History`(
`phone_number` int,
`bs_id` int,
`connection_time` datetime NOT null,
`disconnection_time` datetime null,
PRIMARY KEY(`phone_number`,`connection_time`),
CONSTRAINT `fk_phone_num2` FOREIGN KEY (`phone_number`) REFERENCES `cw3`.`patient` (`phone_number`),
CONSTRAINT `fk_bs` FOREIGN KEY(`bs_id`) REFERENCES `base_station`(`bs_id`)
);

 INSERT INTO `risk_information` VALUE(1,'high','If a district has one or more positive cases staying for more than 24 hours'),(2,'mid','Districts that have positive cases within 1 week (even count people just passing by)'),(3,'low','Districts with no positive cases within 1 week are low-risk areas');

INSERT INTO `virus` VALUES('Coughid-21','Coughid-21 is a newly identified type of virus this year, all patients tested to be positive should rest well and avoid going outside.'),
('Coughid-19','Coughid-19 has a fatality rate of about 2 to 4 percent.'),
('Coughid-20','The most common clinical manifestations are fever with chills, cough, shortness of breath, and muscle soreness.'),
('Coughid-22','Highly infectious, with fever as the first symptom.'),
('Coughid-2','Infection can lead to pneumonia, severe acute respiratory syndrome, kidney failure and even death.'),
('Influenza-1','The case fatality rate is high.'),
('Influenza-2','The most common complication is pneumonia.');

INSERT INTO `region`(`name`) VALUES ('North'),('South'),('East'),('West'),('Centre');


INSERT INTO `district`VALUES ('Centre Lukewarm Hillside','Centre',1,0),
('Lenny town','Centre',1,0),
('Glow Sand district','North',2,0), 
('Futian','North',3,0),
('Longhua','South',3,0),
('Raspberry town','South',3,0),
('Yuexiu','West',3,0),
('Bunny Tail district','West',3,0),
('Baiyun','East',3,0),
('Pudong','East',3,0);

INSERT INTO `hospital` VALUES ('Central Lukewarm Kingdom Hospital','Centre Lukewarm Hillside',2340),
('North Lukewarm Kingdom Hospital','Futian',1240),
('South Lukewarm Kingdom Hospital','Longhua',1340),
('East Lukewarm Kingdom Hospital','Baiyun',980),
('West Lukewarm Kingdom Hospital','Yuexiu',780),
('Shenzhen People\'s Hospital','Lenny town',3043),
('Second People\'s Hospital','Centre Lukewarm Hillside',2340),
('Union Medical College Hospital','Glow Sand district',2350),
('Chao-yang Hospital','Bunny Tail district',2360),
('General Hospital','Pudong',1230),
('Nanfang Hospital','Raspberry town',1430),
('Jiulong Hospital','Lenny town',2360),
('Dushu Lake Hospital','Futian',1560),
('Guangzhou First People\'s Hospital','Yuexiu',790),
('Zhongshan Hospital','Baiyun',3450);

INSERT INTO `base_station` VALUES (1,120.746372,31.281388,'Centre Lukewarm Hillside','120.746372,31.281388-120.729229,31.274124'),
(2,120.751286,31.281088,'Centre Lukewarm Hillside','120.751286,31.281088-120.744531,31.282197'),   
(3, 120.727766,31.293915,'Lenny town','120.727766,31.293915-120.72475,31.300233'),
(4,120.72775,31.302855,'Glow Sand district','120.72775,31.302855-120.727014,31.301357'),
(5,120.725285,31.303447,'Futian','120.725285,31.303447-120.726125,31.301496'),
(6,120.743698,31.264052,'Longhua','120.743698,31.264052-120.742448,31.263701'),
(7,120.7455,31.264843,'Raspberry town','120.7455,31.264843-120.745002,31.264354'),
(8,120.7273,31.262793,'Yuexiu','120.7273,31.262793-120.724973,31.259032'),
(9,120.716541,31.253694,'Bunny Tail district','120.716541,31.253694-120.712864,31.253344'),
(10,120.752102,31.282207,'Baiyun','120.752102,31.282207-120.751897,31.281475'),
(11,120.751449,31.281557,'Pudong','120.751449,31.281557-120.751286,31.281088');

INSERT INTO `patient` VALUES (203336,'Peter','Male',33,'Central Lukewarm Kingdom Hospital'),
(133445,'Mary','Female',23,'Central Lukewarm Kingdom Hospital'),
(158309,'Hebe','Female',26,'Second People\'s Hospital'),
(149046,'Carry','Female',44,'Central Lukewarm Kingdom Hospital'),
(173507,'Ada','Female',54,'Central Lukewarm Kingdom Hospital'),
(120842,'Cora','Female',21,'Shenzhen People\'s Hospital'),
(233636,'Mark','Male',20,'Jiulong Hospital'),
(320816,'Eve','Female',56,'Shenzhen People\'s Hospital');
INSERT INTO `patient`(`phone_number`,`name`,sex,age) VALUES (203345,'Jesse','Female',26),
(277889,'Tom','Male',43),
(122334,'Lily','Female',33),
(255667,'Kim','Male',37),
(133467,'Jack','Male',28),
(233445,'Tim','Male',34),
(266641,'Ivan','Female',35),
(262661,'Alex','Male',29),
(344667,'John','Male',57),
(344523,'Frank','Male',65),
(290937,'Luke','Male',18),
(280735,'Jacob','Male',19),
(253109,'Eve','Female',32),
(289032,'Gina','Female',44),
(379201,'Neil','Male',43);

INSERT INTO `travel_history` (`phone_number`,bs_id,connection_time)VALUES(203336,1,'2021/10/01 09:23'),
(133445,2,'2021/10/01 10:22'),
(158309,1,'2021/10/01 07:21'),
(149046,1,'2021/09/27 08:33'),
(173507,1,'2021/10/01 13:09'),
(203345,5,'2021/09/26 12:33'),
(277889,8,'2021/09/27 13:22'),
(122334,3,'2021/09/26 07:21'),
(255667,1,'2021/08/26 19:09'),
(133467,6,'2021/09/19 03:44'),
(233445,10,'2021/09/26 09:23'),
(266641,9,'2021/10/01 21:09'),
(262661,11,'2021/09/29 09:45'),
(344667,4,'2021/09/30 10:28'),
(344523,7,'2021/09/28 09:12'),
(290937,3,'2021/09/26 08:23'),
(289032,3,'2021/10/07 19:30'),
(233636,3,'2021/10/08 09:30'),-- Mark Lenny
(253109,3,'2021/10/06 19:30'),-- Eve Lenny
(120842,3,'2021/10/04 14:30'),-- Cora Lenny
(379201,4,'2021/10/05 11:21'),-- Neil
(320816,3,'2021/10/08 17:30'),-- Eve2
(280735,9,'2021/10/07 20:40');

INSERT INTO `travel_history`VALUES(233636,3,'2021/10/07 08:30','2021/10/08 07:30'),-- Mark Lenny
(233636,4,'2021/10/08 07:30','2021/10/08 09:30'),-- Mark Glow
(280735,8,'2021/09/26 18:19','2021/10/07 20:40');




INSERT INTO doctor VALUES (2444567,'Jun Qi','Central Lukewarm Kingdom Hospital'),
(2333567,'Jianjun Chen','North Lukewarm Kingdom Hospital'),
(2555678,'Yanjie Xu','South Lukewarm Kingdom Hospital'),
(2888876,'Hanqi Tang','East Lukewarm Kingdom Hospital'),
(2111234,'Liyuan Jin','West Lukewarm Kingdom Hospital'),
(2555432,'Yunlong Xia','Shenzhen People\'s Hospital'),
(2777543,'Binhong Zhang','Second People\'s Hospital'),
(2333123,'Yiming Li','Union Medical College Hospital'),
(2999123,'Eric','Chao-yang Hospital'),
(2888345,'Alex','General Hospital'),-- doctor has the same name with the patient
(2666567,'George','Nanfang Hospital'),
(2888908,'Alan','Jiulong Hospital'),
(2009800,'Jackson','Guangzhou First People\'s Hospital'),
(2890987,'Mike','Central Lukewarm Kingdom Hospital'),
(2349083,'Mike','Shenzhen People\'s Hospital'),-- two doctors have same name
(2579304,'Joe','Shenzhen People\'s Hospital'),
(2486434,'Terry','East Lukewarm Kingdom Hospital');
INSERT INTO doctor (doctor_phone_number,doctor_name) VALUES (2777888,'Yuchi Liu');-- this doctor does not have a job.




INSERT INTO test_result VALUES(233636,'Coughid-21','2021/10/09 19:30','2021/10/09 20:10','2021/10/09 21:34','Jiulong Hospital',2888908,1),  -- Mark positive case1 case3
(120842,'Coughid-21','2021/10/09 21:36','2021/10/09 21:59','2021/10/09 23:32','Shenzhen People\'s Hospital',2349083,1),-- Cora positive
(320816,'Coughid-21','2021/10/09 21:36','2021/10/09 21:59','2021/10/09 23:32','Shenzhen People\'s Hospital',2349083,1),-- Eve2 positive 

(253109,'Coughid-21','2021/10/09 21:55','2021/10/09 22:20','2021/10/09 23:45','Jiulong Hospital',2888908,0),-- Eve negative 1,2,4,7 further check the test result.
(253109,'Coughid-21','2021/10/10 20:09','2021/10/10 21:00','2021/10/10 22:19','Jiulong Hospital',2888908,0),
(253109,'Coughid-21','2021/10/12 07:32','2021/10/12 08:12','2021/10/12 09:57','Jiulong Hospital',2888908,0),
(253109,'Coughid-21','2021/10/15 09:12','2021/10/15 10:12','2021/10/15 11:50','Jiulong Hospital',2888908,0);


INSERT INTO test_result VALUES(289032,'Coughid-21','2021/10/09 21:36','2021/10/09 22:20','2021/10/09 23:45','Union Medical College Hospital',2333123,0),-- Gina negative
(289032,'Coughid-21','2021/10/10 20:08','2021/10/10 21:00','2021/10/10 22:19','Union Medical College Hospital',2333123,0),
(289032,'Coughid-21','2021/10/12 07:32','2021/10/12 08:12','2021/10/12 09:57','Union Medical College Hospital',2333123,0),
(289032,'Coughid-21','2021/10/15 09:25','2021/10/15 10:12','2021/10/15 11:49','Union Medical College Hospital',2333123,0),

(379201,'Coughid-21','2021/10/09 21:45','2021/10/09 22:21','2021/10/09 23:45','Union Medical College Hospital',2333123,0),-- Neil negative
(379201,'Coughid-21','2021/10/10 20:09','2021/10/10 21:00','2021/10/10 22:23','Union Medical College Hospital',2333123,0),
(379201,'Coughid-21','2021/10/12 07:35','2021/10/12 08:12','2021/10/12 09:59','Union Medical College Hospital',2333123,0),
(379201,'Coughid-21','2021/10/15 09:37','2021/10/15 10:12','2021/10/15 11:47','Union Medical College Hospital',2333123,0);


INSERT INTO test_result VALUES(203336,'Coughid-21','2021/10/04 8:40','2021/10/04 9:40','2021/10/04 10:10','Central Lukewarm Kingdom Hospital',2890987,1),-- Peter positive case6
(133445,'Coughid-21','2021/10/04 10:10','2021/10/04 10:50','2021/10/04 11:32','Central Lukewarm Kingdom Hospital',2444567,1),-- Mary positive case6

(158309,'Coughid-2','2021/10/05 11:21','2021/10/05 11:57','2021/10/05 13:08','Second People\'s Hospital',2777543,1),-- Hebe positive case7
(149046,'Coughid-20','2021/10/05 06:08','2021/10/05 07:10','2021/10/05 07:54','Central Lukewarm Kingdom Hospital',2890987,1),-- Carry positive case7
(173507,'Coughid-21','2021/10/05 08:09','2021/10/05 9:01','2021/10/05 9:56','Central Lukewarm Kingdom Hospital',2444567,1),-- Ada positive case7

(203345,'Coughid-21','2021/10/03 7:40','2021/10/03 8:00','2021/10/03 10:10','North Lukewarm Kingdom Hospital',2333567,0),-- Jesse negative case3,4 
(203345,'Coughid-21','2021/10/04 7:56','2021/10/04 8:20','2021/10/04 10:09','North Lukewarm Kingdom Hospital',2333567,0),

(277889,'Coughid-21','2021/10/03 12:10','2021/10/03 12:30','2021/10/03 14:33','West Lukewarm Kingdom Hospital',2111234,0),-- Tom negative case3,4
(277889,'Coughid-21','2021/10/04 13:33','2021/10/04 13:59','2021/10/04 16:10','West Lukewarm Kingdom Hospital',2111234,0),

(122334,'Coughid-21','2021/10/03 11:13','2021/10/03 12:00','2021/10/03 13:45','Shenzhen People\'s Hospital',2555432,0),-- Lily negative case3,4
(122334,'Coughid-21','2021/10/04 11:56','2021/10/04 12:30','2021/10/04 14:02','Shenzhen People\'s Hospital',2555432,0),

(255667,'Coughid-21','2021/10/03 15:34','2021/10/03 16:10','2021/10/03 17:45','Second People\'s Hospital',2777543,0),-- Kim  negative case3,4
(255667,'Coughid-21','2021/10/04 16:08','2021/10/04 16:45','2021/10/04 17:59','Second People\'s Hospital',2777543,0),

(133467,'Coughid-21','2021/10/03 6:30','2021/10/03 7:20','2021/10/03 8:59','South Lukewarm Kingdom Hospital',2555678,0),-- Jack negative case3,4
(133467,'Coughid-21','2021/10/04 7:30','2021/10/04 8:20','2021/10/04 9:59','South Lukewarm Kingdom Hospital',2555678,0),


(233445,'Coughid-21','2021/10/03 7:33','2021/10/03 8:22','2021/10/03 10:10','East Lukewarm Kingdom Hospital',2888876,0),-- Tim negative case3,4
(233445,'Coughid-21','2021/10/04 8:23','2021/10/04 8:56','2021/10/04 11:33','East Lukewarm Kingdom Hospital',2888876,0),

(266641,'Coughid-21','2021/10/05 12:27','2021/10/05 12:56','2021/10/05 14:31','Chao-yang Hospital',2999123,0),-- Ivan negative  case3,
(262661,'Coughid-19','2021/10/05 15:07','2021/10/05 15:35','2021/10/05 16:59','General Hospital',2888345,0),-- Alex negative case3, EAST
(344667,'Coughid-20','2021/10/05 19:08','2021/10/05 19:34','2021/10/05 21:01','Union Medical College Hospital',2333123,0),-- John negative case3, North
(344523,'Coughid-19','2021/10/05 17:09','2021/10/05 17:39','2021/10/05 18:57','Nanfang Hospital',2666567,0),-- Frank negative case3 
(290937,'Coughid-21','2021/10/05 10:44','2021/10/05 11:12','2021/10/05 12:33','Jiulong Hospital',2888908,0),-- Luke negative case3,
(280735,'Influenza-1','2021/10/10 09:33','2021/10/10 10:12','2021/10/10 12:23','Guangzhou First People\'s Hospital',2009800,1);-- Jacob negative


INSERT INTO hospital_virus (`hospital_name`, `virus_type`) VALUES ('Dushu Lake Hospital','Influenza-1'),('Dushu Lake Hospital','Influenza-2'),('North Lukewarm Kingdom Hospital','Coughid-21'),('North Lukewarm Kingdom Hospital','Coughid-19'),('North Lukewarm Kingdom Hospital','Coughid-20'),('North Lukewarm Kingdom Hospital','Coughid-22'),('North Lukewarm Kingdom Hospital','Coughid-2'),('North Lukewarm Kingdom Hospital','Influenza-1');
--         Important use cases
-- usecase1
Select  DISTINCT T.patient_phone_number  
From(`test_result` T Inner Join `travel_history` H on T.`patient_phone_number`=H.`phone_number`AND H.`bs_id`IN (select bs_id from `travel_history` where `phone_number`=233636)) 
WHERE sample_type LIKE 'Coughid%' AND result =1 
AND unix_timestamp(connection_time) < unix_timestamp('2021/10/09 19:30') 
OR unix_timestamp(disconnection_time) > unix_timestamp('2021/10/07 19:30');

-- usecase2
Insert into `travel_history` (phone_number,bs_id,connection_time) Value (173507,9,'2021/12/13 20:47');
SELECT * FROM `travel_history` H, base_station B WHERE H.bs_id=B.bs_id AND connection_time='2021/12/13 20:47';
Update `travel_history` set disconnection_time = '2021/12/13 21:47' where phone_number=173507;
SELECT * FROM `travel_history` H, base_station B WHERE H.bs_id=B.bs_id AND connection_time='2021/12/13 20:47';


-- usecase3
Select  test_hospital, AVG(TIMESTAMPDIFF(Minute, test_time, report_time)) as `average` 
From test_result 
Group by test_hospital 
HAVING `average` <= ALL (Select AVG(TIMESTAMPDIFF(Minute, test_time, report_time)) as average From test_result Group by test_hospital);



-- usecase4
Select A.`patient_phone_number`
From `test_result` A,`test_result` B WHERE A.patient_phone_number=B.patient_phone_number  AND unix_timestamp(A.`collect_time`)>unix_timestamp('2021-10-03 00:00') AND unix_timestamp(B.`collect_time`)<unix_timestamp('2021-10-05 00:00') And TIMESTAMPDIFF(MINUTE, A.collect_time,B.collect_time) > 1440;


-- usecase5
Select  `district_name`,`risk_level`  From district D,risk_information R  Where D.`risk_id`=R.`risk_id` Order by R.`risk_id`;

-- usecase6
SELECT	P.phone_number, P.`name`FROM	test_result AS T	INNER JOIN	patient AS P ON T.patient_phone_number = P.phone_number 	INNER JOIN	hospital AS H	ON 	T.test_hospital = H.hospital_name WHERE 	TIMESTAMPDIFF(Hour, '2021/10/04 00:00',T.collect_time) < 24 AND T.sample_type LIKE 'Coughid%' AND	T.result = 1 AND	H.location = 'Centre Lukewarm Hillside';


-- usecase7
SELECT (COUNT(phone_number) -(SELECT	COUNT(P.phone_number) FROM	test_result AS T	INNER JOIN	patient AS P ON T.patient_phone_number = P.phone_number 	INNER JOIN	hospital AS H	ON 	T.test_hospital = H.hospital_name WHERE 	TIMESTAMPDIFF(Hour, '2021/10/04 00:00',T.collect_time) < 24 AND T.sample_type LIKE 'Coughid%' AND	T.result = 1 AND	H.location = 'Centre Lukewarm Hillside')) AS increment
FROM	test_result AS R	INNER JOIN	patient ON R.patient_phone_number = phone_number 	INNER JOIN	hospital	ON R.test_hospital = hospital_name WHERE 	TIMESTAMPDIFF(MINUTE,'2021/10/05 00:00',R.collect_time) < 1440 AND  TIMESTAMPDIFF(MINUTE,'2021/10/05 00:00',R.collect_time) >0 AND R.sample_type LIKE 'Coughid%' AND	R.result = 1 AND location = 'Centre Lukewarm Hillside';

-- usecase 8 
SELECT (Select  Count(DISTINCT T.patient_phone_number)
From(`test_result` T Inner Join `travel_history` H on T.`patient_phone_number`=H.`phone_number`AND H.`bs_id`IN (select bs_id from `travel_history` where `phone_number`=233636) )
WHERE sample_type LIKE 'Coughid%' 
AND unix_timestamp(connection_time) < unix_timestamp('2021/10/09 19:30') 
OR unix_timestamp(disconnection_time) > unix_timestamp('2021/10/07 19:30'))/
(Select  Count(DISTINCT T.patient_phone_number)
From(`test_result` T Inner Join `travel_history` H on T.`patient_phone_number`=H.`phone_number`AND H.`bs_id`IN (select bs_id from `travel_history` where `phone_number`=233636)) 
WHERE sample_type LIKE 'Coughid%' AND result =1 
AND unix_timestamp(connection_time) < unix_timestamp('2021/10/09 19:30') 
OR unix_timestamp(disconnection_time) > unix_timestamp('2021/10/07 19:30')) AS Rate;

--          Extended use cases
-- extended usecase1
Update `district` set `accumulated_cases`=
(select count(`result`) from`test_result`,`hospital` where `result`=1 and `test_hospital`=`hospital_name` and `location`='Centre Lukewarm Hillside' And `sample_type` Like 'Coughid%') Where district_name = 'Centre Lukewarm Hillside' ;

-- extended usecase2
Select sample_type, COUNT(result) as Positive_cases  From test_result Where result = 1 AND sample_type LIKE 'Coughid%' Group by sample_type;

-- extended usecase3
Select doctor_name,doctor_phone_number,hospital_name,total_bednum From doctor LEFT JOIN hospital on hospital = hospital_name order by total_bednum DESC;

-- extended usecase4
SELECT *
FROM test_result WHERE patient_phone_number = 289032 AND UNIX_TIMESTAMP(collect_time) > UNIX_TIMESTAMP('2021/10/09 19:30') AND collect_time IN 
(SELECT DISTINCT A.collect_time FROM test_result A INNER JOIN test_result B ON A.patient_phone_number = B.patient_phone_number AND A.patient_phone_number =289032
WHERE TIMESTAMPDIFF(DAY,'2021/10/09 19:30',B.collect_time)=1 OR TIMESTAMPDIFF(DAY,'2021/10/09 19:30',B.collect_time)= 3 OR TIMESTAMPDIFF(DAY,'2021/10/09 19:30',B.collect_time)= 6);


-- extended usecase5
SELECT * FROM hospital_virus H, virus V WHERE H.virus_type = V.sample_type and H.hospital_name = 'North Lukewarm Kingdom Hospital';

-- extended usecase6
SELECT P.`name`,P.phone_number,B.district,B.signal_range FROM patient P INNER JOIN travel_history T on P.phone_number=T.phone_number INNER JOIN base_station B ON T.bs_id = B.bs_id 
WHERE P.phone_number=203336 AND disconnection_time IS NULL;

-- extended usecase7
Select A.age,A.`name`,A.phone_number,A.sex,A.treatment_hospital From patient A INNER JOIN patient B on A.`name` = B.`name` where A.phone_number != B.phone_number;

-- extended usecase8
UPDATE patient set patient.treatment_hospital = NULL WHERE patient.phone_number = 149046;

-- extentded usecase9

SELECT * From test_result T INNER JOIN patient P on T.patient_phone_number=P.phone_number Order by T.collect_time LIMIT 1;
-- extended usecase10
SELECT * FROM base_station WHERE district = 'Centre Lukewarm Hillside';