%i used if else syntax because it's easier to read and understand
%in an example (X > 0 -> writeln('X is positive'); writeln('X is not positive')).
%the first part of the example is the condition
%the second part is the true part
%the third part is the false part
% -> is the then keyword
% ; is the else keyword
%you can do several operations in the true and false parts

%create_register(Size, Register)
%create_register creates a list of zeros with the size 'Size'
%i'll use the created list for saving the values of the registers
create_register(0, []):-!.
create_register(Size, Register):- NewSize is Size - 1, create_register(NewSize, NewRegister), append(NewRegister, [0], Register). 

%read_register(Register, Index, Value)
%read_register returns the value at 'Index' in the 'Register'
%Index is the index of the value in the register
%Value is the value at the index 'Index' in the register
%i'll use this predicate to get the value of a register
read_register([H|_], 0, H):-!.
read_register([_|T], Index, Value):- NewIndex is Index - 1, read_register(T, NewIndex, Value).

%change_register(Register, Index, Value, NewRegister)
%change_register changes the value at 'Index' in the 'Register' to 'Value' and returns the new register
%Index is the index of the value in the register
%Value is the value to be set at the index 'Index' in the register
%NewRegister is the new register after changing the value at 'Index' to 'Value'
%i'll use this predicate to change the value of a register
change_register([_|T], 0, Value, [Value|T]):-!.
change_register([H|T], Index, Value, [H|NewT]):- NewIndex is Index - 1, change_register(T, NewIndex, Value, NewT).

%lines(Lines) -> 'Lines' is the list of lines in the file
%I'll use this predicate to get the list of lines in the file into a variable
%I'll use this variable to get the line at a specific index
lines(LineList) :- 
    read_file('program.txt', LineList).

%read_file(FileName, Lines) -> 'Lines' is the list of lines in the file
%I'll use this predicate to read the lines in the file and store them in a list
read_file(FileName, Lines) :- 
    open(FileName, read, Stream),       % Open the file
    process_lines(Stream, Lines),      % Process the lines
    close(Stream).                     % Close the file

%base case: at the end of the file
process_lines(Stream, []) :- 
    at_end_of_stream(Stream), 
    !.

%process_lines(Stream, Lines) -> 'Lines' is the list of lines in the file
%I'll use this predicate to process the lines in the file and store them in a list
process_lines(Stream, [Line | Rest]) :- 
    read_line_to_string(Stream, Line), % Read the current line as a string
    writeln(Line),                     % Print the line
    process_lines(Stream, Rest).      % Process the rest of the lines

%read_line(Index, Line) -> 'Line' is the line at 'Index' in the file
%I'll use this predicate to get the line at a specific index
read_line(Index, Line, Lines):- read_lines(Lines, Index, Line).
read_lines([H|_], 0, H):-!.
read_lines([_|T], Index, Line):- NewIndex is Index - 1, read_lines(T, NewIndex, Line).

%operating_system(Register, LineIndex) -> 'Register' is the register after executing the instruction at 'LineIndex'
%I'll use this predicate to execute the instructions in the file
%LineIndex is the current index of the line in the file
%Register is the register that contains the values of the registers

%base case: for using halt
operating_system(_, -1, _):-true,!.

%base case: for the first call
%i'll use this predicate to start the operating system
%the first call predicate will start the operating system with an empty register list and the first lie index 0
operating_system([], 0, []):-
    create_register(32, Register),
    lines(Lines),
    operating_system(Register, 0, Lines).  

%recursive calls
%this part will be called recursively for every line until the halt instruction is called
%or the end of the file is reached
%if the halt instruction is called, the predicate will print the register values and stop with the line index -1
%if the halt called predicate will and with a true result
%if the end of the file is reached, the predicate will stop by giving false as the result

%the predicate will read the line at the current index
%then it will split the line into the instruction and the arguments
%then it will execute the instruction after checking the instruction type
%the instruction type will be checked by comparing the instruction with the available instructions
%the program first checks if the line is the halt instruction
%because the halt instruction doesn't have any arguments so the line is not splitable
%if it's not the halt instruction, the program will split the line into the instruction and the arguments and continue the execution
operating_system(Register, LineIndex, Lines):-
    read_line(LineIndex, Line, Lines),

    (Line = "halt" -> 
        halt(Register, _),!
    ;

        %split the line into the instruction and the arguments
        %split the arguments into a list of arguments
        %i need to put arguments in [] because arguments are a list of strings
        %and i want to put them in a list of strings
        %i need to split the arguments into a list because the number of arguments is not fixed
        split_string(Line, " ", " ", [Instruction|[Arguments]]),    %i can take the first element and second element of the list by using [Instruction|Arguments],
        split_string(Arguments, ",", "", ArgumentsList),            %but arguments must be in a list to split them again

        %check the instruction type and execute the instruction
        %if the instruction is not one of the available instructions, the program will print 'Invalid instruction!'
        %if the registers are changed, the new register and the new line index will be passed to the next call
        %if only the line index is changed, the new line index will be passed to the next call
        %not every instruction is changing the registers so i called the operating_system predicate differently for every instruction
        (Instruction = "put" ->
            put(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex),
            operating_system(NewRegister, NewLineIndex, Lines)
        
        ;Instruction = "prn" ->
            prn(Register, LineIndex, ArgumentsList, NewLineIndex),
            operating_system(Register, NewLineIndex, Lines)
        
        ;Instruction = "add" ->
            add(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex),
            operating_system(NewRegister, NewLineIndex, Lines)
        
        ;Instruction = "jmpe" ->
            jmpe(Register, LineIndex, ArgumentsList, NewLineIndex),
            operating_system(Register, NewLineIndex, Lines)
        
        ;Instruction = "jmpu" ->
            jmpu(ArgumentsList, NewLineIndex),
            operating_system(Register, NewLineIndex, Lines)
        ;
            writeln('Invalid instruction!')
        )
    ),
    
    !.

