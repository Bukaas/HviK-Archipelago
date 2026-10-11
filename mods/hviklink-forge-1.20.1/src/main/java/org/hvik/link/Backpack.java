package org.hvik.link;

import net.minecraft.nbt.CompoundTag;
import net.minecraft.nbt.ListTag;
import net.minecraft.nbt.Tag;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.SimpleContainer;
import net.minecraft.world.SimpleMenuProvider;
import net.minecraft.world.inventory.ChestMenu;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;

/**
 * Rucksack (Perk): 27 Plätze extra, Taste B bzw. /backpack. Inhalt liegt in den Spielerdaten der Welt
 * und zählt beim Ziel ("Items sammeln" / "Wer hat am meisten?") mit.
 */
public final class Backpack {
    static final String KEY = "hviklink_backpack";
    static final int SIZE = 27;

    private Backpack() {
    }

    /** Darf gerade geöffnet werden? (Perk an, Runde läuft, Countdown vorbei) */
    static boolean enabled() {
        LinkClient c = HvikLink.CLIENT;
        return c.active() && c.backpack && "running".equals(c.status) && c.countdown() == 0 && !c.detached;
    }

    static void open(ServerPlayer sp) {
        if (!enabled()) {
            sp.sendSystemMessage(Component.literal("🎒 Der Rucksack ist in dieser Runde nicht an."));
            return;
        }
        SimpleContainer box = load(sp);
        box.addListener(c -> save(sp, (SimpleContainer) c));
        sp.openMenu(new SimpleMenuProvider((id, inv, p) -> ChestMenu.threeRows(id, inv, box), Component.literal("🎒 Rucksack")));
    }

    static SimpleContainer load(ServerPlayer sp) {
        SimpleContainer box = new SimpleContainer(SIZE);
        ListTag list = sp.getPersistentData().getCompound(KEY).getList("Items", Tag.TAG_COMPOUND);
        for (int i = 0; i < list.size(); i++) {
            CompoundTag t = list.getCompound(i);
            int slot = t.getByte("Slot") & 255;
            if (slot < SIZE) box.setItem(slot, ItemStack.of(t));
        }
        return box;
    }

    static void save(ServerPlayer sp, SimpleContainer box) {
        ListTag list = new ListTag();
        for (int i = 0; i < box.getContainerSize(); i++) {
            ItemStack s = box.getItem(i);
            if (s.isEmpty()) continue;
            CompoundTag t = new CompoundTag();
            t.putByte("Slot", (byte) i);
            s.save(t);
            list.add(t);
        }
        CompoundTag tag = new CompoundTag();
        tag.put("Items", list);
        sp.getPersistentData().put(KEY, tag);
    }

    /** Wie viele von diesem Item liegen im Rucksack? */
    static int count(ServerPlayer sp, Item item) {
        int n = 0;
        ListTag list = sp.getPersistentData().getCompound(KEY).getList("Items", Tag.TAG_COMPOUND);
        for (int i = 0; i < list.size(); i++) {
            ItemStack s = ItemStack.of(list.getCompound(i));
            if (s.is(item)) n += s.getCount();
        }
        return n;
    }
}
