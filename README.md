
# MIPS Emulator written in Prolog ![Prolog](https://img.shields.io/badge/Prolog-SWI--Prolog-%40f040?logo=swi-prolog) 
**A Register-Based Language Interpreter in Prolog**  
*A low-level emulator for an imaginary MIPS-like programming language demonstrating register operations and program flow control.*

## Architecture 
The emulator features:  
- **32-register memory** (initialized to zeros) using list-based storage
- **Program counter** tracking current line index
- **Dynamic program loading** loads the program to the memory to save I/O proccessing time 
- **Register operations**:  
  - `put` - Store immediate values  
  - `add` - Arithmetic operations  
  - `prn` - Print register values  
- **Flow control**:  
  - `jmpu` - Unconditional jump  
  - `jmpe` - Conditional jump (register equality check)  
  - `halt` - Program termination with register dump

---

## Supported Commands  
| Command | Description | 
|---------|--------|-------------|
| `put X,Y` | Store value X in register Y (0-31) |
| `add X,Y` | Add registers X and Y, store result in Y |
| `prn X` | Print value of register X |
| `jmpe X,Y,Z` | Jump to line Z if register X == Y |
| `jmpu X` | Unconditional jump to line X |
| `halt` | Terminate program and show registers |

---

## Installation  
1. Install [SWI-Prolog](https://www.swi-prolog.org/download/stable)
2. Clone repository:  
   ```bash
   git clone https://github.com/e-Aurora/prolog_os.git
   cd simlan-emulator

## Usage
1. Create program file with the name  `program.txt`
2. Run `swipl`:
   ```bash
    swipl main.pl
    ```
3. Start emulating with:
   ```prolog
   1 ?- operating_system([], 0, []).
   ```
        
    
    

----------

## Example Program (`for`  loop from 0 to 9)

- `program.txt`: 
```prolog
put 1,5     % Store 1 in register 5
put 0,1     % Store 0 in register 1
put 10,2    % Store 10 in register 2
jmpe 1,2,7  % Jump to line 7 if register1 == register2
prn 1       % Print register1
add 5,1     % Add register5 + register1, store in register1
jmpu 3      % Jump back to line 3
prn 1       % Print register1 
halt
   ```

- **Execution Output**:  
```prolog
0
1
2
3
4
5
6
7
8
9
Register: 
[0,10,10,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
```
## Contributing

This implementation demonstrates core concept and its not designed to be something fancy but stilll, feel free to clone or contribute to the project.
