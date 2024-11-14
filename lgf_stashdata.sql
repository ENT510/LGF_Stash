
CREATE TABLE IF NOT EXISTS `lgf_stashdata` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `stash_id` varchar(50) NOT NULL,
  `placer` varchar(50) NOT NULL,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`coords`)),
  `stash_prop` varchar(50) NOT NULL,
  `gps` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

