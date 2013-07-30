package utilits.openfl;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tilesheet;

/**
 * ...
 * @author Vakulin S.S.
 */
class Tile
{

	private var _bitmapData:BitmapData;
	private var tilesheet:Tilesheet;
	private var _graphics:Graphics;
	
	private var _childNum:Int = 0;
	
	/**
	   //tile = new Tile(graphics, "img/rabbit_alpha_26x37.png");
		var bitmapData:BitmapData = new BitmapData(w, h, false, 0x00AA00);
		tile = new Tile(graphics, bitmapData );
		tile.createClone();
		
		updateFunction(){
			graphics.clear();
			tile.bitmapData.fillRect(new Rectangle(0,0,tile.bitmapData.width, tile.bitmapData.height),0x00AA00);
			tile.bitmapData.fillRect(new Rectangle(10+Std.int(Math.random()*w-10),10+Std.int(Math.random()*h-10),10,10), 0xFF0000);
			tile.drawChildInPosition(0, 100, 50);
		}
		
	 * @param	graphics
	 * @param	bitmapData
	 * @param	x
	 * @param	y
	 */
	public function new(graphics:Graphics, bitmapData:BitmapData, x:Float=0.0, y:Float=0.0) 
	{
		_graphics = graphics;
		
		//bitmapData= new BitmapData(100, 100, false, 0x2C2CCF);
		_bitmapData = bitmapData;
		 
		//this.bitmapData = new BitmapData(bitmapData.width, bitmapData.height);
		//this.bitmapData = bitmapData;
	 
		tilesheet = new Tilesheet (_bitmapData);
		
	}
	
	
	public function createClone():Int {
		
		var tileId:Int = tilesheet.addTileRect (new Rectangle (0, 0, _bitmapData.width, _bitmapData.height));
		_childNum++;
		
		return tileId;
	}
	
	
	private static var MSG:String = "Child index out of bounds! Run tile.createClone()";
	
	
	/**
	 * Clear graphics before draw
	 * @param	childId
	 * @param	x
	 * @param	y
	 */
	public function drawChildInPosition(childId:Int = 0 , x:Float = 0, y:Float) {
		if(childId < _childNum){
			tilesheet.drawTiles (_graphics, [ x, y, childId ]);
		}else {
			trace("Error message : " + MSG );
		}
		
	}
	
	public function clear():Void {
		tilesheet = null;
		_bitmapData = null;
		
	}
	
	// GET / SET
	function get_graphics():Graphics 
	{
		return _graphics;
	}
	
	function set_graphics(value:Graphics):Graphics 
	{
		return _graphics = value;
	}
	
	public var graphics(get_graphics, set_graphics):Graphics;
	
	
	function get_bitmapData():BitmapData 
	{
		return _bitmapData;
		//return tilesheet.getBitmap();
	}
	
	
	
	public var bitmapData(get_bitmapData, null):BitmapData;
	
	
 
	 
	
	
	
	function get_childNum():Int 
	{
		return _childNum;
	}
	
	 
	 
	
}