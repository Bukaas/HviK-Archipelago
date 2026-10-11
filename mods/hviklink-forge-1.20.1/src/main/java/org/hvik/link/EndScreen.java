package org.hvik.link;

import com.mojang.authlib.GameProfile;
import com.mojang.authlib.minecraft.MinecraftProfileTexture;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.components.PlayerFaceRenderer;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.resources.sounds.SimpleSoundInstance;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.sounds.SoundEvents;

/**
 * Season vorbei (Ziel erreicht, Zeit um, alle tot oder vom Host beendet). Bei "Wer hat am meisten?" erst das Podium
 * mit Aufdecken (Platz 3, 2, 1). Der Host entscheidet für alle: Neustarten, ohne Link weiterspielen oder Welt verlassen.
 */
public class EndScreen extends Screen {
    private static final Map<UUID, ResourceLocation> SKINS = new ConcurrentHashMap<>();
    private int seenVersion = -1;
    private final long openedAt = System.currentTimeMillis();
    private int revealed = 0;  // wie viele Podiumsplätze schon aufgedeckt sind

    public EndScreen() {
        super(Component.literal("Season vorbei"));
    }

    private boolean podiumMode() {
        LinkClient c = HvikLink.CLIENT;
        return "most".equals(c.goalType) && !c.podium.isEmpty();
    }

    @Override
    protected void init() {
        LinkClient c = HvikLink.CLIENT;
        seenVersion = c.version;
        int cx = width / 2, y = podiumMode() ? height - 34 : height / 2 + 30;
        if (c.host) {
            addRenderableWidget(Button.builder(Component.literal("🔄 Neustarten"), b -> choose("restart")).bounds(cx - 154, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("▶ Ohne Link spielen"), b -> choose("continue")).bounds(cx - 50, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("🚪 Welt verlassen"), b -> choose("leave")).bounds(cx + 54, y, 100, 20).build());
        } else {
            addRenderableWidget(Button.builder(Component.literal("Ohne Link weiterspielen"), b -> ClientEvents.detach()).bounds(cx - 102, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("🚪 Welt verlassen"), b -> ClientEvents.leaveWorld(false)).bounds(cx + 2, y, 100, 20).build());
        }
        for (LinkClient.Podium p : c.podium) skin(p);  // Skins schon mal laden
    }

    /** Host: Wahl an alle schicken und selbst sofort ausführen. */
    private void choose(String choice) {
        com.google.gson.JsonObject o = LinkClient.ev("after");
        o.addProperty("choice", choice);
        HvikLink.CLIENT.send(o);
        ClientEvents.runChoice(choice);
    }

    /** Skin eines Mitspielers (lädt im Hintergrund, bis dahin der Standard-Skin). */
    private static ResourceLocation skin(LinkClient.Podium p) {
        if (p.uuid() == null) return net.minecraft.client.resources.DefaultPlayerSkin.getDefaultSkin();
        return SKINS.computeIfAbsent(p.uuid(), id -> {
            Minecraft.getInstance().getSkinManager().registerSkins(new GameProfile(id, p.mcName()), (type, loc, tex) -> {
                if (type == MinecraftProfileTexture.Type.SKIN) SKINS.put(id, loc);
            }, false);
            return net.minecraft.client.resources.DefaultPlayerSkin.getDefaultSkin(id);
        });
    }

