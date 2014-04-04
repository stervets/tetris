<?php
/**
 * Класс шаблонизатора
 *
 */
class Tpl implements ArrayAccess{


	public $path; //массив_путей_к_шаблонам
	public $compiled; //общий скомпилированный шаблон
	public $all; //масскив скомпилированных файлов
	// Скомпилированные шаблоны аккумулируются в $compiled 
	private $regex_tmpl = "/<%([\w\s\d]+)%>/";
	private $regex_tmpl_full = "/<%(.+?)%>(.+?)<%\/(\\1)%>/is";
	
	
	/**
	 * Инициализация
	 *
	 * @param $path массив_путей_к_шаблонам
	 */
	function __construct($path = array()){
		$this->path = (is_array($path)?$path:array($path));
		$this->path[] = '.';
		$this->compiled;
	}

	/**
	 * Компилирует часть файла без аккумуляции в $comipled
	 *
	 * @param $filename имя файла
	 * @param unknown_type $parts
	 * @param $vars массив переменных
	 * @param $ext расширение файла
	 * @return Скомпилированный HTML
	 */
	function compile_part($filename, $parts = array(), $vars=array(), $ext='.html'){
		// Я походу здесь когда-то пытался написать обработку только части файла
		// Но по какой-то причине бросил.
		
		$file = $this->load($filename, $ext, true);
		
		//while (trim($s)){
		//		preg_match($this->regex_tmpl,$s,$tmp);
		//}
		__dump($file);
		//return compile_file(, $vars, $ext, false, $parts);
	}
	
	/**
	 * Компилирует файл (чтобы вывести на экран используйте - render() или render_file() или )
	 *
	 * @param $filename имя файла
	 * @param $vars массив переменных
	 * @param $ext Аккумулировать в $compiled
	 * @param $ext расширение файла
	 */
	function compile_file($filename, $vars=array(), $accumulate=true, $ext='.html', $part=array()){
// $part - это походу массив тех отдельных частей файла, которые следовало компилить
// compile_part видимо предназначался для этого
		
		if (!is_array($vars))new Debug('Передаваемый параметр $vars должен быть массивом', E_ERROR, array('Переданная переменная'=>$vars));
		
		$tmpl = $this->load($filename, $ext, (empty($vars)?true:false));
		//__dump($filename);
		$this[$filename] = (empty($vars)?$tmpl[0]:$this->compile($tmpl, $vars));
		
		if ($accumulate)
		$this->compiled.= $this[$filename];
		
		return $this[$filename];
	}
	
	/**
	 * Компилирует и выводит файл в браузер
	 *
	 * @param $filename имя файла
	 * @param $vars переменные
	 * @param $ext расширение файла
	 */
	function render_file($filename, $vars, $ext='.html'){
		echo $this->compile_file($filename, $vars, $ext, false);
	}

	/**
	 * Вывод скомпилированных ф-цией compile_file файлов в браузер
	 *
	 */
	function render(){
		if (!headers_sent()){
			header("Content-Type: text/html; charset=utf-8"); 
		}
		echo $this->compiled;
	}
	
	
	//Служебные функции для интерфейса ArrayAccess
	//Нужны для того, чтобы обращаться к TPL как к массиву: $TPL['myvar'] = 1;
	function offsetExists($offset) {return isset($this->all[$offset]);}
	function offsetGet($offset) {return $this->all[$offset];}
	function offsetSet($offset, $value) {$this->all[$offset] = $value;}
	function offsetUnset($offset) {unset($this->all[$offset]);}

	
	
	/**
	 * Загрузка файла с шаблоном
	 *
	 * @param $file имя_файла
	 * @param $ext расширение_файла
	 * @return unknown
	 */
	function load($file, $ext='.html', $noslice=false){
		
		
		foreach($this->path as $v){
		
		if (($s = @file_get_contents($v."/".$file.$ext))!==false){
		
		$tmpl = ($noslice?$s:$this->slice($s));
		
		if (!is_array($tmpl))$tmpl = array($tmpl);
		return $tmpl;
		}
		}
		
		new Debug(' Не удалось открыть файл с шаблонами', E_WARNING, array('Требуемый файл: '=>$file.$ext, 'Пути:' => $this->path));
		return false;
	}

