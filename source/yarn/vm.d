module yarn.vm;
import yarn.value;
import yarn.stack;

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

package(yarn) struct YarnState {
private:
    Stack!Value stack;

public:
    /**
        Name of the current node
    */
    string currentNode;

    /**
        Program/instruction counter
    */
    int programCounter;

    /**
        Push a value to the stack
    */
    void pushValue(T)(T value) {
        static if (is(T == Value)) {
            stack.push(value);
        } else {
            stack.push(Value!T(value));
        }
    }

    /**
        Pop value off the stack
    */
    Value popValue() {
        return stack.pop();
    }

    /**
        Peek at the top value of the stack
    */
    Value peekValue() {
        return stack.peek();
    }

    /**
        Clears the stack
    */
    void clearStack() {
        stack.clear();
    }
}

/**
    The execution state of a VM
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

class YarnVM {
private:
    YarnState state;

public:

}