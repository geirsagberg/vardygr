# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Vardygr** is a 2D side-scrolling platformer built in Godot 4.4 with pixel art aesthetics. The game features a dark atmospheric character with combat mechanics and smooth parallax backgrounds.

## Development Commands

### Running the Game
- Open in Godot Editor: `godot project.godot`
- Run from command line: `godot --headless --main-pack game.tscn`

### Project Structure
- **Main Scene**: `game.tscn` - Root game scene with parallax backgrounds
- **Player Scene**: `player.tscn` - Player character with physics and animations
- **Scripts**: `player.gd` (main character controller), `camera_target.gd` (camera system)
- **Assets**: `/assets/` (backgrounds), `/sprites/` (character sprites)

## Code Architecture

### Player System (`player.gd`)
The player controller uses a dual-state system:
- **Movement States**: IDLE, RUNNING, JUMPING, FALLING
- **Combat States**: NO_ATTACK, ATTACK_1, ATTACK_2, JUMP_ATTACK, RUN_ATTACK_1

Key constants:
- `RUN_SPEED = 120`, `GRAVITY = 1000`, `JUMP_SPEED = -250`, `CAMERA_OFFSET = 96`

Attack system supports combo chains with `queued_attack` mechanism. Context-sensitive attacks change based on movement state (idle/running/jumping).

### Camera System (`camera_target.gd`)
Smooth camera following with look-ahead functionality. Camera offset dynamically adjusts based on player direction (`target_offset_x`). Uses interpolation at 200 pixels/second for smooth movement.

### Scene Hierarchy
- **Game** (Node2D)
  - **ParallaxBackground** with 6 layers (sky, planet, clouds, back, mid, front)
  - **Player** (CharacterBody2D instance)
  - **Ground** (StaticBody2D with collision)

### Animation System
Character has 11 animations managed through `AnimatedSprite2D`:
- Movement: idle, run, walk, jump, fall
- Combat: idle_attack_1/2, run_attack_1/2, jump_attack_1/2

All animations run at 10 FPS. Attack animations are non-looping and trigger state changes via `animation_finished` signal.

### Input Configuration
- Movement: A/D keys (left/right)
- Jump: Spacebar
- Attack: J key
- All inputs have 0.2 deadzone

### Display Settings
- Viewport: 288x156 pixels (low-res)
- Window: 1152x624 pixels (4x scale)
- Pixel-perfect rendering with no texture filtering
- Viewport stretch mode for consistent scaling

## Development Notes

### Working with Animations
When adding new animations, ensure they're added to the AnimatedSprite2D node in `player.tscn` and handle state transitions in the `_on_animated_sprite_2d_animation_finished()` function.

### Physics System
Uses Godot's CharacterBody2D with `move_and_slide()`. Ground collision uses WorldBoundaryShape2D for infinite ground plane.

### Sprite Management
Character sprites are organized in `/sprites/dark-hollow.png` as a 256x128 grid. Background assets in `/assets/` are used for parallax layers with different scroll speeds.

### State Management
The dual-state system allows independent tracking of movement and combat states, enabling context-sensitive animations and preventing movement during attack animations.