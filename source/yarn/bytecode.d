/*
    Based on auto generated protobuf bindings

    !! This will manually be maintained !!
*/
module yarn.bytecode;

import google.protobuf;

/**
    ProtoC version used to originally generate this file
*/
enum protocVersion = 3_014_000;


/**
    A program
*/
struct Program
{
    /**
        Load program
    */
    static Program load(ubyte[] buff) {
        return fromProtobuf!Program(buff);
    }

    /**
        Save program
    */
    ubyte[] save() {
        return toProtobuf(this);
    }

    /**
        Name of the program
    */
    @Proto(1) string name = protoDefaultValue!string;

    /**
        Map of nodes in this program
    */
    @Proto(2) Node[string] nodes = protoDefaultValue!(Node[string]);
    
    /**
        Initial values for this program
    */
    @Proto(3) Operand[string] initialValues = protoDefaultValue!(Operand[string]);
}

/**
    A node
*/
struct Node
{
    /**
        Name of the node
    */
    @Proto(1) string name = protoDefaultValue!string;

    /**
        Instructions stored in this node
    */
    @Proto(2) Instruction[] instructions = protoDefaultValue!(Instruction[]);

    /**
        Labels in this node
    */
    @Proto(3) int[string] labels = protoDefaultValue!(int[string]);

    /**
        Tags in this node
    */
    @Proto(4) string[] tags = protoDefaultValue!(string[]);

    /**
        Source text string ID
    */
    @Proto(5) string sourceTextStringID = protoDefaultValue!string;
}

/**
    OPCodes
*/
enum OpCode : ubyte
{
    JUMP_TO = 0,
    JUMP = 1,
    RUN_LINE = 2,
    RUN_COMMAND = 3,
    ADD_OPTION = 4,
    SHOW_OPTIONS = 5,
    PUSH_STRING = 6,
    PUSH_FLOAT = 7,
    PUSH_BOOL = 8,
    PUSH_NULL = 9,
    JUMP_IF_FALSE = 10,
    POP = 11,
    CALL_FUNC = 12,
    PUSH_VARIABLE = 13,
    STORE_VARIABLE = 14,
    STOP = 15,
    RUN_NODE = 16,
}

/**
    An instruction
*/
struct Instruction
{
    /**
        The OPCode for the instruction
    */
    @Proto(1) OpCode opcode = protoDefaultValue!OpCode;

    /**
        The instruction's operands
    */
    @Proto(2) Operand[] operands = protoDefaultValue!(Operand[]);
}

/**
    An operand
*/
struct Operand
{
    /**
        Value case
    */
    enum ValueCase
    {
        valueNotSet = 0,
        stringValue = 1,
        boolValue = 2,
        floatValue = 3,
    }
    ValueCase _valueCase = ValueCase.valueNotSet;
    @property ValueCase valueCase() { return _valueCase; }
    void clearValue() { _valueCase = ValueCase.valueNotSet; }
    @Oneof("_valueCase") union
    {
        @Proto(1) string _stringValue = protoDefaultValue!string; mixin(oneofAccessors!_stringValue);
        @Proto(2) bool _boolValue; mixin(oneofAccessors!_boolValue);
        @Proto(3) float _floatValue; mixin(oneofAccessors!_floatValue);
    }
}
