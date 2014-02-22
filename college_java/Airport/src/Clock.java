import java.util.ArrayList;

public class Clock 
{
    //data
    private ArrayList <ClockListener> listeners;

    //construct
    public Clock()
    {listeners =new ArrayList<ClockListener>();}

    //methods
    public void addListener(ClockListener input)
    {
        listeners.add(input);
    }

    public void run(int numTicks)
    {
        String message;

        for(int currentTick =0; currentTick<numTicks; ++currentTick)//run thru each tick
        {
            System.out.println("Tick " +currentTick +":");
            for(int i=0; i<listeners.size(); ++i)
            {
                message =(listeners.get(i).preEvent(currentTick));
                if(message !="")
                {
                    System.out.println(message);
                }
            }
            for(int i=0; i<listeners.size(); ++i)//run thru each listener (per tick)
            {
                message =(listeners.get(i).event(currentTick));
                if(message != "") System.out.println(message);
            }
        }
    }
    //end of methods
}
