module yarn.stack;

/**
    A basic stack
*/
struct Stack(T) {
private:
    T[] values;

public:

    /**
        Pushes a value to the stack
    */
    void push(T value) {
        values ~= value;
    }

    /**
        Pops value off stack
    */
    T pop() {
        scope(exit) values.length--;
        return values[$-1];
    }

    /**
        Peeks the top value of the stack
    */
    T peek() {
        return values[$-1];
    }

    /**
        Clears the stack
    */
    void clear() {
        values.length = 0;
    }
}