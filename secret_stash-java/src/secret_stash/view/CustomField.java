package secret_stash.view;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionListener;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
import javax.swing.border.TitledBorder;

/*
 * A text field with a titled border that can declared to be a password
 * field on creation. Action listeners that are added to a CustomField
 * are simply added to the underlying field object.
 */
public class CustomField extends JPanel {

    private static final Dimension SIZE = new Dimension(300, 28);

    private final static char HIDDEN_ECHO_CHAR = '*';
    private JTextField field;
    private boolean isPasswordField;

    public CustomField(String title, boolean passwordField) {
        if (passwordField) {
            field = new JPasswordField();
            ((JPasswordField) field).setEchoChar(HIDDEN_ECHO_CHAR);
        } else
            field = new JTextField();

        isPasswordField = passwordField;
        setLayout(new BorderLayout());
        setBorder(new TitledBorder(title));
        field.setPreferredSize(SIZE);
        add(field, BorderLayout.CENTER);
    }


    public void addActionListener(ActionListener listener) {
        field.addActionListener(listener);
    }


    public String getText() {
        return field.getText();
    }


    public void setText(String text) {
        field.setText(text);
    }

    public void toggleHide() {
        if (isPasswordField) {
            JPasswordField f = ((JPasswordField) field);

            if (f.getEchoChar() == (char) 0)
                f.setEchoChar(HIDDEN_ECHO_CHAR);
            else
                f.setEchoChar((char) 0);
        }
    }
}
