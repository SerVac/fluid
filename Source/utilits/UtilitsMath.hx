package utilits;
/**
 *   Математические методы.
 */
 class UtilitsMath   {

    //private static const MAX_RATIO:Float = 1 / uint.MAX_VALUE;
    //private static var r:uint = Math.random() * uint.MAX_VALUE;
	
	  static function main() {
	}
	
    // Credit to: http://www.codeguru.com/forum/showpost.php?p=1913101&postcount=16
    public static function distPointToSegmentSquared(lineX1:Float, lineY1:Float, lineX2:Float, lineY2:Float, pointX:Float, pointY:Float) {
        var vx:Float = lineX1 - pointX;
        var vy:Float = lineY1 - pointY;
        var ux:Float = lineX2 - lineX1;
        var uy:Float = lineY2 - lineY1;

        var len:Float = ux * ux + uy * uy;
        var det:Float = (-vx * ux) + (-vy * uy);
        if ((det < 0) || (det > len)) {
            ux = lineX2 - pointX;
            uy = lineY2 - pointY;
            return Math.min(vx * vx + vy * vy, ux * ux + uy * uy);
        }

        det = ux * vy - uy * vx;
        return (det * det) / len;
    }

    /**
     * Округляет указанное значение в меньшую сторону.
     *
     * @param    value     Значение которое необходимо округлить.
     * @return        Округленное значение.
     */
    public static function floor(value:Float):Float {
        var n:Float =  value ;
		if (value > 0) return n else if (n != value) return n - 1 else return n; // TODO !
        //return (value > 0) ? (n) : ((n != value) ? n - 1 : n);
    }

    /**
     * Округляет указанное значение в большую сторону.
     *
     * @param    value     Значение которое необходимо округлить.
     * @return        Округленное значение.
     */
    public static function ceil(value:Float):Float {
        var n:Float =  value ;
        //return (value > 0) ? ((n != value) ? n + 1 : n) : n;
		 return 1;// TODO !
    }

    /**
     * Убирает минус у отрицательных значений, позитивные значения остаются без изменений.
     *
     * @param    value     Значение для которого необходимо убрать минус.
     * @return        Позитивное значение.
     */
    public static function abs(value:Float):Float {
        //return (value < 0) ? value * -1 : value;
		return if (value < 0) value * -1 else value;
    }

    /**
     * Проверяет вхождение значение в заданный диапазон.
     *
     * @param    value     Значение вхождение которого необходимо проверить.
     * @param    aLower     Наименьшее значение диапазона.
     * @param    aUpper     Наибольшоее значение диапазона.
     * @return        Возвращает true если указанное значение в заданном диапазоне.
     */
    public static function range(value:Float, aLower:Float, aUpper:Float):Bool  {
        return ((value > aLower) && (value < aUpper));
    }

    /**
     * Возрващает ближайшее значение к заданному.
     *
     * @param    value     Заданное значение.
     * @param    out1     Первое возможно ближайшее значение.
     * @param    out2     Второе возможно ближайшее значение.
     * @return        Возвращает ближайшее из out1 и out2 к value.
     */
    public static function closest(value:Float, out1:Float, out2:Float):Float {
        return (Math.abs(value - out1) < Math.abs(value - out1)) ? out1 : out2;
    }

    /**
     * Возвращает случайное целочисленное число из заданного диапазона.
     *
     * @param    aLower     Меньшее значание в диапазоне.
     * @param    aUpper     Большее значание в диапазоне.
     * @return        Случайное целочисленное число из заданного диапазона.
     */
    public static function randomRangeInt(aLower:Int, aUpper:Int):Int {
        return  Std.int(Math.random() * (aUpper - aLower + 1)) + aLower;
    }

    /**
     * Возвращает случайное число из заданного диапазона.
     *
     * @param    aLower     Меньшее значание в диапазоне.
     * @param    aUpper     Большее значание в диапазоне.
     * @return        Случайное число из заданного диапазона.
     */
    public static function randomRangeNumber(aLower:Float, aUpper:Float):Float {
		return Math.random() * (aUpper - aLower) + aLower;
    }

    /**
     * Возвращает случайное число.
     *
     * @return        Случайное число.
     */
    //public static function random():Float {
        //r ^= (r << 21);
        //r ^= (r >>> 35);
        //r ^= (r << 4);
        //return r * MAX_RATIO;
    //}

    /**
     * Сравнивает указанные значения с возможной погрешностью.
     *
     * @param    aValueA     Первое значение.
     * @param    aValueB     Второе значение.
     * @param    aDiff     Допустимая для сравнения погрешность.
     * @return        Возвращает true если указанные значения равны с допустимой погрешностью.
     */
    public static function equal(aValueA:Float, aValueB:Float, aDiff:Float = 0.00001):Bool {
        return (Math.abs(aValueA - aValueB) <= aDiff);
    }

    

    /**
     * Ограничивает указанное значение заданным диапазоном.
     *
     * @param    value     Значение которое необходимо ограничить.
     * @param    aLower     Наименьшее значение диапазона.
     * @param    aUpper     Наибольшее значение диапазона.
     * @return        Если значение меньше или больше заданного диапазона, то будет возвращена граница диапазона.
     */
    public static function trimToRange(value:Float, aLower:Float, aUpper:Float):Float {
        return (value > aUpper) ? aUpper : (value < aLower) ? aLower : value;
    }

    /**
     * Возрващает значение из заданного диапазона с заданным коэффицентом.
     * <p>Например:
     * <code>if (aCoef == 0.0) return aLower;
     * if (aCoef == 1.0) return aUpper;</code></p>
     *
     * @param    aLower     Наименьшее значение диапазона.
     * @param    aUpper     Наибольшее значение диапазона.
     * @param    aCoef     Коэффицент.
     * @return        Значение из диапазона согласно коэфиценту.
     */
    public static function lerp(aLower:Float, aUpper:Float, aCoef:Float):Float {
        return aLower + aCoef * (aUpper - aLower);
    }


    /**
     * Рассчитывает процент исходя из текущего и общего значения.
     *
     * @param    aCurrent     Текущее значание.
     * @param    aTotal     Общее значение.
     * @return        Возвращает процент текущего значения.
     */
    public static function toPercent(aCurrent:Float, aTotal:Float):Float {
        return (aCurrent / aTotal) * 100;
    }

    /**
     * Рассчитывает текущее значение исходя из текущего процента и общего значения.
     *
     * @param    aPercent     Текущий процент.
     * @param    aTotal     Общее значение.
     * @return        Возвращает текущее значение.
     */
    public static function fromPercent(aPercent:Float, aTotal:Float):Float {
        return (aPercent * aTotal) / 100;
    }

    /**
     * Определяет наибольшее число из указанного массива.
     *
     * @param    aArray     Массив значений.
     * @return        Возвращает наибольшее число из массива.
     */
   /* public static function maxFrom(aArray:Array):Float {
        return Math.max.apply(null, aArray);
    }*/

    /**
     * Определяет наименьшее число из указанного массива.
     *
     * @param    aArray     Массив значений.
     * @return        Возвращает наименьшее число из массива.
     */
 /*   public static function minFrom(aArray:Array):Float {
        return Math.min.apply(null, aArray);
    }*/
 
    /**
     * Проверка на ЧЁТНОСТЬ
     * @param value  Число
     * @return    false - нечётное; true - чётное
     */
    public static function Parity(value:Float):Bool {
        return(Std.int(value) & 1) == 0;
    }

    /**
     * Вычислить позицию между двумя числами, через процентное соотношение
     * The lerp function is convenient for creating motion along a straight path and for drawing dotted lines.
     * <p>Lerp is an abbreviation for linear interpolation, which can also be used as a verb (Raymond 2003).</p>
     * <p>Linear interpolation is a method of curve fitting using linear polynomials.
     * It is heavily employed in mathematics (particularly numerical analysis), and numerous applications including computer graphics. It is a simple form of interpolation.</p>
     * <p><b>Example :</b></p>
     * <pre class="prettyprint">
     * import core.maths.lerp ;
     * trace( lerp( 0 , 100 , 0.5 ) ; // 50
     * </pre>
     * @param amount The amount to interpolate between the two values where 0.0 equal to the first point, 0.1 is very near the first point, 0.5 is half-way in between, etc.
     * @param start the begining value.
     * @param end The ending value.
     * @return The interpolated value between two Floats at a specific increment.
     */
    public static  function mlerp(amount:Float, start:Float, end:Float):Float {
        if (start == end) {
            return start;
        }
        return ( ( 1 - amount ) * start ) + ( amount * end );
    };

    /**
     signum — возвращает 1.0 если число больше 0 и -1.0 если число меньше нуля
     и ноль, если аргумент равен нулю;
     **/
    public static function signum(value:Float):Float {
        if (value == 0) return 0;
        if (value > 0)return 1.0;
        else return -1.0;
    }

   


}
 