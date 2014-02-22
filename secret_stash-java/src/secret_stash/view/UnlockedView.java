package secret_stash.view;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Set;

import javax.swing.Box;
import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.SwingConstants;

import secret_stash.controller.Controller;

public class UnlockedView extends View {

    private static final int B_COLS = 3;
    private static final int B_ROWS = 1;
    private static final int B_HGAP = 25;
    private static final int B_VGAP = 0;
    private static final int NAME_GAP = 5;

    private JPanel namesPanel;

    public UnlockedView(final Controller controller) {
        super(controller);

        this.namesPanel = new JPanel();
        JPanel buttonsPanel = new JPanel();
        JButton lockButton = new JButton("Lock");
        JButton addButton = new JButton("New");
        JButton helpButton = new JButton("Help");
        JScrollPane scrolly = new JScrollPane(namesPanel);

        buttonsPanel.setLayout(new GridLayout(B_ROWS, B_COLS, B_HGAP, B_VGAP));
        buttonsPanel.add(lockButton);
        buttonsPanel.add(addButton);
        buttonsPanel.add(helpButton);

        lockButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent ev) {
                try { controller.lock(); }
                catch (Exception e) { error(e.getMessage()); }
            }
        });

        addButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent arg0) {
                controller.add();
            }
        });

        helpButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent arg0) {
                controller.help();
            }
        });

        updateListing();

        mainPanel.setLayout(new BorderLayout(HORZ_GAP, VERT_GAP));
        mainPanel.add(buttonsPanel, BorderLayout.NORTH);
        mainPanel.add(scrolly, BorderLayout.CENTER);
    }

    @Override
    protected String getBanner() {
        return "Secret Stash";
    }


    private void updateListing() {
        Set<String> names = controller.getNames();
        namesPanel.removeAll();
        namesPanel.setLayout(new GridLayout(names.size(), 1, 0, NAME_GAP));
        for (String name : names)
            namesPanel.add(new NameListing(name));
        revalidate();
        repaint();
    }


    private class NameListing extends JPanel {

        private static final int HGAP = 10;
        private static final int VGAP = 0;

        public NameListing(final String name) {
            JLabel nameLabel = new JLabel(name);
            JButton editButton = new JButton("Edit/View");
            JButton removeButton = new JButton("Remove");
            JPanel buttonPanel = new JPanel();

            nameLabel.setHorizontalAlignment(SwingConstants.CENTER);
            buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.X_AXIS));
            buttonPanel.add(editButton);
            buttonPanel.add(Box.createHorizontalStrut(HGAP));
            buttonPanel.add(removeButton);

            editButton.addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    controller.edit(name);
                }
            });
            removeButton.addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    controller.remove(name);
                    updateListing();
                }
            });

            this.setLayout(new BorderLayout(HGAP, VGAP));
            this.add(nameLabel, BorderLayout.CENTER);
            this.add(buttonPanel, BorderLayout.EAST);
        }
    }
}
