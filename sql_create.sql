CREATE  TABLE IF NOT EXISTS info_site (
  site_id INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  domain_name VARCHAR(255) NOT NULL ,
  PRIMARY KEY (site_id),
  INDEX sitename (domain_name ASC) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS info_server (
  server_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  server_name VARCHAR(256) NOT NULL ,
  server_descr VARCHAR(256) ,
  PRIMARY KEY (server_id) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS info_pusers (
  proxy_user_id INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  ProxyUserName VARCHAR(45) NOT NULL ,
  user_id INT UNSIGNED ,
  PRIMARY KEY (proxy_user_id) )
ENGINE = MyISAM;

CREATE  TABLE IF NOT EXISTS stat_site_tmp (
  Server_id TINYINT UNSIGNED NOT NULL DEFAULT 1 ,
  LogDate DATE NOT NULL ,
  proxy_user_id INT UNSIGNED NOT NULL ,
  StatusSquid VARCHAR(45) NOT NULL ,
  RequestSite VARCHAR(45) NOT NULL ,
  RequestBytes BIGINT UNSIGNED NOT NULL ,
  RequestCount INT UNSIGNED NOT NULL DEFAULT 1 ,
  PRIMARY KEY (Server_id, LogDate, proxy_user_id, StatusSquid, RequestSite) )
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

-- Initial data
INSERT INTO info_server (server_id, server_name, server_descr) VALUES (1, 'Proxy server #1', 'Default first server');