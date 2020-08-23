This project was written as a preliminary test to learn how to parse complex code.
It is an implementation of a LL parser for Lua code written in Lua using the
grammar definitions lua.org provides as a basis.

It tokenizes and parses a Lua script fed in through a long string at the top of the
script. As it parses the script it generates graphviz data that can be visualized on
the site webgraphviz.com. I'd recommend using a smaller script like a standalone
function for visualization because a lot of nodes are generated and webgraphviz.com
has a very strict limit.