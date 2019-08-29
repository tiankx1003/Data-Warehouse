-- 1）在MySQL中创建ads_gmv_sum_province表
DROP TABLE IF EXISTS `ads_gmv_sum_province`;
CREATE TABLE `ads_gmv_sum_province`  (
  `province` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `gmv` bigint(255) DEFAULT NULL,
  `remark` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;
-- 2）向MySQL中插入数据
INSERT INTO `ads_gmv_sum_province` VALUES ('北京', 2000, '');
INSERT INTO `ads_gmv_sum_province` VALUES ('辽宁', 30000, '沈阳：21.1%，大连：20%，鞍山：35%');
INSERT INTO `ads_gmv_sum_province` VALUES ('浙江', 8002, '杭州：20%，舟山：50%');
