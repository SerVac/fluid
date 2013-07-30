package fluids;


 
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import utilits.openfl.Tile;

import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.Lib;
import openfl.Assets;
import openfl.display.FPS;


//import verlet.utilits.UtilitsMath;

//[SWF(width="800", height="800", backgroundColor="#888888", frameRate="60")]
class DemosFluidsMod extends Sprite {

    private var backgroundColor:Int = 0x000000;

    public static var stageW:Int = 800;
    public static var stageH:Int = 800;

    var fluidSolver:NavierStokesSolverMod;
    var particles:flash.Vector<FluidParticle>;
    var numParticles:Int;

    var visc:Float;
    var diff:Float;
    var limitVelocity:Float;
    var vScale:Float;
    var velocityScale:Float;

    private var bitmap:Bitmap;
    private var bitmapData:BitmapData;

    public static var DRAW_SCALE:Float = 0.5;
    public static var FLUID_WIDTH:Int = 50;
    public static var isw:Float = 1 / stageW;
    public static var ish:Float = 1 / stageH;

   public function new () {
		super ();
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		init();
	}
 
	
	
    private var N:Int;
    private var cellHeight:Float;
    private var cellWidth:Float;
    private var gridLayer:Sprite ;
    private var motionLayer:Sprite  ;
    private var particleLayer:Sprite  ;

    private var rect:Rectangle;
    private var fade:BitmapData;
    private var fluidImage:Bitmap;
	
	private var bounds:Rectangle ;
    private var shape:Shape ;
	private var sizeR:Int = 2;
    private var sizeRdiv2:Int ;
	private var rectPix:Rectangle ;

	private var layer0:Sprite;
	private var layer1:Sprite;
	  
	private var layer0_tile:Sprite;
	  
	var tile:Tile;
    private function init( ):Void {
        stageW = 600;
		stageH = 600;
		
		stage.frameRate = 40;
		
		layer0 = new Sprite();
		layer1 = new Sprite();
		
		sizeR = Std.int(sizeR * 0.5);
		rectPix = new Rectangle(0, 0, sizeR, sizeR);
		shape = new Shape();
		bounds = new Rectangle();
		gridLayer = new Sprite();
		motionLayer = new Sprite();
		particleLayer = new Sprite();
		
        rect = new Rectangle(0, 0, stageW, stageH);
		
		addChild(layer0);
		addChild(layer1);
		layer1.addChild(new FPS(0,0,0xffffff));
		
		
        layer0.addChild(gridLayer);
        layer0.addChild(motionLayer);
        //addChild(particleLayer);
		
		layer0_tile = new Sprite();
        layer0.addChild(layer0_tile);
		
        bitmapData = new BitmapData(stageW, stageH, false, backgroundColor);
		tile = new Tile(layer0_tile.graphics, bitmapData );
		tile.createClone();
        //bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, true);
        //layer0.addChild(bitmap);
		
		 
		
		
		var fps:Int = 60;
        N = 25 * 25;
        fluidSolver = new NavierStokesSolverMod(25, 25);
        fluidSolver.set_fadeSpeed ( 0.007);
        fluidSolver.deltaT (1 / fps);
        fluidSolver.set_viscosity (0.00015);
        var dw:Float = stageW / fluidSolver.width;
        var dh:Float = stageH / fluidSolver.height;
		
        cellHeight = stageH / fluidSolver.get_NY2();
        cellWidth = stageW / fluidSolver.get_NX2();
		
      
        numParticles = 1000;
        particles = new flash.Vector<FluidParticle>(numParticles, true);
        visc = 0.0008;
        diff = 0.25;
        velocityScale = 16;
        vScale = velocityScale * 0.4;
		// vScale = velocityScale * 60 / 60.0;
        limitVelocity = 100;
		
        fluidSolver.set_fadeSpeed ( 0.007);
        fluidSolver.deltaT  (1/60.0);//0.03;
        fluidSolver.set_viscosity ( 0.008);
		
		
        //paIntGrid();
		
        initParticles();
		
        addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMotion);
        addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
        addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
		
