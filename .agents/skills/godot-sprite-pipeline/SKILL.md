---
name: godot-sprite-pipeline
description: Create or revise 2D sprite-sheet animations for Godot 4.x. Use when generating frames from an existing character, aligning a sprite strip, or adding its frames to AnimatedSprite2D and SpriteFrames. For animation state logic alone, use the project's existing controller patterns.
---

# Godot Sprite Pipeline

Use this workflow for the art and Godot resource together. Start with the project's existing sprite, cell size, pixel style, and animation setup.

## Make the strip

1. Pick one frame already used in the game as the reference for character identity and scale. Inspect adjacent animations too, especially the frames where this action begins and ends.
2. For new art, give image generation a transparent reference canvas with the seed frame and enough room for the full action. Request the complete animation as one strip with an exact frame count and equal slots. Specify the action beat across the frames, facing direction, silhouette, palette, costume, proportions, and pixel style. Keep labels, scenery, and extra characters out of the asset. Use the available image-generation skill for generative edits.
3. Split or arrange the result into equal-size transparent cells. Apply **one scale to the whole strip**, then align every pose to the same gameplay anchor, usually the feet at bottom center. Check the body position as well as the cell bounds; transparent padding alone can hide motion drift. If the first pose should be identical to an existing idle or run frame, use that exact source frame in the final strip.
4. Keep deliberate motion readable. A wide attack, dash trail, or other effect may need a larger cell or a separate effect node. Do not center each pose independently to make it fit. For a dash, move the `CharacterBody2D` through gameplay code; the sprite frames depict that movement and must not create a second, baked displacement that snaps back at the end.

## Put it in Godot

1. Follow the scene's current asset format. For a sheet, add the cells to its `SpriteFrames` resource through Godot's sprite-sheet importer or `AtlasTexture` regions already used by the scene. For separate images, add those textures to the same resource. Preserve existing animation names and frame order used by scripts.
2. Set the intended frame speed and loop behavior. Locomotion usually loops; one-shot actions need a final frame and a transition that returns to the next movement state. `AnimatedSprite2D.animation_finished` fires for a one-shot animation, not a looping one.
3. Keep the `AnimatedSprite2D` origin, offset, and frame dimensions consistent with neighboring animations. Follow the project's texture filter and pixel-snap settings. Keep collision and actual character position owned by the physics body, even when the visual pose or effect extends outside it.

## Check the result

- Inspect a contact sheet or equivalent frame-by-frame view for transparency, exact count, consistent proportions, anchor, and neighboring-frame continuity.
- Play the animation in `SpriteFrames`, then run the scene at its native game scale. Check both facing directions and entry/exit transitions, including idle or run to action and back. Look for a one-pixel body wobble and a snap when a one-shot finishes.
- Run the smallest relevant Godot project check after changing scene resources or scripts. Report any visual check that could not be performed.

Adapted from [GameStudio's sprite pipeline](https://github.com/openai/plugins/blob/main/plugins/game-studio/skills/sprite-pipeline/SKILL.md); Godot's [2D sprite animation guide](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) covers the engine resource workflow.
