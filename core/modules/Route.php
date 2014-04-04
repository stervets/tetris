<?php
// v.1.2.1 small fix - support "-" symbol in the path
// v.1.2 directory prefix support for custom header and footer
// v.1.1 added images support
class Route{
	public $fileName;
	public $htmlType;
	public $imageType;
		
	
	public $prefix; //directory prefix for custom header and footer
	public $files;
	public $vars;
	

	function __construct(){
		
	}

	public function route($path='/'){
		preg_match_all('/[\w\.-]+/', $path, $path);
		$path = $path[0];

		if (!preg_match('/^.+\.html|.+\.json|.+\.jpg|.+\.gif|.+\.png$/i',end($path))){
			array_push($path, 'index.html');
		}
		
		$vars = array();
		
		$fn = array_pop($path);
		$this->fileName = substr($fn, 0, strrpos($fn,'.'));
		$this->htmlType = substr($fn, strlen($fn)-4)=='html';
		
		switch (substr($fn, strlen($fn)-3)){
			case 'jpg' : $this->imageType = 'jpeg';break;
			case 'png' : $this->imageType = 'png';break;
			case 'gif' : $this->imageType = 'gif';break;
			default : $this->imageType = false;
		}
		
		$this->files = array();

		$this->prefix = implode('_',$path);
		$path = '/'.(empty($path)?'':implode('/', $path).'/');
		for($i=0, $cnt=count($fn = explode('_', $this->fileName));$i<$cnt;$i++){
			$this->filename .= array_shift($fn); 
			if ($this->htmlType){
				if (is_file($_SERVER['DOCUMENT_ROOT'].($tfn = '/modules'.$path.$this->filename.'.php'))){
					$this->files['module'] = $tfn;
				}			
				if (is_file($_SERVER['DOCUMENT_ROOT'].'/tpl'.($tfn = $path.$this->filename).'.html')){
					$this->files['tpl'] = $tfn;
				}			
				if (is_file($_SERVER['DOCUMENT_ROOT'].'/assets'.($tfn = '/js'.$path.$this->filename.'.js'))){
					$this->files['js'] = $tfn;
				}
                if (is_file($_SERVER['DOCUMENT_ROOT'].'/assets'.($tfn = '/js/test'.$path.$this->filename.'.js'))){
                    $this->files['jsTest'] = $tfn;
                }

				if (is_file($_SERVER['DOCUMENT_ROOT'].'/assets'.($tfn = '/css'.$path.$this->filename.'.css'))){
					$this->files['css'] = $tfn;
				}			
							
			}if ($this->imageType){
                if (is_file($_SERVER['DOCUMENT_ROOT'].($tfn = '/img'.$path.$this->filename.'.php'))){
					$this->files['module'] = $tfn;
				}			
			}else{
				if (is_file($_SERVER['DOCUMENT_ROOT'].($tfn = '/json'.$path.$this->filename.'.php'))){
					$this->files['json'] = $tfn;
				}			
			}
			
			if (!empty($this->files)){
				$this->vars = $fn;
				break;
			}
			$this->filename .='_';
		}
		
	}
	
}
