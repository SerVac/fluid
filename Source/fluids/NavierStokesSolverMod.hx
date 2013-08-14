package fluids;
	
   
  import flash.Vector.Vector;
  import utilits.UtilitsMath;

  class NavierStokesSolverMod {

    public static var N:Int = 25;
    public var h:Float;
    public static var SIZE:UInt ;

  
    public var u_prev:Vector<Float>;
    public var v_prev:Vector<Float>;
    public var dense:Vector<Float>;
    public var dense_prev:Vector<Float>;
	  public var u:Vector<Float>;
    public var v:Vector<Float>;
	
    private var _dt:Float = 1.0/30.0;
    private var dt0:Float;
    private var CONST_1:Float;
    
	
    public function new() {
	reset();
    }

    public function reset():Void {
	h = 1.0 / N;
	SIZE = (N + 2) * (N + 2);
	tmp = new Vector<Float>(SIZE, true);
	_dt = 1/30.0;
        dt0 = _dt * N;
        CONST_1 = _dt * N * N;
		
        var fixed:Bool = false;
	u = new Vector<Float>(SIZE, fixed);
        u_prev = new Vector<Float>(SIZE, fixed);
        v = new Vector<Float>(SIZE, fixed);
        v_prev = new Vector<Float>(SIZE, fixed);

        dense = new Vector<Float>(SIZE, true);
        dense_prev = new Vector<Float>(SIZE, true);

        var i:Int = SIZE;
        while (--i > -1) {
            u[i] = u_prev[i] = v[i] = v_prev[i] = 0.0;
        } 
    }

    public function applyForce(cellX:Int, cellY:Int, vx:Float, vy:Float):Void {
        cellX += 1;
        cellY += 1;
        var index:Int = INDEX(cellX, cellY);
        var dx:Float = u[index];
        var dy:Float = v[index];

        u[index] = (vx != 0) ? UtilitsMath.mlerp(vx, dx, 0.85) : dx;
        v[index] = (vy != 0) ? UtilitsMath.mlerp(vy, dy, 0.85) : dy;

    }
    
    
    public function tick(dt:Float, visc:Float, diff:Float):Void {
        vel_step(u, v, u_prev, v_prev, visc, dt);
        dens_step(dense, dense_prev, u, v, diff, dt);
    }


    private function diffuse(b:Int, x:Vector<Float>, x0:Vector<Float>, diff:Float):Void {
        var i:Int;
        var j:Int;
        var k:Int;
        var a:Float = diff * CONST_1;
        var a2:Float = 1 / (1 + 4 * a);
        var index:Int = 0;
		
	for(k in 0...20){
        	for(i in 1...N+1){
                	for(j in 1...N+1){
                    		index = INDEX(i, j);
                    		x[index] = (x0[index] + a
                            	* (x[INDEX(i - 1, j)] + x[INDEX(i + 1, j)]
                            	+ x[INDEX(i, j - 1)] + x[INDEX(i, j + 1)]))
                            	* a2;
                }
            }
            set_bnd(b, x);
        }
    }


    function advect(b:Int, d:Vector<Float>, d0:Vector<Float>, u:Vector<Float>, v:Vector<Float>):Void {
        var i:Int, j:Int, i0:Int, j0:Int, i1:Int, j1:Int;
        var x:Float, y:Float, s0:Float, t0:Float, s1:Float, t1:Float;
		
        var index:Int = 0;
    	for(i in 1...N+1){
            for(j in 1...N+1){
                index = INDEX(i, j);
                x = i - dt0 * u[index];
                y = j - dt0 * v[index];
                if (x < 0.5)
                    x = 0.5;
                if (x > N + 0.5)
                    x = N + 0.5;

                i0 = Std.int(x);
                i1 = i0 + 1;
                if (y < 0.5)
                    y = 0.5;
                if (y > N + 0.5)
                    y = N + 0.5;

                j0 = Std.int(y);
                j1 = j0 + 1;
                s1 = x - i0;
                s0 = 1 - s1;
                t1 = y - j0;
                t0 = 1 - t1;
                d[index] = s0 * (t0 * d0[INDEX(i0, j0)] + t1 * d0[INDEX(i0, j1)])
                        + s1 * (t0 * d0[INDEX(i1, j0)] + t1 * d0[INDEX(i1, j1)]);
            }
        }
        set_bnd(b, d);
    }


    private function set_bnd(b:Int, x:Vector<Float>):Void {
        var i:Int;
        var index:Int = 0;
        for(i in 1...N+1){
       	    index = INDEX(1, i);
            x[INDEX(0, i)] = (b == 1) ? -x[index] : x[index];
            index = INDEX(N, i);
            x[INDEX(N + 1, i)] = b == 1 ? -x[index] : x[index];
            index = INDEX(i, 1);
            x[INDEX(i, 0)] = b == 2 ? -x[index] : x[index];
            index = INDEX(i, N);
            x[INDEX(i, N + 1)] = b == 2 ? -x[index] : x[index];
        }

        x[INDEX(0, 0)] = 0.5 * (x[INDEX(1, 0)] + x[INDEX(0, 1)]);
        x[INDEX(0, N + 1)] = 0.5 * (x[INDEX(1, N + 1)] + x[INDEX(0, N)]);
        x[INDEX(N + 1, 0)] = 0.5 * (x[INDEX(N, 0)] + x[INDEX(N + 1, 1)]);
        x[INDEX(N + 1, N + 1)] = 0.5 * (x[INDEX(N, N + 1)] + x[INDEX(N + 1, N)]);
    }

    private function dens_step(x:Vector<Float>, x0:Vector<Float>, u:Vector<Float>, v:Vector<Float>, diff:Float, dt:Float):Void {
        add_source(x, x0, dt);
        SWAP(x0, x);
        diffuse(0, x, x0, diff);
        SWAP(x0, x);
        advect(0, x, x0, u, v);
    }


    private function vel_step(u:Vector<Float>, v:Vector<Float>, u0:Vector<Float>, v0:Vector<Float>, visc:Float, dt:Float):Void {
        add_source(u, u0, dt);
        add_source(v, v0, dt);
        SWAP(u0, u);

        diffuse(1, u, u0, visc);
        SWAP(v0, v);
        diffuse(2, v, v0, visc);

        project(u, v, u0, v0);
        SWAP(u0, u);
        SWAP(v0, v);

        advect(1, u, u0, u0, v0);
        advect(2, v, v0, u0, v0);
        project(u, v, u0, v0);

    }

    private function add_source(x:Vector<Float>, s:Vector<Float>, dt:Float):Void {
        var size:Int = (N + 2) * (N + 2);
        for(i in 0...size){
        	x[i] += dt * s[i];
        }

    }

     function addSourceUV(dt:Float):Void {
        var i:Int = SIZE;
        while (--i > -1) {
            u[i] += dt * u_prev[i];
            v[i] += dt * v_prev[i];
        }
    }

    var limitVelocity:Float = 1.6;

    private function project(u:Vector<Float>, v:Vector<Float>, p:Vector<Float>, div:Vector<Float>):Void {
        var i:Int;
        var j:Int;
        var k:Int;
        var index:Int = 0;
		
        for(i in 1...N+1){
                for(j in 1...N+1){
                index = INDEX(i, j);
                div[index] = -0.5* h * (u[INDEX(i + 1, j)] - u[INDEX(i - 1, j)]
                        	+ v[INDEX(i, j + 1)] - v[INDEX(i, j - 1)]);
						
                p[index] = 0;
            }
        }
        set_bnd(0, div);
        set_bnd(0, p);
		
        for(k in 0...20){
        	for(i in 1...N+1){
                	for(j in 1...N+1){
                    		index = INDEX(i, j);
                    p[index] = (div[INDEX(i, j)] + p[INDEX(i - 1, j)]
                            + p[INDEX(i + 1, j)] + p[INDEX(i, j - 1)]
                            + p[INDEX(i, j + 1)]) * 0.25;
                }
            }
            set_bnd(0, p);
        }
		
        var n:Float;
        for(i in 1...N+1){
                for(j in 1...N+1){
                index = INDEX(i, j);
                u[index] -= 0.5 * (p[INDEX(i + 1, j)] - p[INDEX(i - 1, j)]) * N;
                v[index] -= 0.5 * (p[INDEX(i, j + 1)] - p[INDEX(i, j - 1)]) * N;
                
		n = u[index];
                u[index] = (Math.abs(n) > limitVelocity) ? UtilitsMath.signum(n) * limitVelocity : n;
                n = v[index];
                v[index] = (Math.abs(n) > limitVelocity) ? UtilitsMath.signum(n) * limitVelocity : n;
            }
        }
		
        set_bnd(1, u);
        set_bnd(2, v);
    }


    private var tmp:Vector<Float> ;
    private  function SWAP(x0:Vector<Float>, x:Vector<Float>):Void {
        vectorCopy(x0, 0, tmp, 0, SIZE);
        vectorCopy(x, 0, x0, 0, SIZE);
        vectorCopy(tmp, 0, x, 0, SIZE);
    }

    public function vectorCopy(src:Vector<Float>, srcPos:Int, 
						dest:Vector<Float>, destPos:Int, length:Int):Void {
							
        var lenSrc:Int = srcPos + length;
        var lenDest:Int = destPos + length;
        
        for(i in srcPos...lenSrc){
            dest[destPos] = src[i];
            destPos++;
            if (destPos == lenDest) break;
        }
    }

    public inline function getDx(x:Int, y:Int):Float {
        return u[INDEX(x + 1, y + 1)];
    }

    public inline function getDy(x:Int, y:Int):Float {
        return v[INDEX(x + 1, y + 1)];
    }


    public inline function INDEX(i:Int, j:Int):Int {
        return i + (N + 2) * j;
    }
}
 
