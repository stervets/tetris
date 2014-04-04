<?php
/****
 
 _query();
 _dump();
 _correctmail();
 _mail();
 _win2utf();
 * 
 * 
 *   
 */

function _win2utf($s)
{
	$t = '';
   for($i=0, $m=strlen($s); $i<$m; $i++)
   {
       $c=ord($s[$i]);
       if ($c<=127) {$t.=chr($c); continue; }
       if ($c>=192 && $c<=207)    {$t.=chr(208).chr($c-48); continue; }
       if ($c>=208 && $c<=239) {$t.=chr(208).chr($c-48); continue; }
       if ($c>=240 && $c<=255) {$t.=chr(209).chr($c-112); continue; }
       if ($c==184) { $t.=chr(209).chr(209); continue; };
   if ($c==168) { $t.=chr(208).chr(129);  continue; };
   }
   return $t;
}
 
 
function _correctmail($email){
return preg_match('/^[-_a-zA-Z0-9\.]+@[-_a-zA-Z0-9\.]+\.[a-zA-Z]+$/', $email);
}

function _mail($from="HTTP Server", $to, $subject="", $message){
$headers  = "MIME-Version: 1.0\r\n";
$headers .= "Content-type: text/html; charset=utf-8\r\n";
$headers .= "From: $from\r\n";
return mail($to, $subject, $message, $headers);
}
 
// V 1.5 
function _query($query, $attr=false) {
    $q = mysql_query($query);
    $res = false;
    if ($n = mysql_error()) {
        return false;
    }
    if (!@mysql_num_rows($q)) {
        return false;
    }else
        while ($r = mysql_fetch_assoc($q)
            )$res[] = $r;
    if ($attr && count($res) == 1
        )$res = $res[0];
    return $res;
}

function __dump() {
    global $DUMP_NOECHO;
    $f = func_get_args();
    new Debug("������", E_NOTICE, $f);
//	_dump(func_get_args());
}

//=============================
// _dump();
function _dump() {
    global $DUMP_NOECHO;

    $ver = "VarDump by Foxy 2005 (v 3.1)";

    $bg = false;

    $out = '';

    if (count($f = func_get_args())) {
        if (mysql_error ()
            )$ver.="
 :: </td></tr><tr><td bgcolor=#FF9090 colspan=2><b>MySQL error:</b> " . mysql_error();
        $out = _dump_thead($ver, 0, 1);
        foreach ($f as $v)
            $out.=_dump_val($v, $bg = !$bg);
    }else
        _dump($GLOBALS);
    $out.=_dump_tfoot();
    new Debug("dumper:", E_NOTICE);
    if ($DUMP_NOECHO
        )return $out;else
        echo $out;
}

function _dump_tfoot() {
    return"</table></td></tr></table>\n";
}

function _dump_val($val, $bg=true, $key=false, $level=0) {
    global $DUMP_HIDE;
    static $con = 0;

    $bg = ($bg ? "#FFFFFF" : "#F0F0F7");
    $out = "<tr valign=top><td bgcolor=$bg><nobr>";
    $td = "</nobr></td>" . ($key !== false ? "<td bgcolor=$bg>" . htmlspecialchars($key) . "</td>" : "") . "<td bgcolor=$bg width=100%>";
    if (is_array($val)) {
        $out.=_dump_gettype($val) . $td;
        if (empty($val)
            )$out.="[ EMPTY ARRAY ]";else {
            $bbg = false;
            $out.=_dump_thead("show/hide", 1, ($DUMP_HIDE || $level ? 0 : 1), 1);
            foreach ($val as $k => $v)
                if ($k !== "GLOBALS" && $k !== "plugin_handler" && $k !== "filter_handler")
                    $out.=_dump_val($v, $bbg = !$bbg, $k, 1);
            $out.=_dump_tfoot();
        }
    }else
    if (is_object($val)) {
        $out.=_dump_gettype($val) . $td;
        $out.=_dump_thead(get_class($val) . (get_parent_class($val) ? " (" . get_parent_class($val) . ")" : ""), 1, ($DUMP_HIDE ? 0 : 1), 1);
        $bbbg = false;
        if (is_array($f = get_object_vars($val)))
            foreach ($f as $k => $v)
                $out.=_dump_val($v, $bbbg = !$bbbg, $k, 1);

        if (is_array($f = get_class_methods($val))) {
            $con++;
            $out.= "<tr><td align=center colspan=3  style='height:20px;background:#E0E0E0;cursor:hand' onclick=\"dmet$con.style.display=(dmet$con.style.display=='block'?'none':'block');\" onmouseover=\"style.background='#FFFF00';\" onmouseout=\"style.background='#E0E0E0';\"><b>Methods</b></td></tr>
		<tr><td colspan=3 style='display:none' bgcolor=#EFEFEF id='dmet$con'>
\n<table border=0 width=100% height=100% cellspacing=1 bgcolor=#000000 cellpadding=2>
";
            $bbbg = false;
            foreach ($f as $v)
                $out.= "<tr><td colspan=3 bgcolor=#" . (($bbbg = !$bbbg) ? "FFFFFF" : "F5F5F5") . ">$v()</td></tr>";
            $out.="</table></td></tr>";
        }

        $out.=_dump_tfoot();
    }else
        $out.=_dump_gettype($val) . $td . _dump_getval($val);

    return $out . "</td></tr>\n";
}

function _dump_thead($name, $num, $opened, $width='') {
    static $con = 0;
    $con++;
    $width = ($width ? "width=100%" : "");
    $opened = ($opened ? "block" : "none");
    $num = ($num ? "<td bgcolor=#EFEFEF><b>Key</b></td>" : "");
    $span = ($num ? 3 : 2);
    $out = "\n<table $width border=0 cellspacing=1 cellpadding=0 bgcolor=#000000 style='font-family:Verdana;font-size:11;color:#000000;font-weight:normal;'>";
    $out.="\n<tr align=center><td style='height:18px;background:#E0E0E0;cursor:hand' onclick=\"dtr$con.style.display=(dtr$con.style.display=='block'?'none':'block');\" onmouseover=\"style.background='#FFFF00';\" onmouseout=\"style.background='#E0E0E0';\"><nobr><b>&nbsp;:: $name ::&nbsp;</b></nobr></td></tr>";
    $out.="
\n<tr><td style='display:$opened' bgcolor=#EFEFEF id='dtr$con'>
\n<table border=0 width=100% height=100% cellspacing=1 bgcolor=#000000 cellpadding=2>
\n<tr align=center><td bgcolor=#EFEFEF><b>Type</b></td>$num<td bgcolor=#EFEFEF><b>Value</b></td></tr>
";
    return $out;
}

function _dump_getval($m) {
    if ($m === true
        )$m = "[ True ]";
    else if ($m === false
        )$m = "[ False ]";
    else if ($m === ''
        )$m = "[ Empty string ]";
    else if (!isset($m)
        )$m = "[ Unsetted ]";
    else if (is_resource($m)
        )$m = (string) $m;
    return nl2br(htmlspecialchars(wordwrap($m, 75, "\n", 1)));
}

function _dump_gettype($m) {
    if (is_array($m)
        )$m = "Array(" . count($m) . ")";
    else if (is_object($m)
        )$m = "Object(" . count(get_object_vars($m)) . ")";
    else if (is_string($m)
        )$m = "String(" . strlen($m) . ")";
    else if (is_resource($m)
        )$m = "Resource (" . get_resource_type($m) . ")";
    else
        $m=gettype($m);
    return $m;
}

//=========END _dump()========
?>