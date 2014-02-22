

import java.lang.Runnable;

public class BallController implements Runnable
{
    private BallView view;
    private BallModel ball;

    private boolean north;
    private boolean west;

    public BallController(BallModel model, BallView aView)
    {
        ball = model;
        view = aView;
        north = true;
        west = true;
    }

    @Override
    public void run()
    {
        while(true)
        {
            if(north)
            {
                if(west)
                {
                    //ball is moving northwest
                    ball.setX(ball.getX()-1);
                    ball.setY(ball.getY()-1);
                }
                else 
                {
                    //northeast
                    ball.setX(ball.getX()+1);
                    ball.setY(ball.getY()-1);
                }
            }
            else //south
            {
                if(west)
                {
                    ball.setX(ball.getX()-1);
                    ball.setY(ball.getY()+1);
                }
                else
                {
                    ball.setX(ball.getX()+1);
                    ball.setY(ball.getY()+1);
                }
            }

            int width = view.getSize().width;
            int height = view.getSize().height;
            if(ball.getX() > width-ball.getSize()) west =true;
            if(ball.getX() < 0) west =false;
            if(ball.getY() > height-ball.getSize()) north =true;
            if(ball.getY() < ball.getSize()) north =false;

            view.updateView();

            try
            {
                Thread.sleep(10);
            }
            catch(InterruptedException e)
            {
                e.printStackTrace();
            }
        }
    }
}
