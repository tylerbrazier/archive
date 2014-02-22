

import java.util.ArrayList;

import javax.swing.JFrame;

public class BallTest {

    /**
     * @param args
     */
    public static void main(String[] args) 
    {
        ArrayList<BallModel> models = new ArrayList<BallModel>();

        BallView view1 = new BallView(models);
        view1.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        view1.setSize(500,500);
        view1.setVisible(true);

        //*IMPORTANT NOTE*
        //additional views will not begin to be updated until 
        //they have been clicked in because until then, there is
        //no controller to update that view
        BallView view2 = new BallView(models);
        view2.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        view2.setSize(500,500);
        view2.setVisible(true);
    }

}
