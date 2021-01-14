module yarn.vm;
import yarn.value;
import yarn.bytecode;
import yarn.vm.state;
import yarn.dialogue;

package(yarn) enum TokenType {
    Whitespace,
    Indent,
    Dedent,
    EndOfLine,
    EndOfInput,

    Number, // Numeric values
    String, // Strings
    TagMarker, // #
    BeginCommand, // <<
    EndCommand, // >>

    Variable, // $foo

    ShortcutOption, // ->

    OptionStart,
    OptionDelimit,
    OptionEnd,

    If,
    ElseIf,
    Else,
    EndIf,
    Set,

    True,
    False,

    Null,

    LeftParen,
    RightParen,

    Comma,

    EqualTo,
    GreaterThan,
    GreaterThanOrEqualTo,
    LessThan,
    LessThanOrEqualTo,
    NotEqualTo,

    Or,
    And,
    Xor,
    Not,

    EqualToOrAssign, // Depending on context this can be assignment or equality operator
    UnaryMinus,

    Add,
    Minus,
    Multiply,
    Divide,
    Modulo,

    AddAsign,
    MinusAssign,
    MultiplyAssign,
    DivideAssign,

    Comment,
    Identifier,
    Text
}

/**
    The execution state of a YarnSpinner VM
*/
enum ExecutionState {
    /**
        Execution is stopped
    */
    Stopped,

    /**
        VM is waiting on an option to be selected
    */
    WaitingOnOptionSelection,

    /**
        VM is waiting for green light to continue the dialogue
    */
    WaitingForContinue,

    /**
        VM is currently delivering content
    */
    DeliveringContent,

    /**
        VM is running.
    */
    Running
}

/**
    A YarnSpinner VM
*/
class YarnVM {
private:
    YarnState state;
    YarnDialogue dialogue;

public:
    
    /**
        Dialogue to execute
    */
    this(YarnDialogue dialogue) {
        this.dialogue = dialogue;
    }

    /**
        Runs the next instruction
    */
    void runNext() {
        
    }
}