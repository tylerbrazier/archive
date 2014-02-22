package secret_stash.view;

import java.awt.BorderLayout;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

public class ViewFrame {

    private static final String TITLE = "Secret Stash";
    private static final int FRAME_WIDTH = 500;
    private static final int FRAME_HEIGHT = 500;

    private JFrame frame;
    private View currentView;

    public ViewFrame() {
        this.frame = new JFrame(TITLE);

        frame.setLayout(new BorderLayout());
        frame.setSize(FRAME_WIDTH, FRAME_HEIGHT);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE); // TODO change me
    }


    public void setView(View view) {
        if (currentView != null)
            frame.getContentPane().removeAll();
        frame.getContentPane().add(view, BorderLayout.CENTER);
        frame.revalidate();
        frame.repaint();
        currentView = view;
        frame.setVisible(true);
    }


    public void dialog(String message) {
        JOptionPane.showMessageDialog(frame, message);
    }


    public boolean confirm(String message) {
        int result = JOptionPane.showConfirmDialog(frame, message);
        if (result == JOptionPane.YES_OPTION)
            return true;
        else
            return false;
    }
}
