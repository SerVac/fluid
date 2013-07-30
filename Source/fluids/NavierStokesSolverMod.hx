 
package fluids;
	import utilits.UtilitsMath;

  class NavierStokesSolverMod {

    public static var FLUID_DEFAULT_NX:Float = 25;
    public static var FLUID_DEFAULT_NY:Float = 25;
    public static var FLUID_DEFAULT_DT:Float = .05;
    public static var FLUID_DEFAULT_VISC:Float = 0.0001;
    public static var FLUID_DEFAULT_COLOR_DIFFUSION:Float = 0.0;
    public static var FLUID_DEFAULT_FADESPEED:Float = 0.3;
    public static var FLUID_DEFAULT_SOLVER_ITERATIONS:Int = 10;

    public var r:flash.Vector<Float>;
    public var g:flash.Vector<Float>;
    public var b:flash.Vector<Float>;

    public var x:flash.Vector<Float>;
    public var u:flash.Vector<Float>;
    public var uOld:flash.Vector<Float>;
    public var v:flash.Vector<Float>;
    public var vOld:flash.Vector<Float>;

    public var dense:flash.Vector<Float>;
    public var denseOld:flash.Vector<Float>;
    public var _diff:Float = 0.25;

    public var width:Int;
    public var height:Int;

    public var numCells:Int;
    public var numCellsLite:Int;

    private var _NX:Int;
	private var _NY:Int;
	private var _NX2:Int;
	private var _NY2:Int;
	
      var _invNumCells:Float;
      var _dt:Float;
      var _solverIterations:Int;
      var _colorDiffusion:Float;

      var wrap_x:Bool = false;
      var wrap_y:Bool = false;

      var _visc:Float;
      var _fadeSpeed:Float;

      var _tmp:flash.Vector<Float>;

      var _avgDensity:Float;			// this will hold the average color of the last frame (how full it is)
      var _uniformity:Float;			// this will hold the uniformity of the last frame (how uniform the color is);
      var _avgSpeed:Float;


//    public static const N:uInt = 25;
//    public static var SIZE:uInt = (N + 2) * (N + 2);

    /* public var u_prev:flash.Vector<Float> = new flash.Vector<Float>(SIZE, true);
     public var v_prev:flash.Vector<Float> = new flash.Vector<Float>(SIZE, true);
     public var dense:flash.Vector<Float> = new flash.Vector<Float>(SIZE, true);
     public var dense_prev:flash.Vector<Float> = new flash.Vector<Float>(SIZE, true);*/


    public function new(NX:Int, NY:Int) {
        setup(NX, NY);
    }

    public function setup(NX:Int, NY:Int):Void {
        _dt = FLUID_DEFAULT_DT;
        _fadeSpeed = FLUID_DEFAULT_FADESPEED;
        _solverIterations = FLUID_DEFAULT_SOLVER_ITERATIONS;
        _colorDiffusion = FLUID_DEFAULT_COLOR_DIFFUSION;

        _NX = NX;
        _NY = NY;
        _NX2 = _NX + 2;
        _NY2 = _NY + 2;

        numCellsLite = _NX * _NY;
        numCells = _NX2 * _NY2;

        _invNumCells = 1.0 / numCells;

        width = _NX2;
        height = _NY2;

        reset();
    }


    public function reset():Void {
        var fixed:Bool = false;
		
        u = new flash.Vector<Float>(numCells, fixed);
        uOld = new flash.Vector<Float>(numCells, fixed);
        v = new flash.Vector<Float>(numCells, fixed);
        vOld = new flash.Vector<Float>(numCells, fixed);
		
        dense = new flash.Vector<Float>(numCells, fixed);
        denseOld = new flash.Vector<Float>(numCells, fixed);
		
        var i:Int = numCells;
        while (--i > -1) {
            u[i] = uOld[i] = v[i] = vOld[i] = 0.0;
        }
    }


    public function update():Void {
        addSourceUV();
        swapUV();
        diffuseUV(_visc);
        project(u, v, uOld, vOld);
        swapUV();
        advect(1, u, uOld, uOld, vOld);
        advect(2, v, vOld, uOld, vOld);
        project(u, v, uOld, vOld);

    }

    //==============================================


    function swap(x:flash.Vector<Float>, x0:flash.Vector<Float>):Void {
        _tmp = x;
        x = x0;
        x0 = _tmp;
    }


    //--------------------------------------------
    function addSource(x:flash.Vector<Float>, s:flash.Vector<Float>):Void {
        var i:Int = numCells;
        while (--i > -1) {
            x[i] += _dt * s[i];
        }
    }

    function addSourceUV():Void {
        var i:Int = numCells;
        while (--i > -1) {
            u[i] += _dt * uOld[i];
            v[i] += _dt * vOld[i];
        }
    }

    function swapUV():Void {
        _tmp = u;
        u = uOld;
        uOld = _tmp;
		
        _tmp = v;
        v = vOld;
        vOld = _tmp;
    }


     function diffuseUV(_diff:Float):Void {
        var a:Float = _dt * _diff * _NX * _NY;
        linearSolverUV(a, 1.0 + 4 * a);
    }


     function linearSolverUV(a:Float, c:Float):Void {
        var index:Int;
        var k:Int, i:Int, j:Int;
        c = 1 / c;
		
        //for (k = 0; k < _solverIterations; ++k) {
		 
		
		for(k in 1..._solverIterations){
            //for (j = _NY; j > 0; --j) {
			j = _NY;
			while (--j > 0) {
                index = FLUID_IX(_NX, j);
                //for (i = _NX; i > 0; --i) {
				i = _NX;
				while (--i > 0) {
                    //u[index] = ( ( u[ Std.int(index - 1)] + u[ Std.int(index + 1)] + u[Std.int(index - _NX2)] + u[Std.int(index + _NX2)] ) * a + uOld[index] ) * c;
                    //v[index] = ( ( v[ Std.int(index - 1)] + v[Std.int(index + 1)] + v[Std.int(index - _NX2)] + v[Std.int(index + _NX2)] ) * a + vOld[index] ) * c;
					u[index] = ( ( u[ index - 1] + u[ index + 1] + u[index - _NX2] + u[index + _NX2] ) * a + uOld[index] ) * c;
                    v[index] = ( ( v[ index - 1] + v[index + 1] + v[index - _NX2] + v[index + _NX2] ) * a + vOld[index] ) * c;
                    --index;
                }
            }
            setBoundary(1, u);
            setBoundary(2, v);
        }
    }

     function project(x:flash.Vector<Float>, y:flash.Vector<Float>, p:flash.Vector<Float>, div:flash.Vector<Float>):Void {
        var i:Int, j:Int;
        var index:Int;

        var h:Float = -0.5 / _NX;

        //for (j = _NY; j > 0; --j) {
		j = _NY;
		while (--j > 0) {
		 
            index = FLUID_IX(_NX, j);
            //for (i = _NX; i > 0; --i) {
			i = _NX;
			while (--i > 0) {
				//div[index] = h * ( x[Std.int(index + 1)] - x[Std.int(index - 1)] + y[Std.int(index + _NX2)] - y[Std.int(index - _NX2)] );
				div[index] = h * ( x[index + 1] - x[index - 1] + y[index + _NX2] - y[index - _NX2] );
                p[index] = 0;
                --index;
            }
        }

        setBoundary(0, div);
        setBoundary(0, p);

        linearSolver(0, p, div, 1, 4);

        var fx:Float = 0.5 * _NX;
        var fy:Float = 0.5 * _NY;
        //for (j = _NY; j > 0; --j) {
		j = _NY;
		while (--j > 0) {
			index = FLUID_IX(_NX, j);
			//for (i = _NX; i > 0; --i) {
			i = _NX;
			while (--i > 0) {
				x[index] -= fx * (p[index + 1] - p[index - 1]);
                //y[index] -= fy * (p[index + _NX2] - p[index - _NX2]);
                y[index] -= fy * (p[index + _NX2] - p[index - _NX2]);
                --index;
            }
        }
		
        setBoundary(1, x);
        setBoundary(2, y);
    }

     function linearSolver(b:Int, x:flash.Vector<Float>, x0:flash.Vector<Float>, a:Float, c:Float):Void {
        var k:Int, i:Int, j:Int;
		
        var index:Int;

        if (a == 1 && c == 4) {
            //for (k = 0; k < _solverIterations; ++k) {
			for(k in 0..._solverIterations){
                //for (j = _NY; j > 0; --j) {
				j = _NY;
				while (--j > 0) {
                    index = FLUID_IX(_NX, j);
                    //for (i = _NX; i > 0; --i) {
					i = _NX;
					while (--i > 0) {
                        //x[index] = ( x[index - 1] + x[index + 1] + x[index - _NX2] + x[index + _NX2] + x0[index] ) * 0.25;
                        x[index] = ( x[index - 1] + x[index + 1] + x[index - _NX2] + x[index + _NX2] + x0[index] ) * 0.25;
                        --index;
                    }
                }
                setBoundary(b, x);
            }
        }
        else {
            c = 1 / c;
            //for (k = 0; k < _solverIterations; ++k) {
			for(k in 0..._solverIterations){
                //for (j = _NY; j > 0; --j) {
				j = _NY;
				while (--j > 0) {
                    index = FLUID_IX(_NX, j);
                    //for (i = _NX; i > 0; --i) {
					i = _NX;
					while (--i > 0) {
                        //x[index] = ( ( x[index - 1] + x[index + 1] + x[index - _NX2] + x[index + _NX2] ) * a + x0[index] ) * c;
                        x[index] = ( ( x[index - 1] + x[index + 1] + x[index - _NX2] + x[index + _NX2] ) * a + x0[index] ) * c;
                        --index;
                    }
                }
                setBoundary(b, x);
            }
        }
    }


     function setBoundary(bound:Int, x:flash.Vector<Float>):Void {
        var dst1:Int, dst2:Int, src1:Int, src2:Int;
        var i:Int;
        var step:Int = FLUID_IX(0, 1) - FLUID_IX(0, 0);

        dst1 = FLUID_IX(0, 1);
        src1 = FLUID_IX(1, 1);
        dst2 = FLUID_IX(_NX + 1, 1);
        src2 = FLUID_IX(_NX, 1);

        if (wrap_x) {
            src1 ^= src2;
            src2 ^= src1;
            src1 ^= src2;
        }
        if (bound == 1 && !wrap_x) {
            //for (i = _NY; i > 0; --i) {
			i = _NY;
			while (--i > 0) {
                x[dst1] = -x[src1];
                dst1 += step;
                src1 += step;
                x[dst2] = -x[src2];
                dst2 += step;
                src2 += step;
            }
        } else {
            //for (i = _NY; i > 0; --i) {
			i = _NY;
			while (--i > 0) {
                x[dst1] = x[src1];
                dst1 += step;
                src1 += step;
                x[dst2] = x[src2];
                dst2 += step;
                src2 += step;
            }
        }

        dst1 = FLUID_IX(1, 0);
        src1 = FLUID_IX(1, 1);
        dst2 = FLUID_IX(1, _NY + 1);
        src2 = FLUID_IX(1, _NY);

        if (wrap_y) {
            src1 ^= src2;
            src2 ^= src1;
            src1 ^= src2;
        }
        if (bound == 2 && !wrap_y) {
            //for (i = _NX; i > 0; --i) {
			i = _NX;
			while (--i > 0) {
                x[dst1++] = -x[src1++];
                x[dst2++] = -x[src2++];
            }
        } else {
            //for (i = _NX; i > 0; --i) {
			i = _NX;
			while (--i > 0) {
                x[dst1++] = x[src1++];
                x[dst2++] = x[src2++];
            }
        }
		
        x[FLUID_IX(0, 0)] = 0.5 * (x[FLUID_IX(1, 0)] + x[FLUID_IX(0, 1)]);
        x[FLUID_IX(0, _NY + 1)] = 0.5 * (x[FLUID_IX(1, _NY + 1)] + x[FLUID_IX(0, _NY)]);
        x[FLUID_IX(_NX + 1, 0)] = 0.5 * (x[FLUID_IX(_NX, 0)] + x[FLUID_IX(_NX + 1, 1)]);
        x[FLUID_IX(_NX + 1, _NY + 1)] = 0.5 * (x[FLUID_IX(_NX, _NY + 1)] + x[FLUID_IX(_NX + 1, _NY)]);

    }

	
    function advect(b:Int, _d:flash.Vector<Float>, d0:flash.Vector<Float>, du:flash.Vector<Float>, dv:flash.Vector<Float>):Void {
        var i:Int, j:Int, i0:Int, j0:Int, i1:Int, j1:Int, index:Int;
        var x:Float, y:Float, s0:Float, t0:Float, s1:Float, t1:Float, dt0x:Float, dt0y:Float;

        dt0x = _dt * _NX;
        dt0y = _dt * _NY;

        //for (j = _NY; j > 0; --j) {
		j = _NY;
		while (--j > 0) {
            //for (i = _NX; i > 0; --i) {
			i = _NX;
			while (--i > 0) {

                index = FLUID_IX(i, j);

                x = i - dt0x * du[index];
                y = j - dt0y * dv[index];

                if (x > _NX + 0.5) x = _NX + 0.5;
                if (x < 0.5) x = 0.5;

                i0 =  Std.int(x);
                i1 = i0 + 1;

                if (y > _NY + 0.5) y = _NY + 0.5;
                if (y < 0.5) y = 0.5;

                j0 = Std.int(y);
                j1 = j0 + 1;

                s1 = x - i0;
                s0 = 1 - s1;
                t1 = y - j0;
                t0 = 1 - t1;

                _d[index] = s0 * (t0 * d0[FLUID_IX(i0, j0)] + t1 * d0[FLUID_IX(i0, j1)]) + s1 * (t0 * d0[FLUID_IX(i1, j0)] + t1 * d0[FLUID_IX(i1, j1)]);

            }
        }
        setBoundary(b, _d);
    }

    public function applyForce(cellX:Int, cellY:Int, vx:Float, vy:Float):Void {
        cellX++;
        cellY++;
        var dx:Float = u[FLUID_IX(cellX, cellY)];
        var dy:Float = v[FLUID_IX(cellX, cellY)];
		
		// if( flag ) 1 else 2;
		//u[FLUID_IX(cellX, cellY)] = (vx != 0) ? UtilitsMath.lerp(vx as Float, dx as Float, 0.85) : dx;
		var temp:Float;
		if (vx != 0)  temp = UtilitsMath.lerp(vx , dx, 0.85) else temp = dx;
		u[FLUID_IX(cellX, cellY)] = temp;
        //v[FLUID_IX(cellX, cellY)] = (vy != 0) ? UtilitsMath.lerp(vy as Float, dy as Float, 0.85) : dy;
		if (vy != 0)  temp = UtilitsMath.lerp(vy, dy, 0.85) else temp = dy;
		v[FLUID_IX(cellX, cellY)] = temp;
    }


    public function   wrapX():Bool {
        return wrap_x;
    }

    public function   wrapY():Bool {
        return wrap_y;
    }

    public function getIndexForCellPosition(i:Int, j:Int):Int {
        if (i < 1) i = 1; else if (i > _NX) i = _NX;
        if (j < 1) j = 1; else if (j > _NY) j = _NY;
        return FLUID_IX(i, j);
    }

    public function getIndexForNormalizedPosition(x:Float, y:Float):Int {
        return getIndexForCellPosition(Std.int(x * _NX2), Std.int(y * _NY2));
    }

    public function getDx(x:Int, y:Int):Float {
//        return u[FLUID_IX(x + 1, y + 1)];
//        var index:Float = INDEX(x + 1, y + 1);
//        var index2:Float = getIndexForCellPosition(x,y);
        var index:Int =  getIndexForCellPosition(x + 1, y + 1);

        return u[index];
    }

    public function getDy(x:Int, y:Int):Float {
//        return v[FLUID_IX(x + 1, y + 1)];
//        var index:Float = INDEX(x + 1, y + 1);
//        var index2:Float = getIndexForCellPosition(x,y);
        var index:Int = getIndexForCellPosition(x + 1, y + 1);
        return v[index];
    }


      function FLUID_IX(i:Int, j:Int):Int {
        return  (i + _NX2 * j);
    }

    public function   deltaT(dt:Float):Void {
        _dt = dt;
    }

    /**
     * @param fadeSpeed (0...1)
     */
    public function   set_fadeSpeed(fadeSpeed:Float):Void {
        _fadeSpeed = fadeSpeed;
    }


    /**
     * set Float of iterations for solver (higher is slower but more accurate)
     */
    public function   solverIterations(solverIterations:Int):Void {
        _solverIterations = solverIterations;
    }


    public function   set_viscosity(newVisc:Float):Void {
        _visc = newVisc;
    }

    public function   get_viscosity():Float {
        return _visc;
    }

    public function   get_NX():Int {
        return _NX;
    }

    public function   set_NX(value:Int):Void {
        _NX = value;
    }

    public function   get_NY():Int {
        return _NY;
    }

    public function   set_NY(value:Int):Void {
        _NY = value;
    }

    public function   get_NX2():Int {
        return _NX2;
    }

    public function   get_NY2():Int {
        return _NY2;
    }

    public function   set_NY2(value:Int):Void {
        _NY2 = value;
    }
}
 
