/*
 * This class represents data that is stored in the stash file.
 * A single entry of data (for this version) contains "name,username,password"
 * with "name" being unique and "username" and "password" being encrypted.
 */

package secret_stash.model;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

public class StashData {

    private Map<String, String[]> entries;

    public StashData() {
        entries = new HashMap<>();
    }

    // used for add and edit operations
    public void update(String name, String username, String password) {
        entries.put(name, new String[] {username, password});
    }

    public boolean remove(String name) {
        if (entries.remove(name) != null)
            return true;
        else
            return false;
    }

    public boolean hasName(String name) {
        return entries.containsKey(name);
    }

    public Set<String> getNames() {
        return entries.keySet();
    }

    // returns null if i don't have that name
    public String[] getValues(String name) {
        return entries.get(name);
    }
}