    @Override
    public void tick() {
        LinkClient c = HvikLink.CLIENT;
        if (!"ended".equals(c.status)) {  // z. B. Neustart über die Website
            onClose();
            return;
        }
        if (c.version != seenVersion) rebuildWidgets();
        if (podiumMode()) {  // Aufdecken: 3. Platz, dann 2., dann 1. - mit Ton
            int places = Math.min(3, c.podium.size());
            long ms = System.currentTimeMillis() - openedAt;
            int should = (int) Math.min(places, ms / 1400);
            while (revealed < should) {
                revealed++;
                boolean winner = revealed == places;
                minecraft.getSoundManager().play(SimpleSoundInstance.forUI(
                        winner ? SoundEvents.UI_TOAST_CHALLENGE_COMPLETE : SoundEvents.NOTE_BLOCK_PLING.value(), winner ? 1f : 0.8f + revealed * 0.2f));
            }
        }
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        LinkClient c = HvikLink.CLIENT;
        int cx = width / 2;
        if (podiumMode()) {
            renderPodium(g, c, cx);
        } else {
            boolean won = !c.winner.isEmpty(), me = won && c.winner.equals(c.myName());
            String title = won ? (me ? "⚑ Du hast gewonnen!" : "⚑ " + c.winner + " hat gewonnen!") : "☠ Season vorbei";
            g.pose().pushPose();
            g.pose().scale(2f, 2f, 1f);
            g.drawCenteredString(font, title, cx / 2, (height / 2 - 70) / 2, won ? 0xFFD700 : 0xFF5555);
            g.pose().popPose();
            int y = height / 2 - 34;
            for (String line : c.endLines) {
                g.drawCenteredString(font, line, cx, y, 0xFFFFFF);
                y += 11;
            }
        }
        int hintY = podiumMode() ? height - 48 : height / 2 + 14;
        if (!c.host) g.drawCenteredString(font, "Warte auf den Host: Neustarten, ohne Link weiterspielen oder Welt verlassen …", cx, hintY, 0xAAAAAA);
        else g.drawCenteredString(font, "Du bist Host – deine Wahl gilt für alle, die noch in ihrer Welt sind.", cx, hintY, 0xAAAAAA);
        super.render(g, mouseX, mouseY, partialTick);
    }

    /** Podium: Mitte 1., links 2., rechts 3. - wird nacheinander aufgedeckt. Darunter der Rest. */
    private void renderPodium(GuiGraphics g, LinkClient c, int cx) {
        List<LinkClient.Podium> p = c.podium;
        int places = Math.min(3, p.size());
        g.pose().pushPose();
        g.pose().scale(2f, 2f, 1f);
        g.drawCenteredString(font, "🥇 Wer hat am meisten?", cx / 2, 10, 0xFFD700);
        g.pose().popPose();
        g.drawCenteredString(font, c.goalLabel, cx, 42, 0xFFFF55);
        int base = height / 2 + 40;
        int[] xs = {cx, cx - 80, cx + 80};
        int[] hs = {56, 40, 28};
        int[] colors = {0xFFD700, 0xC0C0C0, 0xCD7F32};
        for (int i = 0; i < places; i++) {
            int x = xs[i], h = hs[i];
            g.fill(x - 34, base - h, x + 34, base, 0xAA000000 | (colors[i] & 0x00FFFFFF) >> 1);
            g.fill(x - 34, base - h, x + 34, base - h + 2, 0xFF000000 | colors[i]);
            g.drawCenteredString(font, String.valueOf(i + 1), x, base - h / 2 - 4, 0xFFFFFF);
            boolean shown = revealed >= places - i;  // 3. zuerst, 1. zuletzt
            LinkClient.Podium e = p.get(i);
            if (shown) {
                PlayerFaceRenderer.draw(g, skin(e), x - 16, base - h - 40, 32);
                g.drawCenteredString(font, e.name(), x, base - h - 52, colors[i]);
                g.drawCenteredString(font, e.value() + "×", x, base + 4, 0xFFFFFF);
            } else {
                g.drawCenteredString(font, "?", x, base - h - 24, 0x777777);
            }
        }
        if (revealed >= places) {
            int y = base + 18;
            for (int i = 3; i < p.size() && y < height - 60; i++, y += 10) {
                g.drawCenteredString(font, (i + 1) + ". " + p.get(i).name() + " – " + p.get(i).value() + "×", cx, y, 0xAAAAAA);
            }
        }
    }

    @Override
    public boolean isPauseScreen() {
        return true;
    }

    @Override
    public boolean shouldCloseOnEsc() {
        return false;
    }
}
