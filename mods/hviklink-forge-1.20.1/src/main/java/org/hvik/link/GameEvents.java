package org.hvik.link;

import com.google.gson.JsonObject;
import net.minecraft.advancements.Advancement;
import net.minecraft.network.chat.Component;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.stats.Stats;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.item.Item;
import net.minecraftforge.registries.ForgeRegistries;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.damagesource.DamageSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.food.FoodData;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.event.entity.living.LivingDeathEvent;
import net.minecraftforge.event.entity.living.LivingHurtEvent;
import net.minecraftforge.event.entity.player.PlayerEvent;
import net.minecraftforge.event.server.ServerStoppingEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;

/**
 * Spielseite (integrierter Server im Einzelspieler): eigene Herz-/Hunger-Änderungen melden,
 * Änderungen der anderen anwenden, Tod weitergeben (Death Link).
 */
public class GameEvents {
    private float lastHp = -1;
    private int lastFood = -1;
    private boolean linkKill = false;
    private String lastReason = "";
    private int statusTimer = 0;
    private boolean wasRunning = false;
    private int baseAdv = 0, baseKills = 0, lastProgress = -1;
    private boolean goalSent = false;
    private int advTimer = 0;

    @SubscribeEvent
    public void onLogin(PlayerEvent.PlayerLoggedInEvent e) {
        if (e.getEntity() instanceof ServerPlayer sp) {
            lastHp = sp.getHealth();
            lastFood = sp.getFoodData().getFoodLevel();
            LinkClient c = HvikLink.CLIENT;
            c.worldHardcore = sp.level().getLevelData().isHardcore();
            c.start();
            JsonObject w = LinkClient.ev("world");
            w.addProperty("hardcore", c.worldHardcore);
            c.send(w);
        }
    }

    @SubscribeEvent
    public void onStopping(ServerStoppingEvent e) {
        HvikLink.CLIENT.stop();
        HvikLink.CLIENT.worldHardcore = null;
    }

    @SubscribeEvent
    public void onHurt(LivingHurtEvent e) {
        if (e.getEntity() instanceof ServerPlayer) lastReason = reason(e.getSource());
    }

    @SubscribeEvent
    public void onDeath(LivingDeathEvent e) {
        if (!(e.getEntity() instanceof ServerPlayer)) return;
        if (linkKill) {  // durch den Link gestorben - nicht nochmal weitergeben
            linkKill = false;
            return;
        }
        LinkClient c = HvikLink.CLIENT;
        if (c.active() && "running".equals(c.status)) {
            JsonObject ev = LinkClient.ev("death");
            ev.addProperty("reason", reason(e.getSource()));
            c.send(ev);
        }
    }

    @SubscribeEvent
    public void onTick(TickEvent.PlayerTickEvent e) {
        if (e.phase != TickEvent.Phase.END || !(e.player instanceof ServerPlayer sp)) return;
        LinkClient c = HvikLink.CLIENT;
        if (!c.active()) return;
        JsonObject ev;
        while ((ev = c.effects.poll()) != null) apply(sp, ev);
        FoodData food = sp.getFoodData();
        if (!"running".equals(c.status)) wasRunning = false;
        if (!"running".equals(c.status) || !sp.isAlive()) {
            lastHp = sp.getHealth();
            lastFood = food.getFoodLevel();
            return;
        }
        if (!wasRunning) {  // gerade gestartet: Ausgangswerte für das Ziel merken (zählt ab Start)
            wasRunning = true;
            baseAdv = advancements(sp);
            baseKills = kills(sp, c.goalTarget);
            lastProgress = -1;
            goalSent = false;
        }
        if (statusTimer % 20 == 0 && !c.goalType.isEmpty() && !goalSent) checkGoal(sp, c);
        float h = sp.getHealth();
        if (lastHp >= 0 && Math.abs(h - lastHp) > 0.001f) {
            float d = h - lastHp;
            if ((d < 0 && c.shareDamage) || (d > 0 && c.shareHeal) || c.shareHearts) {
                JsonObject o = LinkClient.ev("hp");
                o.addProperty("delta", d);
                if (d < 0) o.addProperty("reason", lastReason);
                c.send(o);
            }
        }
        lastHp = h;
        int f = food.getFoodLevel();
        if (lastFood >= 0 && f != lastFood && c.shareHunger) {
            JsonObject o = LinkClient.ev("food");
            o.addProperty("delta", f - lastFood);
            c.send(o);
        }
        lastFood = f;
        if (++statusTimer >= 40) {  // alle 2 s Herzen/Hunger für Anzeige + Website
            statusTimer = 0;
            JsonObject o = LinkClient.ev("status");
            o.addProperty("hp", h);
            o.addProperty("max", sp.getMaxHealth());
            o.addProperty("food", f);
            // Statistik fürs HviK-Profil (Welt-Gesamtwerte - die Website zählt nur den Zuwachs)
            o.addProperty("play", stat(sp, Stats.PLAY_TIME) / 20);
            o.addProperty("kills", stat(sp, Stats.MOB_KILLS));
            o.addProperty("dist", (stat(sp, Stats.WALK_ONE_CM) + stat(sp, Stats.SPRINT_ONE_CM) + stat(sp, Stats.CROUCH_ONE_CM)
                    + stat(sp, Stats.SWIM_ONE_CM) + stat(sp, Stats.WALK_UNDER_WATER_ONE_CM) + stat(sp, Stats.WALK_ON_WATER_ONE_CM)) / 100);
            if (++advTimer >= 15) {  // alle 30 s - Achievements seit dem Start
                advTimer = 0;
                o.addProperty("adv", Math.max(0, advancements(sp) - baseAdv));
            }
            c.send(o);
        }
    }

