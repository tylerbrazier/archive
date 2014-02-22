

import javax.swing.JFrame;

public class DrawingTest extends JFrame
{
    public static void main(String[] args)
    {
        DrawFrame app =new DrawFrame();

        app.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        app.setSize(500,500);
        app.setVisible(true);
    }
}
