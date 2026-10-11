package org.hvik.link;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/** config/hviklink.json - kommt aus dem persönlichen Download auf hvik.org (Link-Code + Token + Name). */
public final class LinkConfig {
    public final String server;
    public final String code;
    public final String token;
    public final String name;

    private LinkConfig(String server, String code, String token, String name) {
        this.server = server;
        this.code = code;
        this.token = token;
        this.name = name;
    }

    public boolean usable() {
        return !token.isEmpty() && !server.isEmpty();
    }

    public static LinkConfig load(Path configDir) {
        Path file = configDir.resolve("hviklink.json");
        try {
            if (Files.exists(file)) {
                JsonObject o = JsonParser.parseString(Files.readString(file, StandardCharsets.UTF_8)).getAsJsonObject();
                return new LinkConfig(str(o, "server", "https://hvik.org"), str(o, "code", ""), str(o, "token", ""), str(o, "name", ""));
            }
        } catch (Exception e) {
            HvikLink.LOG.error("hviklink.json konnte nicht gelesen werden", e);
        }
        return new LinkConfig("", "", "", "");
    }

    private static String str(JsonObject o, String key, String def) {
        return o.has(key) && !o.get(key).isJsonNull() ? o.get(key).getAsString().trim() : def;
    }
}
