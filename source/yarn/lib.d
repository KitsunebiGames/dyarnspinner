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
        Delegates can return void, void returns will be rewritten
        to return YarnValue.undefined
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