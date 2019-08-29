-- 1）在MySQL中创建ads_user_action_convert_day表
DROP TABLE IF EXISTS `ads_user_action_convert_day`;
CREATE TABLE `ads_user_action_convert_day`  (
  `dt` varchar(200) DEFAULT NULL COMMENT '统计日期',
  `total_visitor_m_count` bigint(20) DEFAULT NULL COMMENT '总访问人数',
  `order_u_count` bigint(20) DEFAULT NULL COMMENT '下单人数',
  `visitor2order_convert_ratio` decimal(10, 2) DEFAULT NULL COMMENT '购物车到下单转化率',
  `payment_u_count` bigint(20) DEFAULT NULL COMMENT '支付人数',
  `order2payment_convert_ratio` decimal(10, 2) DEFAULT NULL COMMENT '下单到支付的转化率'
) ENGINE = InnoDB CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '每日用户行为转化率统计' ROW_FORMAT = Dynamic;
-- 2）向MySQL中插入数据
INSERT INTO `ads_user_action_convert_day` VALUES ('2019-04-28 19:36:18', 10000, 3000, 0.25, 2000, 0.15);
