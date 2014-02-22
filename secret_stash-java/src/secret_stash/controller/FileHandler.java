package secret_stash.controller;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Properties;

import secret_stash.model.StashData;

/*
 * Handles reading from and writing to the stash file and config file.
 */
public class FileHandler {

    private final static String PROPS_FILE_NAME = ".secret_stash.conf";
    private final static String CONFIG_COMMENT = "Secret Stash config file";
    private final static String SEPARATOR = ",";
    private Crypt crypt;
    private String configPath;
    private Properties props;

    public FileHandler() {
        // build path to config file
        StringBuilder sb = new StringBuilder();
        sb.append(System.getProperty("user.home"));
        sb.append(System.getProperty("file.separator"));
        sb.append(PROPS_FILE_NAME);
        this.configPath = sb.toString();
        this.crypt = new Crypt();
        this.props = new Properties();
    }


    public Properties parseConfig() throws FileNotFoundException, IOException {
        props.load(new FileInputStream(configPath));
        return props;
    }


    public void storeConfig(Properties props)
            throws FileNotFoundException, IOException {
        props.store(new FileOutputStream(configPath), CONFIG_COMMENT);
    }


    public boolean createStash(String path) throws Exception {
        File f = new File(path);
        f.getParentFile().mkdirs();
        return f.createNewFile();
    }


    public StashData parseStash(String fileName,
                                String unlockPass) throws Exception{
        String line;
        String[] fields;
        String name;
        String username;
        String password;
        BufferedReader reader = null;
        StashData data = new StashData();

        try {
            reader = new BufferedReader(new FileReader(fileName));

            while ((line = reader.readLine()) != null) {
                fields = line.split(SEPARATOR);

                name = fields[0];
                username = crypt.decrypt(fields[1], unlockPass);
                password = crypt.decrypt(fields[2], unlockPass);
                data.update(name, username, password);
            }
            reader.close();
        } catch (Exception e) {
            if (reader != null)
                reader.close();
            throw e;
        }

        return data;
    }


    public void storeStash(String fileName,
                           String lockPass,
                           StashData data) throws Exception {
        String username;
        String password;
        String line;
        PrintWriter writer = null;

        try {
            writer = new PrintWriter(fileName);
            for (String name : data.getNames()) {
                String[] values = data.getValues(name);
                username = crypt.encrypt(values[0], lockPass);
                password = crypt.encrypt(values[1], lockPass);
                line = String.format("%s,%s,%s", name, username, password);
                writer.println(line);
            }
            writer.close();
        } catch (Exception e) {
            if (writer != null)
                writer.close();
            throw e;
        }
    }
}
