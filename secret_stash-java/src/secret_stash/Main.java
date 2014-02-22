package secret_stash;

import javax.swing.SwingUtilities;

import secret_stash.controller.Controller;
import secret_stash.view.LockedView;
import secret_stash.view.ViewFrame;

public class Main {

    public static final int VERSION = 20131227;

    public static void main(String[] args) {

        final ViewFrame frame = new ViewFrame();
        final Controller c = new Controller(frame);

        SwingUtilities.invokeLater(new Runnable() {

            @Override
            public void run() {
                frame.setView(new LockedView(c));
            }
        });
    }
}
