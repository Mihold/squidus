CREATE  TABLE IF NOT EXISTS info_site (
  site_id INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  domain_name VARCHAR(255) NOT NULL ,
  PRIMARY KEY (site_id) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS stat_site_tmp (
  Server_id TINYINT UNSIGNED NOT NULL DEFAULT 1 ,
  LogDate DATE NOT NULL ,
  UserName VARCHAR(45) NOT NULL ,
  StatusSquid VARCHAR(45) NOT NULL ,
  RequestSite VARCHAR(45) NOT NULL ,
  RequestBytes INT UNSIGNED NOT NULL ,
  RequestCount SMALLINT UNSIGNED NOT NULL DEFAULT 1 ,
  PRIMARY KEY (Server_id, LogDate, UserName, StatusSquid, RequestSite) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS stat_site (
  Server_id TINYINT UNSIGNED NOT NULL DEFAULT 1 ,
  LogDate DATE NOT NULL ,
  UserName VARCHAR(45) NOT NULL ,
  StatusSquid VARCHAR(45) NOT NULL ,
  RequestSiteId INT UNSIGNED NOT NULL,
  RequestBytes INT UNSIGNED NOT NULL ,
  RequestCount SMALLINT UNSIGNED NOT NULL DEFAULT 1 ,
  PRIMARY KEY (Server_id, LogDate, UserName, StatusSquid, RequestSite) )
ENGINE = MyISAM;