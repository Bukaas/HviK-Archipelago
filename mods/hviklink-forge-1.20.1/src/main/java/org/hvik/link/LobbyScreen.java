package org.hvik.link;

import com.google.gson.JsonObject;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.GenericDirtMessageScreen;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.gui.screens.TitleScreen;
import net.minecraft.client.resources.sounds.SimpleSoundInstance;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.network.chat.Component;

/**
 * Lobby im Spiel: pausiert die Welt (wie das Esc-Menü), bis alle bereit sind und der Host startet.
 * Lässt sich nicht wegklicken - nur „Welt verlassen“.
 */
public class LobbyScreen extends Screen {
    private int seenVersion = -1;
    private int lastCount = -1;

    public LobbyScreen() {
        super(Component.literal("HviK Link"));
    }

    @Override
    protected void init() {
        LinkClient c = HvikLink.CLIENT;
        seenVersion = c.version;
        int cx = width / 2;
        int y = height - 58;
        if (c.countdown() > 0) return;  // Countdown läuft: keine Knöpfe mehr
        if ("lobby".equals(c.status)) {
            Button ready = Button.builder(Component.literal(c.meReady ? "Doch nicht bereit" : "Bereit ✔"), b -> {
                JsonObject o = LinkClient.ev("ready");
                o.addProperty("ready", !c.meReady);
                if (c.worldHardcore != null) o.addProperty("hardcore", c.worldHardcore);
                c.send(o);
            }).bounds(c.host ? cx - 102 : cx - 100, y, c.host ? 100 : 200, 20).build();
            ready.active = !wrongWorld(c);
            addRenderableWidget(ready);
            if (c.host) {
                Button start = Button.builder(Component.literal("Start ▶"), b -> c.send(LinkClient.ev("start")))
                        .bounds(cx + 2, y, 100, 20).build();
                start.active = allReady(c);
                addRenderableWidget(start);
                String[][] opts = {{"share_hearts", "Herzen"}, {"share_heal", "Heilung"}, {"share_hunger", "Hunger"}, {"death_link", "Death Link"}};
                boolean[] vals = {c.shareHearts, c.shareHeal, c.shareHunger, c.deathLink};
                for (int i = 0; i < opts.length; i++) {
                    String key = opts[i][0];
                    boolean val = vals[i];
                    addRenderableWidget(Button.builder(Component.literal(opts[i][1] + ": " + (val ? "AN" : "AUS")), b -> {
                        JsonObject o = LinkClient.ev("settings");
                        o.addProperty(key, !val);
                        c.send(o);
                    }).bounds(cx - 204 + i * 102, y - 26, 100, 20).build());
                }
            }
        }
        addRenderableWidget(Button.builder(Component.literal("Welt verlassen"), b -> leave()).bounds(cx - 100, height - 30, 200, 20).build());
    }

    /** Lobby Hardcore, Welt Softcore (oder umgekehrt) -> diese Welt geht nicht. */
    static boolean wrongWorld(LinkClient c) {
        return c.worldHardcore != null && c.worldHardcore != c.hardcore;
    }

    private static boolean allReady(LinkClient c) {
        if (c.members.isEmpty()) return false;
        for (LinkClient.Member m : c.members) {
            if (!m.ready() || !m.online() || m.dead()) return false;
        }
        return true;
    }

