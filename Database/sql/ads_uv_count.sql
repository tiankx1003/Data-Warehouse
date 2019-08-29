-- 1）在MySQL中创建ads_uv_count表
DROP TABLE IF EXISTS `ads_uv_count`;
CREATE TABLE `ads_uv_count`  (
  `dt` varchar(255) DEFAULT NULL COMMENT '统计日期',
  `day_count` bigint(200) DEFAULT NULL COMMENT '当日用户数量',
  `wk_count` bigint(200) DEFAULT NULL COMMENT '当周用户数量',
  `mn_count` bigint(200) DEFAULT NULL COMMENT '当月用户数量',
  `is_weekend` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Y,N是否是周末,用于得到本周最终结果',
  `is_monthend` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT 'Y,N是否是月末,用于得到本月最终结果'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '每日活跃用户数量' ROW_FORMAT = Dynamic;
-- 2）向MySQL中插入如下数据
INSERT INTO `ads_uv_count` VALUES ('2019-03-01 14:10:04', 20, 30, 100, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-02 14:12:48', 35, 50, 100, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-03 14:14:07', 25, 640, 3300, 'Y', 'Y');
INSERT INTO `ads_uv_count` VALUES ('2019-03-04 14:14:14', 10, 23, 123, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-05 14:14:21', 80, 121, 131, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-06 14:14:38', 30, 53, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-07 14:33:27', 20, 31, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-08 14:33:39', 10, 53, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-09 14:33:47', 10, 34, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-10 14:33:54', 10, 653, 8453, 'Y', 'Y');
INSERT INTO `ads_uv_count` VALUES ('2019-03-11 14:34:04', 100, 453, 1453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-12 14:34:10', 101, 153, 134, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-13 14:34:16', 100, 286, 313, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-14 14:34:22', 100, 45, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-15 14:34:29', 100, 345, 3453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-16 14:34:35', 101, 453, 453, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-17 14:34:41', 100, 678, 9812, 'Y', 'Y');
INSERT INTO `ads_uv_count` VALUES ('2019-03-18 14:34:46', 100, 186, 193, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-19 14:34:53', 453, 686, 712, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-20 14:34:57', 452, 786, 823, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-21 14:35:02', 214, 58, 213, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-22 14:35:08', 76, 78, 95, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-23 14:35:13', 76, 658, 745, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-24 14:35:19', 76, 687, 9300, 'Y', 'Y');
INSERT INTO `ads_uv_count` VALUES ('2019-03-25 14:35:25', 76, 876, 923, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-26 14:35:30', 76, 456, 511, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-27 14:35:35', 76, 456, 623, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-28 14:35:41', 43, 753, 4000, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-29 14:35:47', 76, 876, 4545, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-30 14:35:57', 76, 354, 523, 'N', 'N');
INSERT INTO `ads_uv_count` VALUES ('2019-03-31 14:36:02', 43, 634, 6213, 'Y', 'Y');
