module yarn.dialogue;

// TODO: Should I support logger per-dialogue instance?

alias YarnLoggerFunc = void delegate(string);
/**
    The function that recieves diagnostic messages and errors from
    YarnDialogue instances.
*/
YarnLoggerFunc YarnLogger;

/**
    A line of dialogue sent from the YarnDialogue to the game.

    When the game recieves a YarnLine, it should do the  
    following things to prepare the line for presentation to the user.

    1. Use the value in the `id` field to luuk up the  
    appropriate user-facing text in the string table.

    2. Use `YarnDialogue.expandSubstitutions` to replace all  
    substituions in the user-facing text

    3. Use `YarnDialogue.parseMarkup` to parse all markup in  
    the line.

    You do not create instances of this struct yourself. They are  
    created by the YarnDialogue during program execution.
*/
struct YarnLine {
private:
    this(string id) {
        this.id = id;
    }

public:
    /**
        The string ID for this line
    */
    string id;

    /**
        The values that should be inserted in to the user-facing text  
        before delivery.
    */
    string[] substitutions;
}