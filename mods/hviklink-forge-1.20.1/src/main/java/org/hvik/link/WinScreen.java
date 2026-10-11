package org.hvik.link;

import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.components.Button;
import net.minecraft.client.gui.screens.GenericDirtMessageScreen;
import net.minecraft.client.gui.screens.Screen;
import net.minecraft.client.gui.screens.TitleScreen;
import net.minecraft.network.chat.Component;

/** Jemand hat das Ziel erreicht: bei allen erscheint dieser Bildschirm, der Link ist vorbei. */
public class WinScreen extends Screen {
    private final String winner;

    public WinScreen(String winner) {
        super(Component.literal("Gewonnen"));
        this.winner = winner;
    }

    @Override
    protected void init() {
        int cx = width / 2;
        addRenderableWidget(Button.builder(Component.literal("Weiterspielen (ohne Link)"), b -> onClose()).bounds(cx - 100, height / 2 + 30, 200, 20).build());
        addRenderableWidget(Button.builder(Component.literal("Welt verlassen"), b -> leave()).bounds(cx - 100, height / 2 + 56, 200, 20).build());
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        renderBackground(g);
        int cx = width / 2;
        boolean me = winner.equals(HvikLink.CLIENT.myName());
        g.pose().pushPose();
        g.pose().scale(2f, 2f, 1f);
        g.drawCenteredString(font, me ? "⚑ Du hast gewonnen!" : "⚑ " + winner + " hat gewonnen!", cx / 2, (height / 2 - 40) / 2, 0xFFD700);
        g.pose().popPose();
        String goal = HvikLink.CLIENT.goalLabel;
        g.drawCenteredString(font, goal.isEmpty() ? "Das Ziel ist erreicht – der Link ist vorbei." : "Ziel erreicht: " + goal + " – der Link ist vorbei.",
                cx, height / 2 - 6, 0xFFFFFF);
        super.render(g, mouseX, mouseY, partialTick);
    }

    @Override
    public boolean isPauseScreen() {
        return true;
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
