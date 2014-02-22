

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class DrawFrame extends JFrame
{
    private DrawPanel drawPanel;
    private String[] shapesArray;
    private String[] colorsArray;
    private JLabel statusBar;
    private BorderLayout layout;
    private JButton undoButton;
    private JButton clearButton;
    private JComboBox colorsBox;
    private JComboBox shapesBox;
    private JCheckBox checkFilled;
    private JPanel buttonPanel; //used for fitting 5 buttons on northern layout

    //constructor
    public DrawFrame()
    {
        super("Draw Something");

        layout =new BorderLayout(5,5);
        setLayout(layout);

        statusBar =new JLabel();

        drawPanel =new DrawPanel(statusBar);
        buttonPanel =new JPanel();
        buttonPanel.setLayout(new GridLayout(1,5));

        add(drawPanel,BorderLayout.CENTER);
        add(statusBar,BorderLayout.SOUTH);
        add(buttonPanel,BorderLayout.NORTH);

        Itemmer itemmer =new Itemmer();//handler
        Buttoner buttoner =new Buttoner();//handler

        //shapes box setup
        String[] shapesArray ={"Line","Rectangle","Oval"};
        shapesBox =new JComboBox(shapesArray);
        shapesBox.setMaximumRowCount(3);
        shapesBox.addItemListener(itemmer);
        //

        //colors box setup
        String[] colorsArray ={"Black","Blue","Cyan","Dark Gray","Gray","Green","Light Gray",
                "Magenta","Orange","Pink","Red","White","Yellow"};
        colorsBox =new JComboBox(colorsArray);
        colorsBox.setMaximumRowCount(5);
        colorsBox.addItemListener(itemmer);
        //

        //button setup
        undoButton =new JButton("Undo");
        undoButton.addActionListener(buttoner);

        clearButton =new JButton("Clear");
        clearButton.addActionListener(buttoner);
        //

        //check box setup
        checkFilled =new JCheckBox("Filled");
        checkFilled.addItemListener(itemmer);

        //add stuff
        buttonPanel.add(undoButton);
        buttonPanel.add(clearButton);
        buttonPanel.add(shapesBox);
        buttonPanel.add(colorsBox);
        buttonPanel.add(checkFilled);

    }
    //button handler
    private class Buttoner implements ActionListener
    {
        public void actionPerformed(ActionEvent event)
        {
            if(event.getSource()==undoButton)
            {drawPanel.clearLastShape();}
            else if(event.getSource()==clearButton)
            {drawPanel.clearDrawing();}
        }
    }
    //item handler
    private class Itemmer implements ItemListener
    {
        public void itemStateChanged(ItemEvent event)
        {
            if(event.getSource()==colorsBox)
            {
                Color[] thirteenColors ={Color.BLACK,Color.BLUE,Color.CYAN,Color.DARK_GRAY,Color.GRAY,
                        Color.GREEN,Color.LIGHT_GRAY,Color.MAGENTA,Color.ORANGE,Color.PINK,Color.RED,
                        Color.WHITE,Color.YELLOW};
                if(event.getStateChange() ==ItemEvent.SELECTED)
                {drawPanel.setCurrentColor(thirteenColors[colorsBox.getSelectedIndex()]);}
            }
            else if(event.getSource()==shapesBox)
            {
                if(event.getStateChange() ==ItemEvent.SELECTED)
                {drawPanel.setShapeType(shapesBox.getSelectedIndex());}
            }
            else if(event.getSource()==checkFilled)
            {
                if(checkFilled.isSelected())
                {drawPanel.setFilled(true);}
                else
                {drawPanel.setFilled(false);}
            }
        }
    } 	  
}
