package org.hvik.link;

import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import net.minecraft.client.Minecraft;
import net.minecraft.client.model.PlayerModel;
import net.minecraft.client.player.AbstractClientPlayer;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.decoration.ArmorStand;

/**
 * Emotes (Taste N): Posen für Screenshots / Siegerfotos. Sitzen = echter Sitz (unsichtbarer Rüstungsständer),
 * die Arm-Posen setzt das eigene Spielermodell (EmoteModel). Jeder sieht nur sich selbst (Einzelspieler-Welten).
 */
public final class Emotes {
    public enum Emote {
        NONE("✖ Normal stehen", false), SIT("🪑 Sitzen", true), CROSS_LEGGED("🧘 Schneidersitz", true), CHEER("🙌 Jubeln", false),
        WAVE("👋 Winken", false), POINT("👉 Zeigen", false), ARMS_CROSSED("🙅 Arme verschränkt", false), VICTORY("🏆 Siegerpose", false),
        HANDS_HIPS("💪 Hände in die Hüften", false), SIT_WAVE("🪑👋 Sitzen + winken", true);

        public final String label;
        public final boolean seated;

        Emote(String label, boolean seated) {
            this.label = label;
            this.seated = seated;
        }
    }

    /** Aktuelle Pose des eigenen Spielers (nur Client). */
    public static volatile Emote current = Emote.NONE;
    private static int seatedTicks = 0;
    /** Sitze auf dem (eingebauten) Server - leere werden aufgeräumt. */
    static final Set<UUID> SEATS = ConcurrentHashMap.newKeySet();
    static final String SEAT_TAG = "hviklink_seat";

    private Emotes() {
    }

    /** Pose wählen (Client): Sitz anlegen bzw. aufstehen läuft auf dem eingebauten Server. */
    public static void choose(Emote e) {
        Minecraft mc = Minecraft.getInstance();
        Emote before = current;
        current = e;
        seatedTicks = 0;
        var srv = mc.getSingleplayerServer();
        if (srv == null || mc.player == null) return;
        UUID id = mc.player.getUUID();
        boolean sit = e.seated, wasSeated = before.seated;
        if (sit == wasSeated && mc.player.isPassenger() == sit) return;
        srv.execute(() -> {
            ServerPlayer sp = srv.getPlayerList().getPlayer(id);
            if (sp == null) return;
            if (sit) sitDown(sp);
            else standUp(sp);
        });
    }

    static void sitDown(ServerPlayer sp) {
        if (sp.isPassenger()) {
            if (sp.getVehicle() != null && sp.getVehicle().getTags().contains(SEAT_TAG)) return;  // sitzt schon
            sp.stopRiding();
        }
        ArmorStand seat = EntityType.ARMOR_STAND.create(sp.level());
        if (seat == null) return;
        CompoundTag t = new CompoundTag();
        t.putBoolean("Marker", true);
        t.putBoolean("Invisible", true);
        t.putBoolean("NoGravity", true);
        t.putBoolean("Invulnerable", true);
        t.putBoolean("Silent", true);
        seat.readAdditionalSaveData(t);
        seat.setInvisible(true);
        seat.setNoGravity(true);
        seat.setSilent(true);
        seat.setInvulnerable(true);
        seat.addTag(SEAT_TAG);
        // Spielerfüße liegen 0,35 unter dem Sitz -> Hüfte knapp über dem Boden
        seat.moveTo(sp.getX(), sp.getY() - 0.3, sp.getZ(), sp.getYRot(), 0f);
        sp.level().addFreshEntity(seat);
        SEATS.add(seat.getUUID());
        sp.startRiding(seat, true);
    }

    static void standUp(ServerPlayer sp) {
        Entity v = sp.getVehicle();
        if (v != null && v.getTags().contains(SEAT_TAG)) {
            sp.stopRiding();
            v.discard();
            SEATS.remove(v.getUUID());
        }
    }

