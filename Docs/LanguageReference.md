## Language reference

### Comments
___

* Single line comment:

```
    // This is a single line comment

```
* Multiline comment:

```
    /* This
        is
        a
        multiline
        comment */

```


### Basic types
___

* **Int**: signed integer number 
* **Real**: signed real number
* **Bool**: boolean (true/false)
* **String**: character string

### Variable
___

#### Declaration

* **var** \<identifier\> **: \<Type\>**
```
var name: String
var age: Int
var height: Real
var isHappy: Bool
```

#### Declaration & definition

* **var** \<identifier\> **: \<Type\> =** \<expression\>
```
var name: String = "Bob"
var age: Int =  20
var height: Real = 1.90 
var isHappy: Bool == true
```

#### Type inferrence:

When value is defined, type is optional. If omitted, variable type will be inferred from the expression type.

* **var** \<identifier\> [**: \<Type\>**] **=** \<expression\>
```
var name = "Bob"
var age =  20
var height = 1.90 
var isHappy = true
```

#### Nil reference:

* A variable is a container holding a reference to a basic type value or an instance of a class. If mutable, a variable can be undefined while being declared. In that particular case, a variable references a nil content.

* Accessing a nil reference leads to a undefined variable error at runtime.

* For variable susceptible of referencing a nil content during its lifetime, one should test this variable before accessing its content.

```
var name: String		// name declared but not defined

if name == nil {
	// name is not defined!
}
```

* A defined variable can be relieved from referencing its content.

```
var name = "Bob"

if name != nil {
	// That's my Bob!
}

name = nil

if name == nil {
	// No Bob anymore, sob...
}

```

### Constant
___

* **const** \<identifier\> [**: \<Type\>**] **=** \<expression\>

Value expression is required for constant declaration
```
const name = "Bob"
const age =  20
const height = 1.90 
const isHappy = true
```

### Control flow statements
___

#### If-else statement
___

**if** \<conditional expression\> {
    \<statements\>
}  **else** {
    \<statements\>
}

```
if name == "Bob" {
    // This is Bob
}

if name == "Bob" {
    // This is Bob
} else {
    // This is not Bob
}

if name == "Bob" {
    // This is Bob
} else if name == "John" {
    // Oh, this is John!
} else {
    // Unknown dude...
}
```

#### For loop statement
___

**for** \<identifier\> **in** \<start value expression\> **to** \<end value expression\> [**step** \<step value expression\>] {
    \<statements\>
}

Step is optional and default to 1.

```
for i in 0 to 5 {
    // loop five times with i € [0, 1, 2, 3, 4]
}

for i in 0 to 10 step 2 {
    // loop five times with i € [0, 2, 4, 6, 8]
}

for i in 10 to 0 step -2 {
    // loop five times with i € [10, 8, 6, 4, 2]
}

```

#### While loop statement
___

**while** \<conditional expression\> {
    \<statements\>
}

```
var count = 0

while count < 5 {
    count = count - 1
    // Loop five times
}

```

### Function
___

#### Function declaration
___

**func** \<identifier\>**(**\<params\>**)** **->** \<Type\> {
    \<statements\>
}

* named parameter:

```
func add(a: Int, b: Int) -> Int {
    return a + b
}

const c = add(a: 1, b: 2)

```

* anonymous parameter:

```
func add(#a: Int, #b: Int) -> Int {
    return a + b
}

const c = add(1, 2)
```

* **nil** return:

```
func getNameForBadgeId(#badgeId: Int) -> String {

	if badgeId == 0 {
		return "Bob"

	} else if badgeId == 1 {
		return "Bill"
	}

	return nil
}

const name = getNameForBadgeId(2)

if name == nil {
	// Unknown dude!
}

```

### Class

* static members,
    * static properties are shared by instances
* instance members,
    * instance property accessed with self keyword in instance methods,
* initializers,
    * initializers are functions named "init"
* inheritance,
* polymorphism

```
/*
    Superclass
*/
class Entity {

    static var counterId = 0

    var uniqueId: Int

    func init() {
        counterId = counterId + 1
        self.uniqueId = counterId
    }
}

/*
    Subclass
*/
class Player: Entity {

    var name: String
    
    func init(name: String) {
        super.init()
        self.name = name
    }

    func getDescription() -> String {
        return "[" + Sys.string(self.uniqueId) + "] - " + self.name
    }

}
```

### Native module: import & content acces

**import** \<module name\>

```
import Sys // Sytem module import

Sys.print("Hello world!")   // print function call
```

A module can declare & define :
* variables,
* functions,
* classes.


