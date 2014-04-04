<?php
class Mysql{
	
	private $dbhost;
	private $dbname;
	private $dbuser;
	private $dbpass;
	private $id; //ID базы данных
	private $query_id; //ID запроса 
	private $version; // Версия MySQL 
	
	/**
	 * Коструктор класса
	 *
	 * @param $dbhost имя_хоста
	 * @param $dbuser логин 
	 * @param $dbpass пароль
	 * @param $dbname название_БД
	 */
	function __construct($dbhost, $dbuser, $dbpass, $dbname){
			if(!$this->id = mysql_pconnect($dbhost, $dbuser, $dbpass)) {
			new Debug("Невозможно соединиться с базой данных: $dbuser:*@$dbhost", E_ERROR);
			}		
			
			$this->version = mysql_get_server_info();
			if (version_compare($this->version, '4.1', ">=")) mysql_query("/*!40101 SET NAMES 'utf8' */");
			else 
			new Debug("Только для версий MySql 4.1 или выше", E_ERROR);

			$this->dbhost = $dbhost;
			$this->dbuser = $dbuser;
			$this->dbpass = $dbpass;
			$this->select_db($dbname);
	}

	/**
	 * Выбрать базу данных
	 *
	 * @param $dbname имя_БД
	 */
	function select_db($dbname){
		if(!@mysql_select_db($dbname, $this->id)) {
		new Debug("Невозможно выбрать базу данных '$dbname'", E_ERROR);

		}
		$this->dbname = $dbname;
	}


    /**
	 * Запрос к БД
	 *
	 * @param unknown_type $query
	 * @return unknown
	 */
	function query($query)
	{
	// if(!($this->query_id = mysql_query($this->safesql($query), $this->id) )) {
	// safesql в данном случае - параноидальная строчка, которая, кстати, приводт к ошибкам! 
	// Пример: когда $query равно ($query="select * from table where id='1'"), 
	// а так же тормозит каждый запрос из-за лишних обращений
	// к лишним функциям типа ($this->safe_sql, mysql_real_escape_string ($source, $this->id)) 
	// Знаки ' " ( ) .. и т.п.  в адресной строке обрубаются на уровне роутера (Router.php) 
	// 
	// --------------------------------------------------------------------------------
	// ВНИМАНИЕ!!!! ПРОВЕРКИ РОУТЕРА НА ДАННЫЙ МОМЕНТ СПРАВЕДЛИВЫ НА УРОВНЕ АДРЕСНОЙ СТРОКИ т.е. $_GET!
	// ОБЕСПЕЧИТЬ ПРОВЕРКУ НА УРОВНЕ РОУТЕРА В $_POST!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	// --------------------------------------------------------------------------------
	
		if(!($this->query_id = mysql_query($query, $this->id) )) {

			$this->mysql_error = mysql_error();
			$this->mysql_error_num = mysql_errno();
			new Debug("Ошибка MySql (".$this->mysql_error_num ."): <br>&nbsp;&nbsp;".$this->mysql_error."<br><br>&nbsp;&nbsp;".$query, E_ERROR);
		}
		return $this->query_id;
	}
	
	
	function get_row($query_id = '')
	{
		if ($query_id == '') $query_id = $this->query_id;
		return @mysql_fetch_assoc($query_id);
	}


	function fetch_row($query_id = '')
	{
		if ($query_id == '') $query_id = $this->query_id;
		return @mysql_fetch_row($query_id);
	}
	
	function super_query($query){
		$query = $this->query($query);
		$out = array();
		while ($r = $this->get_row($query))
		$out[] = $r;

		return $out;
	}
	
    function safesql( $source )
	{
		if ($this->id) return mysql_real_escape_string ($source, $this->id);
		else return mysql_real_escape_string($source);
	}
	
	function last_id(){
		return mysql_insert_id($this->id);
	}
	
	/**
	 * Добавление данных в таблицу
	 *
	 * @param unknown_type $base
	 * @param array $data
	 * @param bool $show_error
	 * @return unknown
	 */
	function insert ($base, $data)
	{
		foreach ($data as $key => $value) {
			if (strpos($value,'##')===0) $data[$key]=str_replace('##','',$value);
			else	$data[$key]="'".$this->safesql($value)."'";
		}
		
		$keys	=	array_keys($data);
		$values	=	array_values($data);
		
		$keys	=	implode(',',$keys);
		$values	=	implode(',',$values);
		
		$sql="INSERT INTO $base ($keys) VALUES ($values)";
		
		$this->query($sql);
		
		return $this->last_id();
		
	}


	function close()
	{
		@mysql_close($this->id);
	}
	
}


?>