module yarn.parser;
import pegged.grammar;

private {
    mixin(grammar(import("yarn.peg")));
}

mixin(import("header.d"));