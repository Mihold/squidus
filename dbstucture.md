# Database tables #
## info\_options ##
init data
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `opt_key`     | varchar(15)   | +      | Key name        |
| `opt_val`     | varchar(15)   |        | Key value       |
| `opt_descr`   | text          |        | Key description |

## info\_pusers ##
Match proxy users name to squidus users
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `proxy_user_id` | INT (UNSIGNED) | +      |                 |
| `ProxyUserName` | varchar(45)   |        |                 |
| `user_id`     | INT (UNSIGNED) |        |                 |

## info\_server ##
Proxy servers list
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `server_id`   | TINYINT (UNSIGNED) | +      |                 |
| `server_descr` | varchar(256)  |        |                 |
| `server_name` | varchar(256)  |        |                 |

## info\_site ##
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `site_id`     | INT (UNSIGNED) | +      |                 |
| `domain_name` | varchar(256)  |        |                 |

## stat\_site ##
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `server_id`   | TINYINT (UNSIGNED) | +      |                 |
| `LogDate`     | DATE          | +      |                 |
| `proxy_user_id` | INT (UNSIGNED) | +      |                 |
| `RequestSite_id` | INT (UNSIGNED) | +      |                 |
| `RequestBytes` | BIGINT (UNSIGNED) |        |                 |
| `RequestCount` | INT (UNSIGNED) |        |                 |

## stat\_site\_tmp ##
Temporary data storage
| **Fild name** | **Data type** | **PK** | **Description** |
|:--------------|:--------------|:-------|:----------------|
| `server_id`   | TINYINT (UNSIGNED) | +      |                 |
| `LogDate`     | DATE          | +      |                 |
| `UserName`    | varchar(20)   | +      |                 |
| `StatusSquid` | varchar(45)   | +      |                 |
| `RequestSite` | varchar(255)  | +      |                 |
| `RequestBytes` | BIGINT (UNSIGNED) |        |                 |
| `RequestCount` | INT (UNSIGNED) |        |                 |