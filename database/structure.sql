# phpMyAdmin MySQL-Dump
# http://phpwizard.net/phpMyAdmin/
#
# Host: localhost Database : binky
# --------------------------------------------------------

#
# Table structure for table 'config'
#

DROP TABLE IF EXISTS config;
CREATE TABLE config (
   config_key varchar(128) NOT NULL,
   config_value blob NOT NULL,
   PRIMARY KEY (config_key)
);

#
# Dumping data for table 'config'
#

INSERT INTO config (config_key, config_value) VALUES ( 'QUOTA_PERIOD', '14');
INSERT INTO config (config_key, config_value) VALUES ( 'BINKY_ENABLED', '1');
INSERT INTO config (config_key, config_value) VALUES ( 'DB_VERSION', '1');
INSERT INTO config (config_key, config_value) VALUES ( 'QUOTA_AMOUNT', '8192');
