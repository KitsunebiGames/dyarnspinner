module yarn.dialogue.varstore;
import std.traits;
import std.format;
import std.exception;

/**
    Exception to be thrown if a variable is not found in a store.
*/
class VariableNotFoundException : Exception {
    /**
        Constructor
    */
    this(string name) {
        super("%s not found in variable store".format(name));
    }
}

/**
    Exception to be thrown if the types of the variables don't match
*/
class VariableTypeMismatchException : Exception {

    /**
        Constructor
    */
    this(string name, string typeName) {
        super("%s is not a %s".format(name, typeName));
    }
}

/**
    A place you store variables
*/
interface VariableStorage {

    /**
        Sets a string value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, string value);

    /**
        Sets a number value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, float value);

    /**
        Sets a boolean value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, bool value);

    /**
        Gets whether a variable is present in the store
    */
    bool has(string name);
    
    /**
        Gets a string value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    string getString(string name);

    /**
        Gets a number value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    float getNumber(string name);

    /**
        Gets a bool value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    bool getBool(string name);

    /**
        Clears the variable store
    */
    void clear();
}

/**
    Memory based variable storage
*/
class MemVariableStore : VariableStorage {
private:
    enum VType {
        String,
        Bool,
        Number
    }

    struct Variable {
        VType type;
        union {
            string str_;
            bool bool_;
            float num_;
        }

        this(string value) {
            this.type = VType.String;
            this.str_ = value;
        }

        this(bool value) {
            this.type = VType.Bool;
            this.bool_ = value;
        }

        this(float value) {
            this.type = VType.Number;
            this.num_ = value;
        }
    }

    Variable[string] variables;

public:

    /**
        Sets a string value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, string value) {
        enforce(name !in variables || variables[name].type == VType.String, new VariableTypeMismatchException(name, "string"));
        variables[name] = Variable(value);
    }

    /**
        Sets a float value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, float value) {
        enforce(name !in variables || variables[name].type == VType.Number, new VariableTypeMismatchException(name, "number"));
        variables[name] = Variable(value);
    }

    /**
        Sets a boolean value in the store

        Throws: `VariableTypeMismatchException` if types mismatch
    */
    void set(string name, bool value) {
        enforce(name !in variables || variables[name].type == VType.Bool, new VariableTypeMismatchException(name, "bool"));
        variables[name] = Variable(value);
    }

    /**
        Gets whether a variable is present in the store
    */
    bool has(string name) {
        return (name in variables) != null;
    }
    
    /**
        Gets a string value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    string getString(string name) {
        
        enforce(has(name), new VariableNotFoundException(name));
        enforce(variables[name].type == VType.String, new VariableTypeMismatchException(name, "string"));
        
        return variables[name].str_;
    }

    /**
        Gets a number value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    float getNumber(string name) {
        
        enforce(has(name), new VariableNotFoundException(name));
        enforce(variables[name].type == VType.Number, new VariableTypeMismatchException(name, "number"));
        
        return variables[name].num_;
    }

    /**
        Gets a bool value by name

        Throws: `VariableNotFoundException` when variable not found
        Throws: `VariableTypeMismatchException` when variable does not match output type
    */
    bool getBool(string name) {
        
        enforce(has(name), new VariableNotFoundException(name));
        enforce(variables[name].type == VType.Bool, new VariableTypeMismatchException(name, "bool"));
        
        return variables[name].bool_;
    }


    /**
        Clears the variable store
    */
    void clear() {
        variables.clear();
    }
}

@("Memory Variable Storage")
unittest {
    MemVariableStore store = new MemVariableStore();
    store.set("test", 42.0);
    store.set("test2", true),
    store.set("test3", "Hello, world!");

    assert(store.getNumber("test") == 42.0, "Expected 42.0 from test!");
    assert(store.getBool("test2") == true, "Expected true from test2!");
    assert(store.getString("test3") == "Hello, world!", "Expected 'Hello, world!' from test3!");
}