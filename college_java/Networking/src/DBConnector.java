/*
 * Can be used to connect to a MySQL or Postgres database and run SQL statements.
 * Remember that you need a driver. To include the driver in the classpath when
 * running this use 'java -cp "<driver.jar>:." DBConnector' 
 * 
 * **A note for Postgres database**
 * Table names should be lowercase. I had issues when trying to
 * read from a table who's name began with an uppercase letter.
 */

import java.sql.*;

public class DBConnector 
{
    private String dbIp;
    private String dbPort;
    private String dbType;
    private String dbName;
    private String dbUsername;
    private String dbPassword;
    private Connection dbCon;
    private String url;

    public DBConnector(){} //empty constructor. you can call connectToDB to connect after creating this object

    public DBConnector(String type, String ip, String port, String name, String username, String password)
    {
        connectToDB(type, ip, port, name, username, password);
    }

    public void connectToDB(String type, String ip, String port, String name, String username, String password)
    {
        if(type.equals("postgres")) type = "postgresql";
        this.dbType = type;
        this.dbIp = ip;
        this.dbPort = port;
        this.dbName = name;
        this.dbUsername = username;
        this.dbPassword = password;
        this.url = "jdbc:"+this.dbType+"://"+this.dbIp+":"+this.dbPort+"/";

        try 
        {
            System.out.println("Attempting to connect to "+this.dbName+" database.");
            //a little hacky but whatever
            if(this.dbType == "mysql") Class.forName("com.mysql.jdbc.Driver").newInstance();
            if(this.dbType == "postgresql") Class.forName("org.postgresql.Driver");
            this.dbCon = DriverManager.getConnection(url+this.dbName,this.dbUsername,this.dbPassword);
            System.out.println("Success!");
        }
        catch(Exception e){e.printStackTrace();}	
    }

    public ResultSet executeStatement(String query)
    {
        ResultSet result = null;
        Statement statement;
        try
        {
            statement = dbCon.createStatement();
            result = statement.executeQuery(query);
        }
        catch (Exception e) {e.printStackTrace();}

        return result;
    }

    public void disconnectDB()
    {
        try
        {
            this.dbCon.close();
            System.out.println("Disconnected from database.");
        }
        catch (Exception e) {e.printStackTrace();}
    }
}
