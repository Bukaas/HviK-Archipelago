package org.hvik.link;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.IdentityHashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.GZIPOutputStream;
import net.minecraft.client.Minecraft;
import net.minecraft.client.renderer.block.model.BakedQuad;
import net.minecraft.client.renderer.texture.TextureAtlasSprite;
import net.minecraft.client.resources.model.BakedModel;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.core.Rotations;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.network.chat.ClickEvent;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.util.RandomSource;
import net.minecraft.world.entity.decoration.ArmorStand;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.phys.AABB;
import net.minecraft.world.phys.shapes.VoxelShape;

/**
 * /hvik szene [radius]: Siegerszene für hvik.org auslesen - Rüstungsständer (Position, Richtung, Pose, Name = Platz),
 * sichtbare Blöcke (mit den Texturen aus dem Spiel) und der eigene Blick als Kamera. Ergebnis: hvik-szene-*.json.gz
 * im Spielordner, das man auf hvik.org hochlädt.
 */
public final class SceneExport {
    private SceneExport() {
    }

    public static int run(ServerPlayer sp, int radius) {
        ServerLevel level = sp.serverLevel();
        BlockPos c = sp.blockPosition();
        List<ArmorStand> stands = level.getEntitiesOfClass(ArmorStand.class, new AABB(c).inflate(radius, 48, radius),
                s -> !s.getTags().contains(Emotes.SEAT_TAG));
        if (stands.isEmpty()) {
            sp.sendSystemMessage(Component.literal("🎬 Keine Rüstungsständer im Umkreis von " + radius + " Blöcken gefunden."));
            return 0;
        }
        int minY = Integer.MAX_VALUE, maxY = Integer.MIN_VALUE;
        for (ArmorStand s : stands) {
            minY = Math.min(minY, s.blockPosition().getY());
            maxY = Math.max(maxY, s.blockPosition().getY());
        }
        int x0 = c.getX() - radius, z0 = c.getZ() - radius, y0 = Math.max(level.getMinBuildHeight(), minY - 6);
        int sx = radius * 2 + 1, sz = radius * 2 + 1, sy = Math.min(level.getMaxBuildHeight() - y0, maxY - y0 + 40);

        // Blöcke: nur sichtbare (mindestens eine offene Seite), als Palette + Lauflängen (x schnellste Achse, dann z, dann y)
        Map<BlockState, Integer> palette = new IdentityHashMap<>();
        List<BlockState> states = new ArrayList<>();
        states.add(null);  // 0 = Luft/unsichtbar
        JsonArray rle = new JsonArray();
        int run = 0, last = -1;
        BlockPos.MutableBlockPos p = new BlockPos.MutableBlockPos(), q = new BlockPos.MutableBlockPos();
        for (int y = 0; y < sy; y++) for (int z = 0; z < sz; z++) for (int x = 0; x < sx; x++) {
            p.set(x0 + x, y0 + y, z0 + z);
            BlockState st = level.getBlockState(p);
            int id = 0;
            if (!st.isAir()) {
                boolean visible = false;
                for (Direction d : Direction.values()) {
                    q.setWithOffset(p, d);
                    BlockState n = level.getBlockState(q);
                    if (n.isAir() || !n.isSolidRender(level, q)) {
                        visible = true;
                        break;
                    }
                }
                if (visible) {
                    Integer known = palette.get(st);
                    if (known == null) {
                        known = states.size();
                        palette.put(st, known);
                        states.add(st);
                    }
                    id = known;
                }
            }
            if (id == last) run++;
            else {
                if (run > 0) {
                    rle.add(run);
                    rle.add(last);
                }
                last = id;
                run = 1;
            }
        }
        if (run > 0) {
            rle.add(run);
            rle.add(last);
        }

        JsonObject out = new JsonObject();
        out.addProperty("version", 1);
        JsonArray size = new JsonArray();
        size.add(sx);
        size.add(sy);
        size.add(sz);
        out.add("size", size);
        JsonArray origin = new JsonArray();
        origin.add(x0);
        origin.add(y0);
        origin.add(z0);
        out.add("origin", origin);
        out.add("blocks", rle);

        // Rüstungsständer = Plätze (Name "1", "2", ...)
        JsonArray js = new JsonArray();
        for (ArmorStand s : stands) {
            JsonObject o = new JsonObject();
            o.addProperty("name", s.hasCustomName() ? s.getCustomName().getString() : "");
            o.addProperty("x", s.getX() - x0);
            o.addProperty("y", s.getY() - y0);
            o.addProperty("z", s.getZ() - z0);
            o.addProperty("yaw", s.getYRot());
            o.addProperty("small", s.isSmall());
            o.addProperty("arms", s.isShowArms());
            JsonObject pose = new JsonObject();
            pose.add("head", rot(s.getHeadPose()));
            pose.add("body", rot(s.getBodyPose()));
            pose.add("left_arm", rot(s.getLeftArmPose()));
            pose.add("right_arm", rot(s.getRightArmPose()));
            pose.add("left_leg", rot(s.getLeftLegPose()));
            pose.add("right_leg", rot(s.getRightLegPose()));
            o.add("pose", pose);
            js.add(o);
        }
        out.add("stands", js);

        // Kamera = eigener Blick beim Export
        JsonObject cam = new JsonObject();
        cam.addProperty("x", sp.getEyePosition().x - x0);
        cam.addProperty("y", sp.getEyePosition().y - y0);
        cam.addProperty("z", sp.getEyePosition().z - z0);
        cam.addProperty("yaw", sp.getYRot());
        cam.addProperty("pitch", sp.getXRot());
        out.add("camera", cam);

        // Texturen kommen vom Client (Modelle/Atlas) - im Einzelspieler gleiche JVM
        Minecraft mc = Minecraft.getInstance();
        BlockPos tintPos = c;
        mc.execute(() -> {
            try {
                Map<String, String> textures = new LinkedHashMap<>();
                out.add("palette", palette(mc, states, tintPos, textures));
                JsonObject tx = new JsonObject();
                textures.forEach(tx::addProperty);
                out.add("textures", tx);
                Path dir = mc.gameDirectory.toPath();
                Path file = dir.resolve("hvik-szene-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss")) + ".json.gz");
                try (OutputStream os = new GZIPOutputStream(Files.newOutputStream(file))) {
                    os.write(out.toString().getBytes(StandardCharsets.UTF_8));
                }
                long kb = Files.size(file) / 1024;
                mc.gui.getChat().addMessage(Component.literal("🎬 Szene gespeichert: " + stands.size() + " Rüstungsständer, " + (states.size() - 1)
                        + " Blockarten, " + kb + " KB – ").append(Component.literal("[Ordner öffnen]").withStyle(st -> st.withUnderlined(true)
                        .withColor(0x55FF55).withClickEvent(new ClickEvent(ClickEvent.Action.OPEN_FILE, dir.toString())))));
                mc.gui.getChat().addMessage(Component.literal("   Datei auf hvik.org unter HviK Link → Siegerszene hochladen."));
            } catch (Exception e) {
                HvikLink.LOG.warn("HviK Link: Szene speichern fehlgeschlagen", e);
                mc.gui.getChat().addMessage(Component.literal("🎬 Speichern fehlgeschlagen: " + e));
            }
        });
        sp.sendSystemMessage(Component.literal("🎬 Lese Szene aus (" + sx + "×" + sy + "×" + sz + " Blöcke) …"));
        return 1;
    }

    private static JsonArray rot(Rotations r) {
        JsonArray a = new JsonArray();
        a.add(r.getX());
        a.add(r.getY());
        a.add(r.getZ());
        return a;
    }

    /** Je Blockart: Texturen der Seiten (oben/unten/Seite, ggf. mit Färbung und Overlay), Form. */
    private static JsonArray palette(Minecraft mc, List<BlockState> states, BlockPos tintPos, Map<String, String> textures) {
        JsonArray pal = new JsonArray();
        pal.add(new JsonObject());
        RandomSource rand = RandomSource.create(42);
        for (int i = 1; i < states.size(); i++) {
            BlockState st = states.get(i);
            JsonObject e = new JsonObject();
            e.addProperty("id", String.valueOf(BuiltInRegistries.BLOCK.getKey(st.getBlock())));
            VoxelShape shape = st.getShape(mc.level, tintPos);
            boolean cross = shape.isEmpty() || st.getCollisionShape(mc.level, tintPos).isEmpty() && !st.isSolidRender(mc.level, tintPos);
            e.addProperty("shape", cross ? "cross" : "box");
            if (!cross) {
                e.addProperty("h", Math.round(shape.max(Direction.Axis.Y) * 100) / 100.0);
                e.addProperty("y0", Math.round(shape.min(Direction.Axis.Y) * 100) / 100.0);
            }
            e.addProperty("transparent", !st.canOcclude());
            BakedModel model = mc.getBlockRenderer().getBlockModel(st);
            JsonObject faces = new JsonObject();
            for (Direction d : new Direction[]{Direction.UP, Direction.DOWN, Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST}) {
                List<BakedQuad> quads = new ArrayList<>(model.getQuads(st, d, rand));
                if (quads.isEmpty()) quads.addAll(model.getQuads(st, null, rand));
                JsonArray layers = new JsonArray();
                for (BakedQuad qd : quads.subList(0, Math.min(2, quads.size()))) {
                    JsonObject l = new JsonObject();
                    l.addProperty("tex", tex(qd.getSprite(), textures));
                    if (qd.isTinted()) l.addProperty("tint", mc.getBlockColors().getColor(st, mc.level, tintPos, qd.getTintIndex()) & 0xFFFFFF);
                    layers.add(l);
                }
                if (layers.isEmpty()) {
                    JsonObject l = new JsonObject();
                    l.addProperty("tex", tex(model.getParticleIcon(), textures));
                    layers.add(l);
                }
                faces.add(d.getName(), layers);
            }
            e.add("faces", faces);
            pal.add(e);
        }
        return pal;
    }

    /** Textur einmal als PNG (Base64) ablegen, Name zurückgeben. */
    private static String tex(TextureAtlasSprite sprite, Map<String, String> textures) {
        String name = String.valueOf(sprite.contents().name());
        if (!textures.containsKey(name)) {
            String data = "";
            try {
                data = Base64.getEncoder().encodeToString(sprite.contents().getOriginalImage().asByteArray());
            } catch (Exception e) {
                HvikLink.LOG.debug("HviK Link: Textur {} nicht lesbar", name);
            }
            textures.put(name, data);
        }
        return name;
    }
}
