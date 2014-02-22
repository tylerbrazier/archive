package secret_stash.view;

import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JPanel;

import secret_stash.controller.Controller;

public class EditView extends View {

    private CustomField nameField;
    private CustomField usernameField;
    private CustomField passwordField;

    public EditView(Controller c) {
        super(c);

        nameField = new CustomField("Account Name", false);
        usernameField = new CustomField("Username", false);
        passwordField = new CustomField("Password", true);
        JPanel namePanel = new JPanel();
        JPanel userPanel = new JPanel();
        JPanel passPanel = new JPanel();
        JPanel buttonPanel = new JPanel();
        JButton okButton = new JButton("OK");
        JButton cancelButton = new JButton("Cancel");
        JButton toggleButton = new JButton("Show/Hide Password");

        okButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                try {
                    controller.update(nameField.getText(),
                                      usernameField.getText(),
                                      passwordField.getText());
                } catch (Exception err) {
                    error(err.getMessage());
                }
            }
        });
        cancelButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                controller.cancel();
            }
        });
        toggleButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                passwordField.toggleHide();
            }
        });

        namePanel.add(nameField);
        userPanel.add(usernameField);
        passPanel.add(passwordField);
        buttonPanel.add(okButton);
        buttonPanel.add(cancelButton);
        buttonPanel.add(toggleButton);

        mainPanel.setLayout(new GridLayout(4, 1));
        mainPanel.add(namePanel);
        mainPanel.add(userPanel);
        mainPanel.add(passPanel);
        mainPanel.add(buttonPanel);
    }

    public EditView(Controller c, String name, String username, String pass) {
        this(c);
        nameField.setText(name);
        usernameField.setText(username);
        passwordField.setText(pass);
    }

    @Override
    protected String getBanner() {
        return "Edit/View";
    }
}
