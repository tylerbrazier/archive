package secret_stash.view;

import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.filechooser.FileNameExtensionFilter;
import secret_stash.controller.Controller;

public class LockedView extends View {

    private static final String STASH_FILE_NAME = "stash.csv";
    private CustomField pathField;
    private CustomField passField;

    public LockedView(Controller c) {
        super(c);

        // initialize components
        pathField = new CustomField("Path to stash file", false);
        passField = new CustomField("Password to unlock", true);
        JButton browseButton = new JButton("Browse");
        JButton unlockButton = new JButton("Unlock");
        JButton createButton = new JButton("Create");
        JLabel createLabel = new JLabel("No stash yet?");
        JPanel filePanel = new JPanel();
        JPanel passPanel = new JPanel();
        JPanel createPanel = new JPanel();
        GridLayout layout = new GridLayout(3,1); // 3 rows, 1 column

        // build file panel
        browseButton.setFocusable(false);
        browseButton.addActionListener(new BrowseListener());
        filePanel.add(pathField);
        filePanel.add(browseButton);
        pathField.setText(c.getStashPath());

        // build password panel
        unlockButton.setFocusable(false);
        UnlockListener listener = new UnlockListener();
        unlockButton.addActionListener(listener);
        passField.addActionListener(listener);
        passPanel.add(passField);
        passPanel.add(unlockButton);

        // build create panel
        createButton.setFocusable(false);
        createButton.addActionListener(new CreateListener());
        createPanel.add(createLabel);
        createPanel.add(createButton);

        // build this panel
        mainPanel.setLayout(layout);
        mainPanel.add(filePanel);
        mainPanel.add(passPanel);
        mainPanel.add(createPanel);
    }


    @Override
    public String getBanner() {
        return "Select file location and enter password to unlock.";
    }


    private class BrowseListener implements ActionListener {

        private JFileChooser chooser;

        public BrowseListener() {
            chooser = new JFileChooser();
            chooser.setFileFilter(
                    new FileNameExtensionFilter("CSV files", "csv"));
        }
        @Override
        public void actionPerformed(ActionEvent arg0) {
            int result = chooser.showOpenDialog(LockedView.this);

            if (result == JFileChooser.APPROVE_OPTION)
                pathField.setText(chooser.getSelectedFile().getAbsolutePath());
        }
    }


    private class UnlockListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent arg0) {
            try {
                controller.unlock(pathField.getText(), passField.getText());
            } catch (Exception e) {
                e.printStackTrace();
                error(e.getMessage());
                //error("Wrong password");
            }
        }
    }


    private class CreateListener implements ActionListener {
        private JFileChooser chooser;

        public CreateListener() {
            chooser = new JFileChooser();
            chooser.setFileFilter(
                    new FileNameExtensionFilter("CSV files", "csv"));

            // build path to stash file
            StringBuilder sb = new StringBuilder();
            sb.append(System.getProperty("user.home"));
            sb.append(System.getProperty("file.separator"));
            sb.append(STASH_FILE_NAME);
            chooser.setSelectedFile(new File(sb.toString()));
        }
        @Override
        public void actionPerformed(ActionEvent arg0) {
            int result = chooser.showOpenDialog(LockedView.this);

            if (result == JFileChooser.APPROVE_OPTION) {
                try {
                    String path = chooser.getSelectedFile().getAbsolutePath();
                    controller.createStash(path);
                    pathField.setText(path);
                } catch (Exception e) {
                    error("Unable to create file.");
                }
            }
        }
    }
}
