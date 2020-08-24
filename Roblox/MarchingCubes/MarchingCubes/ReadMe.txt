This project served as the testing grounds for a series of experiments
with the marching cubes algorithm. I used this project to prototype
a marching cubes implementation for use in a custom game engine.

The project is designed to be run in Roblox Studio using the Lua command
line. The terrain module is fetched with

terrainModule = require(workspace.TerrainModule)

In order to make the module functions more convenient to use I made the
helper script RunScript and ran the command

require(workspace.RunScript:Clone())( mode, terrainType )

where "mode" is a string with one of four modes: 'draw', 'node',
'debug', 'debugDraw', and "terrainType" is one of the modules in the
workspace.TerrainTypes folder object.