<?php
class Debug extends  Exception {


	var $fsize = "14px";
	var $font = "Verdana";
	
	
	
	private $msgcol = array(//Цвета
							"D8DDCC", // Notice
							"ffff66", // Warning
							"ff6666", // Error
							); 

	private $msgtype = array(
							"",
							"Предупреждение: ",
							"Ошибка! ",
							); 
	
	
	function set_error_handler(){
		set_error_handler(array($this,'handler'));
	}

	function restore_error_handler(){
				restore_error_handler();
	}

	function __construct($msg='', $code=0, $vars=array()){
	parent::__construct($msg, $code);
	if (!$code)return;
		
	$this->out($code,$msg,array_merge(array( 
							'Файл'=> $this->getFile(),
							'Строка'=>$this->getLine(),
							'Стек'=>$this->getTraceAsString(), 
							),(is_array($vars)?$vars:array())));
	if ($code==E_ERROR||$code==E_USER_ERROR)die();
	}
	
	function __destruct(){
	}
	
	function dump(){
		$f = func_get_args();
		if (@count($f[0])){	
			$this->out(E_USER_NOTICE,'Debug',$f[0],true,true);
		}else 	$this->out(E_USER_NOTICE,'Global dump',$GLOBALS,true, true);

	
	}
	

	function getval($m)
	{
	if ($m===true)$m="[ True ]";
	else if ($m===false)$m="[ False ]";
	else if ($m==='')$m="[ Empty string ]";
	else if (!isset($m))$m="[ Unsetted ]"; 
	else if (is_resource($m))$m=(string)$m;
	return nl2br(htmlspecialchars(wordwrap($m,100,"\n",1)));
	}
	
	function gettype($m)
	{
	if (is_array($m))$m="Array(".count($m).")";
	else if (is_object($m))$m="Object(".count(get_object_vars($m)).")";
	else if (is_string($m))$m="String(".strlen($m).")";
	else if (is_resource($m))$m="Resource (".get_resource_type($m).")";
	else $m=gettype($m); 
	return $m;
	}
	
	private $con = 0;
	
// вывод в браузер пользователя	
	function out($type, $title, $arg=array(), $opened=true, $show_type = false, $show = true, $show_pic=true){
		//Котроллер выпадающих меню... по идее должен инкрементиться...
		//$this -> con++;
		$this -> con = rand(0,0xFFFFFF);
		
		$pic = '';
		static $con=0;
		$con++;
		//$con = rand(0,0xFFFFFF);
		switch ($type){
			case E_NOTICE: $pic = self::pic1;$type=0;break;
			case E_USER_NOTICE: $pic = self::pic1;$type=0;break;
			case E_WARNING: $pic = self::pic2;$type=1;break;
			case E_USER_WARNING: $pic = self::pic2;$type=1;break;
			case E_USER_ERROR: $pic = self::pic3;$type=2;break;
			case E_ERROR: $pic = self::pic3;$type=2;break;
			default: $pic=''; $type=1;
		}
//		echo $pic;
		$opened = ($opened?"block":"none");
		$out = "
		<style>
		.debugger_pic td{
			padding:0px !important;
		}
		</style>
		<table cellspacing=1 cellpadding=2 border=0 style='background-color:#808080'>
		<tr><td style='background:#{$this->msgcol[$type]};cursor:hand;' onclick=\"dump$this->con.style.display=(dump$this->con.style.display=='block'?'none':'block');\" onmousemove=\"style.background='#DDDDDD';\" onmouseout=\"style.background='#{$this->msgcol[$type]}';\">
				<table cellspacing=0 cellpadding=0 border=0>
				<tr>
				".($show_pic?"<td>&nbsp;</td><td width=15% align=left>".$pic."</td><td>&nbsp;&nbsp;</td>":'')."
				<td style='font-name:$this->font;font-size:$this->fsize;'><b><nobr>{$this->msgtype[$type]}$title</nobr></b></td></tr>
				</table>
		</td></tr>
		<tr>
			<td id='dump$this->con' style='display:$opened;' width=100% style='background-color:#AAAAAA'>
			<table cellspacing=1 cellpadding=4 border=0 width=100% height=100% style='background-color:#808080'>
		";
		
		if (!empty($arg))
		foreach ($arg as $k=>$v){
			$type = ($show_type?"<td align=right style='background-color:#FFFFFF;color:#404040;font-name:$this->font;font-size:$this->fsize;'>".$this->gettype($v)."</td>":'');
			
			$out .= "<tr>
					$type
				    <td align=right style='background-color:#FFFFFF;color:#404040;font-name:$this->font;font-size:$this->fsize;'>".htmlspecialchars($k)."</td>
				    <td width=100% align=left  style='background-color:#FFFFFF;color:#404040;font-name:$this->font;font-size:$this->fsize;'>
				    ";
			if ($k==="GLOBALS"){
			$out.='{RECURSION}';
			}else{
			if ($con>10)return $out."{RECURSION}</td></tr>";	
			if (is_object($v)){
			$obj = array('Properties'=>get_object_vars($v), 'Methods'=> get_class_methods($v));
			
			$out.=$this->out(E_USER_NOTICE, "[ OBJECT \"".get_class($v).(get_parent_class($v)?" (".get_parent_class($v).")":"")."\"]", $obj, true,true,false,false);

			}else
			$out.=(is_array($v)?(empty($v)?'[ EMPTY ARRAY ]':$this->out(E_USER_NOTICE,'[ ARRAY ]',$v, ($con==1?true:false), true, false,false)):$this->getval($v));

			}			
			$out.="</td> </tr>\n";
		}
		
		$out.= "
			</table>
		</td></tr>
		</table>";
		$con--;
		
		if ($show){
			if (!headers_sent()){
				header("Content-Type: text/html; charset=utf-8"); 
			}
			echo $out;
		}else return $out;
	}
	
	
	
	
	// Обработчик ошибок
	function handler($eno, $estr, $efile, $eline){
		global $_CONFIG;
		parent::__construct($estr, $eno);
		if (!error_reporting())return;
			
	$msg = $this->getMessage();	
	
	$stack = nl2br(@strtr($this->getTraceAsString(),array($_CONFIG['db']['login']=>'Логин скрыт', $_CONFIG['db']['pass']=>'Пароль скрыт', $_CONFIG['db']['dbname']=>'Имя БД скрыто')));
	//_dump($eno, $estr, $efile, $eline, E_USER_NOTICE);
	//_dump($this->getTrace());

	$this->out($eno, $estr, array(
							'Файл'=> $efile,
							'Строка'=>$eline,
							'Стек'=>$stack, 
							));
	if ($eno==E_USER_ERROR)die();
	}
	
	
	
