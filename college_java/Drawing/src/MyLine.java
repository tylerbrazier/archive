

import java.awt.Graphics;
import java.awt.Color;

public class MyLine extends MyShape
{
    public MyLine()//no args constructor
    {super();}

    public MyLine(int x1,int y1, int x2, int y2, Color color)//args constructor
    {super(x1,y1,x2,y2,color);}

    public void draw(Graphics g)
    {
        g.setColor(super.getColor());
        g.drawLine(getX1(),getY1(),getX2(),getY2());		
    }
}