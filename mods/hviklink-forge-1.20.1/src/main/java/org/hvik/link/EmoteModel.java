package org.hvik.link;

import net.minecraft.client.model.PlayerModel;
import net.minecraft.client.model.geom.ModelPart;
import net.minecraft.client.player.AbstractClientPlayer;

/** Normales Spielermodell - danach wird die gewählte Emote-Pose draufgelegt. */
public class EmoteModel extends PlayerModel<AbstractClientPlayer> {
    public EmoteModel(ModelPart root, boolean slim) {
        super(root, slim);
    }

    @Override
    public void setupAnim(AbstractClientPlayer player, float limbSwing, float limbSwingAmount, float ageInTicks, float netHeadYaw, float headPitch) {
        super.setupAnim(player, limbSwing, limbSwingAmount, ageInTicks, netHeadYaw, headPitch);
        Emotes.apply(this, player, ageInTicks);
    }
}