%instructions

%halt(Register, NewLineIndex)
%halt stops the operating system and prints the register values and sets the new line index to -1
halt(Register, NewLineIndex):-
    writeln('Register: '), writeln(Register),
    NewLineIndex is -1.

%put(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex)
%put changes the value of a register to a new value
put(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex):-
    [Arg1, Arg2] = ArgumentsList,     %i can take the ArgumentsList elements by using [Arg1, Arg2] because ArgumentsList has only two elements
    number_string(Value, Arg1),      %number_string converts a string to a number
    split_string(Arg2, "r", "r", [RegStr]),     %i can reach the register number by splitting the string by 'r', it gives me a one-element list
    number_string(Reg, RegStr),
    change_register(Register, Reg, Value, NewRegister),
    NewLineIndex is LineIndex + 1.
%put first takes the value and the register number from the arguments as strings
%then it converts the value to a number
%then it changes the value of the register to the new value by calling the change_register predicate
%then it increases the line index by 1

%prn(Register, LineIndex, ArgumentsList, NewLineIndex)
%prn prints the value of a register
prn(Register, LineIndex, ArgumentsList, NewLineIndex):-
    [Arg1] = ArgumentsList,     %i took all arguments with this method because i know the length of the list after splitting
    split_string(Arg1, "r", "r", [RegStr]),     
    number_string(Reg, RegStr),
    read_register(Register, Reg, Value),
    writeln(Value),
    NewLineIndex is LineIndex + 1.
%prn first takes the register number from the arguments as a string
%then it converts the register number to a number
%then it reads the value of the register by calling the read_register predicate
%then it prints the value
%then it increases the line index by 1


%add(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex)
%add adds the values of two registers and saves the result in the second register
add(Register, LineIndex, ArgumentsList, NewRegister, NewLineIndex):-
    [Arg1, Arg2] = ArgumentsList,
    split_string(Arg1, "r", "r", [Reg1String]),     
    number_string(Reg1, Reg1String),  
    split_string(Arg2, "r", "r", [Reg2String]),     
    number_string(Reg2, Reg2String),
    read_register(Register, Reg1, Value1),
    read_register(Register, Reg2, Value2),
    ResultValue is Value1 + Value2,
    change_register(Register, Reg2, ResultValue, NewRegister),
    NewLineIndex is LineIndex + 1.
%add first takes the register numbers from the arguments as strings
%then it converts the register numbers to numbers
%then it reads the values of the registers by calling the read_register predicate
%then it adds the values
%then it changes the value of the second register to the result value by calling the change_register predicate
%then it increases the line index by 1

%jmpe(Register, LineIndex, ArgumentsList, NewLineIndex)
%jmpe jumps to a new line if the values of two registers are equal
%if the values are not equal, it goes to the next line
jmpe(Register, LineIndex, ArgumentsList, NewLineIndex):-
    [Arg1, Arg2, Arg3] = ArgumentsList,
    split_string(Arg1, "r", "r", [Reg1String]),     
    number_string(Reg1, Reg1String),      
    split_string(Arg2, "r", "r", [Reg2String]),    
    number_string(Reg2, Reg2String),
    number_string(NewLineIndexValue, Arg3),
    read_register(Register, Reg1, Value1),
    read_register(Register, Reg2, Value2),
    (Value1 \= Value2 -> NewLineIndex is LineIndex + 1; NewLineIndex is NewLineIndexValue).    
%jmpe first takes the register numbers and the new line index from the arguments as strings
%then it converts the register numbers and the new line index to numbers
%then it reads the values of the registers by calling the read_register predicate
%then it checks if the values are equal
%if the values are equal, it sets the new line index to the new line index value
%if the values are not equal, it sets the new line index to the next line index

%jmpu(ArgumentsList, NewLineIndex)
%jmpu jumps to a new line
%it doesn't check any condition
jmpu(ArgumentsList, NewLineIndex):-
    [Arg1] = ArgumentsList,    %Arg1 is the first element of ArgumentsList because ArgumentsList has only one element
    split_string(Arg1, "r", "r", [NewLineIndexString]),     
    number_string(NewLineIndex, NewLineIndexString).
%jmpu first takes the new line index from the arguments as a string
%then it converts the new line index to a number
%and sets the new line index to the new line index value while calling the predicate