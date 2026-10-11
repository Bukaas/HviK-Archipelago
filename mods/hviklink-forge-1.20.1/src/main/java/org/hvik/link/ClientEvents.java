package org.hvik.link;

import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraftforge.client.event.RegisterGuiOverlaysEvent;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

/** Client: Lobby-Fenster erzwingen, solange nicht gestartet; Anzeige der Mitspieler am Rand. */
public class ClientEvents {
    private String shownWinner = "";

    @SubscribeEvent
    public void onClientTick(TickEvent.ClientTickEvent e) {
        if (e.phase != TickEvent.Phase.END) return;
        Minecraft mc = Minecraft.getInstance();
        LinkClient c = HvikLink.CLIENT;
        if (mc.level == null || mc.player == null || !c.configured() || !c.active()) return;
        if (!"ended".equals(c.status)) shownWinner = "";  // neuer Versuch -> Gewinner-Bildschirm wieder möglich
        else if (!c.winner.isEmpty() && !shownWinner.equals(c.winner)) {
            if (!(mc.screen instanceof WinScreen)) mc.setScreen(new WinScreen(c.winner));
            shownWinner = c.winner;
            return;
        }
        boolean blocking = !"running".equals(c.status) && !"ended".equals(c.status);
        if (blocking && !(mc.screen instanceof LobbyScreen)) mc.setScreen(new LobbyScreen());
    }

    public static void registerOverlay(RegisterGuiOverlaysEvent e) {
        e.registerAboveAll("hviklink", (gui, graphics, partialTick, width, height) -> renderHud(graphics));
    }

    private static void renderHud(GuiGraphics g) {
        Minecraft mc = Minecraft.getInstance();
        LinkClient c = HvikLink.CLIENT;
        if (!c.active() || !"running".equals(c.status) || mc.options.hideGui) return;
        int y = 4;
        g.drawString(mc.font, "HviK Link", 4, y, 0xFFAA00, true);
        y += 11;
        if (!c.goalType.isEmpty()) {
            g.drawString(mc.font, "⚑ Ziel: " + c.goalLabel, 4, y, 0xFFFF55, true);
            y += 11;
        }
        for (LinkClient.Member m : c.members) {
            String hearts = m.hp() < 0 ? "?" : String.format("%.1f", m.hp() / 2f);
            String line = (m.dead() ? "☠ " : "") + m.name() + "  ❤ " + hearts + "/" + Math.round(m.max() / 2f)
                    + (c.goalType.isEmpty() ? "" : "  ⚑ " + m.progress() + "/" + c.goalCount);
            int color = m.dead() ? 0x888888 : (m.online() ? 0xFFFFFF : 0xAAAAAA);
            g.drawString(mc.font, line, 4, y, color, true);
            y += 10;
        }
    }
}
