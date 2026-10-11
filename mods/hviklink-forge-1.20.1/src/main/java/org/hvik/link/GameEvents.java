package org.hvik.link;

import com.google.gson.JsonObject;
import net.minecraft.network.chat.Component;
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

    @SubscribeEvent
    public void onLogin(PlayerEvent.PlayerLoggedInEvent e) {
        if (e.getEntity() instanceof ServerPlayer sp) {
            lastHp = sp.getHealth();
            lastFood = sp.getFoodData().getFoodLevel();
            HvikLink.CLIENT.start();
        }
    }

    @SubscribeEvent
    public void onStopping(ServerStoppingEvent e) {
        HvikLink.CLIENT.stop();
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
        if (!"running".equals(c.status) || !sp.isAlive()) {
            lastHp = sp.getHealth();
            lastFood = food.getFoodLevel();
            return;
        }
        float h = sp.getHealth();
        if (lastHp >= 0 && Math.abs(h - lastHp) > 0.001f) {
            float d = h - lastHp;
            if ((d < 0 && c.shareDamage) || (d > 0 && c.shareHeal)) {
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

    private static String reason(DamageSource s) {
        Entity a = s.getEntity();
        if (a != null) return a.getName().getString();
        Entity d = s.getDirectEntity();
        if (d != null) return d.getName().getString();
        return s.getMsgId();
    }
}