	/**
	 * Приводит текст в массив шаблона
	 *
	 * @param строка
	 * @return массив
	 */
	function slice($s){
		$i=0;
		$array_present=false;
		$ret = array();
		$bugtrap=0;
		//_dump($s);
		while(($s = trim($s))&&$bugtrap++<10000){
			if ($bugtrap>=10000)new Debug("Ошибка в шаблоне",E_ERROR, array("Шаблон"=>$s));
			preg_match_all($this->regex_tmpl_full,$s,$tmp);
			//__dump($tmp);
			break;
		}
		
		while (trim($s)){
				preg_match($this->regex_tmpl,$s,$tmp);
				
				if (count($tmp)){
				$tag1 = $tmp[0];
				$tag2 = "<%/$tmp[1]%>";
				$tagi = $tmp[1];
				
				if ($del = substr($s,0,strpos($s,$tag1))){
						if (trim($del))$ret[]=$del;
						$s = substr_replace($s,'',strpos($s,$del), strlen($del));
					}
					if (strpos($s, $tag2)!==false){
					$array_present=true;
					
					$pattern = '/'.$tag1.'(.*)'.addcslashes($tag2,'/').'/is'; 
					preg_match($pattern,$s,$tmp);
					$del = $tmp[0];
					$ret[$tagi]=$this->slice($tmp[1]);	
					if (!is_array($ret[$tagi]))$ret[$tagi]=array($ret[$tagi]);
					}else 
					$ret[]=$del=$tag1;
				}else
				$ret[]=$del=$s;
				$s = substr_replace($s,'',strpos($s,$del), strlen($del));
				if ($i++>1000)new Debug("Template error near \"<br><br>".nl2br(htmlspecialchars($s))."\"<br><br>Please check templates", E_ERROR);
		}
		
		if (!$array_present)
		return implode("",$ret);
		else return $ret;
	}

	
	
/*

JOIN 
 Сначала ДОЧЕРНИЙ, потом РОДИТЕЛЬСКИЙ
------
Когда 3 параметра
кладет в каждый элемент $ar 
массив $source под именем $name

Пример:

$r = array(
	0=>array("title"=>"asd"),
	1=>array("title"=>"zxc")
);

$n = array(
	0=>array("num"=>"111"),
	1=>array("num"=>"222")
);

$out = _join("mytag",$n,$r);

на выходе:

$out = array(

	0=>array(
		"title"=>"asd"
		"mytag"=> array(
				0=>array("num"=>"111"),
				1=>array("num"=>"222")
				)
		),
	
	1=>array(
		"title"=>"zxc"
		"mytag"=> array(
				0=>array("num"=>"111"),
				1=>array("num"=>"222")
				)
		)
);


--------------

Когда 2 параметра 
возвращает массив вида array($name=>$source);

Пример:
$r = array(
	0=>array("title"=>"asd"),
	1=>array("title"=>"zxc")
);

$out = _join("mytag",$r);

На выходе:

$out = array(
	"mytag" =>array(
	0=>array("title"=>"asd"),
	1=>array("title"=>"zxc")
		)
	);

*/
	function join($name='', $source='', $ar=array()){
		if (!empty($ar)&&is_array($ar)){
		foreach($ar as $k=>$v)
		$ar[$k][$name]=$source;
		return $ar;}else
		return array($name=>$source);
	}
	
	
	