    @Override
    public void tick() {
        LinkClient c = HvikLink.CLIENT;
        int count = c.countdown();
        if (count != lastCount) {  // Ton pro Sekunde, beim Start ein "Los"
            if (lastCount > 0 && count == 0) minecraft.getSoundManager().play(SimpleSoundInstance.forUI(SoundEvents.PLAYER_LEVELUP, 1f));
            else if (count > 0) minecraft.getSoundManager().play(SimpleSoundInstance.forUI(SoundEvents.NOTE_BLOCK_HAT.value(), count <= 3 ? 1.6f : 1f));
            if ((lastCount == -1) != (count == -1) || (lastCount > 0) != (count > 0)) rebuildWidgets();
            lastCount = count;
        }
        if (("running".equals(c.status) && count == 0) || "ended".equals(c.status) || !c.active()) {
            minecraft.setScreen(null);
            return;
        }
        if (c.version != seenVersion) rebuildWidgets();
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        LinkClient c = HvikLink.CLIENT;
        int cx = width / 2;
        g.drawCenteredString(font, "HviK Link" + (c.linkName.isEmpty() ? "" : " – " + c.linkName) + (c.hardcore ? "  ☠ HARDCORE" : "  ❤ Softcore"),
                cx, 16, 0xFFAA00);
        String info;
        int infoColor = 0xCCCCCC;
        if ("lobby".equals(c.status) && wrongWorld(c)) {
            info = c.hardcore ? "Diese Lobby ist HARDCORE – das hier ist keine Hardcore-Welt. Bitte Welt verlassen und eine neue Hardcore-Welt erstellen."
                    : "Diese Lobby ist SOFTCORE – das hier ist eine Hardcore-Welt. Bitte Welt verlassen und eine neue normale Welt erstellen.";
            infoColor = 0xFF5555;
        } else if ("lobby".equals(c.status)) {
            info = c.host ? "Du bist Host: Einstellungen wählen und starten, wenn alle bereit sind."
                    : "Das Spiel ist pausiert, bis alle bereit sind und der Host startet.";
        } else if ("error".equals(c.status)) {
            info = c.error;
            infoColor = 0xFF5555;
        } else {
            info = c.error.isEmpty() ? "Verbinde mit hvik.org ..." : c.error;
            infoColor = 0xFFFF55;
        }
        int count = c.countdown();
        if (count > 0) {  // großer Countdown in der Mitte
            g.pose().pushPose();
            g.pose().scale(6f, 6f, 1f);
            g.drawCenteredString(font, String.valueOf(count), cx / 6, (height / 2 - 30) / 6, count <= 3 ? 0xFF5555 : 0xFFFF55);
            g.pose().popPose();
            g.drawCenteredString(font, "Gleich geht's los – macht euch bereit!", cx, height / 2 + 30, 0xFFFFFF);
            super.render(g, mouseX, mouseY, partialTick);
            return;
        }
        g.drawCenteredString(font, info, cx, 30, infoColor);
        int y = 50;
        for (LinkClient.Member m : c.members) {
            String state = !m.online() ? "✖ nicht verbunden" : (m.ready() ? "✔ bereit" : "… wartet");
            String line = m.name() + (m.host() ? " (Host)" : "") + "  –  " + (m.pack().isEmpty() ? "?" : m.pack()) + "  –  " + state;
            int color = !m.online() ? 0x888888 : (m.ready() ? 0x55FF55 : 0xFFFFFF);
            g.drawCenteredString(font, line, cx, y, color);
            y += 12;
        }
        if ("lobby".equals(c.status)) {
            String set = "Geteilt: " + (c.shareHearts ? "Herzen " : "") + (c.shareHeal ? "Heilung " : "")
                    + (c.shareHunger ? "Hunger " : "")
                    + (c.deathLink ? "– Death Link an" : "– Death Link aus");
            g.drawCenteredString(font, set, cx, y + 8, 0xAAAAAA);
            if (!c.goalType.isEmpty()) g.drawCenteredString(font, "⚑ Ziel: " + c.goalLabel + " – wer es zuerst schafft, gewinnt!", cx, y + 20, 0xFFFF55);
        }
        super.render(g, mouseX, mouseY, partialTick);
    }

    @Override
    public boolean isPauseScreen() {
        return true;
    }

    @Override
    public boolean shouldCloseOnEsc() {
        return false;
    }

    private void leave() {
        boolean local = minecraft.isLocalServer();
        if (minecraft.level != null) minecraft.level.disconnect();
        if (local) {
            minecraft.clearLevel(new GenericDirtMessageScreen(Component.translatable("menu.savingLevel")));
        } else {
            minecraft.clearLevel();
        }
        minecraft.setScreen(new TitleScreen());
    }
}
