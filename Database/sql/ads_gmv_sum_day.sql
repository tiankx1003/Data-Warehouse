-- 1）在MySQL中创建ads_gmv_sum_day表
DROP TABLE IF EXISTS ads_gmv_sum_day;
CREATE TABLE ads_gmv_sum_day(
  `dt` varchar(200) DEFAULT NULL COMMENT '统计日期',
  `gmv_count` bigint(20) DEFAULT NULL COMMENT '当日gmv订单个数',
  `gmv_amount` decimal(16, 2) DEFAULT NULL COMMENT '当日gmv订单总金额',
  `gmv_payment` decimal(16, 2) DEFAULT NULL COMMENT '当日支付金额'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '每日活跃用户数量' ROW_FORMAT = Dynamic;
-- 2）向MySQL中插入数据
INSERT INTO `ads_gmv_sum_day` VALUES ('2019-03-01 22:51:37', 1000, 210000.00, 2000.00);
INSERT INTO `ads_gmv_sum_day` VALUES ('2019-05-08 22:52:32', 3434, 12413.00, 1.00);
INSERT INTO `ads_gmv_sum_day` VALUES ('2019-07-13 22:52:51', 1222, 324345.00, 1.00);
INSERT INTO `ads_gmv_sum_day` VALUES ('2019-09-13 22:53:08', 2344, 12312.00, 1.00);
