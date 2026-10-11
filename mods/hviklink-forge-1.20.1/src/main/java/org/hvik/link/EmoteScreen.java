package org.hvik.link;

import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.network.chat.Component;

/** Emote-Auswahl (Taste N). Tipp: mit F5 sieht man sich selbst. */
public class EmoteScreen extends Screen {
    public EmoteScreen() {
        super(Component.literal("Emotes"));
    }

    @Override
    protected void init() {
        Emotes.Emote[] all = Emotes.Emote.values();
        int cols = 2, w = 150, h = 20, gap = 4;
        int rows = (all.length + cols - 1) / cols;
        int x0 = width / 2 - (cols * w + gap) / 2, y0 = height / 2 - (rows * (h + gap)) / 2 + 6;
        for (int i = 0; i < all.length; i++) {
            Emotes.Emote e = all[i];
            int x = x0 + (i % cols) * (w + gap), y = y0 + (i / cols) * (h + gap);
            Button b = Button.builder(Component.literal((e == Emotes.current ? "» " : "") + e.label), btn -> {
                Emotes.choose(e);
                onClose();
            }).bounds(x, y, w, h).build();
            addRenderableWidget(b);
        }
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        Emotes.Emote[] all = Emotes.Emote.values();
        int rows = (all.length + 1) / 2;
        int top = height / 2 - (rows * 24) / 2 - 14;
        g.drawCenteredString(font, "🎭 Emote wählen", width / 2, top - 10, 0xFFAA00);
        g.drawCenteredString(font, "F5 = dich selbst sehen · Sitzen: mit Schleichen (Shift) wieder aufstehen", width / 2, top + 2, 0xAAAAAA);
        super.render(g, mouseX, mouseY, partialTick);
    }

    @Override
    public boolean isPauseScreen() {
        return false;
    }
}
