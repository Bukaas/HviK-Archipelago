package org.hvik.link;

import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;

/**
 * Season vorbei (Ziel erreicht, alle tot oder vom Host beendet). Der Host entscheidet für alle:
 * Neustarten (neue Welt), ohne Link weiterspielen oder Welt verlassen. Mitspieler können vorher selbst gehen.
 */
public class EndScreen extends Screen {
    private int seenVersion = -1;

    public EndScreen() {
        super(Component.literal("Season vorbei"));
    }

    @Override
    protected void init() {
        LinkClient c = HvikLink.CLIENT;
        seenVersion = c.version;
        int cx = width / 2, y = height / 2 + 30;
        if (c.host) {
            addRenderableWidget(Button.builder(Component.literal("🔄 Neustarten"), b -> choose("restart")).bounds(cx - 154, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("▶ Ohne Link spielen"), b -> choose("continue")).bounds(cx - 50, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("🚪 Welt verlassen"), b -> choose("leave")).bounds(cx + 54, y, 100, 20).build());
        } else {
            addRenderableWidget(Button.builder(Component.literal("Ohne Link weiterspielen"), b -> ClientEvents.detach()).bounds(cx - 102, y, 100, 20).build());
            addRenderableWidget(Button.builder(Component.literal("🚪 Welt verlassen"), b -> ClientEvents.leaveWorld(false)).bounds(cx + 2, y, 100, 20).build());
        }
    }

    /** Host: Wahl an alle schicken und selbst sofort ausführen. */
    private void choose(String choice) {
        LinkClient c = HvikLink.CLIENT;
        com.google.gson.JsonObject o = LinkClient.ev("after");
        o.addProperty("choice", choice);
        c.send(o);
        ClientEvents.runChoice(choice);
    }

    @Override
    public void tick() {
        LinkClient c = HvikLink.CLIENT;
        if (!"ended".equals(c.status)) {  // z. B. Neustart über die Website
            onClose();
            return;
        }
        if (c.version != seenVersion) rebuildWidgets();  // Host gewechselt o. Ä.
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        LinkClient c = HvikLink.CLIENT;
        int cx = width / 2;
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
        if (!c.host) g.drawCenteredString(font, "Warte auf den Host: Neustarten, ohne Link weiterspielen oder Welt verlassen …", cx, height / 2 + 14, 0xAAAAAA);
        else g.drawCenteredString(font, "Du bist Host – deine Wahl gilt für alle, die noch in ihrer Welt sind.", cx, height / 2 + 14, 0xAAAAAA);
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
}
