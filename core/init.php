<?php
if (version_compare(phpversion(), '8.1.0', '<') == true) { die ('PHP81 or over Only'); }

date_default_timezone_set('Europe/Moscow');

define('ROOT_DIR', $_SERVER['DOCUMENT_ROOT']);

require(ROOT_DIR.'/core/config.php');
$_SERVER['CORE'] = &$_CORE;

$_CORE['rootDir'] = ROOT_DIR;

error_reporting($_CORE['debugMode']?E_ALL:0);

require(ROOT_DIR.'/core/utils.php');

for($i=0,$j=count($_CORE['modules']);$i<$j;$i++){
	if (is_callable($module = '__init'.$_CORE['modules'][$i])){
	    $file = ROOT_DIR.'/core/modules/'.$_CORE['modules'][$i].'.php';
		if(@is_file($file)){
        			require($file);
        			call_user_func($module);
        		}elseif(error_reporting()){
        			new Debug('Can\'t load model '.$class, E_ERROR);
        		}
	}elseif(error_reporting){
		new Debug('Can\'t load module '.$_CORE['modules'][$i], E_ERROR);
	}
}
