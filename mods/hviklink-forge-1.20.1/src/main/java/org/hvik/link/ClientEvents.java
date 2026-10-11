package org.hvik.link;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.Font;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.toasts.SystemToast;
import net.minecraft.network.chat.Component;
import net.minecraft.client.gui.screens.GenericDirtMessageScreen;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.gui.screens.TitleScreen;
import net.minecraft.client.gui.screens.worldselection.CreateWorldScreen;
import net.minecraft.client.gui.screens.worldselection.WorldCreationUiState;
import net.minecraftforge.client.event.RegisterGuiOverlaysEvent;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

/** Client: Lobby-Fenster erzwingen, solange nicht gestartet; Anzeige der Mitspieler am Rand. */
public class ClientEvents {
    private static boolean endShown = false;
    private Screen lastCreate = null;
    private boolean toastShown = false;

    @SubscribeEvent
    public void onClientTick(TickEvent.ClientTickEvent e) {
        if (e.phase != TickEvent.Phase.END) return;
        Minecraft mc = Minecraft.getInstance();
        LinkClient c = HvikLink.CLIENT;
        if (mc.screen instanceof CreateWorldScreen cws && c.configured()) {
            if (cws != lastCreate) {  // Bildschirm neu geöffnet -> aktuelle Lobby-Einstellung holen
                lastCreate = cws;
                c.infoLoaded = false;
                toastShown = false;
                c.fetchInfo();
            }
            if (c.infoLoaded && !toastShown) {  // einmal als normale Minecraft-Benachrichtigung oben rechts
                toastShown = true;
                SystemToast.addOrUpdate(mc.getToasts(), SystemToast.SystemToastIds.PERIODIC_NOTIFICATION,
                        Component.literal(c.hardcore ? "HviK Link: Hardcore-Lobby" : "HviK Link: Softcore-Lobby"),
                        Component.literal(c.hardcore ? "Spielmodus ist auf Hardcore festgelegt." : "Hardcore ist in dieser Lobby gesperrt."));
            }
            if (c.infoLoaded) {  // Hardcore-Lobby: nur Hardcore. Softcore-Lobby: Hardcore gesperrt.
                WorldCreationUiState ui = cws.getUiState();
                WorldCreationUiState.SelectedGameMode cur = ui.getGameMode();
                if (c.hardcore && cur != WorldCreationUiState.SelectedGameMode.HARDCORE) ui.setGameMode(WorldCreationUiState.SelectedGameMode.HARDCORE);
                if (!c.hardcore && cur == WorldCreationUiState.SelectedGameMode.HARDCORE) ui.setGameMode(WorldCreationUiState.SelectedGameMode.SURVIVAL);
            }
            return;
        }
        if (mc.level == null || mc.player == null || !c.configured() || !c.active()) return;
        if (c.afterChoice != null) {  // der Host hat entschieden
            String choice = c.afterChoice;
            c.afterChoice = null;
            runChoice(choice);
            return;
        }
        if (!"ended".equals(c.status)) {
            endShown = false;  // neuer Versuch -> End-Bildschirm wieder möglich
            if (!"running".equals(c.status)) c.detached = false;
        } else if (!endShown && !c.detached) {
            endShown = true;
            mc.setScreen(new EndScreen());
            return;
        }
        boolean blocking = !"running".equals(c.status) && !"ended".equals(c.status);
        if (blocking && !(mc.screen instanceof LobbyScreen)) mc.setScreen(new LobbyScreen());
    }

    /** Wahl des Hosts ausführen (beim Host direkt, bei den anderen über den Server). */
    static void runChoice(String choice) {
        switch (choice) {
            case "restart" -> leaveWorld(true);  // neue Welt erstellen - die Lobby erscheint darin
            case "leave" -> leaveWorld(false);
            default -> detach();
        }
    }

    /** Ohne Link weiterspielen: Bildschirm zu, keine Anzeige mehr. */
    static void detach() {
        HvikLink.CLIENT.detached = true;
        endShown = true;
        Minecraft.getInstance().setScreen(null);
    }

    /** Welt verlassen; bei Neustart direkt "Neue Welt erstellen" öffnen (Spielmodus legt die Mod dort fest). */
    static void leaveWorld(boolean newWorld) {
        Minecraft mc = Minecraft.getInstance();
        boolean local = mc.isLocalServer();
        if (mc.level != null) mc.level.disconnect();
        if (local) mc.clearLevel(new GenericDirtMessageScreen(Component.translatable("menu.savingLevel")));
        else mc.clearLevel();
        endShown = false;
        if (newWorld) CreateWorldScreen.openFresh(mc, new TitleScreen());
        else mc.setScreen(new TitleScreen());
    }

    public static void registerOverlay(RegisterGuiOverlaysEvent e) {
        e.registerAboveAll("hviklink", (gui, graphics, partialTick, width, height) -> renderHud(graphics, width, height));
    }

    /** Rangliste rechts am Rand (wie die Scoreboard-Seitenleiste): Ziel, Spieler mit Fortschritt und Herzen. */
    private static void renderHud(GuiGraphics g, int width, int height) {
        Minecraft mc = Minecraft.getInstance();
        LinkClient c = HvikLink.CLIENT;
        if (!c.active() || !"running".equals(c.status) || c.detached || mc.options.hideGui) return;
        Font f = mc.font;
        boolean goal = !c.goalType.isEmpty();
        List<LinkClient.Member> ms = new ArrayList<>(c.members);
        if (goal) ms.sort(Comparator.comparingInt(LinkClient.Member::progress).reversed());
        String title = c.hardcore ? "☠ HviK Link" : "HviK Link";
        String goalLine = goal ? "⚑ " + c.goalLabel : null;
        List<String[]> rows = new ArrayList<>();
        for (LinkClient.Member m : ms) {
            String hearts = m.hp() < 0 ? "?" : String.format("%.1f", m.hp() / 2f);
            String right = (goal ? m.progress() + "/" + c.goalCount + "  " : "") + "❤" + hearts;
            rows.add(new String[]{(m.dead() ? "☠ " : "") + m.name(), right});
        }
        int w = f.width(title);
        if (goalLine != null) w = Math.max(w, f.width(goalLine));
        for (String[] r : rows) w = Math.max(w, f.width(r[0]) + 10 + f.width(r[1]));
        int lh = 9, lines = rows.size() + (goal ? 1 : 0);
        int h = (lines + 1) * lh + 2;
        int x2 = width - 2, x1 = x2 - w - 4;
        int y = height / 2 - h / 3;
        g.fill(x1, y, x2, y + lh + 1, 0x66000000);  // Kopfzeile etwas dunkler
        g.fill(x1, y + lh + 1, x2, y + h, 0x4C000000);
        g.drawString(f, title, x1 + (x2 - x1 - f.width(title)) / 2, y + 1, c.hardcore ? 0xFF5555 : 0xFFAA00, false);
        int ly = y + lh + 2;
        if (goalLine != null) {
            g.drawString(f, goalLine, x1 + 2, ly, 0xFFFF55, false);
            ly += lh;
        }
        for (int i = 0; i < rows.size(); i++) {
            LinkClient.Member m = ms.get(i);
            int color = m.dead() ? 0x777777 : (m.online() ? 0xFFFFFF : 0xAAAAAA);
            g.drawString(f, rows.get(i)[0], x1 + 2, ly, color, false);
            g.drawString(f, rows.get(i)[1], x2 - 2 - f.width(rows.get(i)[1]), ly, m.dead() ? 0x777777 : 0xFF5555, false);
            ly += lh;
        }
    }
}
