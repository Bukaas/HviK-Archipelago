package org.hvik.link;

import java.util.ArrayList;
import java.util.List;
import net.minecraft.core.BlockPos;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.nbt.ListTag;
import net.minecraft.nbt.Tag;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.entity.ChestBlockEntity;
import net.minecraft.world.level.block.entity.SkullBlockEntity;
import net.minecraft.world.level.block.state.BlockState;

/**
 * Grab: Beim Tod (Runde läuft, "Nur Rucksack" / "Alles verlieren") landet das Inventar in Kisten an der Todesstelle,
 * obendrauf der Kopf des Spielers. Ein Pfeil im HUD zeigt die Richtung - hinteleportieren geht nicht.
 * Ist das Grab leer geräumt, verschwindet es von selbst.
 */
public final class Grave {
    static final String KEY = "hviklink_graves";
    static final int MAX_CHESTS = 4;

    /** Gräber des Spielers in dieser Welt - der integrierte Server schreibt, das HUD liest. */
    public record Spot(String dim, int x, int y, int z, int chests) {
    }

    public static volatile List<Spot> spots = List.of();

    private Grave() {
    }

    static void create(ServerPlayer sp, List<ItemStack> items) {
        items.removeIf(ItemStack::isEmpty);
        if (items.isEmpty()) return;
        ServerLevel lvl = sp.serverLevel();
        int chests = Math.min(MAX_CHESTS, (items.size() + 26) / 27);
        BlockPos pos = findSpot(lvl, sp.blockPosition(), chests + 1);
        int n = 0;
        for (int i = 0; i < chests; i++) {
            BlockPos p = pos.above(i);
            lvl.setBlock(p, Blocks.CHEST.defaultBlockState(), 3);
            if (lvl.getBlockEntity(p) instanceof ChestBlockEntity ch) {
                ch.setCustomName(Component.literal("✝ Grab von " + sp.getGameProfile().getName()));
                for (int s = 0; s < 27 && n < items.size(); s++) ch.setItem(s, items.get(n++));
            }
        }
        while (n < items.size()) sp.drop(items.get(n++), false);  // mehr als 4 Kisten voll (kommt praktisch nicht vor): liegt daneben
        BlockPos top = pos.above(chests);
        lvl.setBlock(top, Blocks.PLAYER_HEAD.defaultBlockState(), 3);
        if (lvl.getBlockEntity(top) instanceof SkullBlockEntity sk) sk.setOwner(sp.getGameProfile());
        String dim = lvl.dimension().location().toString();
        ListTag list = sp.getPersistentData().getList(KEY, Tag.TAG_COMPOUND);
        CompoundTag t = new CompoundTag();
        t.putString("dim", dim);
        t.putInt("x", pos.getX());
        t.putInt("y", pos.getY());
        t.putInt("z", pos.getZ());
        t.putInt("n", chests);
        list.add(t);
        sp.getPersistentData().put(KEY, list);
        sync(sp);
        sp.sendSystemMessage(Component.literal("✝ Deine Sachen liegen in deinem Grab bei " + pos.getX() + " / " + pos.getY() + " / " + pos.getZ()
                + dimName(dim) + " – der Pfeil oben zeigt dir den Weg."));
    }

    /** Freie Stelle für Kisten + Kopf: an der Todesstelle, sonst darüber (z. B. in einer Wand erstickt). */
    private static BlockPos findSpot(ServerLevel lvl, BlockPos death, int height) {
        int min = lvl.getMinBuildHeight() + 1, max = lvl.getMaxBuildHeight() - height - 1;
        BlockPos start = new BlockPos(death.getX(), Math.max(min, Math.min(max, death.getY())), death.getZ());
        for (int dy = 0; dy < 24 && start.getY() + dy <= max; dy++) {
            BlockPos p = start.above(dy);
            boolean free = true;
            for (int i = 0; i < height && free; i++) free = replaceable(lvl.getBlockState(p.above(i)));
            if (free) return p;
        }
        return start;
    }

    private static boolean replaceable(BlockState s) {
        return s.isAir() || s.canBeReplaced() || !s.getFluidState().isEmpty();
    }

    /** Leer geräumte oder abgebaute Gräber entfernen (läuft alle 2 Sekunden). */
    static void check(ServerPlayer sp) {
        ListTag list = sp.getPersistentData().getList(KEY, Tag.TAG_COMPOUND);
        if (list.isEmpty()) {
            if (!spots.isEmpty()) sync(sp);
            return;
        }
        String here = sp.serverLevel().dimension().location().toString();
        boolean changed = false;
        for (int i = list.size() - 1; i >= 0; i--) {
            CompoundTag t = list.getCompound(i);
            if (!here.equals(t.getString("dim"))) continue;
            BlockPos pos = new BlockPos(t.getInt("x"), t.getInt("y"), t.getInt("z"));
            ServerLevel lvl = sp.serverLevel();
            if (!lvl.isLoaded(pos)) continue;
            boolean empty = true;
            for (int c = 0; c < t.getInt("n"); c++) {
                if (lvl.getBlockEntity(pos.above(c)) instanceof ChestBlockEntity ch && !ch.isEmpty()) empty = false;
            }
            if (!empty) continue;
            for (int c = 0; c < t.getInt("n"); c++) {
                if (lvl.getBlockState(pos.above(c)).is(Blocks.CHEST)) lvl.removeBlock(pos.above(c), false);
            }
            if (lvl.getBlockState(pos.above(t.getInt("n"))).is(Blocks.PLAYER_HEAD)) lvl.removeBlock(pos.above(t.getInt("n")), false);
            list.remove(i);
            changed = true;
            sp.sendSystemMessage(Component.literal("✝ Grab ausgeräumt – es ist verschwunden."));
        }
        if (changed) sp.getPersistentData().put(KEY, list);
        if (changed || spots.size() != list.size()) sync(sp);
    }

    static void sync(ServerPlayer sp) {
        List<Spot> out = new ArrayList<>();
        ListTag list = sp.getPersistentData().getList(KEY, Tag.TAG_COMPOUND);
        for (int i = 0; i < list.size(); i++) {
            CompoundTag t = list.getCompound(i);
            out.add(new Spot(t.getString("dim"), t.getInt("x"), t.getInt("y"), t.getInt("z"), t.getInt("n")));
        }
        spots = List.copyOf(out);
    }

    static String dimName(String dim) {
        return switch (dim) {
            case "minecraft:the_nether" -> " im Nether";
            case "minecraft:the_end" -> " im End";
            case "minecraft:overworld" -> "";
            default -> " (" + dim + ")";
        };
    }
}
