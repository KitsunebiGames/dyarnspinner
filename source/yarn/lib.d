module yarn.lib;
import yarn.value;
import std.traits;
import std.exception;
import std.format;

private string buildDelegateType(int args) {
    string o = "YarnValue delegate(";
    if (args == 0) return o ~ ")";
    if (args == 1) return o ~ "YarnValue)";
    
    foreach(i; 0..args) {
        if (i < args-1) {
            o ~= "YarnValue, ";
        } else {
            o ~= "YarnValue)";
        }
    }
    return o;
}

/**
    A library
*/
class Library {
private:
    struct ProtoDelegate {

        // Pointer to delegate
        YarnType delegate() ptr;

        /*
            NOTE
            D has no generic "delegate type"
            Therefore we store each delegate pointer as a void
            pointer and cast them when we call them

            This is very unsafe to do but we have no other choice
        */
        int args;

        /**
            Gets whether a call is valid
        */
        bool isCallValid(int argCount) {
            return args == argCount;
        }

    }

    ProtoDelegate[string] delegates;

public:

    /**
        Registers a delegate

        NOTE: Delegates can only take Values as parameters
        Delegates HAS to return a YarnValue, you can return
        YarnValue.undefined if you have nothing useful to return.
    */
    @trusted
    void register(T)(string name, T dg) if (isDelegate!T) {
        
        // Some compile time checks
        static foreach(arg; Parameters!T) {
            static assert(is(typeof(arg) == YarnValue), "Delegates can only take YarnValue arguments!");
        }
        static assert(is(ReturnType!T == YarnValue), "Delegates have to return a YarnValue, return YarnValue.undefined if you don't want to return anything.");
        
        // Get arg count and store it with the delegate
        int argCount = Parameters!T.length;
        delegates[name] = ProtoDelegate(
            cast(YarnType delegate())dg,
            argCount
        );
    }

    /**
        Gets whether the specificed delegate is in the library
    */
    bool has(string name) {
        return (name in delegates) !is null;
    }

    /**
        Removes delegate from library if it exists
    */
    void deregister(string name) {
        if (has(name)) delegates.remove(name);
    }

    /**
        Imports delegates from an other library
    */
    void importLibrary(Library other) {
        foreach(name, otherDelegate; other.delegates) {
            delegates[name] = otherDelegate;
        }
    }

    /**
        Calls a function from the library
    */
    @trusted
    YarnValue call(Args...)(string name, Args args) {
        enforce(name in delegates, "Delegate %s not found in library".format(name));
        enforce(args.length == delegates[name].args, "Argument count mismatch!");
        
        // Compile time check to make sure arg types are compatible
        static foreach(arg; Args) {
            static assert(is(typeof(arg) == YarnValue), "Delegates can only take YarnValue arguments!");
        }

        alias dgType = mixin(buildDelegateType(args.length));
        return (cast(dgType)delegates[name].ptr)(args);
    }
    
}

@("Library functionality")
unittest {
    Library terribleLib = new Library();
    terribleLib.register("Test", delegate() { return YarnValue(42); });

    assert(terribleLib.call("Test").get!float == 42, "Did not get expected result");
}

/**
    Implementation of the YarnSpinner standard library
*/
class StandardLibrary : Library {
    this() {
        this.register("Add", delegate(YarnValue rhs, YarnValue lhs) {
            return rhs + lhs;
        });

        this.register("Minus", delegate(YarnValue rhs, YarnValue lhs){
            return rhs - lhs;
        });

        this.register("UnaryMinus", delegate(YarnValue rhs){
            return -rhs;
        });

        this.register("Divide", delegate(YarnValue rhs, YarnValue lhs){
            return rhs / lhs;
        });

        this.register("Multiply", delegate(YarnValue rhs, YarnValue lhs){
            return rhs * lhs;
        });

        this.register("Modulo", delegate(YarnValue rhs, YarnValue lhs){
            return rhs % lhs;
        });

        this.register("EqualTo", delegate(YarnValue rhs, YarnValue lhs){
            return rhs == lhs;
        });

        this.register("NotEqualTo", delegate(YarnValue rhs, YarnValue lhs){
            return rhs != lhs;
        });

        this.register("GreaterThan", delegate(YarnValue rhs, YarnValue lhs){
            return rhs > lhs;
        });

        this.register("GreaterThanOrEqualTo", delegate(YarnValue rhs, YarnValue lhs){
            return rhs >= lhs;
        });

        this.register("LessThan", delegate(YarnValue rhs, YarnValue lhs){
            return rhs < lhs;
        });

        this.register("LessThanOrEqualTo", delegate(YarnValue rhs, YarnValue lhs){
            return rhs <= lhs;
        });

        this.register("And", delegate(YarnValue rhs, YarnValue lhs){
            return Value(rhs.get!bool && lhs.get!bool);
        });

        this.register("Or", delegate(YarnValue rhs, YarnValue lhs){
            return Value(rhs.get!bool || lhs.get!bool);
        });

        this.register("Xor", delegate(YarnValue rhs, YarnValue lhs){
            return Value(rhs.get!bool ^ lhs.get!bool);
        });

        this.register("Not", delegate(YarnValue rhs){
            return Value(!rhs.get!bool);
        });

        this.register("string", delegate(YarnValue rhs){
            return Value(rhs.get!string);
        });

        this.register("number", delegate(YarnValue rhs){
            return Value(rhs.get!float);
        });

        this.register("bool", delegate(YarnValue rhs){
            return Value(rhs.get!bool);
        });
    }
}