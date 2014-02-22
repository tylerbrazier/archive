public interface ClockListener 
{

    public String event(int currentTick);
    public String preEvent(int currentTick);

    //some events might not need to trigger every tick
    //so all ClockListeners should know what tick
    //the clock is currently on (even if it doesn't
    //matter in some cases).
    //also, when an event happens, it should report
    //what happened so each listener should return a 
    //string
}
