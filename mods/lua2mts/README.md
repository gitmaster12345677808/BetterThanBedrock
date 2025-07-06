# Lua2Mts [`lua2mts`]

## Version
1.0

## Description
This is a mod which allows you to convert schematics in the form of .lua files into .mts files using the lua2mts server command.  
.lua files are easier to edit with a text editor.  .mts files are binary and thus perform better because they are smaller.
It is intended to be used in conjunction with the Schematic Editor mod (schemedit) by Wuzzy.  
schemedit has a 3d schematic editor along with the following server commands:
* `placeschem` to place a schematic
* `mts2lua` to convert .mts files to .lua files (Lua code)

The reason this mod exists is if a schematic has hundreds of nodes, it is easier to edit that schematic doing a text editor search and replace of the .lua file than in the 3D editor that schemedit provides.
Editing a .lua file this way allows you to very quickly change the node type or the probability of a node for hundreds or more nodes.

An example workflow would be this:  
Say you have .mts schematic files of trees (tree_1.mts - tree_9.mts that look too symmetrical to be natural.  You want to change the probability of the leaf nodes to be something less than 254 to make the leaf placement be a little more random and thus more natural looking.  To accomplish that do the following.
1) Create a world in Minetest and enable schmedit and lua2mts mods in that world.
2) In a file manager create a schems sub folder in that world folder.  e.g.  C:\games\minetest-5.7.0-win64\worlds\myworld\schems
3) Copy all the tree .mts files into that schems folder
4) Use the command "/mts2lua tree_1" for all of the tree files 1-9.  To convert them all to .lua files. 
5) Open tree .lua files in a text editor.  
6) Search and replace "{name="default:tree_leaves", prob=254, param2=0}," with "{name="default:tree_leaves", prob=190, param2=0}," 
7) Use the command "/lua2mts tree_1"  for all of the .lua files 1-9.  This will convert them all back to .mts files. 

## Usage help
This mod assumes you already have a basic understanding about how schematics in Minetest work.
If not, refer to the Minetest Lua API documentation to understand more about schematics.

## License of everything
MIT License
