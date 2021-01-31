module app;
import pegged.grammar;
import std.stdio;

void main(string[] args) {
    if (args.length != 3) {
        writeln("Parser generator generator needs [moduleName] and [file] as arguments.");
    }
    string modName = args[1];
    string file = args[2];

    asModule(modName, file, import("yarn.peg"), import("header.d"));
}