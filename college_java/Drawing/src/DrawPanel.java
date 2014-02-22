

import javax.swing.*;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;
import java.awt.event.MouseAdapter;

public class DrawPanel extends JPanel
{	//instance variables
    MyLine line;
    MyRectangle rect;
    MyOval oval;
    private MyShape[] shapesArray;//stores all the shapes that the user draws
    private int shapeCount;//counts the number of shapes in the array
    private int shapeType;//determines type of shape to draw. each shape has a number to represent it. 
    //line =0
    //rect =1
    //oval =2
    private MyShape currentShape;//represents current shape the user is drawing
    private Color currentColor;
    private boolean filled;
    private JLabel statusLabel;//displays coordinates of the current mouse position
    private int startX;
    private int startY;
    //

    public DrawPanel(JLabel arg)//constructor
    {
        setStatusLabel(arg);
        shapesArray =new MyShape[100];
        setShapeCount(0);	
        setShapeType(0);// initialize shapeType to the value that represents a line (which is 0)
        setCurrentShape(null);
        setCurrentColor(Color.black);
        setBackground(Color.WHITE);

        addMouseMotionListener(new Mouser());
        addMouseListener(new Mouser());		
    }

    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);//call this first every time in paintComponent

        for(int i=0; i<getShapeCount();++i)
        {shapesArray[i].draw(g);}

        if(getCurrentShape() != null)
        {getCurrentShape().draw(g);}
    }
    //set methods
    public void setShapeType(int arg)
    {shapeType =arg;}
    public void setCurrentColor(Color arg)
    {currentColor =arg;}
    public void setFilled(boolean arg)
    {filled =arg;}
    public void setStatusLabel(JLabel arg)
    {statusLabel =arg;}
    public void setShapeCount(int arg)
    {shapeCount =arg;}
    public void setCurrentShape(MyShape arg)
    {currentShape =arg;}
    public void setStartX(int x)
    {startX =x;}
    public void setStartY(int y)
    {startY =y;}
    //
    //get methods
    public int getShapeType()
    {return shapeType;}
    public Color getCurrentColor()
    {return currentColor;}
    public boolean getFilled()
    {return filled;}
    public JLabel getStatusLabal()
    {return statusLabel;}
    public int getShapeCount()
    {return shapeCount;}
    public MyShape getCurrentShape()
    {return currentShape;}
    public int getStartX()
    {return startX;}
    public int getStartY()
    {return startY;}
    //end of get and set methods

    public void drawCorrectly(int mouseX, int mouseY)
    {
        //this method should set currentShape's x,y,height, and width correctly
        if(mouseX ==getStartX())
        {getCurrentShape().setX2(0);}
        else if(mouseX>getStartX())//drawing to the right
        {getCurrentShape().setX2(mouseX-getCurrentShape().getX1());}
        else if(mouseX<getStartX())//drawing to the left
        {
            getCurrentShape().setX1(mouseX);
            getCurrentShape().setX2(getStartX()-mouseX);
        }

        if(mouseY ==getStartY())
        {getCurrentShape().setY2(0);}
        else if(mouseY>getStartY())
        {getCurrentShape().setY2(mouseY-getCurrentShape().getY1());}
        else if(mouseY<getStartY())
        {
            getCurrentShape().setY1(mouseY);
            getCurrentShape().setY2(getStartY()-mouseY);
        }	
    }
    public void clearLastShape()
    {
        if(getShapeCount() >0)
        {
            shapesArray[getShapeCount()-1] =null;
            setShapeCount(getShapeCount()-1);
        }	
        repaint();
    }

    public void clearDrawing()
    {
        for(int i=0;i<getShapeCount();++i)
        {shapesArray[i] =null;}
        setShapeCount(0);
        repaint();
    }

    //
    //mouse handling class
    //
    private class Mouser extends MouseAdapter implements MouseMotionListener
    {
        //override mousePressed
        public void mousePressed(MouseEvent event)
        {
            if(getShapeCount() <shapesArray.length)
            {
                switch(getShapeType())
                {
                case 0:
                    line =new MyLine(event.getX(),event.getY(),event.getX(),event.getY(),getCurrentColor());
                    setCurrentShape(line);
                    setStartX(event.getX());
                    setStartY(event.getY());
                    break;
                case 1:
                    rect =new MyRectangle(event.getX(),event.getY(),event.getX(),event.getY(),getCurrentColor(),getFilled());

                    setCurrentShape(rect);
                    setStartX(event.getX());
                    setStartY(event.getY());
                    break;
                case 2:
                    oval =new MyOval(event.getX(),event.getY(),event.getX(),event.getY(),getCurrentColor(),getFilled());

                    setCurrentShape(oval);
                    setStartX(event.getX());
                    setStartY(event.getY());
                    break;
                }
            }
        }
        //override mouseReleased
        public void mouseReleased(MouseEvent event)
        {
            if(getShapeCount() <shapesArray.length)
            {
                if(getShapeType() ==0)//if the shape is a line
                {
                    getCurrentShape().setX2(event.getX());
                    getCurrentShape().setY2(event.getY());
                }
                else //the shape isn't a line
                {drawCorrectly(event.getX(),event.getY());}

                shapesArray[getShapeCount()] =getCurrentShape();
                setShapeCount(getShapeCount()+1);
                setCurrentShape(null);
                repaint();
            }	
            if(getShapeCount() >=shapesArray.length)
            {statusLabel.setText("MAXED OUT DRAWING CAPACITY. PLEASE UNDO SOME OR CLEAR DRAWING.");}

        }
        //override mouseMoved
        public void mouseMoved(MouseEvent event)
        {
            if(getShapeCount() >=shapesArray.length)
            {statusLabel.setText("MAXED OUT DRAWING CAPACITY. PLEASE UNDO SOME OR CLEAR DRAWING.");}
            else
            {statusLabel.setText(String.format("mouse position: %d, %d", event.getX(), event.getY()));}
        }

        //override mouseDragged
        public void mouseDragged(MouseEvent event)
        {
            if(getShapeCount() <shapesArray.length)
            {
                if(getShapeType() ==0)//if the shape is a line
                {
                    getCurrentShape().setX2(event.getX());
                    getCurrentShape().setY2(event.getY());
                }
                else //the shape isn't a line
                {drawCorrectly(event.getX(),event.getY());}

                repaint();
                statusLabel.setText(String.format("mouse position: %d, %d", event.getX(), event.getY()));
            }
        }

    }

}
