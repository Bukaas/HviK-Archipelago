package org.hvik.link;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * Verbindung zu hvik.org über Long-Polling (nginx lässt keine WebSockets durch):
 * POST /api/mclink/poll hält bis zu ~20 s, bis es etwas Neues gibt; POST /api/mclink/send schickt eigene Ereignisse.
 * Spielwirkungen (Herzen, Hunger, Tod) landen in {@link #effects} und werden im Server-Tick angewendet.
 */
public final class LinkClient {
    private final LinkConfig cfg;
    private final HttpClient http = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
    private volatile Thread pollThread;
    private volatile boolean running;
    private long seq = 0;

    /** Ereignisse für die Spielwelt (hp/food/die/chat) - im Server-Tick abgearbeitet. */
    public final ConcurrentLinkedQueue<JsonObject> effects = new ConcurrentLinkedQueue<>();

    // ----- Zustand der Lobby (vom Server) -----
    public volatile String status = "connecting";  // connecting | lobby | running | ended | error
    public volatile String error = "";
    public volatile String linkName = "";
    public volatile boolean host = false;
    public volatile boolean meReady = false;
    public volatile boolean shareDamage = false, shareHeal = false, deathLink = false, shareHunger = false, shareHearts = false;
    /** Ziel (optional): type = "" | item | advancements | kills; target = Item-ID bzw. Monster-ID (leer = alle). */
    public volatile String goalType = "", goalTarget = "", goalLabel = "";
    public volatile int goalCount = 0;
    public volatile String winner = "";
    public volatile List<Member> members = List.of();
    public volatile int version = 0;  // ändert sich bei jedem neuen Zustand -> Lobby baut Knöpfe neu

    public record Member(String name, String pack, boolean ready, boolean online, float hp, float max, int food, boolean dead, boolean host, int progress) {}

    public LinkClient(LinkConfig cfg) {
        this.cfg = cfg;
        if (!cfg.usable()) {
            status = "error";
            error = "Keine hviklink.json - Mod bitte über hvik.org einrichten.";
        }
    }

    public boolean configured() {
        return cfg.usable();
    }

    public String myName() {
        return cfg.name;
    }

    public synchronized void start() {
        if (!cfg.usable() || running) return;
        running = true;
        status = "connecting";
        pollThread = new Thread(this::pollLoop, "HviK-Link");
        pollThread.setDaemon(true);
        pollThread.start();
    }

    public synchronized void stop() {
        running = false;
        if (pollThread != null) pollThread.interrupt();
        pollThread = null;
        effects.clear();
    }

    public boolean active() {
        return running;
    }

    // ----- Senden -----

    public void send(JsonObject event) {
        if (!running) return;
        JsonObject body = new JsonObject();
        body.addProperty("token", cfg.token);
        JsonArray arr = new JsonArray();
        arr.add(event);
        body.add("events", arr);
        HttpRequest req = HttpRequest.newBuilder(URI.create(cfg.server + "/api/mclink/send"))
                .timeout(Duration.ofSeconds(15))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                .build();
        http.sendAsync(req, HttpResponse.BodyHandlers.ofString()).thenAccept(r -> {
            if (r.statusCode() == 200) handleResponse(r.body());
        }).exceptionally(e -> {
            HvikLink.LOG.warn("HviK Link: Senden fehlgeschlagen: {}", e.toString());
            return null;
        });
    }

    public static JsonObject ev(String type) {
        JsonObject o = new JsonObject();
        o.addProperty("t", type);
        return o;
    }

    // ----- Empfangen -----

    private void pollLoop() {
        int fails = 0;
        while (running) {
            try {
                JsonObject body = new JsonObject();
                body.addProperty("token", cfg.token);
                body.addProperty("since", seq);
                HttpRequest req = HttpRequest.newBuilder(URI.create(cfg.server + "/api/mclink/poll"))
                        .timeout(Duration.ofSeconds(40))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(body.toString()))
                        .build();
                HttpResponse<String> r = http.send(req, HttpResponse.BodyHandlers.ofString());
                if (r.statusCode() == 200) {
                    handleResponse(r.body());
                    fails = 0;
                } else if (r.statusCode() == 403 || r.statusCode() == 404) {
                    status = "error";
                    error = "Link nicht gefunden - auf hvik.org neu herunterladen.";
                    version++;
                    sleep(15000);
                } else {
                    throw new RuntimeException("HTTP " + r.statusCode());
                }
            } catch (InterruptedException e) {
                return;
            } catch (Exception e) {
                fails++;
                if (!"running".equals(status)) {
                    status = "connecting";
                    error = "Keine Verbindung zu hvik.org (" + fails + ") ...";
                    version++;
                }
                HvikLink.LOG.warn("HviK Link: Poll fehlgeschlagen: {}", e.toString());
                sleep(Math.min(10000, 1000L * fails));
            }
        }
    }

    private static void sleep(long ms) {
        try {
            Thread.sleep(ms);
        } catch (InterruptedException ignored) {
            Thread.currentThread().interrupt();
        }
    }

    private synchronized void handleResponse(String text) {
        JsonObject o = JsonParser.parseString(text).getAsJsonObject();
        if (o.has("state")) applyState(o.getAsJsonObject("state"));
        if (o.has("events")) {
            for (JsonElement e : o.getAsJsonArray("events")) {
                JsonObject ev = e.getAsJsonObject();
                long s = ev.has("seq") ? ev.get("seq").getAsLong() : 0;
                if (s > seq) {
                    seq = s;
                    effects.add(ev);
                }
            }
        }
        if (o.has("seq")) seq = Math.max(seq, o.get("seq").getAsLong());
    }

    private void applyState(JsonObject s) {
        status = s.get("status").getAsString();
        linkName = s.has("name") ? s.get("name").getAsString() : "";
        host = s.has("host") && s.get("host").getAsBoolean();
        JsonObject set = s.getAsJsonObject("settings");
        shareDamage = set.get("share_damage").getAsBoolean();
        shareHeal = set.get("share_heal").getAsBoolean();
        deathLink = set.get("death_link").getAsBoolean();
        shareHunger = set.get("share_hunger").getAsBoolean();
        shareHearts = set.has("share_hearts") && set.get("share_hearts").getAsBoolean();
        JsonObject goal = set.has("goal") && set.get("goal").isJsonObject() ? set.getAsJsonObject("goal") : null;
        goalType = goal != null && goal.has("type") ? goal.get("type").getAsString() : "";
        goalTarget = goal != null && goal.has("target") ? goal.get("target").getAsString() : "";
        goalCount = goal != null && goal.has("count") ? goal.get("count").getAsInt() : 0;
        goalLabel = s.has("goal_label") && !s.get("goal_label").isJsonNull() ? s.get("goal_label").getAsString() : "";
        winner = s.has("winner") && !s.get("winner").isJsonNull() ? s.get("winner").getAsString() : "";
        List<Member> list = new ArrayList<>();
        for (JsonElement e : s.getAsJsonArray("members")) {
            JsonObject m = e.getAsJsonObject();
            Member mem = new Member(m.get("name").getAsString(), m.has("pack") && !m.get("pack").isJsonNull() ? m.get("pack").getAsString() : "",
                    m.get("ready").getAsBoolean(), m.get("online").getAsBoolean(),
                    m.has("hp") && !m.get("hp").isJsonNull() ? m.get("hp").getAsFloat() : -1,
                    m.has("max") && !m.get("max").isJsonNull() ? m.get("max").getAsFloat() : 20,
                    m.has("food") && !m.get("food").isJsonNull() ? m.get("food").getAsInt() : -1,
                    m.get("dead").getAsBoolean(), m.get("host").getAsBoolean(),
                    m.has("progress") && !m.get("progress").isJsonNull() ? m.get("progress").getAsInt() : 0);
            list.add(mem);
            if (mem.name().equals(cfg.name)) meReady = mem.ready();
        }
        members = List.copyOf(list);
        error = "";
        version++;
    }
}