        addEventListener(Event.ENTER_FRAME, update);
		
    }


	var oldMouseX:Float = 1;
    var oldMouseY:Float = 1;

    private var mMouseX:Float = 1 ;
    private var mMouseY:Float = 1;

	private var mouseDown:Bool = false;
	private function handleMouseDown(event:MouseEvent):Void {
		if (event.stageX > 0 || event.stageX < stageW
			&&
			event.stageY > 0 || event.stageY < stageH)
		mouseDown = true;  
	}
	private function handleMouseUp(event:MouseEvent):Void {
		mouseDown = false;  
	}
	 
	
    private function handleMouseMotion(event:MouseEvent):Void {
       
		if(mouseDown){
			mMouseX = Math.max(1, stage.mouseX);
			mMouseX = Math.min(stage.mouseX, stageW);
			mMouseY = Math.max(1, stage.mouseY);
			mMouseY = Math.min(stage.mouseY, stageH);
			
			
			var mouseDx:Float = mMouseX - oldMouseX;
			var mouseDy:Float = mMouseY - oldMouseY;
			
			var cellX:Int = Math.floor(mMouseX / cellWidth);
			var cellY:Int = Math.floor(mMouseY / cellHeight);
			if (cellX < 1) cellX = 1 ;
			else if (cellX > fluidSolver.get_NX()) cellX = fluidSolver.get_NX();
			
			if (cellY < 1) cellY = 1 ;
			else if (cellY > fluidSolver.get_NY()) cellY = fluidSolver.get_NY();
			
			if (Math.abs(mouseDx) > limitVelocity)  mouseDx = utilits.UtilitsMath.signum(mouseDx) * limitVelocity ;
			if (Math.abs(mouseDy) > limitVelocity) mouseDy = utilits.UtilitsMath.signum(mouseDy) * limitVelocity;
			
			fluidSolver.applyForce(cellX, cellY, mouseDx, mouseDy);
			
			oldMouseX = mMouseX;
			oldMouseY = mMouseY;
		} 
    }
	
    private function stageSize(w:Int, h:Int):Void {
		stageW = w;
        stageH = h;
		
        isw = stageW * 0.5;
        ish = stageH * 0.5;
    }


    private var dt:Float = 1 / 60.0;

    private function update(event:Event):Void {
		handleMouseMotion(null);
		fluidSolver.update();
		
		graphics.clear();
		
		tile.bitmapData.fillRect(rect, backgroundColor);
		
		paIntMotionVector((vScale * 2));// Draw Velocity grid vectors 
        vScale = velocityScale;
		
        paIntParticles();		
		
		tile.drawChildInPosition(0, 0, 0);// (id, x,y)
		
        /*
		bitmap.bitmapData.fillRect(rect, 0x000000);
        bitmap.bitmapData.lock();
        ///--------------------------
		
        handleMouseMotion(null);
		
        fluidSolver.update();
		
        paIntMotionVector((vScale * 2));
        vScale = velocityScale;
		
        paIntParticles();
		
        ///--------------------------
        bitmap.bitmapData.unlock();
		*/
    }


    private function paIntGrid():Void {
        gridLayer.graphics.clear();
        gridLayer.graphics.lineStyle(2, 0xFFFFFF);
		
        //for (var i:Int = 1; i < fluidSolver.numCells; i++) {
		for( i  in 0...fluidSolver.numCells ) {
			
            
            gridLayer.graphics.moveTo(0, cellHeight * i);
            gridLayer.graphics.lineTo(stageW, cellHeight * i);
			
            gridLayer.graphics.moveTo(cellWidth * i, 0);
            gridLayer.graphics.lineTo(cellWidth * i, stageH);
            
        }
    }

  
    

    private function paIntMotionVector(scale:Float):Void {
        motionLayer.graphics.clear();
        motionLayer.graphics.lineStyle(1, 0x00ff00);

//        bitmap.bitmapData.fillRect(rectPix, c);
       
        var rows:Int = fluidSolver.get_NX2();
        var cols:Int = fluidSolver.get_NY2();
        //for (var i:Int = 0; i < rows; i++) {
		for (i in 0...rows) {
			for (j in 0...cols){
            //for (var j:Int = 0; j < cols; j++) {
                var dx:Float = fluidSolver.getDx(i, j);
                var dy:Float = fluidSolver.getDy(i, j);
				
                var x:Float = cellWidth / 2 + cellWidth * i;
                var y:Float = cellHeight / 2 + cellHeight * j;
                dx *= scale;
                dy *= scale;
				
				
                shape.graphics.clear();
                shape.graphics.lineStyle(1, 0x00ff00);
                shape.graphics.moveTo(0, 0);
                shape.graphics.lineTo(dx, dy);
				
                var matrix:Matrix = moveMatrixVectr[fluidSolver.getIndexForCellPosition(i, j)];
                matrix.tx = -bounds.x + x;
                matrix.ty = -bounds.y + y;
                
				//bitmapData.draw(shape, matrix);
				tile.bitmapData.draw(shape, matrix);
				
            }
        }
    }


 
  
    private function paIntParticles():Void {
        var c:Int = 0xff44AA;
        var len:Int = particles.length;
        particleLayer.graphics.clear();
		
        //for (var i:Int = 0; i < len; i++) {
		for (i in 0...len){
            var p:FluidParticle = particles[i];
			 if (p != null) {
                var cellX:Int = Math.floor(p.x / cellWidth);
                var cellY:Int = Math.floor(p.y / cellHeight);
				
                var dx:Float = fluidSolver.getDx(cellX, cellY);
                var dy:Float = fluidSolver.getDy(cellX, cellY);
				
                var lX:Float = p.x - cellX * cellWidth - cellWidth / 2;
                var lY:Float = p.y - cellY * cellHeight - cellHeight / 2;
				
                var v:Int;
                var h:Int;
                var vf:Int;
                var hf:Int;
				
                if (lX > 0) {
                    v = Std.int(Math.min(fluidSolver.numCells, cellX + 1));
                    vf = 1;
                } else {
                    v = Std.int(Math.min(fluidSolver.numCells, cellX - 1));
                    vf = -1;
                }
				
                if (lY > 0) {
                    h = Std.int(Math.min(fluidSolver.numCells, cellY + 1));
                    hf = 1;
                } else {
                    h = Std.int(Math.min(fluidSolver.numCells, cellY - 1));
                    hf = -1;
                }
                //cellY
                var dxv:Float = fluidSolver.getDx(v, cellX);
                var dxh:Float = fluidSolver.getDx(cellX, h);
                var dxvh:Float = fluidSolver.getDx(v, h);
				
                var dyv:Float = fluidSolver.getDy(v, cellY);
                var dyh:Float = fluidSolver.getDy(cellX, h);
                var dyvh:Float = fluidSolver.getDy(v, h);
				
                dx = utilits.UtilitsMath.lerp(utilits.UtilitsMath.lerp(dx, dxv, hf * lY / cellWidth), utilits.UtilitsMath.lerp(dxh, dxvh, hf * lY / cellWidth), vf * lX / cellHeight);
			    dy = utilits.UtilitsMath.lerp(utilits.UtilitsMath.lerp(dy, dyv, hf * lY / cellWidth), utilits.UtilitsMath.lerp(dyh, dyvh, hf * lY / cellWidth), vf * lX / cellHeight);
				
                p.x += dx * vScale;
                p.y += dy * vScale;
				
                if (p.x < 0 || p.x >= stageW) {
                    p.x = utilits.UtilitsMath.randomRangeNumber(0, stageW);
					
                }
                if (p.y < 0 || p.y >= stageH) {
                    p.y = utilits.UtilitsMath.randomRangeNumber(0, stageH);
                }
				
				
                rectPix.x = p.x - sizeRdiv2;
                rectPix.y = p.y - sizeRdiv2;
				
				//bitmap.bitmapData.fillRect(rectPix, c);
				tile.bitmapData.fillRect(rectPix, c);
				
            }
        }
    }


  


    private var moveMatrixVectr: flash.Vector<Matrix>;

    private function initParticles():Void {
		moveMatrixVectr = new flash.Vector<Matrix>();
		
        //for (var i:Int = 0; i < numParticles - 1; i++) {
		for(i in 0...numParticles){
            particles[i] = new FluidParticle();
            particles[i].x = Math.random() * stageW;
            particles[i].y = Math.random() * stageH;
        }
		
		
        var rows:Int = fluidSolver.get_NX()+1;
        var cols:Int = fluidSolver.get_NY()+1;
        moveMatrixVectr = new flash.Vector<Matrix>(fluidSolver.numCells, true);
		
        //for (i = 0; i < rows; i++) {
		for(i in 1...rows){
            //for (var j:Int = 0; j < cols; j++) {
			for(j in 1...cols){
                var indx:Int = fluidSolver.getIndexForCellPosition(i, j);
                bounds = shape.getBounds(shape);
                moveMatrixVectr[indx] = (new Matrix(1, 0, 0, 1, -bounds.x + x, -bounds.y + y) );
            }
        }
    }


}

 