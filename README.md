# gbjam13

Made with [LÖVE](https://love2d.org/)❣️

## Libraries

- [hump](https://hump.readthedocs.io/en/latest/)
- [flux](https://github.com/rxi/flux)
- [shove](https://github.com/Oval-Tutu/shove)
- [bump](https://github.com/kikito/bump.lua)
- [SYSL-Text](https://github.com/sysl-dev/SYSL-Text)
- [cimgui-love](https://codeberg.org/apicici/cimgui-love)

## Repo Structure

### `asset`

#### `audio`

Place Music and SFX here. A separate `text` subdir is also here for textboxes and frames used by `SYSL-Text`

#### `sprite`

Place sprite sheets here. Sprite sheets are sliced into quads for animations in `util/create_animation.lua`

#### `font`

Font assets used in game

### `class`

Files for OOP classes using `hump.class`.

### `gamestate`

Files for Gamestates dictates by `States` in `main.lua`. Uses `hump.gamestate`.

### `level`

Level tilemaps and enemy placements in each level

### `lib`

Imported libraries. See Libraries above for documentation.

### `util`

General purpose functions, such as the loading or creation of animations, enemies, and maps from other source/asset files.

#### Tilemap Keys

The collision for these tiles use AABB collision.

`1`: Solid - Usually the ground or the wall

`2`: Spike - Tile that inflicts damage or kills the player on contact

### `util`

Helper functions and libraries