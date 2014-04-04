<?php
//v 1.0.1 with authorization

$_CORE = array(
'modules' => array(
	'Debug',
//	'Mysql',
	'Tpl',
	'Route',
),

'debugMode' => true,

'MySQLConfig'	=> array( 
				  'host'	=>	'localhost',
				  'login'	=>	'root',
				  'pass'	=>	'Zaraber32',
				  'dbName'	=>	'chat',
),

'defaultPage' =>'404',
);

function __initDebug(){
	$_SERVER['CORE']['debug'] =  new Debug();
	$_SERVER['CORE']['debug']->set_error_handler();
}

function __initMysql(){
	$_SERVER['CORE']['db'] = new Mysql($_SERVER['CORE']['MySQLConfig']['host'], $_SERVER['CORE']['MySQLConfig']['login'], $_SERVER['CORE']['MySQLConfig']['pass'], $_SERVER['CORE']['MySQLConfig']['dbName']); //MySql
}

function __initTpl(){
	$_SERVER['CORE']['tpl'] = new Tpl('tpl');
}

function __initRoute(){
	$_SERVER['CORE']['route'] = new Route();
}

//////////////////////////////////////////////////

function mmd5($str){
    return $_SERVER['CORE']['db']->safesql(
        md5(str_repeat(md5($str).md5(strrev($str)), 10))
    );
}

function login($login, $password){
    return _query("select * from user where login='".$_SERVER['CORE']['db']->safesql($login)."' and password='".mmd5($password)."'",1);
}

function auth(){
	session_start();
    $approved = true;
    if (isset($_SESSION['session'])){
        if ($session = _query("select * from user where session='".$_SERVER['CORE']['db']->safesql($_SESSION['session'])."' and ip='".$_SERVER['REMOTE_ADDR']."'",1)){

        }else{
            unset($_SESSION['session']);
            $approved = false;
        }
    }else{
        $approved = false;
    }

    if (!$approved){
        if ($_SERVER['CORE']['route']->htmlType){
            header("HTTP/1.1 301 Moved Permanently");
            header("Location: /login.html?".$_SERVER['REQUEST_URI']);
        }else{
            echo json_encode("Authorization required");
        }
        die();
    }
}
