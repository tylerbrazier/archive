public class Runway implements ClockListener
{
    private Airplane currentPlane;
    private AirplaneQueue arrivalQu;
    private AirplaneQueue departureQu;
    private String name;
    private int timeOnRunway;
    private int idleTime;
    private int numOfPlanesSupported;
    private int totalTimeInQs;

    public Runway(String n)
    {
        name =n;
        arrivalQu =new AirplaneQueue();
        departureQu =new AirplaneQueue();
        currentPlane =null;
        timeOnRunway =0;
        idleTime =0;
        numOfPlanesSupported =0;
        totalTimeInQs =0;
    }
    public Runway()
    {
        this("Unnamed runway");
    }

    public String preEvent(int currentTick)
    {
        if(currentPlane ==null) return "";

        else if(getCurrentPlane().isFinished())
        {//if current plane is finished, remove it from the runway
            Airplane tempRef =currentPlane;
            currentPlane =null;

            return tempRef.toString() + " successfully landed on and removed from " + 
            name + ".";
        }
        else return "";
    }
    public String event(int currentTick)
    {
        //first, add to total time in q
        for(int i=0; i<arrivalQu.size(); ++i)
        {totalTimeInQs++;}
        for(int i=0; i<departureQu.size(); ++i)
        {totalTimeInQs++;}

        if(this.isInUse() && !getCurrentPlane().isFinished())
        {
            getCurrentPlane().useRunway();
            timeOnRunway++;

            return "";
        }
        else //runway can accept a new plane from the Q
        {
            idleTime++;
            //planes waiting to land have priority over 
            //those waiting to depart 
            if(arrivalQu.size() >0)
            {
                addToRunway(this.takeFromArrival());

                return currentPlane.toString() +" begins to land on " + 
                name + ".";
            }
            //check departure q second
            else if(departureQu.size() >0)
            {
                addToRunway(this.takeFromDeparture());

                return currentPlane.toString() +" begins to depart on " +
                name + ".";
            }
        }
        return "";
    }

    public int getWaitTime(boolean arriving)
    {//returns the time of current plane plus total of each 
        //arriving plane if arriving arg is true. if arriving 
        //arg is false, returns time of current plus time of
        //departing planes plus total time of arriving planes
        int total;

        if(this.isInUse()) total =currentPlane.getTimeOnRunway();

        else total =0;

        for(int i=0; i< arrivalQu.size(); ++i)
        {
            try
            {
                total +=arrivalQu.planeAt(i).getTimeOnRunway();
            }
            catch(IndexOutOfBoundsException e)
            {e.printStackTrace();}

        }

        if(!arriving) //caller requests to get departing time
        {
            for(int i=0; i< departureQu.size(); ++i)
            {
                try
                {
                    total +=departureQu.planeAt(i).getTimeOnRunway();
                }
                catch(IndexOutOfBoundsException e)
                {e.printStackTrace();}

            }
        }
        return total;
    }

    private void addToRunway(Airplane plane)
    {//will NOT add to runway if another plane is there
        //but will report a message
        if(this.isInUse()) 
        {
            System.out.println("Notice! Blocked attempt to add " +
                    "an Airplane to the occupied " +name +".");
        }	
        else
        {
            currentPlane =plane;
            numOfPlanesSupported++;
        }
    }

    //basic methods
    public String toString()
    {return this.name;}

    public int getTimeOnRunway()
    {return timeOnRunway;}

    public int getIdleTime()
    {return idleTime;}

    public int getNumOfPlanesSupported()
    {return numOfPlanesSupported;}

    public int getTotalTimeInQs()
    {return totalTimeInQs;}

    public Airplane getCurrentPlane()
    {return currentPlane;}

    public boolean isInUse()
    {
        if(currentPlane ==null) return false;

        else return true;
    }

    public AirplaneQueue arrivalQ()
    {return this.arrivalQu;}

    public AirplaneQueue departureQ()
    {return this.departureQu;}

    //put and take methods
    public void putInArrival(Airplane plane)
    {arrivalQu.addPlane(plane);}

    private Airplane takeFromArrival()
    {return arrivalQu.removePlane();}

    public void putInDeparture(Airplane plane)
    {departureQu.addPlane(plane);}

    private Airplane takeFromDeparture()
    {return departureQu.removePlane();}
    //
}
