public class ControlTower implements ClockListener 
{	
    private Runway[] runways;
    private ThinAir generator;
    private Airplane planeHolder;
    private int totalPlanesSupportedByAllQs; //used for final report

    public ControlTower()
    {
        this(new Runway[0], new ThinAir());
    }
    public ControlTower(Runway[] runwaysArg, ThinAir thinair)
    {
        if(runwaysArg[0] ==null) runwaysArg[0] = new Runway();
        runways =runwaysArg;
        generator =thinair;
        planeHolder =null;
        totalPlanesSupportedByAllQs =0;
    }

    public String preEvent(int currentTick)
    {
        if(generator.hasPlane())
        {
            planeHolder =generator.retrievePlane();

            if(planeHolder.isArriving())
                return "Control tower grants permission for " +planeHolder.toString() + " to land.";

            else //planeHolder's plane is departing
                return "Control tower grants permission for " +planeHolder.toString() + " to depart.";
        }
        return "";
    }

    public String event(int currentTick)
    {
        if(planeHolder ==null) return "";

        else //control tower has a plane that needs to be added to a runway q
        {
            Runway shortest;

            shortest =this.shortestWaitTime(planeHolder.isArriving());

            if(planeHolder.isArriving())
            {
                shortest.putInArrival(planeHolder);
                totalPlanesSupportedByAllQs++;

                Airplane tempref =planeHolder;
                planeHolder =null;

                return (tempref.toString() +" enters arrival queue on " + shortest.toString() + ".");
            }
            else //plane is departing
            {
                shortest.putInDeparture(planeHolder);
                totalPlanesSupportedByAllQs++;

                Airplane tempref =planeHolder;
                planeHolder =null;

                return (tempref.toString() +" enters departure queue on " +shortest.toString() + ".");
            }
        }
    }

    private Runway shortestWaitTime(boolean arriving)
    {//returns shortest arriving if true parameter and
        //shortest departing if false
        Runway shortest;

        shortest =runways[0];

        for(int i=1; i<runways.length; ++i)
        {
            if(runways[i].getWaitTime(arriving) < shortest.getWaitTime(arriving)) shortest =runways[i];	
        }
        return shortest;	
    }

    public void report()
    {//
        System.out.println("\n~~Report~~\n");

        int totalTimeOnRunways =0;
        int totalPlanesSupportedByAllRunways =0;
        int totalTimeInQs =0;
        int totalIdleTime =0;
        double averageTimeOnRunway =0.0;
        double averageWaitTimeInQ =0.0;
        double averageIdleTime =0.0;

        for(int i=0; i<runways.length; ++i)
        {
            totalTimeOnRunways +=runways[i].getTimeOnRunway();
            totalPlanesSupportedByAllRunways +=runways[i].getNumOfPlanesSupported();
            totalTimeInQs +=runways[i].getTotalTimeInQs();
            totalIdleTime +=runways[i].getIdleTime();	
        }

        averageTimeOnRunway =divide(totalTimeOnRunways, totalPlanesSupportedByAllRunways);
        averageWaitTimeInQ =divide(totalTimeInQs, totalPlanesSupportedByAllQs);
        averageIdleTime =divide(totalIdleTime, runways.length);

        System.out.println("Average time an airplane is on a runway: " +averageTimeOnRunway +
        " ticks.");
        System.out.println("Average wait time in queues: " +averageWaitTimeInQ +" ticks.");
        System.out.println("Average idle time on runways: " +averageIdleTime +" ticks.");
        System.out.println("Final contents of each queue: \n");

        for(int i=0; i<runways.length; ++i)
        {
            System.out.println(runways[i].toString() +": ");

            System.out.println("\tArrival Queue: ");
            boolean empty =true;
            for(int j=0; j<runways[i].arrivalQ().size(); ++j)
            {
                empty =false;
                try
                {
                    System.out.println("\t" +runways[i].arrivalQ().planeAt(j).toString());
                }
                catch(IndexOutOfBoundsException e)
                {e.printStackTrace();}
            }
            if(empty) System.out.println("\tempty...");

            System.out.println("\tDeparture Queue: ");
            empty =true;
            for(int j=0; j<runways[i].departureQ().size(); ++j)
            {
                empty =false;
                try
                {
                    System.out.println("\t" +runways[i].departureQ().planeAt(j).toString());
                }
                catch(IndexOutOfBoundsException e)
                {e.printStackTrace();}
            }
            if(empty) System.out.println("\tempty...");
        }
    }
    private double divide(int nume, int denom)
    {//used for report method
        try
        {
            return nume / denom;
        }
        catch(ArithmeticException e)
        {
            System.out.println("Exception! Cannot divide by zero.");
            return 0.0;
        }
    }
}
