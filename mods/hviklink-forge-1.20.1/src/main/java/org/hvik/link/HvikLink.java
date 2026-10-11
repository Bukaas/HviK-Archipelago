package org.hvik.link;

import com.mojang.logging.LogUtils;
import net.minecraftforge.api.distmarker.Dist;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.fml.DistExecutor;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.fml.loading.FMLPaths;
import org.slf4j.Logger;

/** HviK Link: Einzelspieler-Welten über hvik.org koppeln - geteilte Herzen/Hunger, Death Link, gemeinsamer Start. */
@Mod(HvikLink.MODID)
public class HvikLink {
    public static final String MODID = "hviklink";
    public static final Logger LOG = LogUtils.getLogger();
    public static LinkClient CLIENT;
    /** sha256 der eigenen Jar - hvik.org erkennt daran veraltete Versionen. */
    public static String MOD_SHA = "";

    public HvikLink() {
        try {
            java.nio.file.Path jar = net.minecraftforge.fml.ModList.get().getModFileById(MODID).getFile().getFilePath();
            if (java.nio.file.Files.isRegularFile(jar)) {
                byte[] d = java.security.MessageDigest.getInstance("SHA-256").digest(java.nio.file.Files.readAllBytes(jar));
                StringBuilder sb = new StringBuilder();
                for (byte b : d) sb.append(String.format("%02x", b));
                MOD_SHA = sb.toString();
            }
        } catch (Exception e) {
            LOG.warn("HviK Link: eigene Version nicht lesbar: {}", e.toString());
        }
        CLIENT = new LinkClient(LinkConfig.load(FMLPaths.CONFIGDIR.get()));
        MinecraftForge.EVENT_BUS.register(new GameEvents());
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT, () -> () -> {
            MinecraftForge.EVENT_BUS.register(new ClientEvents());
            FMLJavaModLoadingContext.get().getModEventBus().addListener(ClientEvents::registerOverlay);
            FMLJavaModLoadingContext.get().getModEventBus().addListener(ClientEvents::registerKeys);
            FMLJavaModLoadingContext.get().getModEventBus().addListener(ClientEvents::addLayers);
        });
    }
}
