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
