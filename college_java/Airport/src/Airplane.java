public class Airplane 
{
    //data
    private boolean arriving; //false if departing
    private boolean finished;
    private int timeOnRunway;
    private String name;

    public int getTimeOnRunway()
    {return timeOnRunway;}
    public boolean isArriving()
    {return arriving;}
    public boolean isFinished()
    {return finished;}
    //end of data

    //construct
    public Airplane(String n, int t, boolean b)
    {
        name =n;
        timeOnRunway =t;
        arriving =b;
        finished =false;
    }	
    public Airplane()
    {this("Unnamed airplane", 10, true);}
    //

    //methods
    public void useRunway()
    {//precondition is to make sure this plane is NOT finished
        timeOnRunway--;

        if(timeOnRunway <=0) finished =true;
    }

    public String toString()
    {
        return this.name;
    }
    //
}
