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
    public static final net.minecraft.client.KeyMapping BACKPACK = new net.minecraft.client.KeyMapping(
            "key.hviklink.backpack", org.lwjgl.glfw.GLFW.GLFW_KEY_B, "key.categories.hviklink");
    private int lastCountdown = 0;
    public static final net.minecraft.client.KeyMapping EMOTES = new net.minecraft.client.KeyMapping(
            "key.hviklink.emotes", org.lwjgl.glfw.GLFW.GLFW_KEY_N, "key.categories.hviklink");
    private long lastTick = -1;
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
        if (mc.level != null && mc.player != null) {
            Emotes.clientTick(mc);
            while (EMOTES.consumeClick()) if (mc.screen == null) mc.setScreen(new EmoteScreen());
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
        while (BACKPACK.consumeClick()) {  // Rucksack: im Einzelspieler direkt auf dem eingebauten Server öffnen
            var srv = mc.getSingleplayerServer();
            java.util.UUID id = mc.player.getUUID();
            if (!Backpack.enabled()) mc.player.displayClientMessage(Component.literal("🎒 Der Rucksack ist in dieser Runde nicht an."), true);
            else if (srv != null) srv.execute(() -> {
                net.minecraft.server.level.ServerPlayer sp = srv.getPlayerList().getPlayer(id);
                if (sp != null) Backpack.open(sp);
            });
        }
        int cd = c.countdown();  // Countdown vorbei -> großer Titel mit dem Ziel ("Wer hat am meisten von ...")
        if (lastCountdown > 0 && cd == 0 && "running".equals(c.status) && !c.goalType.isEmpty()) {
            boolean most = "most".equals(c.goalType);
            mc.gui.setTimes(10, 70, 20);
            mc.gui.setTitle(Component.literal(most ? "Wer hat am meisten von" : "Ziel"));
            mc.gui.setSubtitle(Component.literal("§e" + (most && !c.goalItemName.isEmpty() ? c.goalItemName : c.goalLabel)));
        }
        lastCountdown = cd;
        long rem = c.remaining();  // letzte 10 Sekunden: Tick-Ton
        if ("running".equals(c.status) && rem >= 0 && rem <= 10 && rem != lastTick && c.countdown() == 0 && !c.detached) {
            lastTick = rem;
            if (rem > 0) mc.getSoundManager().play(net.minecraft.client.resources.sounds.SimpleSoundInstance.forUI(
                    net.minecraft.sounds.SoundEvents.NOTE_BLOCK_HAT.value(), rem <= 3 ? 1.6f : 1.2f));
        }
        boolean blocking = (!"running".equals(c.status) && !"ended".equals(c.status)) || c.countdown() > 0;
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

    public static void registerKeys(net.minecraftforge.client.event.RegisterKeyMappingsEvent e) {
        e.register(BACKPACK);
        e.register(EMOTES);
    }

    /** Spielermodell durch das Emote-Modell ersetzen (gleiches Modell + Pose obendrauf). */
    @SuppressWarnings({"unchecked", "rawtypes"})
    public static void addLayers(net.minecraftforge.client.event.EntityRenderersEvent.AddLayers e) {
        for (String skin : e.getSkins()) {
            try {
                net.minecraft.client.renderer.entity.LivingEntityRenderer r = e.getSkin(skin);
                if (r == null) continue;
                boolean slim = "slim".equals(skin);
                EmoteModel m = new EmoteModel(e.getContext().bakeLayer(slim ? net.minecraft.client.model.geom.ModelLayers.PLAYER_SLIM
                        : net.minecraft.client.model.geom.ModelLayers.PLAYER), slim);
                net.minecraftforge.fml.util.ObfuscationReflectionHelper.setPrivateValue(
                        net.minecraft.client.renderer.entity.LivingEntityRenderer.class, r, m, "f_115290_");
            } catch (Exception ex) {
                HvikLink.LOG.warn("HviK Link: Emote-Modell nicht gesetzt ({}): {}", skin, ex.toString());
            }
        }
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
        long rem = c.remaining();
        long t = rem >= 0 ? rem : c.elapsed();
        String clock = t >= 3600 ? String.format("%d:%02d:%02d", t / 3600, t / 60 % 60, t % 60) : String.format("%d:%02d", t / 60, t % 60);
        String title = (c.hardcore ? "☠ HviK Link" : "HviK Link") + (rem >= 0 ? "  ⏳ " : "  ⏱ ") + clock;
        boolean urgent = rem >= 0 && rem <= 60;
        boolean most = "most".equals(c.goalType);
        net.minecraft.world.item.ItemStack icon = net.minecraft.world.item.ItemStack.EMPTY;
        if (goal && ("item".equals(c.goalType) || most) && !c.goalTarget.isEmpty()) {
            net.minecraft.resources.ResourceLocation rl = net.minecraft.resources.ResourceLocation.tryParse(c.goalTarget);
            net.minecraft.world.item.Item it = rl == null ? null : net.minecraftforge.registries.ForgeRegistries.ITEMS.getValue(rl);
            if (it != null) icon = new net.minecraft.world.item.ItemStack(it);
        }
        int mine = c.members.stream().filter(m -> m.name().equals(c.myName())).mapToInt(LinkClient.Member::progress).findFirst().orElse(0);
        String goalLine = goal ? (most ? (c.goalItemName.isEmpty() ? c.goalLabel : "Meiste " + c.goalItemName) + "  – du: " + Math.max(0, mine) + "×"
                : "⚑ " + c.goalLabel) : null;
        List<String[]> rows = new ArrayList<>();
        for (LinkClient.Member m : ms) {
            String hearts = m.hp() < 0 ? "?" : String.format("%.1f", m.hp() / 2f);
            String prog = m.progress() < 0 ? "?" : String.valueOf(m.progress());
            String right = (goal ? ("most".equals(c.goalType) ? prog + "×" : prog + "/" + c.goalCount) + "  " : "") + "❤" + hearts;
            rows.add(new String[]{(m.dead() ? "☠ " : "") + m.name(), right});
        }
        int w = f.width(title);
        int iconW = icon.isEmpty() ? 0 : 18;
        if (goalLine != null) w = Math.max(w, f.width(goalLine) + iconW);
        for (String[] r : rows) w = Math.max(w, f.width(r[0]) + 10 + f.width(r[1]));
        int lh = 9, lines = rows.size() + (goal ? (iconW > 0 ? 2 : 1) : 0);
        int h = (lines + 1) * lh + 2;
        int x2 = width - 2, x1 = x2 - w - 4;
        int y = height / 2 - h / 3;
        g.fill(x1, y, x2, y + lh + 1, 0x66000000);  // Kopfzeile etwas dunkler
        g.fill(x1, y + lh + 1, x2, y + h, 0x4C000000);
        g.drawString(f, title, x1 + (x2 - x1 - f.width(title)) / 2, y + 1, urgent ? 0xFF5555 : (c.hardcore ? 0xFF5555 : 0xFFAA00), false);
        int ly = y + lh + 2;
        if (goalLine != null) {
            if (iconW > 0) {  // Item-Bild, damit man nicht vergisst, worum es geht
                g.renderItem(icon, x1 + 1, ly);
                g.drawString(f, goalLine, x1 + 1 + iconW, ly + 4, 0xFFFF55, false);
                ly += lh * 2;
            } else {
                g.drawString(f, goalLine, x1 + 2, ly, 0xFFFF55, false);
                ly += lh;
            }
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
