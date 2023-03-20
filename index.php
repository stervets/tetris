<?php
//version 1.3 var $GET added. for quick use of $_CORE['route']->vars;
//version 1.2 with custom header and footer support
//version 1.1 with images
require($_SERVER['DOCUMENT_ROOT']."/core/init.php");
$VARS = array();

if (!isset($_SERVER['REDIRECT_URL']))$_SERVER['REDIRECT_URL']='/';

$_CORE['route']->route($_SERVER['REDIRECT_URL']);

$GET = $VARS['ROUTE'] = $_CORE['route']->vars;
//$ADMIN_MODE = $GET

if ($_CORE['route']->htmlType){
	if (isset($_CORE['route']->files['module'])){
	_dump(111);
		require(ROOT_DIR.$_CORE['route']->files['module']);
	}

	$HEADER_SCRIPT = isset($_CORE['route']->files['js'])?"<script src='/assets".$_CORE['route']->files['js']."'></script>":'';
    $HEADER_TEST = isset($_CORE['route']->files['jsTest'])?"<script src='/assets".$_CORE['route']->files['jsTest']."'></script>":'';
	$HEADER_CSS = 	 isset($_CORE['route']->files['css'])?"<link type='text/css' href='/assets".$_CORE['route']->files['css']."' rel='stylesheet' />":'';

	if ($_CORE['route']->prefix){
	_dump(222);
		if (is_file($_SERVER['DOCUMENT_ROOT'].'/tpl/system/'.$_CORE['route']->prefix.'_header.html')&&
			is_file($_SERVER['DOCUMENT_ROOT'].'/tpl/system/'.$_CORE['route']->prefix.'_footer.html')
		){
			$_CORE['route']->prefix.='_';
		}else{
			$_CORE['route']->prefix='';
		}
	}

	$_CORE['tpl']->compile_file('system/'.$_CORE['route']->prefix.'header', array(
			'HEADER_SCRIPT'=>$HEADER_SCRIPT,
            'HEADER_TEST'=>$HEADER_TEST,
			'HEADER_CSS'=>$HEADER_CSS
		));

	if (isset($_CORE['route']->files['tpl'])){
		$_CORE['tpl']->compile_file($_CORE['route']->files['tpl'], $VARS);
	}else{
		if (empty($_CORE['route']->files)){
		_dump('EMPTY');
			$_CORE['tpl']->compile_file($_CORE['defaultPage'], $VARS);
		}
	}

	$_CORE['tpl']->compile_file('system/'.$_CORE['route']->prefix.'footer');


	$_CORE['tpl']->render();
}elseif ($_CORE['route']->imageType){
    if (isset($_CORE['route']->files['module'])){
		header("Content-type: image/".$_CORE['route']->imageType.';');
		require(ROOT_DIR.$_CORE['route']->files['module']);
	}else{
		header("Content-type: image/png;");
		echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/img/system/404.png');
	}
}else{
	header("Content-type: text/html; charset=utf-8");
	if (isset($_CORE['route']->files['json'])){
		require(ROOT_DIR.$_CORE['route']->files['json']);
	}else{
		echo json_encode('File '.$_SERVER['REDIRECT_URL'].' not found');
	}
}

?>
