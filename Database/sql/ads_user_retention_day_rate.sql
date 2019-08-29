-- 1）在MySQL中创建ads_user_retention_day_rate表
DROP TABLE IF EXISTS `ads_user_retention_day_rate`;
CREATE TABLE `ads_user_retention_day_rate`  (
  `stat_date` varchar(255)  DEFAULT NULL COMMENT '统计日期',
  `create_date` varchar(255) DEFAULT NULL COMMENT '设备新增日期',
  `retention_day` bigint(200) DEFAULT NULL COMMENT '截止当前日期留存天数',
  `retention_count` bigint(200) DEFAULT NULL COMMENT '留存数量',
  `new_mid_count` bigint(200) DEFAULT NULL COMMENT '当日设备新增数量',
  `retention_ratio` decimal(10, 2) DEFAULT NULL COMMENT '留存率'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '每日用户留存情况' ROW_FORMAT = Dynamic;
-- 2）向MySQL中插入数据
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-09','2019-03-08', 1,88,  99,  0.78);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-10','2019-03-08', 2,77,  88,  0.68);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-11','2019-03-08', 3,66,  77,  0.58);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-12','2019-03-08', 4,55,  66,  0.48);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-13','2019-03-08', 5,44,  55,  0.38);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-14','2019-03-08', 6,33,  44,  0.28);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-10','2019-03-09', 1,77,  88,  0.56);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-11','2019-03-09', 2,66,  77,  0.46);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-12','2019-03-09', 3,55,  66,  0.36);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-13','2019-03-09', 4,44,  55,  0.26);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-14','2019-03-09', 5,33,  44,  0.16);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-11','2019-03-10', 1,66,  77,  0.55);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-12','2019-03-10', 2,55,  66,  0.45);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-13','2019-03-10', 3,44,  55,  0.35);
INSERT INTO `ads_user_retention_day_rate` VALUES ('2019-03-14','2019-03-10', 4,33,  44,  0.25);
