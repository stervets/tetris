<?php
function fail($i=0){
	header("Content-type: image/png;");
	echo file_get_contents($_SERVER['DOCUMENT_ROOT'].'/assets/img/system/404.png');	
	die();	
}

$fail = false;
if (count($_CORE['route']->vars)!=3){
	fail(1);
}

$file = strtr($_CORE['route']->vars[2].'.'.($_CORE['route']->imageType=='jpeg'?'jpg':$_CORE['route']->imageType), array('/'=>'', '\\'=>'', '%'=>''));

if (!is_file($_SERVER['DOCUMENT_ROOT'].'/assets/img/gallery/'.$file)){
	fail(2);
}

$type = $_CORE['route']->vars[0]=='h'?true:false;
$size = (int)$_CORE['route']->vars[1];
if (!($size=abs($size)))fail(3);

if (!$src_img = @imagecreatefromjpeg($_SERVER["DOCUMENT_ROOT"]."/assets/img/gallery/".$file))
if (!$src_img = @imagecreatefrompng($_SERVER["DOCUMENT_ROOT"]."/assets/img/gallery/".$file))
if (!$src_img = @imagecreatefromgif($_SERVER["DOCUMENT_ROOT"]."/assets/img/gallery/".$file))
fail(4);

if ($type){
$new_h = $size;
$new_w = imagesx($src_img)/imagesy($src_img)*$new_h;
}else{
$new_w = $size;
$new_h = imagesy($src_img)/imagesx($src_img)*$new_w;
}

$dst_img = imagecreatetruecolor($new_w,$new_h);
imagecopyresampled($dst_img,$src_img,0,0,0,0,$new_w,$new_h,imagesx($src_img),imagesy($src_img));

//header("Content-type: image/png");
imagepng($dst_img);
?>