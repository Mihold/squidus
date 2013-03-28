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

# Load default language file
require_once('lang/en.php');

# Get initial configuration
require_once('squidus.ini.php');

# Product info
$template['title'] = 'Squidus';
$template['info_version'] = 'Version 1.0 (dev)';

# Check language localization
if (isset($conf['lang'])) {
	if(!file_exists('lang/' . $conf['lang'] . '.php')) {
		$template['err'] .= $lang['ERR_LANGUAGE_FILE'] . "\n";
	} else {
		include('lang/' . $conf['lang'] . '.php');
		$lang = array_merge($lang, $lang_local);
		unset($lang_local);
	}
}

# Check template folder
if(!file_exists('template')) {
	die($lang['ERR_NO_TEMPATE']);
}

# Connect to BDS
$dbs = mysql_connect($conf['dbs_server'], $conf['dbs_user'], $conf['dbs_pass']);
if (!$dbs) {
    $template['err'] .= $lang['ERR_DBS_CONNECT'] . mysql_error() . "\n";
}

if(file_exists('install')) {
	# Redirect to install folder or import installation script
	echo 'Installation directory detected.';
	exit();
}

if (!mysql_select_db($conf['dbs_db_name'], $dbs)) {
	$template['err'] .= $lang['ERR_DBS_DB'] . mysql_error() . "\n";
}

# Get user name and check authority

include('modules.php');		# List of modules

?>