

import java.awt.Graphics;
import java.awt.Color;

public abstract class MyShape
{
    private int x1;
    private int y1;
    private int x2;
    private int y2;
    private Color color;

    public MyShape()//no arg constructor
    {
        setX1(0);
        setY1(0);
        setX2(0);
        setY2(0);
        setColor(Color.BLACK);
    }

    public MyShape(int x1,int y1,int x2,int y2,Color color)//arg constructor
    {
        setX1(x1);
        setY1(y1);
        setX2(x2);
        setY2(y2);
        setColor(color);
    }

    //set methods
    protected void setX1(int arg)
    {x1 =arg;}

    protected void setY1(int arg)
    {y1 =arg;}

    protected void setX2(int arg)
    {x2 = arg;}

    protected void setY2(int arg)
    {y2 =arg;}

    protected void setColor(Color arg)
    {color =arg;}

    //get methods
    protected int getX1()
    {return x1;}

    protected int getY1()
    {return y1;}

    protected int getX2()
    {return x2;}

    protected int getY2()
    {return y2;}

    protected Color getColor()
    {return color;}
    //end of get and set methods

    public abstract void draw(Graphics g);
}