# gbjam13

## Libraries

- [hump](https://hump.readthedocs.io/en/latest/)
- [flux](https://github.com/rxi/flux)
- [shove](https://github.com/Oval-Tutu/shove)
- [bump](https://github.com/kikito/bump.lua)

## Repo Structure

### `asset`

#### `audio`

Place Music and SFX here.

#### `sprite`

Place sprite sheets here. Sprite sheets are sliced into quads for animations in `util/create_animation.lua`

### `class`

Files for OOP classes using `hump.class`.

### `gamestate`

Files for Gamestates dictates by `States` in `main.lua`. Uses `hump.gamestate`.

### `lib`

Imported libraries. See Libraries above for documentation.

### `map`

Tilemaps for levels

### `util`

Helper functions and libraries