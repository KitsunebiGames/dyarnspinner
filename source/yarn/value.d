module yarn.value;
import std.traits;
import std.utf : toUTF8;
import std.exception : enforce;
import std.format : format;
import std.conv : text;

/**
    YarnSpinner value types
*/
enum YarnType : ubyte {
    
    /**
        Undefined value
    */
    Undefined,

    /**
        Numeric value
    */
    Number,

    /**
        UTF-8 string value
    */
    String,

    /**
        Boolean value
    */
    Bool,
}

/**
    A YarnSpinner value
*/
struct Value {
private:
    YarnType type;

    /*
        Backing values as a union
    */
    union {
        ubyte[4] underlyingData;
        float num_;
        string str_;
        bool bool_;
    }

public:

    /**
        Gets the type of this value
    */
    YarnType typeOf() {
        return type;
    }

    /**
        Makes a value copy
    */
    this(Value value) {
        if (value.type == YarnType.String) {
            this.str_ = value.str_.dup;
        } else {
            this.underlyingData[] = value.underlyingData[];
        }
    }

    /**
        Constructs a value from a boolean
    */
    this(T)(T value) if (is(T == bool)) {
        // NOTE: Do not move this constructor
        // booleans count as numeric values so if this isn't first
        // the boolean value would be copied to the float value instead!

        this.bool_ = value;
    }

    /**
        Constructs a value from a numeric value
    */
    this(T)(T value) if (isNumeric!T) {
        num_ = cast(float)value;
    }

    /**
        Constructs a value from any type of string

        Strings that aren't UTF-8 will be auto converted.
    */
    this(T)(T value) if(isSomeString!T) {
        static if (is(T == string)) {
            str_ = value;
        } else {
            str_ = value.toUTF8;
        }
    }

    /**
        Compare values
    */
    int cmp(Value value) {

        // We can't compare different types meaningfully
        enforce(type == value.type, "Cannot compare values of differing types %s and %s".format(type.text, value.type.text));

        // TODO: do the comparison
        switch(type) {
            default: assert(0);
        }
    }
    
    /**
        Gets (and converts if possible and needed) the internal value of the Value
    */
    T get(T)() {
        static if (is(T == Value)) {
            return this;
        } static if (isSomeString!T) {

            // Get string conversion of type
            switch(type) {
                case YarnType.Number:
                    return this.num_.text;
                
                case YarnType.String:
                    return this.str_;
                
                case YarnType.Bool:
                    return this.bool_.text;
                
                case YarnType.Undefined:
                    return "undefined";

                default: assert(0);
            }
        } else static if (is(T == bool)) {

            switch(type) {
                case YarnType.Bool:
                    return this.bool_;
                
                case YarnType.Number:
                    return cast(bool)this.num_;
                
                default: throw new Exception("Could not convert type %s to bool".format(type.text));
            }

        } else static if (isNumeric!T) {

            switch(type) {
                case YarnType.Bool:
                    return cast(T)this.bool_;
                
                case YarnType.Number:

                    // NOTE: We cast to T since we don't know what
                    // numeric type we're getting
                    // D does not auto cast numeric types!
                    return cast(T)this.num_;
                
                default: throw new Exception("Could not convert type %s to %s".format(type.text, T.stringof));
            }

        } else {
            static assert(0, "Unknown value type %s".format(T.stringof));
        }
    }

    /**
        Allows comparing values for equality
    */
    bool opEquals(R)(const R other) const if (is(R == Value))
    {
        enforce(type == other.type, "Could not convert type %s to %s".format(type.text, other.type.text));

        switch (type) {
            case YarnType.Number:
                return num_ == other.num_;
            
            case YarnType.String:
                return str_ == other.str_;

            case YarnType.Bool:
                return bool_ == other.bool_;
            
            default: throw new Exception("Unknown value type %s".format(type.text));
        }
    }

    /**
        Allows comparing values
    */
    int opCmp(Value value) const {
        switch (type) {
            case YarnType.Number:
                
                // Compare numeric types
                if (num_ < value.num_) return -1;
                else if (num_ > value.num_) return 1;
                return 0;
            
            case YarnType.String:
                immutable(size_t) thisHash = toHash();
                immutable(size_t) valueHash = value.toHash();
                
                // Compare strings
                // NOTE for now this is not done in the same way as C#!
                // This sorts by how they would be ordered in a 
                // associative array/dictionary
                if (thisHash < valueHash) return -1;
                else if (thisHash > valueHash) return 1;
                return 0;

            case YarnType.Bool:
                
                // Compare boolean types 
                // (this doesn't make much sense but we gotta do it anyways
                // just in case)
                if (bool_ < value.bool_) return -1;
                else if (bool_ > value.bool_) return 1;
                return 0;
            
            default: throw new Exception("Unknown value type %s".format(type.text));
        }
    }

    /**
        Gets this value instance's hash
    */
    @trusted
    size_t toHash()
    {
        switch (type) {
            case YarnType.Number:
                return typeid(num_).getHash(&num_);
            
            case YarnType.String:
                return typeid(str_).getHash(&str_);

            case YarnType.Bool:
                return typeid(bool_).getHash(&bool_);
            
            default: throw new Exception("Can't get hash code for value of type %s".format(type.text));
        }
    }

    /**
        Gets this value instance as a string
    */
    string toString() {
        return "[type=%s, value=%s]".format(type, get!string);
    }
}