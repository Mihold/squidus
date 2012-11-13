CREATE  TABLE IF NOT EXISTS info_site (
  site_id INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  domain_name VARCHAR(255) NOT NULL ,
  PRIMARY KEY (site_id),
  INDEX sitename (domain_name ASC) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS stat_site_tmp (
  Server_id TINYINT UNSIGNED NOT NULL DEFAULT 1 ,
  LogDate DATE NOT NULL ,
  UserName VARCHAR(45) NOT NULL ,
  StatusSquid VARCHAR(45) NOT NULL ,
  RequestSite VARCHAR(45) NOT NULL ,
  RequestBytes BIGINT UNSIGNED NOT NULL ,
  RequestCount INT UNSIGNED NOT NULL DEFAULT 1 ,
  PRIMARY KEY (Server_id, LogDate, UserName, StatusSquid, RequestSite) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS stat_site (
  server_id TINYINT UNSIGNED NOT NULL DEFAULT 1 ,
  LogDate DATE NOT NULL ,
  user_id INT UNSIGNED NOT NULL ,
  RequestSite_id INT UNSIGNED NOT NULL ,
  RequestBytes BIGINT UNSIGNED NOT NULL ,
  RequestCount INT UNSIGNED NOT NULL ,
  PRIMARY KEY (server_id, LogDate, user_id, StatusSquid, RequestSite_id) )
ENGINE = MyISAM;
