Collect all the treasure in the dungeon!  Can you make it to the second level?  Good luck!

[Wizard Chase on itch.io]( https://clarkjohn.itch.io/wizard/)

![Alt Text](https://img.itch.zone/aW1hZ2UvMTMwOTAzMS84MTUwMjU3LmdpZg==/original/gBnCOD.gif)

# Credits:
* Art assets from [0x72.itch.io/dungeontileset-ii]( https://0x72.itch.io/dungeontileset-ii)
* Music from  [xdeviruchi.itch.io/8-bit-fantasy-adventure-music-pack]( https://xdeviruchi.itch.io/8-bit-fantasy-adventure-music-pack)
* Sound assets from:
  * [kronbits.itch.io/freesfx]( https://kronbits.itch.io/freesfx)
  * [harvey656.itch.io/8-bit-game-sound-effects-collection]( https://harvey656.itch.io/8-bit-game-sound-effects-collection) using [LabChirp]( https://labbed.itch.io/labchirp)

Inspired by Pacman and Lock 'n' Chase

# Game 

### Instructions: 

Enter the dungeon and collect all the coins to descend to the next level.

### Controls:

* *Direction or WASD keys* for movement.
* *SpaceBar* to cast a Magic Wall 
![Alt Text](https://img.itch.zone/aW1nLzc3MTE0NTEucG5n/original/PN2m%2FV.png), which blocks enemies.  Magic Walls can only be added to tiles with horizontal and vertical lines (![Alt Text](https://img.itch.zone/aW1nLzgxMjAyNzQucG5n/original/w%2FSQlJ.png) and ![Alt Text](https://img.itch.zone/aW1nLzgxMjAyOTMucG5n/original/zf0%2Fp6.png)).

### Enemies:

Enemies will scatter in different directions, but every few seconds the enemies will have the following AI:

| Enemy      | AI |
| ---------- | ----------- |
| Fiend      | 1. Will target the player’s current tile <br />2. When the player gets 85% of the coins on the current level, will always target the player’s current tile
| Ogre       | Will target the player’s current tile and then retreat if within 3 tiles of the player        |
| Slime      | Will target the 3rd previous tile, the player was just at |
| Lizard Man | Will target 3 tiles ahead the current direction the player is facing        |
   
# Build locally 

HTML, Windows and MacOS are compiled with Godot 3.3.1

### Fix 'Load failed due to missing dependencies' - res://assets/music/xDeviruchi - And The Journey Begins .wav
Music files are not included in this repo.  These files can be downloaded from [xdeviruchi/8-bit-fantasy-adventure-music-pack]( https://xdeviruchi.itch.io/8-bit-fantasy-adventure-music-pack)k and copied to folder /assets/music.  Files include:
* /assets/music/xDeviruchi - And The Journey Begins .wav
* /assets/music/xDeviruchi - The Final of The Fantasy.wav 
