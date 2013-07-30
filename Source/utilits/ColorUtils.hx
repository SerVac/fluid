/**
 * User: Vac
 * Date: 10.05.13
 * Time: 16:48
 */
package utilits {
import flash.geom.ColorTransform;
import flash.net.registerClassAlias;

public class ColorUtils {

    public static function invertHEX(c:uint):uint
    {
        var r:Number=extractRedFromHEX(c);
        var g:Number=extractGreenFromHEX(c);
        var b:Number=extractBlueFromHEX(c);

        r = (255 - r);
        g = (255 - g);
        b = (255 - b);

        return RGBToHex(r, g, b);
    }

    /**
     * Input colour value such as 0xFF0000, and modifier from -1 to 1.
     */
    public static function brighten(color:uint, modifier:Number):uint {
        var z:int = 0xff * modifier;

        var r:uint = trim(((color & 0xff0000) >> 16) + z);
        var g:uint = trim(((color & 0x00ff00) >> 8) + z);
        var b:uint = trim(((color & 0x0000ff) ) + z);

        return r << 16 | g << 8 | b;
    }

    /**
     * Blends two colours. Percentage should be 0.5 for an equal blend.
     */
    public static function blend(first:uint, second:uint, percent:Number):uint {
        var r:int = ((first & 0xff0000) >> 16) * (1 - percent) + ((second & 0xff0000) >> 16) * percent;
        var g:int = ((first & 0x00ff00) >> 8) * (1 - percent) + ((second & 0x00ff00) >> 8) * percent;
        var b:int = ((first & 0x0000ff) ) * (1 - percent) + ((second & 0x0000ff) ) * percent;

        return r << 16 | g << 8 | b;
    }

    public static function desaturate(color:uint, percent:Number):uint {
        return blend(color, 0x7F7F7F, percent);
    }

    public static function bleach(color:uint, percent:Number):uint {
        return blend(color, 0xFFFFFF, percent);
    }

    public static function darken(color:uint, percent:Number):uint {
        return blend(color, 0x000000, percent);
    }

    private static function trim(value:int):uint {
        return Math.min(Math.max(0x00, value), 0xff);
    }


    public static function RGBHEXtoARGBHEX(rgb:uint, newAlpha:uint):uint
    {
        //newAlpha has to be in the 0 to 255 range
        var argb:uint = 0;
        argb += (newAlpha<<24);
        argb += (rgb);
        return argb;
    }


    public static function extractRedFromHEX(c:uint):uint
    {
        return (( c >> 16 ) & 0xFF);
    }

    public static function extractGreenFromHEX(c:uint):uint
    {
        return ( (c >> 8) & 0xFF );
    }

    public static function extractBlueFromHEX(c:uint):uint
    {
        return ( c & 0xFF );
    }



    public static function RGBToHex(r:uint, g:uint, b:uint):uint
    {
        var hex:uint = (r << 16 | g << 8 | b);
        return hex;
    }

    public static function rndColor():uint{
        return UtilitsMath.random() * 0xFFFFFF;
    }
}
}
