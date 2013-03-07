<?php
# Squidus (c) 2012 Mykhaylo Kutsenko
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 
# For details see http://www.gnu.org/licenses/gpl-2.0.html

$template['report_title'] = '';
$template['report_body'] = '';

####
# Last week mini reports
####

# Bigest downloads
$mod_sql = 'SELECT t1.proxy_user_id, t2.ProxyUserName, SUM(RequestBytes) AS SumBytes
FROM `stat_site` AS t1 LEFT JOIN info_pusers AS t2 ON t1.proxy_user_id = t2.proxy_user_id
GROUP BY LogDate, proxy_user_id
HAVING LogDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY SumBytes DESC
LIMIT 5';
#$dbs
?>