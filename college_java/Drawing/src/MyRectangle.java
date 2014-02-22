

import java.awt.Graphics;
import java.awt.Color;

public class MyRectangle extends MyShape
{
    private boolean filled;

    public MyRectangle()//no args constructor
    {
        super();
        setFilled(false);
    }
    public MyRectangle(int x1,int y1, int x2, int y2, Color color, boolean fill)//args constructor
    {
        super(x1,y1,x2,y2,color);
        setFilled(fill);
    }

    public void draw(Graphics g)
    {
        g.setColor(super.getColor());

        if(getFilled())
        {
            g.fillRect(getX1(),getY1(),getX2(),getY2());
        }
        else
        {
            g.drawRect(getX1(),getY1(),getX2(),getY2());
        }
    }

    public void setFilled(boolean fill)
    {
        filled =fill;
    }

    public boolean getFilled()
    {
        return filled;
    }
}