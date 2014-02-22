/*
 * Subclasses should never add to themselves; always add to mainPanel
 */
package secret_stash.view;

import java.awt.BorderLayout;
import java.awt.Color;
import javax.swing.Box;
import javax.swing.JLabel;
import javax.swing.JPanel;

import secret_stash.controller.Controller;

public abstract class View extends JPanel {

    protected static final int VERT_GAP = 25;
    protected static final int HORZ_GAP = 25;

    protected Controller controller;
    protected JPanel mainPanel;
    private JLabel bannerLabel;
    private JLabel messageLabel;

    public View(Controller controller) {
        this.controller = controller;
        this.mainPanel = new JPanel();
        this.bannerLabel = new JLabel();
        this.messageLabel = new JLabel();
        JPanel northPanel = new JPanel();
        JPanel southPanel = new JPanel();

        northPanel.add(bannerLabel);
        southPanel.add(messageLabel);
        bannerLabel.setForeground(Color.BLACK);
        bannerLabel.setText(getBanner());

        this.setLayout(new BorderLayout(HORZ_GAP, VERT_GAP));
        this.add(northPanel, BorderLayout.NORTH);
        this.add(southPanel, BorderLayout.SOUTH);
        this.add(Box.createHorizontalGlue(), BorderLayout.WEST);
        this.add(Box.createHorizontalGlue(), BorderLayout.EAST);
        this.add(mainPanel, BorderLayout.CENTER);
    }


    protected abstract String getBanner();


    protected final void message(String message) {
        messageLabel.setForeground(Color.BLACK);
        messageLabel.setText(message);
    }


    protected final void error(String message) {
        messageLabel.setForeground(Color.RED);
        messageLabel.setText(message);
    }
}
