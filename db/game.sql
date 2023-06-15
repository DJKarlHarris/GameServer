CREATE TABLE `message_board`(
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '玩家id',
  `text` text NOT NULL COMMENT '留言记录',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='留言板';