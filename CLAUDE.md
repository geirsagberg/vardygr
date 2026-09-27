# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Vardygr** is a 2D side-scrolling platformer built in Godot 4.7.2 with pixel art aesthetics. The game features a dark atmospheric character with combat mechanics and smooth parallax backgrounds.

## Development Commands

### Running the Game
- Open in Godot Editor: `godot --editor --path .`
- Run from command line: `godot --path .`
- Check dash alignment: `godot --headless --path . --script res://tests/dash_snap.gd`
- Check dash response: `godot --headless --path . --script res://tests/dash_response.gd`
- Check dash animation switching: `godot --headless --path . --script res://tests/dash_variant_switch.gd`

### Project Structure
- **Main Scene**: `game.tscn` - Root game scene with parallax backgrounds
- **Player Scene**: `player.tscn` - Player character with physics and animations
- **Scripts**: `player.gd` (main character controller), `camera_target.gd` (camera system)
- **Assets**: `/assets/` (backgrounds), `/sprites/` (character sprites)

## Code Architecture

### Player System (`player.gd`)
The player controller uses a dual-state system:
- **Movement States**: IDLE, RUNNING, JUMPING, FALLING, DASHING
- **Combat States**: NO_ATTACK, LIGHT_ATTACK_1, LIGHT_ATTACK_2

Key constants:
- `RUN_SPEED = 120`, `GRAVITY = 1000`, `JUMP_SPEED = -300`, `CAMERA_OFFSET = 96`

Attack system supports combo chains with `queued_attack` mechanism. Context-sensitive attacks change based on movement state (idle/running/jumping).

### Camera System (`camera_target.gd`)
The camera target follows the player on physics ticks. Its look-ahead offset changes with player direction at 200 pixels/second. Camera2D smooths the view. The camera sits beside the player in `game.tscn` so resetting interpolation after a dash does not snap the view.

### Scene Hierarchy
- **Game** (Node2D)
  - **ParallaxBackground** with 6 layers (sky, planet, clouds, back, mid, front)
  - **Player** (CharacterBody2D instance)
  - **CameraTarget** (Marker2D with Camera2D child)
  - **Ground** (StaticBody2D with collision)

### Animation System
Character animations are managed through `AnimatedSprite2D` and `animation_controller.gd`:
- Movement: idle, run, walk, jump, fall
- Dash: idle_dash, run_dash
- Combat: light_attack_1/2, run_light_attack_1/2

All animations run at 10 FPS. Dash and attack animations play once and return to movement animations when they finish. Jumping or attacking interrupts dash. Dash starts on the streak frame, moving the player body immediately with collision. During dash, the animation switches between idle_dash and run_dash as movement input changes, keeping the matching frame. Each dash animation uses its fixed sprite offset to cancel the horizontal shift baked into its sheet.

### Input Configuration
- Movement: A/D keys (left/right)
- Jump: Spacebar
- Attack: J key
- Dash animation: I key (while grounded and not attacking)
- All inputs have 0.2 deadzone

### Display Settings
- Viewport: 288x156 pixels (low-res)
- Window: 1152x624 pixels (4x scale)
- Pixel-perfect rendering with no texture filtering
- Viewport stretch mode for consistent scaling

## Development Notes

### Working with Animations
When adding new animations, add them to the AnimatedSprite2D node in `player.tscn` and handle state transitions in `animation_controller.gd`.

### Physics System
Uses Godot's CharacterBody2D with `move_and_slide()`. Ground collision uses WorldBoundaryShape2D for infinite ground plane.

### Sprite Management
Character sprites are organized in `/sprites/dark-hollow.png` as a 256x128 grid. Background assets in `/assets/` are used for parallax layers with different scroll speeds.

### State Management
The dual-state system tracks movement and combat separately so attacks can use different animations while standing or running.
