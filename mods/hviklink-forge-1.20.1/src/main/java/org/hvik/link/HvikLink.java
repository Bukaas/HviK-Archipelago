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

    public HvikLink() {
        CLIENT = new LinkClient(LinkConfig.load(FMLPaths.CONFIGDIR.get()));
        MinecraftForge.EVENT_BUS.register(new GameEvents());
        DistExecutor.unsafeRunWhenOn(Dist.CLIENT, () -> () -> {
            MinecraftForge.EVENT_BUS.register(new ClientEvents());
            FMLJavaModLoadingContext.get().getModEventBus().addListener(ClientEvents::registerOverlay);
            FMLJavaModLoadingContext.get().getModEventBus().addListener(ClientEvents::registerKeys);
        });
    }
}