    /** Server-Tick: leere Sitze entfernen (z. B. nach Schleichen/Aufstehen). */
    static void cleanSeats(net.minecraft.server.MinecraftServer srv) {
        if (SEATS.isEmpty()) return;
        for (var level : srv.getAllLevels()) {
            for (UUID id : Set.copyOf(SEATS)) {
                Entity e = level.getEntity(id);
                if (e != null && e.getPassengers().isEmpty()) {
                    e.discard();
                    SEATS.remove(id);
                }
            }
        }
    }

    /** Client-Tick: nach dem Aufstehen (Schleichen) wieder normal. */
    static void clientTick(Minecraft mc) {
        if (mc.player == null || !current.seated) return;
        if (mc.player.isPassenger()) seatedTicks = 0;
        else if (++seatedTicks > 15) current = Emote.NONE;
    }

    /** Pose auf das Modell legen (nach der normalen Animation). */
    static void apply(PlayerModel<?> m, AbstractClientPlayer p, float age) {
        Minecraft mc = Minecraft.getInstance();
        if (mc.player == null || !p.getUUID().equals(mc.player.getUUID())) return;
        Emote e = current;
        if (e == Emote.NONE) return;
        float wave = (float) Math.sin(age * 0.35f) * 0.45f;
        switch (e) {
            case SIT -> {
                m.rightArm.xRot = -0.35f;
                m.leftArm.xRot = -0.35f;
            }
            case CROSS_LEGGED -> {  // Beine nach vorne und gekreuzt, Hände auf den Knien
                m.rightLeg.xRot = -1.45f;
                m.leftLeg.xRot = -1.45f;
                m.rightLeg.yRot = 0.55f;
                m.leftLeg.yRot = -0.55f;
                m.rightArm.xRot = -0.75f;
                m.leftArm.xRot = -0.75f;
                m.rightArm.zRot = 0.15f;
                m.leftArm.zRot = -0.15f;
            }
            case SIT_WAVE -> {
                m.leftArm.xRot = -0.35f;
                m.rightArm.xRot = -2.7f;
                m.rightArm.zRot = 0.35f + wave;
            }
            case CHEER -> {
                m.rightArm.xRot = -2.95f;
                m.leftArm.xRot = -2.95f;
                m.rightArm.zRot = 0.35f;
                m.leftArm.zRot = -0.35f;
                m.rightArm.yRot = 0f;
                m.leftArm.yRot = 0f;
            }
            case WAVE -> {
                m.rightArm.xRot = -2.7f;
                m.rightArm.zRot = 0.35f + wave;
                m.rightArm.yRot = 0f;
            }
            case POINT -> {
                m.rightArm.xRot = -1.57f + m.head.xRot;
                m.rightArm.yRot = m.head.yRot;
                m.rightArm.zRot = 0f;
            }
            case ARMS_CROSSED -> {
                m.rightArm.xRot = -0.95f;
                m.leftArm.xRot = -0.95f;
                m.rightArm.yRot = -0.75f;
                m.leftArm.yRot = 0.75f;
                m.rightArm.zRot = 0.1f;
                m.leftArm.zRot = -0.1f;
            }
            case VICTORY -> {  // eine Faust hoch, die andere in die Hüfte
                m.rightArm.xRot = -3.0f;
                m.rightArm.zRot = 0.15f;
                m.leftArm.xRot = -0.2f;
                m.leftArm.zRot = -0.75f;
            }
            case HANDS_HIPS -> {
                m.rightArm.xRot = -0.25f;
                m.leftArm.xRot = -0.25f;
                m.rightArm.zRot = 0.75f;
                m.leftArm.zRot = -0.75f;
            }
            default -> {
            }
        }
        // Zweite Skin-Ebene (Ärmel, Hose, Jacke) mitnehmen
        m.rightSleeve.copyFrom(m.rightArm);
        m.leftSleeve.copyFrom(m.leftArm);
        m.rightPants.copyFrom(m.rightLeg);
        m.leftPants.copyFrom(m.leftLeg);
        m.jacket.copyFrom(m.body);
        m.hat.copyFrom(m.head);
    }
}
