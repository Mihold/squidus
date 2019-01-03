<?php
# Squidus (c) 2012 Mykhaylo Kutsenko
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public
# License as published by the Free Software Foundation.
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

$template['report_title'] = $lang['MOD_TITLE'];
$template['report_body'] = '';

####
# Last week mini reports
####

# Bigest downloads
$template['report_body'] .= '<div class="gadget"><p class="partname">' . $lang['MOD_TOP5USERS'] . '</p>';
$template['report_body'] .= '<table>';
$template['report_body'] .= '<tr class="header"><td>' . $lang['MOD_TOP5USERS_USERNAME'] . '</td><td>' . $lang['MOD_TOP5USERS_VOLUME'] . '</td></tr>';
$mod_sql = 'SELECT t1.proxy_user_id, t2.ProxyUserName, SUM(t1.RequestBytes) AS SumBytes
FROM `stat_site` AS t1 LEFT JOIN info_pusers AS t2 ON t1.proxy_user_id = t2.proxy_user_id
WHERE t1.LogDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY proxy_user_id
ORDER BY SumBytes DESC
LIMIT 5';
$mod_sql_result = mysql_query($mod_sql, $dbs);
while ($mod_row = mysql_fetch_assoc($mod_sql_result)) {
	$template['report_body'] .= '<tr><td>' . htmlspecialchars($mod_row['ProxyUserName']) . '</td><td align="right">' . number_format($mod_row['SumBytes']/1048576, 2, '.', ' ') . '</td></tr>';
}
mysql_free_result($mod_sql_result);
$template['report_body'] .= '</table></div>';

# Most visited sites
$template['report_body'] .= '<div class="gadget"><p class="partname">' . $lang['MOD_TOP5SITES'] . '</p>';
$template['report_body'] .= '<table>';
$template['report_body'] .= '<tr class="header"><td>' . $lang['MOD_TOP5SITES_SITE'] . '</td><td>' . $lang['MOD_TOP5SITES_HITS'] . '</td></tr>';
$mod_sql = 'SELECT t1.RequestSite_id, t2.domain_name, SUM(t1.RequestCount) AS hits
FROM `stat_site` AS t1 LEFT JOIN info_site AS t2 ON t1.RequestSite_id = t2.site_id
WHERE t1.LogDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY t1.RequestSite_id
ORDER BY hits DESC
LIMIT 5';
$mod_sql_result = mysql_query($mod_sql, $dbs);
while ($mod_row = mysql_fetch_assoc($mod_sql_result)) {
	$template['report_body'] .= '<tr><td>' . htmlspecialchars($mod_row['domain_name']) . '</td><td align="right">' . number_format($mod_row['hits'], 0, '', ' ') . '</td></tr>';
}
mysql_free_result($mod_sql_result);
$template['report_body'] .= '</table></div>';

# Most heavy sites
$template['report_body'] .= '<div class="gadget"><p class="partname">' . $lang['MOD_TOP5HEAVY'] . '</p>';
$template['report_body'] .= '<table>';
$template['report_body'] .= '<tr class="header"><td>' . $lang['MOD_TOP5HEAVY_SITE'] . '</td><td>' . $lang['MOD_TOP5HEAVY_VOLUME'] . '</td></tr>';
$mod_sql = 'SELECT t1.RequestSite_id, t2.domain_name, SUM(t1.RequestBytes) AS SumBytes
FROM `stat_site` AS t1 LEFT JOIN info_site AS t2 ON t1.RequestSite_id = t2.site_id
WHERE t1.LogDate >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY t1.RequestSite_id
ORDER BY SumBytes DESC
LIMIT 5';
$mod_sql_result = mysql_query($mod_sql, $dbs);
while ($mod_row = mysql_fetch_assoc($mod_sql_result)) {
	$template['report_body'] .= '<tr><td>' . htmlspecialchars($mod_row['domain_name']) . '</td><td align="right">' . number_format($mod_row['SumBytes']/1048576, 2, '.', ' ') . '</td></tr>';
}
mysql_free_result($mod_sql_result);
$template['report_body'] .= '</table></div>';
?>