module yarn.vm.state;
import yarn.stack;
import google.protobuf;
import yarn.value;
import std.array;
import std.traits;
import std.exception;
import std.format;
import std.conv;

package(yarn.vm) struct YarnState {
private:
    Stack!YarnValue stack;

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
        Create a state from a save state
    */
    this(VMSaveState saveState) {
        this.currentNode = saveState.activeNode;
        this.programCounter = saveState.progc;
        foreach(stackValue; saveState.stack) {
            this.stack.push(stackValue.get!YarnValue);
        }
    }

    /**
        Creates a save state from the current state

        STUB: This needs to be implemented
    */
    VMSaveState saveState() {
        // TODO: Create a save state
        VMSaveState s;
        return s;
    }

    /**
        Push a value to the stack
    */
    void pushValue(T)(T value) {
        static if (is(T == Value)) {
            stack.push(value);
        } else {
            stack.push(YarnValue!T(value));
        }
    }

    /**
        Pop value off the stack
    */
    YarnValue popValue() {
        return stack.pop();
    }

    /**
        Peek at the top value of the stack
    */
    YarnValue peekValue() {
        return stack.peek();
    }

    /**
        Clears the stack
    */
    void clearStack() {
        stack.clear();
    }

    void reset() {
        this.programCounter = 0;
        this.clearStack();
        this.currentNode = "";
    }
}

/**
    Save state of VM
*/
struct VMSaveState {

    /**
        Loads a save state from an array

        NOTE: Read from disk with std.file.read
    */
    static VMSaveState load(ubyte[] data) {
        return fromProtobuf!VMSaveState(data);
    }

    /**
        Saves a save state to an array

        NOTE: Write to disk with std.file.write
    */
    ubyte[] save() {
        return toProtobuf(this).array;
    }

    /**
        Active node
    */
    @Proto(1) string activeNode;

    /**
        Program counter
    */
    @Proto(2) int progc;

    /**
        Values of the stack
    */
    @Proto(3) VMStackValue[] stack = protoDefaultValue!(VMStackValue[]);
}

/**
    YarnValue on the VM stack
*/
struct VMStackValue {

    /**
        Type of the operand
    */
    enum ValueType
    {
        Undefined = 0,
        Number = 1,
        String = 2,
        Boolean = 3,

        stringValue = String,
        numberValue = Number,
        boolValue = Boolean,
    }

    /**
        Type of the operand
    */
    ValueType _type = ValueType.Undefined;

    /**
        Union of operand values
    */
    @Oneof("_type")
    union {

        /// string value
        @Proto(2) string _stringValue = protoDefaultValue!string;

        /// numeric value
        @Proto(1) float _numberValue;

        /// bool value
        @Proto(3) bool _boolValue;
    }

    this(YarnValue value) {
        switch(value.typeOf()) {

            case YarnType.Number:
                _type = ValueType.Number;
                _numberValue = value.get!float;
                break;

            case YarnType.String:
                _type = ValueType.String;
                _stringValue = value.get!string;
                break;

            case YarnType.Bool:
                _type = ValueType.Boolean;
                _boolValue = value.get!bool;
                break;

            default:

                _type = ValueType.Undefined;
                break;
        } 
    }

    /**
        Creates a string operand
    */
    this(string value) {
        _type = ValueType.String;
        _stringValue = value;
    }

    /**
        Creates a boolean operand
    */
    this(bool value) {
        _type = ValueType.Boolean;
        _boolValue = value;
    }

    /**
        Creates a numeric operand
    */
    this(T)(T value) if (isNumeric!T) {
        _type = ValueType.Number;
        _numberValue = cast(float)value;
    }

    /**
        Gets the type of the operand
    */
    @property ValueType type() { return _type; }
    
    /**
        Gets the value of this operand
    */
    T get(T)() {
        static if (isSomeString!T) {

            enforce(_type == ValueType.String, "Can not get string from %s operand".format(_type.text));
            static if (is(T : string)) {
                return _stringValue;
            } else static if (is(T : wstring)) {
                return _stringValue.toUTF16;
            } else {
                return _stringValue.toUTF32;
            }

        } else static if(is(T == bool)) {

            enforce(_type == ValueType.Boolean, "Can not get bool from %s operand".format(_type.text));
            return _boolValue;

        } else static if(isNumeric!T) {

            enforce(_type == ValueType.Number, "Can not get bool from %s operand".format(_type.text));
            return cast(T)_numberValue;

        } else static if(is(T == YarnValue)) {
            
            // Gets the appropriate Yarn type from this type
            switch(_type) {
                case ValueType.Number: return YarnValue(get!float);
                case ValueType.String: return YarnValue(get!string);
                case ValueType.Boolean: return YarnValue(get!bool);
                default: return YarnValue.undefined();
            }

        } else static assert(0, "Invalid operand type conversion");
    }
}
