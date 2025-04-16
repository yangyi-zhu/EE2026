## Description
A minigame inspired by **The World's Hardest Game** by Armor Games consisting of 4 levels which must be completed sequentially in any difficulty before attempting the next. The first three
maps are available in 3 difficulties (Easy, Medium, Hard) whereas the final is only available in one.

Built on the Basys 3 Development Board using Verilog :D

### 🤔 Controls
* Difficulty Selection: Up & Down to switch, Center to confirm
* Movement: Up, Down, Left, & Down to move in the respective directions on screen
* Level Selection: Switches 0 through 3 for Map A through D respectively, 15 for random map

## Contribution to the Project
### 🗺️ Map D
**Map D** is the final level and it incorporates the following unique mechanics: <br>
**Teleportation pad** - Takes player to the destination upon detecting the avatar <br>
**Sliding gate** - Blocks off players from path / crushes players stuck under it <br>
**Map transformation** - Transforms map upon key pickup <br> <br>

**🎮 Gameplay:** <br>
The player spawns on the green pad in the top left and must dodge the obstacles and make it to the teleportation pad on the other end of the map. Upon contact, the pad takes the player to the other map, where they must collect the key before leaving. As the key is picked up, the gate at the bottom opens and the path backwards is now locked. The player must make it through before the gate closes, before taking the second teleportation pad back to the main map.
The obstacles in the main map are now frozen and the green pad is locked up. The player must find a way to return to the green pad to win. There is now an opening in the bottom left, leaving an unexpected path back to the green pad, ending the level. <br> <br>

**🛠️ Other implementations:** <br>
**Death screen** - Shows up when killed by a moving obstacle or sliding gate <br>
**Win screen** - Shows up upon returning to green pad after collecting key <br>
**Key** - Toggles changes on the map and enables win condition <br>
**Avatar change** - Speed, size, and color of avatar change upon entering new map through teleportation pad <br>
**Reset** - Center button, used when locked before the gate to save time

---

### 💀 Death Screen
Displayed briefly when the kill condition is active on any level.
