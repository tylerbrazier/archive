

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.ArrayList;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import javax.swing.JFrame;
import javax.swing.JPanel;

public class BallView extends JFrame
{
    private Panel panel;
    private ExecutorService executor;
    private ArrayList<BallModel> balls;

    public BallView(ArrayList<BallModel> models)
    {
        super("MVC Assignment");

        balls = models;
        executor =Executors.newCachedThreadPool();
        panel = new Panel(models);
        panel.setBackground(Color.WHITE);
        panel.addMouseListener(new Mouser());
        add(panel);

    }

    public void updateView()
    {
        panel.repaint();
    }
    
    public Dimension getSize(){
        return panel.getSize();
    }

    private class Mouser extends MouseAdapter
    {
        public void mouseClicked(MouseEvent e)
        {	
            BallModel b = new BallModel(e.getX(), e.getY(), 10, Color.BLACK);
            balls.add(b);
            executor.execute(new BallController(b, BallView.this));
        }
    }

    private class Panel extends JPanel
    {
        private ArrayList<BallModel> balls;

        public Panel(ArrayList<BallModel> models)
        {
            balls = models;
        }

        public void paintComponent(Graphics g)
        {//draws each ball in the arraylist
            super.paintComponent(g);

            for(int i=0; i<balls.size(); ++i)
            {
                balls.get(i).draw(g);
            }
        }
    }
}
