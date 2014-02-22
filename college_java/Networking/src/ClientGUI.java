import java.awt.event.*;
import javax.swing.*;
import java.io.File;

public class ClientGUI implements MessageListener{
    private Client client;
    private JFrame frame;
    private JPanel panel;
    private JLabel label;
    private JTextField textField;
    private JFileChooser chooser;
    private JButton chooseButton;
    private JButton uploadButton;
    private JPanel buttonPanel;
    private JTextArea logArea;
    private JScrollPane scrolly;
    private File file;

    public ClientGUI(Client c){
        client = c;
        client.setListener(this);
        frame = new JFrame("Uploader");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(380, 220);
        frame.setVisible(true);

        chooser = new JFileChooser();
        panel = new JPanel();
        label = new JLabel("Host:");
        textField = new JTextField(10);
        textField.requestFocus();
        chooseButton = new JButton("Choose file");
        chooseButton.setVisible(false);
        uploadButton = new JButton("Upload");
        uploadButton.setVisible(false);;
        buttonPanel = new JPanel();
        buttonPanel.setLayout(new BoxLayout(buttonPanel, BoxLayout.X_AXIS));
        logArea = new JTextArea("Log: ", 8, 22);
        logArea.setEditable(false);
        scrolly = new JScrollPane(logArea);

        textField.addActionListener(new HostFieldListener());
        chooseButton.addActionListener(new ChooseButtonListener());
        uploadButton.addActionListener(new UploadButtonListener());

        panel.add(label);
        panel.add(textField);
        panel.add(buttonPanel);
        buttonPanel.add(chooseButton);
        buttonPanel.add(uploadButton);
        panel.add(scrolly);
        frame.add(panel);
        frame.validate();
    }

    public void message(String text){
        logArea.append("\n" + text);
    }

    private class HostFieldListener implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            if(client.connect(textField.getText())){
                //connection success
                label.setText("Connected");
                textField.setEditable(false);
                chooseButton.setVisible(true);
                uploadButton.setVisible(true);
    			panel.repaint();
            }
            else{
                //connect failed
            }
        }
    }

    private class ChooseButtonListener implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            int dialogValue = chooser.showOpenDialog(panel);
            if (dialogValue == JFileChooser.APPROVE_OPTION) {
                file = chooser.getSelectedFile();
                label.setText(file.getPath());
                uploadButton.setVisible(true);
                panel.repaint();
            }
        }
    }

    private class UploadButtonListener implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            if(file == null) label.setText("Choose a file first.");
            else{
                client.sendFile(file);
                client.closeConnection();
                label.setText("Reconnect to upload again.");
                textField.setEditable(true);
                chooseButton.setVisible(false);
                uploadButton.setVisible(false);
                panel.repaint();
            }
        }
    }
}