    private void apply(ServerPlayer sp, JsonObject ev) {
        String t = ev.get("t").getAsString();
        switch (t) {
            case "chat" -> sp.sendSystemMessage(Component.literal(ev.get("text").getAsString()));
            case "hp" -> {
                if (!sp.isAlive()) return;
                float delta = ev.get("delta").getAsFloat();
                float nh = Math.min(sp.getMaxHealth(), sp.getHealth() + delta);
                if (nh <= 0) {
                    linkKill = true;
                    sp.kill();
                } else {
                    sp.setHealth(nh);
                    if (delta < 0) sp.level().playSound(null, sp.blockPosition(), SoundEvents.PLAYER_HURT, SoundSource.PLAYERS, 1f, 1f);
                }
                lastHp = sp.getHealth();
            }
            case "sethp" -> {  // Herzen teilen: gemeinsame Lebensleiste
                if (!sp.isAlive()) return;
                float v = ev.get("hp").getAsFloat();
                if (v <= 0) {
                    linkKill = true;
                    sp.kill();
                } else {
                    float nh = Math.min(sp.getMaxHealth(), v);
                    if (nh < sp.getHealth() - 0.01f) sp.level().playSound(null, sp.blockPosition(), SoundEvents.PLAYER_HURT, SoundSource.PLAYERS, 1f, 1f);
                    sp.setHealth(nh);
                }
                lastHp = sp.getHealth();
            }
            case "food" -> {
                FoodData fd = sp.getFoodData();
                fd.setFoodLevel(Math.max(0, Math.min(20, fd.getFoodLevel() + ev.get("delta").getAsInt())));
                lastFood = fd.getFoodLevel();
            }
            case "die" -> {
                if (sp.isAlive()) {
                    linkKill = true;
                    sp.kill();
                }
            }
            default -> { }
        }
    }

    private void checkGoal(ServerPlayer sp, LinkClient c) {
        int progress = switch (c.goalType) {
            case "item" -> {
                ResourceLocation rl = ResourceLocation.tryParse(c.goalTarget);
                Item item = rl == null ? null : ForgeRegistries.ITEMS.getValue(rl);
                yield item == null ? 0 : sp.getInventory().countItem(item);
            }
            case "advancements" -> Math.max(0, advancements(sp) - baseAdv);
            case "advancement" -> {  // ein bestimmtes Achievement
                ResourceLocation rl = ResourceLocation.tryParse(c.goalTarget);
                Advancement a = rl == null ? null : sp.server.getAdvancements().getAdvancement(rl);
                yield a != null && sp.getAdvancements().getOrStartProgress(a).isDone() ? 1 : 0;
            }
            case "kills" -> Math.max(0, kills(sp, c.goalTarget) - baseKills);
            default -> 0;
        };
        if (progress != lastProgress) {
            lastProgress = progress;
            JsonObject o = LinkClient.ev("progress");
            o.addProperty("value", progress);
            c.send(o);
        }
        if (c.goalCount > 0 && progress >= c.goalCount) {
            goalSent = true;
            c.send(LinkClient.ev("goal"));
        }
    }

    private static int stat(ServerPlayer sp, ResourceLocation key) {
        return sp.getStats().getValue(Stats.CUSTOM.get(key));
    }

    /** Erledigte Achievements (nur sichtbare - keine Rezepte). */
    private static int advancements(ServerPlayer sp) {
        int n = 0;
        for (Advancement a : sp.server.getAdvancements().getAllAdvancements()) {
            if (a.getDisplay() != null && sp.getAdvancements().getOrStartProgress(a).isDone()) n++;
        }
        return n;
    }

    /** Getötete Monster: alle oder nur eine Art (Entity-ID wie minecraft:zombie). */
    private static int kills(ServerPlayer sp, String target) {
        if (target == null || target.isEmpty()) return sp.getStats().getValue(Stats.CUSTOM.get(Stats.MOB_KILLS));
        ResourceLocation rl = ResourceLocation.tryParse(target);
        EntityType<?> type = rl == null ? null : ForgeRegistries.ENTITY_TYPES.getValue(rl);
        return type == null ? 0 : sp.getStats().getValue(Stats.ENTITY_KILLED.get(type));
    }

    private static String reason(DamageSource s) {
        Entity a = s.getEntity();
        if (a != null) return a.getName().getString();
        Entity d = s.getDirectEntity();
        if (d != null) return d.getName().getString();
        return s.getMsgId();
    }
}
