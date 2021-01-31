import std.conv;
import std.stdio;

/**
    Function for dumping yarn errors
*/
void delegate(string) yarnErrorDumpFunc = (err) {
    writeln(err);
};

/**
    Parses yarn grammar
*/
ParseTree parseYarn(string source) {
    scope(exit) yarnReset();
    return Yarn(source);
}

/**
    Parses an expression
*/
ParseTree parseExpression(string expr) {
    return Yarn.decimateTree(Yarn.Expression(expr));
}


/*
    PRIVATE SECTION
*/
private:

// How many spaces in an indent
int spaceIndentLength = 4;

// Levels of indentation
int[] indentations;

// Whether indentation has just begun
bool justBegun = false;

int actualIdentation(string matches) {
    int tabMatch = 0;
    int accumMatch = 0;
    foreach(i, match; matches) {
        if (match == ' ') accumMatch++;
        else if (match == '\t') tabMatch++;
        else break;
    }
    return (accumMatch/spaceIndentLength)+tabMatch;
}

/**
    Gets the base indentation level of the block
*/
int getBaseIndent()() {
    return indentations.length > 0 ? indentations[$-1] : 0;
}

/**
    The beginning of a statement block
*/
PT yarnBlockBegin(PT)(PT p) {

    // Get the amount of indentation
    immutable(int) indent = actualIdentation(p.input[p.begin..p.end]);
    indentations ~= indent;
    justBegun = true;

    return p; 
}

/**
    Handle indentation
*/
PT yarnIndentation(PT)(PT p) {

    // Reset just begun flag after doing special indentation handling
    int indent = justBegun ? indentations[$-1] : actualIdentation(p.input[p.begin..p.end]);
    justBegun = false;

    // Remove indentation from stack if need be
    int baseIndent = getBaseIndent();
    p.successful = (indent >= baseIndent && baseIndent != 0);
    if (!p.successful) indentations.length--;
    
    return p;
}

PT yarnFileTag(PT)(PT p) {
    if (p.matches.length == 2) {
        if (p.matches[0] == "Indentation") {
            spaceIndentLength = p.matches[1].to!int;
            writeln("Set indentation level to ", spaceIndentLength);
        }
    }
    return p;
}

PT yarnDumpError(PT)(PT p) {
    if (!p.successful) yarnErrorDumpFunc(p.failMsg);
    return p;
}

/**
    Resets the parser state
*/
void yarnReset() {
    spaceIndentLength = 4;
    indentations.length = 0;
}
