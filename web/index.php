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


# Do common operations
require('inc/common.php');

####
# Check user rights
####


####
# Prepare output data
####
$module = $sys_modules[0];							# Use default module
if (isset($_GET['mode'])) {							# Check module registration
	if(isset($sys_modules[$_GET['mode']])) {
		$module = $sys_modules[$_GET['mode']];
	}
}
# Load module default language file
require("lang/en_$module.php");
# Check module language localization
if (isset($conf['lang'])) {
	if(!file_exists('lang/' . $conf['lang'] . '_' . $module . '.php')) {
		$template['err'] .= $lang['ERR_LANGUAGE_FILE'] . "\n";
	} else {
		include('lang/' . $conf['lang'] . '_' . $module . '.php');
		$lang = array_merge($lang, $lang_local);
		unset($lang_local);
	}
}
include("mod/$module.php");
mysql_close($dbs);

####
# Apply data to template
####

# Output formated page
if ($template['err']) {
	echo htmlspecialchars($template['err']);
} else {
	include('template/index.php');
}
?>