	const pic1 = "
		<table class='debugger_pic' style='width:16px' align=center border=0 CELLSPACING=0 CELLPADDING=0>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#2ed558 width=1 height=1></td><td bgcolor=#31d45a width=1 height=1></td><td bgcolor=#34d45c width=1 height=1></td><td bgcolor=#31d259 width=1 height=1></td><td bgcolor=#2ad053 width=1 height=1></td><td bgcolor=#23ce4e width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#2fd559 width=1 height=1></td><td bgcolor=#32d65b width=1 height=1></td><td bgcolor=#14cf43 width=1 height=1></td><td bgcolor=#03cc36 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#03cc35 width=1 height=1></td><td bgcolor=#0fcc3e width=1 height=1></td><td bgcolor=#22cb4c width=1 height=1></td><td bgcolor=#1dc948 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#34d65d width=1 height=1></td><td bgcolor=#20d24d width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#13c940 width=1 height=1></td><td bgcolor=#1cc646 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#2fd559 width=1 height=1></td><td bgcolor=#20d24d width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#10c73d width=1 height=1></td><td bgcolor=#14c340 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#32d65b width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#60df80 width=1 height=1></td><td bgcolor=#3fd965 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#14c13f width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td bgcolor=#2cd456 width=1 height=1></td><td bgcolor=#14cf43 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#40d966 width=1 height=1></td><td bgcolor=#dff9e5 width=1 height=1></td><td bgcolor=#5fdf7f width=1 height=1></td><td bgcolor=#00c230 width=1 height=1></td><td bgcolor=#00c531 width=1 height=1></td><td bgcolor=#08c737 width=1 height=1></td><td bgcolor=#0dc03a width=1 height=1></td></tr>
		<tr><td bgcolor=#35d55d width=1 height=1></td><td bgcolor=#03cc36 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#20d24d width=1 height=1></td><td bgcolor=#30d659 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#90e9a6 width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#6fde8b width=1 height=1></td><td bgcolor=#00b42d width=1 height=1></td><td bgcolor=#00c230 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#01cb34 width=1 height=1></td><td bgcolor=#0ebb39 width=1 height=1></td></tr>
		<tr><td bgcolor=#34d45c width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#bff2cc width=1 height=1></td><td bgcolor=#90e7a6 width=1 height=1></td><td bgcolor=#10cb3f width=1 height=1></td><td bgcolor=#afefbf width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#afeabe width=1 height=1></td><td bgcolor=#00b02c width=1 height=1></td><td bgcolor=#00c030 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#0cb837 width=1 height=1></td></tr>
		<tr><td bgcolor=#31d259 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#30d659 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#eefbf1 width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#effbf2 width=1 height=1></td><td bgcolor=#0fb538 width=1 height=1></td><td bgcolor=#00b92e width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#09b735 width=1 height=1></td></tr>
		<tr><td bgcolor=#2dd056 width=1 height=1></td><td bgcolor=#03cc35 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#8fe9a5 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#5fcd7b width=1 height=1></td><td bgcolor=#00b22c width=1 height=1></td><td bgcolor=#00ca33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#01cb33 width=1 height=1></td><td bgcolor=#06b532 width=1 height=1></td></tr>
		<tr><td bgcolor=#21ce4c width=1 height=1></td><td bgcolor=#0fcc3e width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#0fcf3f width=1 height=1></td><td bgcolor=#9fe6b1 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#dff5e5 width=1 height=1></td><td bgcolor=#00b02c width=1 height=1></td><td bgcolor=#00c230 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#02c333 width=1 height=1></td><td bgcolor=#03b930 width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#22cb4c width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00ca33 width=1 height=1></td><td bgcolor=#5fd47c width=1 height=1></td><td bgcolor=#effaf2 width=1 height=1></td><td bgcolor=#4fc86d width=1 height=1></td><td bgcolor=#00b42d width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#04b630 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#1dc948 width=1 height=1></td><td bgcolor=#13c940 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#2fcd56 width=1 height=1></td><td bgcolor=#00b22c width=1 height=1></td><td bgcolor=#00c331 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#02be31 width=1 height=1></td><td bgcolor=#01b62e width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#1cc646 width=1 height=1></td><td bgcolor=#10c73d width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00c732 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#02be31 width=1 height=1></td><td bgcolor=#01b42e width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#14c340 width=1 height=1></td><td bgcolor=#14c13f width=1 height=1></td><td bgcolor=#08c737 width=1 height=1></td><td bgcolor=#01cb34 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#00cc33 width=1 height=1></td><td bgcolor=#01cb33 width=1 height=1></td><td bgcolor=#02c333 width=1 height=1></td><td bgcolor=#04b630 width=1 height=1></td><td bgcolor=#01b62e width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#0ebf3a width=1 height=1></td><td bgcolor=#0dbc39 width=1 height=1></td><td bgcolor=#0cb837 width=1 height=1></td><td bgcolor=#09b735 width=1 height=1></td><td bgcolor=#06b732 width=1 height=1></td><td bgcolor=#03b830 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		</table>
		";
		
	
	const pic2 =  "
		<table  class='debugger_pic' style='width:16px' align=center border=0 CELLSPACING=0 CELLPADDING=0>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#ffd52e width=1 height=1></td><td bgcolor=#fed531 width=1 height=1></td><td bgcolor=#fdd534 width=1 height=1></td><td bgcolor=#fcd431 width=1 height=1></td><td bgcolor=#fbd12a width=1 height=1></td><td bgcolor=#fbd023 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#ffd52f width=1 height=1></td><td bgcolor=#ffd632 width=1 height=1></td><td bgcolor=#ffd014 width=1 height=1></td><td bgcolor=#ffcd03 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc03 width=1 height=1></td><td bgcolor=#fdcd0f width=1 height=1></td><td bgcolor=#f9ce22 width=1 height=1></td><td bgcolor=#f8cd1d width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#ffd634 width=1 height=1></td><td bgcolor=#ffd220 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#facc13 width=1 height=1></td><td bgcolor=#f6ca1c width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#ffd52f width=1 height=1></td><td bgcolor=#ffd220 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#403d30 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#403d30 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f9ca10 width=1 height=1></td><td bgcolor=#f5c815 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#ffd632 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#665926 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#665f43 width=1 height=1></td><td bgcolor=#ffe26c width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f4c714 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td bgcolor=#ffd42c width=1 height=1></td><td bgcolor=#ffd014 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#8d761d width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#8d804f width=1 height=1></td><td bgcolor=#ffdd56 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#fac908 width=1 height=1></td><td bgcolor=#f4c50d width=1 height=1></td></tr>
		<tr><td bgcolor=#fed635 width=1 height=1></td><td bgcolor=#ffcd03 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#a68916 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#a69657 width=1 height=1></td><td bgcolor=#ffda48 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#fecb01 width=1 height=1></td><td bgcolor=#f0c30e width=1 height=1></td></tr>
		<tr><td bgcolor=#fdd534 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#cda60d width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#cdb863 width=1 height=1></td><td bgcolor=#ffd739 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#eec10c width=1 height=1></td></tr>
		<tr><td bgcolor=#fcd431 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f3c303 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#f3d96f width=1 height=1></td><td bgcolor=#ffd21c width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#edbf0a width=1 height=1></td></tr>
		<tr><td bgcolor=#fbd22d width=1 height=1></td><td bgcolor=#ffcc03 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcf0e width=1 height=1></td><td bgcolor=#ffe373 width=1 height=1></td><td bgcolor=#ffe373 width=1 height=1></td><td bgcolor=#ffcf0e width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#fecb01 width=1 height=1></td><td bgcolor=#edbf07 width=1 height=1></td></tr>
		<tr><td bgcolor=#fbcf21 width=1 height=1></td><td bgcolor=#fdcd0f width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#e5b906 width=1 height=1></td><td bgcolor=#8c761d width=1 height=1></td><td bgcolor=#8c7a36 width=1 height=1></td><td bgcolor=#e5c238 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f8c703 width=1 height=1></td><td bgcolor=#f0c003 width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#f9ce22 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#595029 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#595236 width=1 height=1></td><td bgcolor=#ffcf0e width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#eebf04 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#f8cd1d width=1 height=1></td><td bgcolor=#facc13 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#403d30 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#333333 width=1 height=1></td><td bgcolor=#403e37 width=1 height=1></td><td bgcolor=#ffdf5d width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f4c403 width=1 height=1></td><td bgcolor=#eebf01 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#f6ca1c width=1 height=1></td><td bgcolor=#f9ca10 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#b39313 width=1 height=1></td><td bgcolor=#403e37 width=1 height=1></td><td bgcolor=#403e37 width=1 height=1></td><td bgcolor=#b3a15b width=1 height=1></td><td bgcolor=#ffe26c width=1 height=1></td><td bgcolor=#ffcc00 width=1 height=1></td><td bgcolor=#f4c403 width=1 height=1></td><td bgcolor=#ecbd01 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#f5c815 width=1 height=1></td><td bgcolor=#f4c714 width=1 height=1></td><td bgcolor=#fac908 width=1 height=1></td><td bgcolor=#fecb01 width=1 height=1></td><td bgcolor=#ffd52b width=1 height=1></td><td bgcolor=#ffe26c width=1 height=1></td><td bgcolor=#ffe16c width=1 height=1></td><td bgcolor=#fbd12d width=1 height=1></td><td bgcolor=#eebf04 width=1 height=1></td><td bgcolor=#eebf01 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#f3c50e width=1 height=1></td><td bgcolor=#f1c30d width=1 height=1></td><td bgcolor=#eec10c width=1 height=1></td><td bgcolor=#edbf0a width=1 height=1></td><td bgcolor=#eec006 width=1 height=1></td><td bgcolor=#efc004 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		</table>
		";
		
