

import java.awt.Color;
import java.awt.Graphics;

public class BallModel 
{
    private int x;
    private int y;
    private int size;
    private Color color;

    public BallModel(int xValue, int yValue, int size, Color c)
    {
        setX(xValue);
        setY(yValue); 
        setSize(size);
        setColor(c);
    }

    public synchronized void setX(int value)
    {
        x =value;
    }

    public synchronized int getX()
    {
        return x;
    }

    public synchronized void setY(int value)
    {
        y =value;
    }

    public synchronized int getY()
    {
        return y;
    }

    public synchronized void setSize(int value)
    {
        size = value;
    }

    public synchronized int getSize()
    {
        return size;
    }

    public synchronized void setColor(Color c)
    {
        color =c;
    }

    public synchronized Color getColor()
    {
        return color;
    }

    public synchronized void draw(Graphics g)
    {
        g.setColor(getColor());

        g.fillOval(getX(), getY(), getSize(), getSize());
    }
}
