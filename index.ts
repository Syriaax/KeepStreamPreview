/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { definePluginSettings } from "@api/Settings";
import definePlugin, { OptionType } from "@utils/types";

const settings = definePluginSettings({
    callTile: {
        type: OptionType.BOOLEAN,
        description: "Keep your own stream tile in the call view live while Discord is not focused",
        default: true
    },
    pictureInPicture: {
        type: OptionType.BOOLEAN,
        description: "Keep your own stream live in the picture-in-picture player while Discord is not focused",
        default: true
    }
});

export default definePlugin({
    name: "KeepStreamPreview",
    description: "Stops Discord from pausing the preview of your own stream when the Discord window loses focus",
    authors: [{ name: "Syriaax", id: 0n }],
    settings,

    patches: [
        // Call view stream tile. Discord pauses your own stream when:
        // isOwnStream && pauseSelfStreamPreviewWhenUnfocused && !windowFocused && popoutType === NO_POPOUT
        {
            find: "Stream Tile State - activeStream:",
            replacement: {
                match: /pauseSelfStreamPreviewWhenUnfocused\).{0,80}?\.NO_POPOUT/,
                replace: "$&&&!$self.settings.store.callTile"
            }
        },
        // Picture-in-picture player. Pauses your own stream whenever the main window is not focused
        // and ignores Discord's own "Pause Preview When Discord Isn't Focused" setting.
        {
            find: "get streamerPaused(){",
            replacement: {
                match: /get streamerPaused\(\)\{/,
                replace: "$&if($self.settings.store.pictureInPicture)return!1;"
            }
        }
    ]
});
