# r/roguelikedev's 2024 roguelike tutorial

Silently participated in the [2024 roguelike tutorial](https://www.reddit.com/r/roguelikedev/comments/1dt8bqm/roguelikedev_does_the_complete_roguelike_tutorial/) at the r/roguelikedev Reddit. This project was written for the Godot 4.2 engine, mostly following along with [SalinaDev's Godot tutorial from 2023](https://selinadev.github.io/tags/roguelike/). All sprites and font are free assets taken from [kenney.nl](https://kenney.nl/).

There is no limit to the number of dungeon floors generated, but you won't see anything new beyond floor 7.

## Noteable deviations from tutorial content

- Field of view is using the "symmetric shadowcasting" algorithm described [here](https://www.albertford.com/shadowcasting/), with an added maximum view distance parameter (set to a constant 8 tiles for this project).
- Look action also includes inspection of tiles (so you don't need to use the mouse to inspect things).

## Controls

| Key(s) | Action |
| --- | --- |
| Keypad | 8-way movement/attacking (recommended) |
| `H` `J` `K` `L` `Y` `U` `B` `N` | 8-way movement/attacking |
| Arrows | 4-way movement/attacking |
| `G` | Pick up item |
| `D` | Drop item |
| `I` | Use/equip item |
| `,` | Descend stairs |
| `Keypad /`, `S` | Look around, inspect tile |
| `Keypad 5`, `Delete`, `.` | Pass turn |
| `V` | View log history |
| `Return` | OK/accept choice |
| `Esc` | Cancel choice, quit to title screen |
| `Ctrl + Q` | Quit to title screen |