	///////////////COMPILE TMPL///////////////////////
	/**
	 * Сборка шаблона
	 *
	 * @param $tmpl подготовленный ф-цией load или slice шаблон
	 * @param $vars массив переменных 
	 * @return unknown
	 */
	function compile($tmpl, $vars){
		if (!is_array($vars)){
			new Debug("Компиляция шаблона невозможна: отсутствует массив переменных", E_WARNING, array("Переданная переменная"=>$vars));
			return false;
		}
		
		if(!is_array($tmpl)){
			new Debug("Шаблон отсутсвует", E_WARNING, array("Переданная переменная"=>$tmpl));
			return false;
		}

		$out='';
		$subs = array();
		
		// Абсолютные пути вида <%.img>
		static $abs = array();
			
		
			if (empty($abs))
			foreach($vars as $k=>$v)
			if (!is_array($v))
			$abs['<%^'.$k.'%>'] = $v;

		foreach($vars as $k=>$v){
		if (is_array($v))
		{
		$rep=array();
		foreach($v as $vv)
			if (isset($tmpl[$k])){
				if (is_array($vv)){
					$rep[]=$this->compile($tmpl[$k],$vv);
				}else{ 
					if (is_array($tmpl[$k])){
						$rep[]=$this->compile($tmpl[$k],$v);
						break;
					}
				}
		}
		
		if (!empty($rep))$tmpl[$k]=implode("",$rep);
		
		}else $subs["<%$k%>"] = $v;
		}
		
		//__dump(array_merge($subs,$abs));

		$subs = array_merge($subs,$abs);
			
		foreach($tmpl as $v)
		if (!is_array($v)){
		
		if (is_array($subs))$out.=@strtr($v,$subs);else
		$out.=$v;
		}
		
		/*
		if ($parse){
		if ($zip)ob_start("ob_gzhandler");
		//echo eval(">".$out."<?");
		echo $out;
		
		if ($zip)ob_end_flush();
		return '';
		
		}
		*/
		//__dump($out);
		return $out;
	}
/*

---Test templates---
<br>
<table border=1>
<%a1%>
<tr>
<td>A1 = <%a1v1%></td>
<td><%a3%>
    LEVEL 2 (<%a3v3%>)
    <ul>
    <%a4%>
      <li> LIST <%a4v4%>
		<%alter%>
		<%alter1%>
		<%/alter%>
    <%/a4%>
    </ul>	
    <%/a3%>
</td>
</tr>
<%/a1%>
</table>

<%a2%>
Cycle <%a2v1%><br>
<%/a2%>
*/
/*

$a = _file_tmpl(m1);

$a2 = array();
for($i=0;$i<4;$i++){
$a2[$i]["a2v2"]=$i;
$a2[$i]["b2v2"]=100-$i;
}

$alter = array();
for($i=0;$i<2;$i++){
$alter[]["alter1"]=$i;
}

$a4 = array();
for($i=0;$i<5;$i++){
if ($i%2==0)$a4[$i]["alter"]=$alter;
$a4[$i]["a4v4"]=$i;
}

$a3 = array();
for($i=0;$i<2;$i++){
$a3[$i]["a4"]=$a4;
$a3[$i]["a3v3"]=$i;
}

$a1 = array();
for($i=0;$i<2;$i++){
$a1[$i]["a3"]=$a3;
$a1[$i]["titlea1"]=" TITLE <b>$i</b>";
$a1[$i]["a1v1"]=$i;
}

//_dump($a1);
$m1 = array();
for($i=0;$i<4;$i++){
$m1[$i]=array("alt".($i%2+1) => array("c"=>"ccc", "a"=>"a$i", "b"=>"bbb"));
$m1[$i]["tmp"]="TMP - $i";
$m1[$i]["tmp2"]="TMP2 - $i";
}

//_dump($m1);
$r = array("title"=>"asd", 
"a1"=>$a1,
"a2"=>$a2,
"m1"=>$m1,
);

//_dump($r);
//echo _fill_tmpl($a,$r, true);
//_dump("FINALLY",_fill_tmpl($a,$r));

*/

	
}

?>