	const pic3 =  "
		<table  class='debugger_pic' style='width:16px' align=center border=0 CELLSPACING=0 CELLPADDING=0>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#d24f2e width=1 height=1></td><td bgcolor=#d25131 width=1 height=1></td><td bgcolor=#d15334 width=1 height=1></td><td bgcolor=#cf5131 width=1 height=1></td><td bgcolor=#cd4b2a width=1 height=1></td><td bgcolor=#cb4523 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#d3502f width=1 height=1></td><td bgcolor=#d35232 width=1 height=1></td><td bgcolor=#cb3914 width=1 height=1></td><td bgcolor=#c62a03 width=1 height=1></td><td bgcolor=#c32700 width=1 height=1></td><td bgcolor=#c32700 width=1 height=1></td><td bgcolor=#c32903 width=1 height=1></td><td bgcolor=#c6340f width=1 height=1></td><td bgcolor=#c74321 width=1 height=1></td><td bgcolor=#c73f1d width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#d45434 width=1 height=1></td><td bgcolor=#cf4320 width=1 height=1></td><td bgcolor=#c42700 width=1 height=1></td><td bgcolor=#c12600 width=1 height=1></td><td bgcolor=#be2600 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#bc2600 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#be2600 width=1 height=1></td><td bgcolor=#c12600 width=1 height=1></td><td bgcolor=#c33613 width=1 height=1></td><td bgcolor=#c33d1b width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#d3502f width=1 height=1></td><td bgcolor=#cf4320 width=1 height=1></td><td bgcolor=#c32700 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#bf3210 width=1 height=1></td><td bgcolor=#b82500 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#bc310e width=1 height=1></td><td bgcolor=#bb2500 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#c03310 width=1 height=1></td><td bgcolor=#c13714 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#d35232 width=1 height=1></td><td bgcolor=#c42700 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#e5ac9e width=1 height=1></td><td bgcolor=#f0d2cb width=1 height=1></td><td bgcolor=#b4300f width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#b5300e width=1 height=1></td><td bgcolor=#ecc2b8 width=1 height=1></td><td bgcolor=#df9b8a width=1 height=1></td><td bgcolor=#ba2500 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#bc3513 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td bgcolor=#d24d2c width=1 height=1></td><td bgcolor=#cb3914 width=1 height=1></td><td bgcolor=#c12600 width=1 height=1></td><td bgcolor=#bf320f width=1 height=1></td><td bgcolor=#f1d5ce width=1 height=1></td><td bgcolor=#fefafa width=1 height=1></td><td bgcolor=#eccfc7 width=1 height=1></td><td bgcolor=#ae2f0f width=1 height=1></td><td bgcolor=#ae2f0f width=1 height=1></td><td bgcolor=#ebc5bc width=1 height=1></td><td bgcolor=#f9e7e3 width=1 height=1></td><td bgcolor=#e9beb4 width=1 height=1></td><td bgcolor=#b02d0d width=1 height=1></td><td bgcolor=#bb2500 width=1 height=1></td><td bgcolor=#be2b07 width=1 height=1></td><td bgcolor=#bc300d width=1 height=1></td></tr>
		<tr><td bgcolor=#d35535 width=1 height=1></td><td bgcolor=#c62a03 width=1 height=1></td><td bgcolor=#be2600 width=1 height=1></td><td bgcolor=#b82500 width=1 height=1></td><td bgcolor=#b7310f width=1 height=1></td><td bgcolor=#edd1cb width=1 height=1></td><td bgcolor=#fdf7f5 width=1 height=1></td><td bgcolor=#eacbc3 width=1 height=1></td><td bgcolor=#eac8c0 width=1 height=1></td><td bgcolor=#faebe7 width=1 height=1></td><td bgcolor=#e8c2b8 width=1 height=1></td><td bgcolor=#a62b0d width=1 height=1></td><td bgcolor=#a62200 width=1 height=1></td><td bgcolor=#b72500 width=1 height=1></td><td bgcolor=#bd2701 width=1 height=1></td><td bgcolor=#b72f0e width=1 height=1></td></tr>
		<tr><td bgcolor=#d15334 width=1 height=1></td><td bgcolor=#c32700 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b02300 width=1 height=1></td><td bgcolor=#ae2f0f width=1 height=1></td><td bgcolor=#ebcfc7 width=1 height=1></td><td bgcolor=#fcf3f0 width=1 height=1></td><td bgcolor=#fbefec width=1 height=1></td><td bgcolor=#e8c5bc width=1 height=1></td><td bgcolor=#a12b0d width=1 height=1></td><td bgcolor=#a12000 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#b32d0c width=1 height=1></td></tr>
		<tr><td bgcolor=#cf5131 width=1 height=1></td><td bgcolor=#c32700 width=1 height=1></td><td bgcolor=#bc2600 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#ae3010 width=1 height=1></td><td bgcolor=#eccfc7 width=1 height=1></td><td bgcolor=#fcf3f0 width=1 height=1></td><td bgcolor=#fbefec width=1 height=1></td><td bgcolor=#e8c4bc width=1 height=1></td><td bgcolor=#a32c0e width=1 height=1></td><td bgcolor=#a82200 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#bc2600 width=1 height=1></td><td bgcolor=#b22b09 width=1 height=1></td></tr>
		<tr><td bgcolor=#cd4d2d width=1 height=1></td><td bgcolor=#c32903 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b53110 width=1 height=1></td><td bgcolor=#eed1cb width=1 height=1></td><td bgcolor=#fdf7f5 width=1 height=1></td><td bgcolor=#eacbc3 width=1 height=1></td><td bgcolor=#e8c8c0 width=1 height=1></td><td bgcolor=#faebe7 width=1 height=1></td><td bgcolor=#e8c2b8 width=1 height=1></td><td bgcolor=#ae2e0e width=1 height=1></td><td bgcolor=#b02300 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#bc2601 width=1 height=1></td><td bgcolor=#b02806 width=1 height=1></td></tr>
		<tr><td bgcolor=#cb4321 width=1 height=1></td><td bgcolor=#c6340f width=1 height=1></td><td bgcolor=#be2600 width=1 height=1></td><td bgcolor=#bc3310 width=1 height=1></td><td bgcolor=#f1d5ce width=1 height=1></td><td bgcolor=#fefafa width=1 height=1></td><td bgcolor=#ebcfc7 width=1 height=1></td><td bgcolor=#a22b0e width=1 height=1></td><td bgcolor=#a32c0e width=1 height=1></td><td bgcolor=#e9c5bc width=1 height=1></td><td bgcolor=#f9e7e3 width=1 height=1></td><td bgcolor=#e8beb4 width=1 height=1></td><td bgcolor=#b5300e width=1 height=1></td><td bgcolor=#b82500 width=1 height=1></td><td bgcolor=#b82702 width=1 height=1></td><td bgcolor=#b42603 width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#c74321 width=1 height=1></td><td bgcolor=#c12600 width=1 height=1></td><td bgcolor=#bb2500 width=1 height=1></td><td bgcolor=#e4ac9e width=1 height=1></td><td bgcolor=#edd1cb width=1 height=1></td><td bgcolor=#a62d0e width=1 height=1></td><td bgcolor=#a12000 width=1 height=1></td><td bgcolor=#a82200 width=1 height=1></td><td bgcolor=#ae2e0e width=1 height=1></td><td bgcolor=#e9c2b8 width=1 height=1></td><td bgcolor=#d89a8a width=1 height=1></td><td bgcolor=#a92200 width=1 height=1></td><td bgcolor=#ba2500 width=1 height=1></td><td bgcolor=#b02603 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td bgcolor=#c73f1d width=1 height=1></td><td bgcolor=#c33613 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#ba2500 width=1 height=1></td><td bgcolor=#b5300f width=1 height=1></td><td bgcolor=#a62200 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#af2300 width=1 height=1></td><td bgcolor=#b02300 width=1 height=1></td><td bgcolor=#b52f0d width=1 height=1></td><td bgcolor=#a92200 width=1 height=1></td><td bgcolor=#ae2300 width=1 height=1></td><td bgcolor=#b52602 width=1 height=1></td><td bgcolor=#b12401 width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#c33d1b width=1 height=1></td><td bgcolor=#c03310 width=1 height=1></td><td bgcolor=#bf2600 width=1 height=1></td><td bgcolor=#bb2500 width=1 height=1></td><td bgcolor=#b52400 width=1 height=1></td><td bgcolor=#b52400 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b62400 width=1 height=1></td><td bgcolor=#b82500 width=1 height=1></td><td bgcolor=#ba2500 width=1 height=1></td><td bgcolor=#b52602 width=1 height=1></td><td bgcolor=#af2401 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#c13714 width=1 height=1></td><td bgcolor=#bc3513 width=1 height=1></td><td bgcolor=#be2b07 width=1 height=1></td><td bgcolor=#bd2701 width=1 height=1></td><td bgcolor=#bd2600 width=1 height=1></td><td bgcolor=#bc2600 width=1 height=1></td><td bgcolor=#bc2601 width=1 height=1></td><td bgcolor=#b82702 width=1 height=1></td><td bgcolor=#b02603 width=1 height=1></td><td bgcolor=#b12401 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		<tr><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td bgcolor=#bc310e width=1 height=1></td><td bgcolor=#b82f0d width=1 height=1></td><td bgcolor=#b32d0c width=1 height=1></td><td bgcolor=#b22b09 width=1 height=1></td><td bgcolor=#b22806 width=1 height=1></td><td bgcolor=#b32603 width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td><td  width=1 height=1></td></tr>
		</table>
		
		";
		
	

}

?>