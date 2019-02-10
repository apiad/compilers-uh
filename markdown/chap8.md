---
previous-chapter: chap7
---

# El lenguaje HULK




En este capítulo definimos el lenguaje **HULK** (_Havana University Language for Kompilers_), un lenguaje de programación didáctico diseñado para este curso.
A grandes razgos, **HULK** es un lenguaje orientado a objetos, con herencia simple, polimorfismo, y encapsulamiento a nivel de clases.
Además en **HULK** es posible definir funciones globales fuera del contexto de cualquier clase.
También es posible definir _una única expresión global_ que constituye el punto de entrada al programa.

La mayoría de las construcciones sintácticas en **HULK** son expresiones, incluyendo las instrucciones condicionales y los ciclos.
**HULK** es un lenguaje estáticamente tipado con inferencia de tipos opcional, lo que significa que algunas (o todas) las partes de un programa pueden ser anotadas con tipos, y el compilador verificará la consistencia de todas las operaciones.

## Un lenguaje didáctico e incremental

El lenguaje **HULK** ha sido diseñado para ser utilizado como mecanismo de aprendizaje y evaluación de un curso de Compilación. Por tal motivo, ciertas decisiones de diseño de lenguaje responden más a cuestiones didácticas que a cuestiones teóricas o pragmáticas. Un ejemplo ilustrativo es la inclusión de un solo tipo numérico básico. En la práctica los lenguajes de programación cuentan con varios tipos numéricos (`int`, `float`, `double`, `decimal`) para cubrir el amplio rango de _trade-off_ entre eficiencia y expresividad. Sin embargo, desde el punto de vista didáctico, ya es suficiente complejidad el tener que lidiar con un tipo numérico, y la inclusión de otros no aporta nada nuevo desde nuestro punto de vista.

Otra decisión importante es el tipado estático con inferencia de tipos, que será explicado más adelante en detalle. La motivación detrás de esta característica es permitir a los estudiantes implementar primero un evaluador para el lenguaje, y luego preocuparse por la verificación de tipos. Así mismo, la decisión de tener expresiones globales, funciones globales, y clases, responde a la necesidad de introducir los diversos elementos del lenguaje poco a poco. Al tener expresiones globales, es posible implementar un intérprete de expresiones sin necesidad de resolver los problemas de contexto. Luego se pueden introducir las funciones y finalmente las características orientadas a objetos. De esta forma los estudiantes pueden ir aprendiendo sobre la marcha a medida que adicionan características al lenguaje, siempre teniendo un subconjunto válido del lenguaje implementado.

El lenguaje **HULK** realmente es un conjunto de lenguajes de programación muy relacionados. Lo que llamaremos **HULK** _básico_ consiste en un subconjunto mínimo al que se le definen un conjunto extenso de características adicionales. El lenguaje _básico_ contiene expresiones, funciones globales y un sistema unificado de tipos con herencia simple. Las extensión incluyen desde soporte para _arrays_, hasta delegados, inferencia de tipos, iteradores, entre otras características. Cada una de estas extensiones se ha diseñado para que sea compatible con el resto de **HULK**, incluyendo el resto de la extensiones. Debe ser posible, una vez implementado un compilador básico, adicionar cualquier subconjunto de estas extensiones.

Este diseño ha sido concebido para permitir el uso de **HULK** en un amplio rango de niveles de aprendizaje. Como lenguaje de expresiones y funciones, es útil para cursos introductorios sobre _parsing_ y técnicas básicas de compilación. La orientación a objetos introduce todo un universo de complejidades semánticas; sin embargo, el sistema de tipos de **HULK** es suficientemente sencillo como para ilustrar los problemas más comunes en la verificación semántica de tipos. Por su parte, cada una de las extensiones introduce problemáticas avanzadas e interesantes. Los _arrays_ introducen problemas relacionados con el manejo de memoria, mientras que las funciones anónimas y los iteradores son fundamentalmente problemas de transpilación y generación de código. La inferencia de tipos y la verificación de _null-safety_ es todo un ejercicio en inferencia lógica, que puede servir en cursos avanzados. La idea es que cada curso defina sus objetivos de interés, y pueda utilizar un subconjunto apropiado de **HULK** para ilustrar y evaluarlos.

## HULK básico

En esta sección definimos el subconjunto mínimo de **HULK**, que llamaremos _básico_. Este subconjunto consiste en un lenguaje de expresiones y funciones globales con tipado estático, y un sistema unificado de tipos con herencia simple.

El programa más sencillo en **HULK** es, por supuesto, _Hola Mundo_:

```hulk
print("Hola Mundo");
```

En **HULK** un programa puede ser simplemente una expresión (terminada en `;`), en este caso, la invocación de una función global llamada `print` (que se presentará más adelante). La cadena de texto `"Hola Mundo"` es un literal del tipo `String`, definido en la biblioteca estándar, que se comporta de la forma convencional en la mayoría de los lenguajes de programación más populares: es inmutable, y codificado en UTF8.

### Tipos básicos

Además de los literales de cadena, en **HULK** hay 2 tipos básicos adicionales: `Number`, que representa valores numéricos y `Boolean` que representa valores de verdad (con los literales usuales `True` y `False`).

El tipo `Number` representa tanto números enteros, como números con coma flotante. La semántica concreta dependerá de la arquitectura. Siempre que sea posible se representará con un valor entero de 64 (o 32) bits, o en su defecto, un valor flotante de 64 (o 32) bits, según permita la arquitectura. Las constantes numéricas se pueden escribir como `42` (valor entero) o `3.14` (valor flotante).

**HULK** tiene una jerarquía de tipos unificada, cuya raíz es el tipo `Object`. Todos los demás tipos definidos en el lenguaje son concretos.

### Expresiones elementales

En **HULK** se definen todas las expresiones usuales, en orden decreciente de precedencia:

- Operaciones lógicas entre expresiones de tipo `Boolean`: `a & b`, `a | b`, `!a`, siempre evaluadas con cortocircuito.
- Operaciones aritméticas entre expresiones de tipo `Number`: `-a`, `a % b`, `a * b`, `a / b`, `a + b`, `a - b`, con la precedencia y asociatividad usuales, y agrupamiento mediante paréntesis. El resultado es de tipo `Number` siempre.
- Comparaciones entre expresiones de tipo `Number`: `a < b`, `a > b`, `a <= b`, `a >= b`, con menor precedencia que las aritméticas, y sin asociatividad.
- Comparaciones de igualdad entre expresiones de cualquier tipo: `a == b`, `a != b`, con la semántica de igualdad por valor entre expresiones de tipo `Number`, `String` o `Boolean`, e igualdad por referencia en todos los demás tipos. Se permite comparar expresiones de cualquier tipo, y si sus tipos no son compatibles (e.j, `"Hola Mundo" == 42`) el resultado será `False`.
- El operador infijo `@` de concatenación entre `String`: `"Hello "@"World" == "Hello World"`. Para los casos donde es conveniente, el operador `@@` adiciona un espacio intermedio: `"Hello" @@ "World"` es igual a `"Hello World"`.

En el espacio de nombres global siempre se encontrarán además las funciones `print`, `read` y `parse`, además de una serie de funciones elementales matemáticas, tales como `exp`, `pow`, `log`, `sqrt`, `min`, `max` y `random`.

El valor `Null` es un valor especial que puede tener cualquier tipo, excepto `Number` y `Boolean`. `Null` representa la no existencia de una instancia asociada a la variable (_l-value_ en caso general) correspondiente, y cualquier operación que se intente sobre un valor `Null` lanzará un error en tiempo de ejecución, excepto `==`, que siempre devuelve `False`, y `!=` (que siempre devuelve `True`, incluso entre expresiones ambas iguales a `Null`). El literal `Null` es una expresión de tipo `Object` con valor igual a `Null`.

### Variables

Las variables en **HULK** se introducen con una expresión `let`:

```hulk
let <var>[:<type>]=<init> in <body>
```

La semántica de la expresión `let` consiste en que se crea un nuevo ámbito donde se define la variable `<var>` cuyo valor es el resultado de evaluar `<init>`, y se evalua en este ámbito la expresión `<body>`.

```hulk
let msg:String="Hola Mundo" in print(msg)
```

Como se verá, indicar el tipo de una variable al declararla es opcional. Los detalles de la inferencia y verificación de tipos se darán más adelante.

Existe una variante extendida de la expresión `let` en la que se permite introducir más de una variable:

```hulk
let x=1, y=2, z=3 in x+(y*z)
```

Esta variante es semánticamente idéntica a:

```hulk
let x=1 in let y=2 in let z=3 in x+(y*z)
```

El cuerpo de una expresión `let` puede ser también una _lista de expresiones_, encerradas entre `{` y `}` y separadas por `;`, siendo el valor final de la expresión `let` el valor de la última expresión de la lista.

```hulk
let x=0 in {
    print(x==0); # Imprime True
    print(x==1); # Imprime False
}
```

Una _lista de expresiones_ **no es** una expresión en sí, es decir, no puede ser usada donde quiera que se requiera una expresión. Solamente se puede usar en el cuerpo de algunas construcciones sintácticas que se irán introduciendo poco a poco.
Es decir, el siguiente ejemplo **no es válido**:

```hulk
let x={0;1} in print(x) # NO es válido
```

Como tampoco lo es:

```hulk
{1;2} + {3;4;let x=5 in 5} # NO es válido
```

Ni ningún otro ejemplo similar donde se use un bloque de expresiones como una expresión, excepto en los contextos donde se indique explícitamente más adelante.

### Asignación

La asignación en **HULK** se realiza con el operador `:=`, y solamente es posible asignar a una variable que exista en el contexto actual:

```hulk
let color="green" in {
    print(color);    # Imprime green
    color:="blue";
    print(color);    # Imprime blue
}
```

La asignación devuelve el valor asignado, y asocia a la derecha. Tiene menor prioridad que todas las expresiones aritméticas:

```hulk
let x=0, y=0 in {
    y := x := 5 + 5;
    print(x); # 10
    print(y); # 10
    y := (x := 5) + 1;
    print(x); # 5
    print(y); # 6
}
```

### Espacios en blanco e indentación

En **HULK** los espacios en blanco no son significativos, ni tampoco la indentación. La sintaxis del lenguaje permite indicar explícitamente, cuando es necesario, el ámbito de un bloque de código. El ejemplo anterior es equivalente a:

```hulk
let x=1 in
let y=2 in
let z=3 in
    x + (y * z)
```

O cualquier otra forma de indentar que sea conveniente.

### Identificadores

Los identificadores empiezan con un caracter del alfabeto ASCII (o `_`) y pueden opcionalmente contener números. Ejemplos de identificadores válidos son:

```hulk
x
name
CamelCase
smallCamelCase
snake_case
_ugly_case
hunter42
```

### Funciones

**HULK** soporta funciones globales con 2 formas sintácticas muy similares. Una función se define por un nombre, argumentos con tipo opcional, un tipo de retorno también opcional, y el cuerpo.
Todas las funciones globales deben ser definidas **antes** de la expresión global que define el _cuerpo_ del programa.

En la primera forma sintáctica, que llamamos "compacta", el cuerpo de la función debe ser exactamente una expresión (terminada en `;`):

```hulk
function isEven(n:Number):Boolean -> n % 2 == 0;
```

En la segunda forma, que llamaremos "extendida", el cuerpo de una función puede ser una _lista de expresiones_ separadas por `;`. El valor de retorno de la función es el valor de la última expresión de la lista. En esta notación **no se incluye** un `;` al final de la declaración de la función.

```hulk
function f(a:Number, b:Number, c:Number):Number {
    a := b + c;
    b := c + a;
    c := a + b;
}

let a:Number=1, b:Number=2, c:Number=3 in print(f(a,b,c)); # Imprime 13
```

En **HULK** no existe una instrucción ni palabra reservada con semántica similar a `return`. Todas las funciones tienen un tipo de retorno y devuelven siempre un valor, aunque este valor puede ser `Null`.

### Condicionales

Las expresiones condicionales se introducen con la sintaxis siguiente:

```hulk
if (<cond>) <body> [elif (<cond>) <body>]* [else <body>]?
```

Es decir, una parte `if`, seguida de cero o más partes `elif` y finalmente una parte `else` opcional.
Una expresión `if` devuelve el valor de la parte que se ejecuta. Si no se ejecuta ninguna (no hay else), devolverá `Null`. Si esto invalida la consistencia de tipos (como se verá más adelante), será necesario definir una parte `else` para garantizar al compilador/intérprete el tipo esperado.

```hulk
function fib(n:Number):Number -> if (n <= 1) 1 else fib(n-1) + fib(n-2);
```

Al igual que con las expresiones `let` y las funciones, cada cuerpo puede ser o bien una expresión o una lista de expresiones. Si no hay parte `else` y ninguna rama condicional se ejecuta, se devuelve `Null`.

### Ciclos

La expresión de ciclo más general en **HULK** es un ciclo `while` con la semántica común:

```hulk
while (<cond>) <body>
```

Como ya es usual, `<body>` puede ser una expresión o una lista de expresiones.

```hulk
function gcd(a:Number, b:Number):Number {
    let q:Number = a%b in while (q != 0) {
        a := b;
        b := q;
        q := a%b;
    };

    b;
}
```

El valor de retorno de la expresión `while` es el valor de retorno del cuerpo la última vez que se ejecutó el ciclo, o `Null` en caso de que nunca se ejecute. Si es necesario, se puede adicionar una cláusula `else` para definir el valor cuando no haya ejecución.

Con esta expresión, la manera más sencilla de implementar un contador (el común ciclo `for`) es:

```hulk
let i:Number=0 in while (i < n) {
    # ...
    i := i+1;
}
```

### Lidiando con valores `Null`

Si una variable tiene valor `Null`, se lanzará un error en tiempo de ejecución si se intenta cualquier operación sobre ella (expecto `==` y `!=`). **No** es posible evitar esto comprobando explícitamente:

```hulk
if (x != Null) x.value else 0
```

Ya que el operador `!=` devuelve `True` siempre que uno de los dos valores sea `Null`. Es decir `Null != Null == True`. Para estos casos, **HULK** introduce una sintaxis específica:

```hulk
with (<expr> as <id>) <expr> [else <expr>]
```

Por ejemplo, en este caso:

```hulk
with (x as o) o.value else 0
```

La ventaja de esta sintaxis es que dentro del cuerpo de `with` se garantiza que `<id>` nunca será `Null`. Además, la variable `<id>` es **una referencia de de solo lectura** a la expresión `<expr>`, y el compilador impide que se le hagan asiganciones. De modo que es posible garantizar que este código nunca lanzará excepción en tiempo de ejecución por accesos o usos de `<id>`.

### Prioridad de las expresiones

Las expresiones `let`, `if`, `while`, `case` y `with` tienen **menor prioridad** que todas las expresiones elementales (aritméticas, etc.), y siempre asocian a la derecha. Por lo tanto, para poder usar una de estas expresiones dentro de una expresión aritmética, por ejemplo, se deben encerrar entre paréntesis.

Por ejemplo, el siguiente es un caso común:

```hulk
let x:Number=5 in let y:Number=8 in x+y
```

Que es equivalente a:

```hulk
let x:Number=5 in (let y:Number=8 in (x+y))
```

Sin embargo, el siguiente caso **no es válido**, pues no se puede sumar con `let` sin parentizar (`let` tiene menor prioridad):

```hulk
let x:Number=5 in x + let y:Number=8 in y # NO es valido
```

La forma correcta es:

```hulk
let x:Number=5 in x + (let y:Number=8 in y)
```

Por último, el bloque `else` siempre asocia al `if` (o `while`) más cercano.
Es decir, la siguiente expresión:

```hulk
if (a) if (b) y else z
```

Es no ambigua, y equivalente a:

```hulk
if (a) (if (b) y else z)
```

Por otro lado, la invocación de funciones, instanciación, el acceso a miembros (e.g., `self.x`) y el indizado en _arrays_ tienen mayor prioridad que todas las expresiones elementales aritméticas.

### Orientación a objetos en HULK

Además de las características estructuradas y funcionales presentadas, el lenguaje **HULK** soporta el concepto de _tipo_, implementado mediante _clases_. Todos los valores creados en un programa de **HULK** tienen un tipo asociado, y este tipo no puede ser cambiado en tiempo de ejecución. Por esto decimos que **HULK** es un lenguaje con tipado estático.

Aparte de los tipos nativos presentados (`Number`, `Boolean` y `String`), es posible definir nuevos tipos mediante la sintaxis:

```hulk
class <name>[<args>] [is <base>[<init>]] {
    [<attribute>;]*
    [<method>]*
}
```

Todas las clases deben ser definidas **antes** que todas las funciones globales, pero esto _no impide_ que dentro del cuerpo de un método en una clase (explicado más adelante), se llame a una función global, o se use una clase definida posteriormente.

Todas las clases en **HULK** heredan de una clase base. En caso de no especificarse, esta clase será `Object`, que es la raíz de la jerarquía de tipos en **HULK**. Los tipos básicos `Number`, `String` y `Boolean` también heredan de `Object`, pero a diferencia del resto de las clases, **no es permitido heredar de los tipos básicos**. Esto se restringe ya que los tipos básicos generalmente se implementan de forma especial para garantizar una mayor eficiencia, y por lo tanto deben ser tratados con cuidado en la jerarquía de tipos.

#### Atributos y métodos

Dentro del cuerpo de una clase se pueden definir dos tipos de elementos: atributos y métodos.
Los atributos se definen con un nombre, un tipo opcional, y una expresión de inicializacion _obligatoria_ (terminado en `;`):

```hulk
class Point {
    x:Number = 0;
    y:Number = 0;
}
```

Todos los atributos en **HULK** son **privados**, es decir, no está permitido acceder a ellos desde otras clases, ni desde clases herederas.

Los métodos se definen con una sintaxis muy similar a las funciones globales. La única diferencia es que en el contexto de un método siempre existe una variable implícita `self` que referencia a la instancia en cuestión. Es obligatorio acceder a los atributos y métodos de una clase a través de `self`, **nunca** usando su nombre directamente.

```hulk
class Point {
    x:Number = 0;
    y:Number = 0;

    translate(x,y) -> Point(self.x + x, self.y + y);
    length() -> sqrt(self.x * self.x + self.y * self.y);
}
```

Todos los atributos deben ser definidos **antes** que todos los métodos, y sus expresiones de inicialización no pueden utilizar métodos de la propia clase, ni valores de otros atributos (aunque sí pueden utilizar funciones globales). Todos los métodos en **HULK** son **públicos** y **virtuales**, redefinibles por los herederos. Además, todos los métodos son de instancia, no existen métodos estáticos, y no existe sintaxis para invocar a un método que no sea a través de una referencia a una instancia de una clase.

#### Instanciando clases

Para obtener una instancia de una clase en **HULK** se utiliza el nombre de la clase como si fuera un método, precedido la palabra clave `new`.

```hulk
let p = new Point() in print(p.translate(5,3).length());
```

Si se desea inicializar los atributos de la clase, se pueden definir _argumentos de clase_, y su valor usarse en la inicialización de los atributos:

```hulk
class Point(x:Number, y:Number) {
    x:Number = x;
    y:Number = y;
    # ...
}
```

Una vez definidos argumentos de clase, es obligatorio proporcionar su valor al construir la clase:

```hulk
let p:Point = new Point(5,3) in print(p.length());
```

#### Redefinición y polimorfismo

En **HULK** todas las invocaciones a métodos de una instancia son polimórficas. Todos los métodos en **HULK** son virtuales, y pueden ser redefinidos, siempre que se mantenga la misma signatura (cantidad y tipo de los parámetros y retorno). La redefinición se realiza implícitamente si se define en una clase heredera un método con el mismo nombre de una clase ancestro.

```hulk
class Person(name:String) {
    name:String=name;
    greet() -> "Hello" @@ self.name;
}

class Colleague is Person {
    greet() -> "Hi" @@ self.name;
}
```

Al heredar de una clase se heredan por defecto las definiciones de los argumentos de clase. Por lo tanto, al instanciar una clase heredera, es obligatorio proporcionar los valores de los argumentos:

```hulk
let p:Person = new Colleague("Pete") in print(p.greet()); # Hi Pete
```

Sin embargo, **no está permitido** usar estos argumentos de clase implícitos en la inicialización de atributos de una clase heredera. Si es necesario usarlos, se pueden redefinir explícitamente en la clase heredera. Por otro lado, siempre que se redefinan argumentos de clase en una clase heredera, será necesario indicar explícitamente cómo se evaluan los argumentos de la clase padre en términos de los argumentos de la clase heredera:

```hulk
class Noble(title:String, who:String) is Person(title @@ who) { }

let p = new Noble("Sir", "Thomas") in print(p.greet()); # Hello Sir Thomas
```

#### Evaluando el tipo dinámico

La expresión `case` permite comparar el tipo dinámico de una expresión con una lista de tipos posibles. Su sintaxis es la siguiente:

```hulk
case <expr> of {
    [<id>:<type> -> <body> ;]+
}
```

Esta expresión compara el tipo dinámico de `<expr>` contra cada uno de los tipos `<type>`, y ejecuta el `<body>` correspondiente a la rama del ancestro más cercano:

```hulk
class A { }
class B is A { }
class C is B { }
class D is A { }

case new C() of {
    a:A -> print("A");
    b:B -> print("B"); # Se ejecuta esta rama
    d:D -> print("D");
}
```

En caso de ninguna rama ser válida en tiempo de ejecución, se lanza un error. En caso de poderse inferir el tipo de `<expr>`, se intentará validar la compatibilidad con los tipos `<type>`, y se lanzará un error semántico de existir. El cuerpo de una rama cualquiera puede ser una lista de expresiones entre `{` y `}` si fuera necesario, como sucede con las funciones.

Existe una versión compacta también de `case` cuando hay una sola rama, con la forma:

```hulk
case <expr> of <id>:<type> -> <body>
```

Esta forma puede usarse para evaluar un "downcast" en **HULK**, cuando se conoce con certeza el tipo dinámico de un objeto.

Por ejemplo, el siguiente programa lanza error semántico pues `o` es de tipo estático `Object`, explícitamente declarado, por lo que no se puede sumar.

```hulk
function dunno():Object -> 40;

let o:Object = something() in o + 2; # error semántico
```

Sin embargo, usando `case` se puede forzar al verificador de tipos a que infiera `Number` para esta expresión, lanzando error en tiempo de ejecución si realmente el tipo dinámico fuera otro.

```hulk
function dunno():Object -> 40;

let o:Object = something() in case o of y:Number -> y + 2;
```

Hasta este punto, el lenguaje **HULK** básico definido representa un reto suficientemente interesante como proyecto de un semestre en un curso estándar de compilación. A continuación se definen un conjunto de extensiones que complejizan considerablemente el lenguaje en distintas dimensiones.

## Extensiones a **HULK**

En esta sección definimos un conjunto de extensiones a **HULK**. Todas estas extensiones adicionan elementos sintácticos o semánticos al lenguaje. Todas las extensiones están diseñadas para que sean compatibles con el lenguaje **HULK** _básico_, y también compatibles entre sí. De este modo, un compilador de **HULK** puede decidir implementar cualquier subconjunto de estas extensiones.

### Extensión: Arrays

Esta extensión introduce un tipo nativo con semántica similar al _array_ de los lenguajes de programación de la familia C. Este _array_ **no crece** dinámicamente y **no es covariante** en la asignación. El _array_ es un tipo genérico que se declara con una sintaxis especial. Como es de esperar, un _array_ se indiza con una expresión de tipo `Number` y el valor del primer índice es `0`. Si el valor del índice no es entero, se lanzará un error en tiempo de ejecución, al igual que si el índice sobrepasa los límites del array. Para los efectos del sistema de tipos, todo tipo _array_ hereda directamente de `Object`, y no se puede heredar de él.
Todos los _arrays_ en **HULK** tienen semántica de enlace por referencia.

```hulk
let a:Number[] = {1, 2, 3, 4}, i:Number=0 in while (i < a.size()) {
    print(a[i]);
    i := i+1;
}
```

La forma de crear un array vacío es mediante la sintaxis:

```hulk
let x:Number[] = new Number[20] in ...
```

Todo _array_ se inicializa con el valor por defecto del tipo correspondiente, que es `0` para `Number`, `False` para `Boolean`, y `Null` para cualquier otro tipo. En **HULK** no existen _arrays_ multidimensionales, pero sí es posible crear _arrays_ de _arrays_ (_ad infinitum_):

```hulk
let x:Number[][] = new Number[][10] in ...
```

En este caso, el único _array_ que se inicializa es el más externo. Cada valor de `x[i]` se inicializa con `Null` y debe asignarse explícitamente:

```hulk
let x:Number[][] = new Number[][10], n=0:Number in while(n<x.size()) {
    x[i] := new Number[i+1];
}
```

El tipo de un _array_ complejo como el anterior sería `Number[][]`.

### Extensión: Inicialización automática de _arrays_

Cuando se instancia un _array_, es posible inicializarlo automáticamente mediante la sintaxis:

```hulk
new <type>[<length>] { <index> -> <expr> }
```

Donde `<expr>` es una expresión que devuelve el valor del i-ésimo elemento, indizado por la variable `<index>`. Por ejemplo:

```hulk
new Number[20]{ i -> 2*i+1 }
```

Es equivalente a:

```hulk
let x:Number[] = new Number[20], i:Number=0 in while (i<x.size()) {
    x[i] := 2*i+1;
    i := i+1;
    x;
}
```

La expresión de inicialización es un atajo sintáctico para no escribir un ciclo de inicialización. Por tal motivo, se comporta exactamente igual que dicho ciclo. Esta expresión crea un nuevo contexto donde se define la variable `<index>`. Este contexto es hijo del contexto donde se crea el _array_. En particular, **no tiene acceso** a la variable que referencia al propio _array_ (en caso de existir). Por ejemplo, la siguiente expresión **no** es válida:

```HUL
# NO es válido
let x:Number[] = new Number[20]{ i -> if (i<=1) 0
                                      else x[i-1] + x[i-2] }
```

Ya que cuando se ejecuta la inicialización, la variable `x` aún no se ha definido. Para poder realizar una construcción de este tipo, introduciremos el uso de la palabra clave `self`, que servirá dentro de una expresión de inicialización para referirse al propio _array_:

```hulk
# SI es válido
let x:Number[] = new Number[20]{ i -> if (i<=1) 0
                                      else self[i-1] + self[i-2] }
```

Pues es equivalente a:

```hulk
let x:Number[] = new Number[20], i:Number=0 in while (i<x.size()) {
    x[i] := if (i<=1) 0 else x[i-1] * x[i-2];
    i := i+1;
    x;
}
```

De esta forma es posible inicializar _arrays_ complejos en una sola expresión, como en el ejemplo siguiente:

```hulk
new Number[][100] { i -> new Number[100] { j -> i*j } }
```

Que es equivalente a:

```hulk
let x:Number[] = new Number[][100], i:Number=0 in while (i<x.size()) {
    x[i] := new Number[100];
    let j:Number=0 in while (j < x[i].size()) {
        x[i][j] := i * j;
        j := j+1;
    };
    i := i+1;
    x;
}
```

### Extensión: Interfaces

Esta extensión introduce el concepto de _interfaz_ en **HULK**. Una interfaz es básicamente una declaración de los métodos que debe contener un tipo:

```hulk
interface Piece {
    canMove(dx:Number, dy:Number): Boolean;
}
```

Una vez declarada una interfaz, se puede utilizar como una anotación de tipo en cualquier lugar donde se requiera un tipo en **HULK**, es decir, en una variable, parámetro, tipo de retorno, etc.

Las interfaces en **HULK** son compatibles con cualquier tipo que implemente los métodos adecuados. **No** es necesario que una clase declare explíciticamente que es compatible con una interfaz.

Por ejemplo, la siguiente clase implementa la interfaz `Piece`.

```hulk
class Bishop(x:Number, y:Number) {
    x:Number = x;
    y:Number = y;

    canMove(dx:Number, dy:Number): Boolean {
        abs(x - dx) == abs(y - dy);
    }
}
```

Para ser compatibile con una interfaz, una clase debe implementar **todos** los métodos. Cada método debe tener la misma cantidad de argumentos, aunque los nombres de los argumentos no importan. Los tipos de los argumentos son _covariantes_ en la entrada y _contravariantes_ en el retorno. Es decir, si una interfaz tiene un método:

```hulk
interface I {
    method(arg1:T1, ..., argn:Tn): Tr;
}
```

Entonces una clase puede implementarla con un método:

```hulk
class C {
    method(arg:T'1, ..., argn:T'n): T'r -> ...
}
```

Si se cumple que `T'i > Ti` y `T'r < Tr`. Es decir, recibe argumentos con tipos iguales o ancestros de los argumentos en la interfaz, y devuelve un tipo igual o descendiente.

Para el sistema de tipos, si una clase `C` implementa una interfaz `I` con estas condiciones, entonces se considera `C < I`. Por lo tanto, es posible usar como tipos de los argumentos de una interfaz a otras interfaces, mientras que las implementaciones pueden usar tipos concretos, u otras interfaces compatibles.

### Extensión: Tipos funcionales

Esta extensión permite definir _tipos_ que representan funciones, y pueden ser utilizadas como ciudadanos de primera clase dentro de la jerarquía de tipos (delegados).

Un _tipo funcional_ se declara con la sintaxis siguiente:

```hulk
(<type1>, <type2>, ...) -> <return>
```

Por ejemplo, para la función siguiente:

```hulk
function fib(n:Number): Number -> if (n<=1) 1 else fib(n-1) + fib(n-2);
```

Una anotación de su tipo sería:

```hulk
(Number) -> Number
```

Estas anotaciones sirven para declarar tipos funcionales que pueden ser usados entonces como argumentos o valores de retorno en otras funciones, o almacenados en variables:

```hulk
let f:(Number)->Number = fib in ...
```

Nótese como se puede utilizar entonces el identificador `fib` (nombre de la función) como referencia a una instancia de un tipo funcional `(Number)->Number`.
Una vez obtenida una referencia a un tipo funcional, se puede utilizar exactamente como cualquier otro valoren **HULK**, es decir, ser pasado como parámetro a un método, almacenado en un _array_ (si se implementa esta extensión), o _invocado_.

Para invocar un tipo funcional se usa la misma sintaxis que para invocar directamente una función global:

```hulk
let f:(Number)->Number = fib in print(f(6));
```

De la misma forma se pueden definir funciones con argumentos de tipos funcionales. Por ejemplo, si se implementan _arrays_, la siguiente función es posible:

```hulk
function map(a:Number[], f:(Number)->Number):Number[] {
    new Number[array.size()] { i -> f(a[i]) };
}
```

Desde el punto de vista semántico, el tipo funcional anterior se comporta _como si_ existiera una interfaz como la siguiente, y una clase respectiva que implementara la interfaz:

```hulk
interface NumberNumberFunction {
    invoke(arg1:Number): Number;
}

class FibFunction {
    invoke(arg1:Number): Number -> fib(arg1);
}
```

Y el uso o invocación de este tipo funcional pudiera verse _como si_ se empleara de la siguiente forma:

```hulk
let f:NumberNumberFunction = new FibFunction() in print(f.invoke(6));
```

Con la particularidad de que, por supuesto, estas _supuestas_ clases e interfaces no son accesibles por el código usuario directamente, sino solo a través de la sintaxis definida anteriormente.

Los tipos funcionales son invariantes tanto en los tipos de los argumentos como en el tipo de retorno.

### Extensión: Funciones anónimas (expresiones _lambda_)

Esta extensión introduce funciones anónimas, también conocidas como expresiones _lambda_. Una función anónima es una expresión cuyo tipo es un funcional. Sintácticamente se declaran muy parecido a las funciones globales, excepto que no es necesario indicar un nombre. Semánticamente, las funciones anónimas son expresiones, por lo que pueden ser usadas donde se requiera un funcional.
Por ejemplo, en una declaración de variables:

```hulk
let f:(Number)->Number = function (x:Number):Number -> x * 2 in print(f(3));
```

O directamente como parámetro a una función o método:

```hulk
function map(a:Number[], f:(Number)->Number) {
    new Number[]{ i -> f(a[i]) };
}

print(map(new Number[20]{ i -> i }, function (x:Number):Number -> x+2));
```

Al igual que las funciones globales, el cuerpo puede ser una expresión simple o un bloque de expresiones.

### Extensión: Clausura funcional

Esta extensión adiciona a las expresiones _lambda_ un mecanismo de clausura que permite capturar variables existentes en el contexto de la función automáticamente.

```hulk
let x:Number=3, f:(Number)->Number = function (y:Number):Number -> y * x in
    print(f(5)); # 15
```

La captura se realiza **por copia** siempre, por lo que las variables capturadas **no mantienen su valor** luego de ejecutada la función.
Sin embargo, la variable capturada visible dentro de la función anónima **si mantiente su valor** de una ejecución a la siguiente:

```hulk
let x:Number=1 in
    let f:(Number)->Number = function (y:Number):Number {
        x := x + 1;
        y * x;
    } in {
        print(f(3)); # Imprime 6
        print(f(5)); # Imprime 15
        print(x);    # Imprime 1
    };
```

Semánticamente, la clausura se comporta como si en el momento de definir la función anónima se copiaran los valores de las variables capturadas a campos internos de una _supuesta_ clase que representa el funcional. El ejemplo anterior sería equivalente semánticamente al siguiente código:

```hulk
interface NumberNumberFunction {
    invoke(arg1:Number):Number;
}

class LambdaFunction1(x:Number) is NumberNumberFunction {
    x:Number = x;
    invoke(arg1:Number):Number {
        self.x := self.x + 1;
        y * self.x;
    }
}

let x:Number=1 in
    let f:NumberNumberFunction = LambdaFunction1(x) in {
        print(f.invoke(3)); # Imprime 6
        print(f.invoke(5)); # Imprime 15
        print(x);    # Imprime 1
    };
```

De esta forma se garantiza que el valor de `x` fuera de `f` no sea modificado, sin embargo, todas las ejecuciones de `f` comparten una misma referencia al `x` interno.

### Extensión: Funciones genéricas

Esta extensión introduce funciones globales con argumentos de tipos genéricos. Un tipo genérico se define con la sintaxis `'T` donde `T` es un identificador. Los tipos genéricos pueden usarse en tipos complejos (por ejemplo, un _array_, un tipo funcional, etc.). Una función genérica puede declarar como tipo de uno o más de sus argumentos un tipo genérico.

```hulk
function map(a:'T[], f:('T)->'R): 'R[] {
    new T'[] { i -> f(a[i]) };
}
```

Los tipos genéricos se consideran declarados en los argumentos de la función. Dentro del cuerpo de una función genérica se pueden utilizar los tipos genéricos como si fueran tipos concretos. En el momento en que se realice una invocación de la función, los tipos genéricos declarados se realizarán en un tipo concreto.

A los efectos semánticos, es como si cuando se realizara una invocación, se definiera en ese momento una versión de la función con los tipos concretos.

### Extensión: Generadores (iteradores)

Esta extensión adiciona una sintaxis para usar generadores (también llamados iteradores). Un generador es cualquier clase que implemente dos métodos: `next()` y `current()`. El método `next()` devuelve `Boolean` y su función es avanzar el iterador. El método `current()` devuelve un tipo arbitrario y retorna el elemento "actual" del generador. Por ejemplo:

```hulk
class Range(start:Number, end:Number) {
    i:Number = start;
    next():Boolean {
        self.i += 1;
        self.i <= end;
    }
    current():Number -> self.i - 1;
}
```

Cualquier clase que posea estos dos métodos puede ser usada con la siguiente sintaxis:

```hulk
for (<var>:<type> in <generator>) <expr>
```

Por ejemplo:

```hulk
for (x:Number in new Range(0,100)) print(x);
```

Esta expresión enlaza una variable `x` al valor `current()` del generador en cada iteración, y ejecuta la expresión correspondiente. Al igual que todas las expresiones con cuerpo (`let`, `while`), es posible usar una expresión simple o un bloque de expresiones.

La expresión `for` es sintácticamente equivalente a una construcción como la siguiente:

```hulk
let _iter:<generator-type>=<generator> in while (_iter.next()) {
    let <var>:<type>=_iter.current() in <expr>;
}
```

Por ejemplo, en este caso:

```hulk
let _iter:Range=new Range(0,100) in while(_iter.next()) {
    let x:Number=_iter.current() in print(x);
};
```

### Extensión: Tipos generadores

Esta extensión adiciona una familia especial de tipos, los tipos generadores, que son covariantes con cualquier clase que implemente una interfaz de generador adecuada.

Un tipo generador se declara con la sintaxis:

```hulk
<type>*
```

Donde `<type>` es un tipo cualquiera. Por ejemplo `Number*`, `Boolean*`, `Number[]*`, y por supuesto, `Number**` y cualquier otra composición. Los tipos generadores pueden usarse como tipo estático de una variable o parámetro donde se espere un generador, y son compatibles (covariantes) con cualquier tipo (clase) que cumpla la interfaz de generador correspondiente.

Por ejemplo, la siguiente clase cumple con la interfaz de un generador de tipo `Number*`:

```hulk
class Range(start:Number, end:Number) {
    i:Number = start;
    next():Boolean {
        self.i += 1;
        self.i <= end;
    }
    current():Number -> self.i - 1;
}
```

Por lo tanto, puede ser usado en el siguiente fragmento:

```hulk
function sum(items:Number*) {
    let s:Number=0 in for(x:Number in items) s:=s+x;
}

print(sum(new Range(1,100))); # 4950
```

De esta forma es posible escribir funciones "genéricas" con respecto a los tipos generadores, es decir, donde no sea necesario conocer de antemano el tipo concreto que implementa la interfaz de generador. Además, es posible escribir funciones que devuelvan tipos generadores y de esta forma simplificar la sintaxis:

```hulk
function range(start:Number, end:Number):Number* -> new Range(start, end);

for (x in range(1,100)) print(x);
```

Las variables y parámetros declarados con un tipo generador pueden ser usados en una expresión `for`, pero además, es posible interpretarlos como una _supuesta_ clase con métodos `next()` y `current()`, ya que la implementación "real" es esta. Por lo tanto, el siguiente código es válido:

```hulk
let items:Number* = range(1,100) in items.next();
```

Aún cuando no sea posible acceder estáticamente al tipo concreto que implementa el generador, es sabido que tendrá al menos los métodos `next()` y `current()` con la semántica esperada, por lo que es posible implementar funciones importantes tales como:

```hulk
function empty(items:Number*) -> !items.next();
```

O patrones como este:

```hulk
class Take(items:Number*, k:Number) {
    items:Number* = items;
    k:Number = k;

    next():Boolean -> if (k>0) self.items.next() else False;
    current():Number -> self.items.current();
}

function take(items:Number*, k:Number):Number* -> Take(items,k);
```

### Extensión: Expresiones generadoras

Esta extensión añade una sintaxis para definir expresiones generadoras, es decir, expresiones que pueden usarse con la sintaxis `for`, cuyo tipo estático será un tipo generador.

Una expresión generadora tiene la forma:

```hulk
{ <expr> | <var> in <loop-expr> }
```

Donde `<expr>` es una expresión que involucra la variable `<var>`, y `<var>` captura el valor de retorno de `<loop-expr>`, que debe ser una de las siguientes expresiones:

- Un tipo generador.
- Un ciclo `while`.
- Un ciclo `for`.
- Una expresión `let` cuyo cuerpo es una de las anteriores.

Los siguientes ejemplos son todos válidos:

- Tipo generador explícito:
    ```hulk
    { 2*x | x in new Range(1, 100) }
    ```

- Función que devuelve un tipo generador:
    ```hulk
    { x+1 | x in range(1, 100) }
    ```

- Ciclo `while` (infinito en este caso):
    ```hulk
    { exp(x) | x in while (True) random() }
    ```

- Ciclo `for` (anidado en este caso):
    ```hulk
    { x | x in for (i in range(1, 100))
               for (j in range(1, 100))
               i*j }
    ```

- Expresión `let` con un ciclo en el cuerpo:
    ```hulk
    { x | x in let i:Number=0 in while (i < 100) {
                   i := i + 1;
                   random(); }}
    ```

La variable `<var>` tendrá sucesivamente todos los valores "producidos" para la expresión de iteración.

Un expresión generadora es semánticamente equivalente a una clase que implemente el tipo generador correspondiente (al tipo estático de `x`), y cuya implementación de los métodos `next()` y `current()` corresponda al comportamiento definido. El mecanismo exacto para lograr esta transpilación es demasiado complejo para formalizarlo en esta sección, pero daremos un ejemplo ilustrativo.

De manera general, el cuerpo del método `next()` corresponderá a la implementación de `<loop-expr>`, desenrrollada de forma tal que cada paso se ejecute en un llamado correspondiente, mientras que el cuerpo de `current()` corresponderá a la expresión `<expr>` de retorno del generador.

Por ejemplo, para la siguiente expresión:

```hulk
{ exp(x) | x in let i:Number=0 in while (i < 100) {
                    i := i + 1;
                    random(); }}
```

Una posible implementación será el siguiente tipo generador:

```hulk
class Generator {
    x:Number = 0; # Variable que almacenará current
    i:Number = 0; # Inicialización de la expresión let

    next():Boolean {
        if (!(self.i < 100)) False
        else {
            self.i := self.i + 1;
            self.x := random();
            True;
        };
    }

    current():Number -> exp(self.x);
}
```

En el caso de que el cuerpo de una expresión generadora sea un generador directamente, o un ciclo `for`, existen formas de convertirlo a un patrón `let-while` básico. De esta forma todas las expresiones generadoras pueden reescribirse como **HULK** básico.

Al igual que en las funciones anónimas, las variables externas referenciadas dentro de la clausura de una expresión generadora se capturan **por copia**. Por lo tanto, su modificación dentro de una expresión generadora no se percibe fuera de la expresión:

```hulk
let i:Number = 0,
    items:Number* = { x | x in while (i<10) i := i+1 }
in {
    for (x:Number in items) print(x); # Imprime 1 ... 10
    print(i);                         # Imprime 0
}
```

### Extensión: Inicialización de _arrays_ con generadores

Esta extensión permite inicializar un _array_ a partir de un generador, mediante la sintaxis:

```hulk
new <array-type>[<generator>]
```

Por ejemplo, usando directamente un tipo generador:

```hulk
new Number[range(1, 100)]
```

O una expresión generadora (en caso de implementarse):

```hulk
new Number[{ 2*x | x in range(1, 100) }]
```

Nótese que esta sintaxis **no es** equivalente a la inicialización automática de _arrays_. En primer lugar no es necesario indicar el tamaño del _array_, pues se ejecutará el generador para saber el tamaño real necesario. Por otro lado, no es posible referirse al propio _array_ que se está inicializando en la expresión generadora, ya que el _array_ conceptualmente no existe hasta que no se haya terminado de generar toda la expresión.

### Extensión: Inferencia de tipos

Esta extensión introduce inferencia de tipos en **HULK**, de modo que no sea necesario especificar todas las anotaciones de tipos, si son inferibles dado el contexto. Formalizar precisamente en qué casos es posible inferir o no el tipo de una declaración es un problema complicado, y no lo intentaremos en este punto. Por el contrario, presentaremos algunos ejemplos donde es posible inferir el tipo, y otros ejemplos donde el mecanismo de inferencia de tipos de **HULK** no será capaz de deducirlo.

El caso más sencillo, es cuando en una declaración de variable se omite el tipo. En este caso, el tipo se infiere de la expresión de inicialización:

```hulk
let x=3+2 in case x of y:Number -> print("Ok);
```

De igual forma sucede con los atributos de una clase, cuando pueden ser inferidos por el tipo de la expresión de inicialización:

```hulk
class Point(x:Number, y:Number) {
    x=x;
    y=y;
    # ...
}
```

Un caso más complejo es cuando se deja sin especificar el tipo de retorno de una función, pero puede ser inferido a partir de su cuerpo:

```hulk
function succ(n:Number) -> n + 1;
```

En el caso anterior, es fácil inferir el tipo de retorno de `succ` porque la expresión retorna exactamente el mismo tipo que un argumento. En estos casos, es posible incluso no especificar el tipo del argumento, ya que el operador `+` solo está definido para `Number`:

```hulk
function succ(n) -> n + 1;
```

Sin embargo, a veces no es posible inferir el tipo de un argumento a partir de su uso _dentro del cuerpo_ de una función. En el caso siguiente, aunque sabemos que el tipo del argumento `p` debe ser `Point` para aceptar la invocación, _no se garantiza_ que el mecanismo de inferencia de tipos deba deducirlo (ya que en el futuro puede haber otras clases con un método `translate`). Dependiendo de la implementación, en estos casos se permite lanzar error semántico indicando que no fue posible inferir el tipo del argumento `p`.

```hulk
function step(p) -> p.translate(1,1);

let p = new Point(0,0) in step(p); # Puede lanzar error semántico
```

Por último, especial complejidad acarrean las funciones recursivas:

```hulk
function fact(n) -> if (n<0) 1 else n*fact(n-1);
```

El ejemplo anterior permite inferir simultáneamente el tipo del argumento `n` y del retorno, ya que se usa el retorno de la función recursiva en una operación `+` que solo está definida para `Number`. Sin embargo, en el ejemplo siguiente:

```hulk
function ackermann(m, n) ->
    if   (m==0) n+1
    elif (n==0) ackermann(m-1, 1)
    else        ackermann(m-1, ackermann(m, n-1));
```

Como el tipo de retorno no se utiliza explícitamente en una operación matemática, no es trivial deducir que su tipo de retorno es `Number`, ya que `Object` funcionaría también como tipo de retorno. En estos casos, se desea que el mecanismo de inferencia deduzca _el tipo más concreto_ para el retorno y _el tipo más abstracto_ para los argumentos que sea posible.

Finalmente, dos funciones mutuamente recursivas:

```hulk
function f(a, b) -> is (a==1) b else g(a+1, b/2);
function g(a, b) -> if (b==1) a else f(a/2, b+1);
```

En este caso, es posible teóricamente inferir que `f` y `g` deben ambos retornar tipo `Number`, pero dada la complejidad de manejar la inferencia de tipos en más de una función a la vez, no se garantiza que sea posible deducir los tipos en este caso.

Varias de las extensiones de **HULK** introducen tipos nuevos, por ejemplo, _arrays_, tipos generadores y tipos funcionales. En caso de implementar algunas de estas extensión, la inferencia de tipos también se debe extender de forma correspondiente.

Cuando se crea un _array_, es posible inferir el tipo estático si se provee una expresión de inicialización:

```hulk
let x = new [20]{ i -> (i+1)*(i+2) } in ... # Infiere Number
```

Sin embargo, si en la expresión de inicialización se usa el propio _array_, entonces no se garantiza que sea posible inferir el tipo:

```hulk
let x = new [20]{ i -> if (i<=1) 1 else x[i-1] + x[i-2] } in ...
```

Cuando se define un tipo funcional, el tipo puede ser inferido a partir de la declaración de una función global:

```hulk
function fib(n) -> if (n <= 1) 1 else fib(n-1) + fib(n-2);

let f=fib in print(f(3)); # f infiere (Number) -> Number
```

Cuando se define una función anónima, el tipo puede ser inferido a partir de su cuerpo:

```hulk
let f = function (x) -> x % 2 == 0 in print(f(10));
```

En ocasiones, se puede inferir el tipo de un parámetro a partir del tipo de la variable donde es almacenada la función anónima:

```hulk
let f:(Person)->Boolean = function (p) -> p.name() == "John" in ...
```

En este caso hipótetico el compilador infiere `Person` para el argumento `p` gracias a la declaración de `f`, por lo que reconoce `p.name` como un método válido en esta clase.

En una expresión `for` el tipo de la variable puede ser inferido a partir del tipo del generador:

```hulk
function range(start:Number, end:Number):Number* {
    new Range(start,end);
}

for (x in range(1,100)) print(x); # x infiere Number
```

Para las expresiones generadoras, el tipo puede ser inferido a partir del tipo de la variable generada. Por ejemplo, en el siguiente caso, el tipo inferido para `x` es `Number`, pues es el tipo de retorno del ciclo `while` (función `random()`).
El tipo inferido para la expresion `exp(x) < 0` es `Boolean`.
Por lo tanto el tipo inferido para toda la expresión `Boolean*`.

```hulk
# g infiere Boolean*
let g = { exp(x) < 0 | x in let i:Number=0 in
                            while (i < 100) {
                                i := i + 1;
                                random(); }} in ...
```

### Extensión: _Null-safety_

Gracias a la existencia de la instrucción `with`, un compilador de **HULK** puede ser capaz de inferir para un programa si es seguro garantizar que no habrá errores en ejecución por variables `Null`. Es posible entonces que un compilador genere en estos casos un código más eficiente, al no tener que validar las referencias en todos los accesos y usos. En todos los casos en que no se pueda garantizar la _null-safety_, el compilador debe emitir una advertencia en tiempo de compilación (_warning_).

Opcionalmente, el compilador de **HULK** puede ejecutarse en modo **null-safe**. En este modo, las advertencias por violación de _null-safety_ se convierten en errores de compilación.

Nótese que no es estrictamente necesario usar `with` en todos los casos para garantizar la _null-safety_. Hay casos en que por el contexto es posible garantizar la seguridad.
El caso más sencillo es cuando se usan variables de tipo `Number` o `Boolean`, que por definición no pueden contener un valor `Null`.

Un caso más interesante es cuando se puede inferir por la inicialización de una variable, por ejemplo:

```hulk
let x = new Person("John Doe") in print(x.greet());
```

En este caso se puede inferir que `x` nunca será `Null` pues no existe ninguna asignación, y el valor de la expresión `new Person(...)` nunca es `Null`.

Por el contrario, si se usa un ciclo o una expresión `if` sin parte `else`, no es posible garantizar _null-safety_, incluso cuando realmente el valor de la expresión no pueda ser `Null`.

```hulk
let i=10, x=(while (i > 0) i:=i-1) in print(x);
```

Así mismo, en los argumentos de una función nunca será posible garantizar _null-safety_.

De manera general el compilador de **HULK** hará todo lo posible por inferir si cada uso es _null-safe_, incluso cuando no se introduzca una expresión `with`. En los casos en que no sea posible inferirlo, el programador siempre podrá introducir una expresión `with` para satisfacer al compilador.

### Extensión: Macros

Esta extensión introduce un sistema limitado de macros en tiempo de compilación con verificación semántica. Una función macro es similar a una función estándar (global) en sintaxis, pero se define con la palabra clave `define`:

```hulk
define dmin(x:Number, y:Number):Number -> if (x <= y) x else y;
```

La diferencia más directa radica en que las funciones macro se evalúan en tiempo de compilación, y se expanden directamente en el lugar donde se usan. Por ejemplo, para el caso anterior, si se usa de la siguiente manera:

```hulk
print(min(3,4));
```

En tiempo de compilación se sustituirá el código anterior directamente por el resultado de expandir la función macro, lo que sería equivalente a haber escrito:

```hulk
print(if (3 <= 4) 3 else 4);
```

Una diferencia adicional entre las funciones macro y las funciones estándar, es que en las funciones macro los parámetros **no se evalúan**, sino que se expanden directamente en el cuerpo del macro. Por ejemplo:

```hulk
print(min(3+2, 4+5));
```

Expande a:

```hulk
print(if ((3+2) <= (4+5)) (3+2) else (4+5));
```

Otra diferencia que se desprende directamente de esta definición, es que los parámetros de una función macro **no son _l-values_**, por lo que no es posible asignarles una expresión.

Esto cambia considerablemente el comportamiento en comparación con una función estándar global si un parámetro tiene efectos colaterales.
Por ejemplo, supongamos las siguientes declaraciones:

```hulk
function fmin(x:Number, y:Number):Number -> if (x<y) x else y;
define dmin(x:Number, y:Number):Number -> if (x<y) x else y;

function f(x:Number) {
    print(x);
    x;
}
```

Aparentemente `fmin` y `dmin` son equivalentes, sin embargo:

```hulk
fmin(f(3), f(4));
```

Imprime una vez `3` y una vez `4`, ya que los argumentos se evalúan antes de ser pasados como parámetros a `fmin`. Por el contrario:

```hulk
dmin(f(3), f(4));
```

Se expande directamente en el siguiente código:

```hulk
if (f(3) < f(4)) f(3) else f(4);
```

Por lo que `f(3)` es llamado 2 veces. Por tal motivo, las funciones macro deben usar en una instrucción `let` para expandir los argumentos una sola vez, a menos que se desee explícitamente ejecutar el efecto colateral potencial de una función más de una vez (por ejemplo, si la intención es realizar un ciclo).

Las funciones macro también **son verificadas semánticamente**, siguiendo las mismas reglas semánticas de las funciones globales, por ejemplo, con respecto a la consistencia en los tipos de los parámetros, el tipo de retorno y el cuerpo del macro. Esto garantiza que las funciones macro son seguras de utilizar en cualquier contexto donde una función estándar con los mismos tipos sería válida.

Un ejemplo más sobre las diferencias semánticas entre una función macro y una función estándar radica en que los argumentos en las funciones globales se pasan por copia. Sin embargo, como las funciones macro no son invocadas, sino expandidas **en el mismo contexto**, realmente no hay un paso de parámetros. Por tal motivo, los efectos colaterales sobre las variables del contexto donde de expande un macro funcionan de forma diferente.

Por ejemplo, si tenemos la siguiente función global:

```hulk
function repeat(x:Number, y:Number):Number {
    while (x > 0) {
        x := x - 1;
        y;
    };
}

let y:Number=0 in print(repeat(10, y:=y + 1));
```

El resultado de invocar a `repeat` es `1` pues **primero** se evalúa `y := y + 1` y luego se pasa este valor por copia a `repeat`. Sin embargo, si se define como una función macro:

```hulk
define repeat(x:Number, y:Number):Number {
    let i:Number=x in while (i > 0) {
        i := i - 1;
        y;
    };
}

let y:Number=0 in print(repeat(10, y:=y + 1));
```

En este caso la expansión de `repeat` genera un código semánticamente equivalente al siguiente:

```hulk
let y:Number=0 in print(
    let i:Number=10 in while (i > 0) {
        i := i - 1;
        y := y + 1;
    }
);
```

En este caso el valor de `y` será `10`, pues la expresión `y := y + 1` se ejecuta **todas** las iteraciones del ciclo, en **el mismo contexto** donde se expande el macro.
Este efecto simplemente no es posible en **HULK** usando solo funciones, ni siquiera con expresiones _lambda_, pues el paso de parámetros siempre es **por copia**.

Una función macro al expandirse puede generar un bloque de expresiones. Aunque en **HULK** no es permitido al usuario escribir directamente un bloque de expresiones en cualquier lugar (por ejemplo, como valor de un parámetro), esta es una restricción sintáctica, impuesta por el _parser_. Desde el punto de vista semántico los bloques de expresión se comportan como expresiones cuyo tipo y valor de retorno son los de la última expresión del bloque.

La expansión de un macro **no es** una simple sustitución léxica del cuerpo del macro en el lugar donde se invoca. Por el contrario, la expansión es sintáctica, y se realiza a nivel de AST. Esto significa que no es necesario que una definición de macro se preocupe por parentizar expresiones o poner `;` adicionales "por si acaso", pues en el momento de la expansión del macro, los elementos léxicos ya no importan.

Por otro lado, las funciones macros deben ser _higiénicas_, esto significa que **no pueden contaminar** el contexto donde se expanden con símbolos que puedan cambiar la semántica. Por este motivo, **todas las variables** declaradas dentro de un macro (ya sea en expresiones `let`, `for`, etc.) deben ser renombradas a símbolos internos que no puedan coincidir con los símbolos escritos por el programador. Si esto no se hiciera, entonces pudiera suceder que nombres de símbolos expandidos por el macro ocultaran símbolos del contexto.
Por ejemplo:

```hulk
let i:Number=0 in repeat(10, i := i + 1);
```

Generaría:

```hulk
let i:Number=0 in
    let i:Number=10 in while (i>0) {
        i := i - 1;
        i := i + 1;
    }
```

Con lo cual el ciclo no terminaría nunca.
Por este motivo realmente la sustitución debe generar un código más parecido al siguiente:

```hulk
let i:Number=0 in
    let #var0:Number=10 in while (#var0>0) {
        #var0 := #var0 - 1;
        i := i + 1;
    }
```

Donde `#var0` es un identificador generador dinámicamente que no puede ser escrito por el usuario (por restricciones del _lexer_). De esta forma se garantiza que la expansión de un macro nunca introduzca símbolos que oculten otros símbolos en el contexto donde se usen. Esta sustitución **debe hacerse automáticamente**, es decir, en la definición del macro se puede declarar un símbolo `i` que será automáticamente sustituido por `#varX` o cualquier otro convenio similar.

El proceso de expansión de un macro puede terminar en una expresión que aún contenga macros. Estos macros volverán a ser expandidos, recursivamente, hasta que no quede ningún macro por expandir. Si este proceso produce una recursión infinita (en la práctica, una cantidad elevada de expansiones), se lanzará un error en tiempo de compilación. Idealmente, si es posible detectar durante el chequeo semántico del macro la posibilidad de una expansión infinita, se debe lanzar un error o _warning_.

### Extensión: Bloques macro

Esta extensión permite invocar a las funciones macro con una sintaxis especial, donde el último parámetro puede ser definido fuera de los paréntesis de la invocación. Siguiendo con el mismo ejemplo de la sección anterior (macro `repeat`), esta extensión permitiría invocarlo de la forma:

```hulk
let y:Number=0 in repeat (10) y:=y+1;
```

O de la forma:

```hulk
let y:Number=0 in repeat (10) {
    y:=y+1;
};
```

Es decir, la expresión (o bloque de expresiones) que sigue a una función macro se usa como el último parámetro del macro. Esto permite simular en **HULK** construcciones sintácticas como la anterior, que parecen nativas del lenguaje, sin perder la verificación semántica ni la inferencia de tipos (opcional) que funciona en el resto de **HULK**.
Veamos algunas macros interesantes que se pueden implementar con esta idea.

Es posible simular expresiones condicionales distintas, como la siguiente:

```hulk
define unless (cond:Boolean, expr:Object):Object -> if (!cond) expr;
```

Que se puede usar de la siguiente forma:

```hulk
let msg:String=read() in unless (msg=="Exit") {
    print("Hello World");
};
```

También es posible simular distintos sabores de ciclos, como este:

```hulk
define until (cond:Boolean, expr:Object):Object -> while(!cond) expr;
```

Que se podría usar de la siguiente manera:

```hulk
let x:Number=10 in until (x == 0) {
    x := x - 1;
    print(x);
};
```

### Extensión: Patrones de expresiones en macros

Esta extensión añade un mecanismo de _pattern matching_ para expresiones dentro de los macros. Este mecanismo permite definir macros cuya expansión dependa de la estructura sintáctica de los argumentos. Para ello introduciremos una expresión `match` que **solo** puede ser usada en macros. Esta expresión permite _deconstruir_ la estructura sintáctica de una expresión arbitraria `e` y tomar decisiones en función de los elementos que la componen.

Veamos un ejemplo un tanto esotérico para introducir los elementos básicos de la sintaxis de patrones. Supongamos que queremos definir un macro `simplify` que recibe una expresión aritmética y devuelve una expresión de igual valor pero simplificada. Las reglas para simplificar serán muy sencillas: si es una expresión `+`, entonces si una de las dos partes es `0`, me quedo con la otra, y si es una expresión `*` entonces si una de las dos partes es `1` me quedo con la otra. En otro caso la expresión se mantiene igual.

```hulk
define simplify(e:Number):Number {
    match e with {
        e1:Number + Number(0) -> simplify(e1);
        e1:Number * Number(1) -> simplify(e1);
        Number(0) + e1:Number -> simplify(e1);
        Number(1) * e1:Number -> simplify(e1);
        e1:Number             -> e1;
    };
}
```

En esta sintaxis, similar a `case`, la expresión `e` se compara _estructuralmente_ (en términos del AST) con cada uno de los patrones (las expresiones en la parte izquierda de `->`). Para el **primer** patrón que sea compatible se expande entonces la expresión en la parte derecha de `->`. Si ningún patrón es compatible, se lanzará un error en tiempo de compilación durante la expansión del macro, indicando que ninguna de las formas esperadas era compatible.
Para indicar _valores literales_ (`Boolean`, `Number` y `String`) usaremos una sintaxis como la mostrada (e.g., `Number(4)` o `String("Hello World")`).

La compatibilidad se realiza mediante una _unificación_ recursiva del AST de `e` con el AST de cada patrón. En este proceso, las variables (`e1` en el ejemplo) que existan en el patrón se unificarán con los sub-árboles correspondientes del AST.
Las "variables" `e1`, `e2`, etc., que unificarán con sub-árboles del AST, deben anotarse con un tipo que indica el tipo más abstracto esperado. Es decir que `e:Object` unifica con cualquier árbol.

Por ejemplo:

```hulk
simplify (1 * 3 + 0);
```

En este caso el primer patrón es compatible, siendo `e1` unificado con `(1 * 3)`, por lo que se obtiene la expansión:

```hulk
simplify(1 * 3);
```

Como en esta expansión aún quedan macros, se vuelve a expandir `simplify` siendo compatible el cuarto patrón, `e1` unificando con `3`. La expansión final queda entonces:

```hulk
3;
```

Nótese que la unificación puede funcionar si se asigna a la misma variable ASTs con estructura idéntica. Por ejemplo, si deseamos añadir como patrón que `x + x` se convierte en `2*x`, podemos definir el macro como:

```hulk
define simplify(e:Number):Number {
    match e with {
        # ... los casos vistos anteriormente
        e1:Number + e1:Number -> 2 * e1;
        e1:Number             -> e1;
    };
}
```

En este caso se unificará solamente si ambas partes de la expresión `+` tienen exactamente la misma estructura, por ejemplo `3*2 + 3*2` unifica `e1` con `3*2`, pero `3*2 + 2*3` no funciona, ya que aunque semánticamente ambas sub-expresiones tendrán el mismo valor, no tienen exactamente la misma estructura sintáctica para los respectivos AST.

Todas las expresiones de **HULK** _que no definen símbolos_ son usables como patrones en una expresión `match`, y para cada una la sintaxis como patrón se corresponde naturalmente con la sintaxis como expresión. Es decir, `let`, `for`, las expresiones generadoras, las expresiones _lambda_ y las expresiones de inicialización de _array_ **no pueden** ser usadas como patrones.
También es posible unificar con una expresión compleja. En este caso, se verificará recursivamente cada parte de la expresión.
Algunos ejemplos:

```hulk
# ...
match e with {
    e1:Number + e2:Number                   -> ... # Expresiones
    e1:Number * e2:Number                   -> ... # aritméticas simples o
    e1:Number + (e2:Number - e3:Number)     -> ... # complejas,
    while (e1:Boolean) e2:Object            -> ... # Ciclos,
    if (c:Boolean) e1:Object                -> ... # Condicionales sin o
    if (c:Boolean) e1:Object else e2:Object -> ... # con parte else,
    x:Number                                -> ... # Variables,
    Number(5)                               -> ... # Literales,
    Person(n:String)                        -> ... # Instanciación,
    e1:Object := e2:Object                  -> ... # Asignación,
    fib(e1:Number)                          -> ... # Invocación a funciones
    e1:Person.greet()                       -> ... # y métodos de instancia.
}
```

Para el caso de los bloques de expresiones, es posible unificar directamente con un bloque de expresión que tiene una cantidad exacta de elementos:

```hulk
match e with {
    { e1:Object ; e2:Object ; e3:Object } -> ...
}
```

Sin embargo, en ocasiones no se sabe de antemano la cantidad de expresiones que tendrá el bloque. Para estos casos, definiremos una sintaxis especial que permite _deconstruir_ un bloque de expresiones con **más de 1 elemento** en 2 partes: la primera expresión, y un bloque de expresiones restante. Esto permite aplicar recursivamente un macro a un bloque de expresiones de longitud arbitraria:

```hulk
define simplify(e:Number):Number {
    match e with {
        # ... los casos vistos anteriormente
        { e1:Number | e2:Number } -> { simplify(e1) ; simplify(e2) };
    }
}
```

En esta nueva sintaxis, el operador `|` sirve para indicar la concatenación de la primera expresión con el resto del bloque de expresiones. Nótese que para que esto funcione, `e2` no puede ser un bloque vacío, es decir, `e` originalmente contenía al menos 2 expresiones. Nótese que en esta situación el código expandido tendría la forma `{ e1 ; { e2; { e3; ...} } }`, es decir, los bloques se irían anidando a medida que se ejecuta el macro recursivamente. Sin embargo, `{ e1; { e2; } }` es semánticamente equivalente a `{ e1; e2 }` siempre, por lo que el compilador es libre de "desenredar" esta anidación de bloques de expresiones de forma automática.
Además, para que el caso base funcione, el compilador debe considerar un bloque con una sola expresión `{ e; }` equivalente a la misma expresión `e` por si sola.

El _pattern matching_ en macros que hemos definido en esta extensión es uno de las técnicas más poderosas de meta-programación que se pueden lograr en un lenguaje con tipado estático. Nótese que el compilador puede tener que realizar un procesamiento potencialmente ilimitado (excepto por efectos prácticos en los límites de la recursividad). Aunque no lo hemos demostrado formalmente, el mecanismo de macros definido con _pattern matching_ es Turing-completo. Una manera relativamente fácil de entender por qué, es notar que es posible codificar cualquier máquina de Turing como una secuencia de expresiones, representando los estados y los valores de la cinta mediante constantes. A base de _pattern matching_ y expansiones de macro recursivas, es posible simular cualquier máquina de Turing _en tiempo de compilación_.

A modo de ejemplo veamos cómo resolver el conocido problema de identificar si una secuencia de números `0` o `1` representa un número en binario divisible por `3`. Este es un conocido lenguaje regular, cuyo autómata tiene `3` estados que representan los posibles restos con `3`. La función macro siguiente simula este autómata (la presentaremos sin demostración):

```hulk
define multiple3(state:Number, value:Number):Boolean {
    match state with {
        Number(0) -> match value with {
            Number(0)                   -> True;
            Number(1)                   -> False;
            { Number(0) | rest:Number } -> multiple3(0, rest);
            { Number(1) | rest:Number } -> multiple3(1, rest);
        };
        Number(1) -> match value with {
            Number(0)                   -> False;
            Number(1)                   -> True;
            { Number(0) | rest:Number } -> multiple3(2, rest);
            { Number(1) | rest:Number } -> multiple3(0, rest);
        };
        Number(2) -> match value with {
            Number(0)                   -> False;
            Number(1)                   -> False;
            { Number(0) | rest:Number } -> multiple3(1, rest);
            { Number(1) | rest:Number } -> multiple3(2, rest);
        };
    };
}
```

Este macro se puede ejecutar de la siguiente forma:

```hulk
multiple3 (0) { 1; 1; 0; };
```

Y se expandiría directamente al literal `True`, computando _en tiempo de compilación_ un problema de la palabra en un lenguaje regular. No es muy complicado ver como extender esta idea a simular una máquina de Turing. Solo es necesario "llevar la cuenta" de la posición del cabezal.

## Formalización del lenguaje HULK

En esta sección presentaremos una descripción formal de **HULK**, en términos sintácticos, semánticos y operacionales. Esta sección debe servir como referencia para la construcción de un compilador de **HULK**, pero recomendamos las secciones anteriores que explican de forma más intuitiva todos los elementos relevantes del lenguaje.

### Sintaxis de HULK

Una gramática posible para **HULK** se muestra a continuación. Nótese que por motivos didácticos, esta gramática es ambigua. En particular, la asociatividad y prioridad de los distintos tipos de expresiones se deja sin resolver, para dar espacio a los estudiantes a que resuelvan estos problemas.

Los terminales de **HULK** son:

```Grammar
NUMBER  := [0-9]+(.[0-9]+)?
STRING  := " UNICODE* " # Todos los caracteres unicode válidos
BOOLEAN := True | False
LITERAL := NUMBER | STRING | BOOLEAN
ID      := [a-zA-Z_][a-zA-Z0-9]*
```

Un programa en **HULK** tiene tres partes: declaraciones de clases, declaraciones de funciones y una expresión opcional terminada en punto y coma (`;`):

```Grammar
<program> := [<class>]* [<function>]* [<expr> ;]
```

Una clase contiene atributos y métodos, y opcionalmente declaraciones de argumentos de clases:

```Grammar
<class>  := class ID [(<params>)] [is ID [(<args>)]] { [<attr> ;]* [<method>]* }
<params> := ID [: ID] [, ID [: ID]]*
          | epsilon
<args>   := <expr> [, <expr>]*
          | epsilon
```

Los atributos tiene un nombre, opcionalmente un tipo y una inicialización obligatoria.

```Grammar
<attr> := ID [: ID] = <expr>
```

Un método tiene un nombre, argumentos, un tipo de retorno opcional y un cuerpo. Hay 2 tipos de notaciones para métodos, una donde el cuerpo es una expresión simple (y termina en `;`) y otra donde el cuerpo es una lista de expresiones.

```Grammar
<method> := ID ( <params> ) [: ID] <body>
<body>   := -> <expr> ;
          | { [<expr> ;]+ }
```

Una función global tiene una signatura muy parecida a un método, pero requiere la palabra clave `function`:

```Grammar
<function> := function ID ( <params> ) [: ID] <body>
```

Finalmente las expresiones se dividen en 8 tipos fundamentales:

```Grammar
<expr> := <let-expr>
        | <if-expr>
        | <while-expr>
        | <case-expr>
        | <assign-expr>
        | <array-expr>
        | <inst-expr>
        | <elem-expr>
```

Una expresión de tipo `let` se compone de un bloque de inicializaciones, y un cuerpo. Igual que las funciones, este cuerpo puede ser simple o compuesto por una lista de expresiones:

```Grammar
<let-expr>  := let <decls> in <expr-body>
<decls>     := <decl> [, <decl>]*
<decl>      := ID [: ID] = <expr>
<expr-body> := <expr>
             | { [<expr> ;]+ }
```

Una expresión de tipo `if` tiene un conjunto de condiciones y opcionalmente una cláusula `else`:

```Grammar
<if-expr> := if ( <expr> ) <expr-body>
             [elif ( <expr> ) <expr-body>]*
             [else <expr-body>]
```

Una expresión de tipo `while` tiene una condición, un cuerpo, y opcionalmente una cláusula `else`:

```Grammar
<while-expr> := while ( <expr> ) <expr-body>
                [else <expr-body>]
```

Una expresión de tipo `case` tiene una expresión y un conjunto de ramas compuestas por identificador, tipo, y expresión de retorno:

```Grammar
<case-expr> := case <expr> of <case-body>
<case-body> := ID : ID -> <expr-body>
             | { [ID : ID -> <expr-body> ;]* }
```

Una asignación tiene una locación a la izquierda y una expresión a la derecha:

```Grammar
<assing-expr> := <loc> ':=' <expr>
<loc>         := <loc> '[' <expr> ']'
               | <loc> . <loc>
               | ID
```

Una expresión de creación de _array_ tiene un tipo opcional, una cantidad, y opcionalmente una cláusula de inicialización:

```Grammar
<array-expr> := new ID? '[' <expr> ']' [{ ID -> <expr> }]?
```

Una expresión de instanciación tiene un tipo y un conjunto de argumentos de clase:

```Grammar
<inst-expr> := new ID ( <args> )
```

Las expresiones elementales se componen de todas las operaciones lógicas, aritméticas, etc., además de la invocación a funciones globales, métodos, y atributos:

```Grammar
<elem-expr> := <expr> == <expr> | <expr> != <expr>
             | <expr> < <expr>  | <expr> > <expr>
             | <expr> <= <expr> | <expr> >= <expr>
             | <expr> & <expr>  | <expr> '|' <expr> | !<expr>
             | <expr> @ <expr>  | <expr> @@ <expr>
             | <expr> + <expr>  | <expr> - <expr>
             | <expr> % <expr>  | <expr> * <expr>   | <expr> / <expr>
             | <expr> [ '[' <expr> ']' ]?
             | [<expr> .] ID [( <args> )]?
             | -<expr> | ( <expr> )
```

**NOTA**: Como se ha explicado al inicio de la sección, la gramática anterior no tiene en cuenta la asociatividad ni precedencia de los diferentes tipos de expresiones. Esto se ha hecho a propósito, para permitir a los estudiantes resolver los problemas de ambigüedad resultantes del modo que consideren oportuno.

### Semántica de tipos

En **HULK** todas las expresiones tienen asociado un tipo estático, que debe ser inferido por el compilador. Cada expresión o instrucción de **HULK** tiene reglas de consistencia de tipos que deben ser verificadas por el compilador. En esta sección asumiremos que todos los tipos están explícitamente declarados. La sección siguiente explica cómo realizar la inferencia de tipos cuando existan declaraciones sin anotaciones de tipo. Para definir el tipo inferido y las restricciones de consistencia de cada tipo de expresión usaremos la notación definida en el capítulo [Semántica de Tipos](#semantics).

### Reglas para la inferencia de tipos

### Semántica operacional

## Implementando un Compilador de **HULK**

La implementación de un compilador de **HULK** tiene varios detalles y retos interesantes. A continuación queremos discutir algunas cuestiones que facilitarán esta tarea.

### Consideraciones generales

El compilador de **HULK** es un proyecto complejo, que debe ser dividido convenientemente en subproblemas, para ser atacado de forma efectiva. Si el proyecto se realiza en un equipo, existen algunos puntos importantes donde la carga puede ser divida.

El punto de división más evidente es el AST semántico, que separa todo el proceso de _parsing_ de las fases de verificación semántica y generación de código. Si se define primero una jerarquía para el AST y se usa el patrón _Visitor_, es posible dividir el trabajo al menos en 2 fases independientes: _parsing_ y chequeo semántico. Mientras un miembro del equipo construye la gramática y el _parser_, otro miembro puede implementar toda la verificación semántica, sin estorbarse mutuamente, pues la interfaz de comunicación es el AST.
Así mismo, un tercer miembro puede a partir del AST semántico implementar toda la generación de código, asumiendo que la verificación semántica es correcta, sin importar que aún no esté implementada.

Para la fase de generación de código, recomendamos que se utilice un lenguaje intermedio, similar a **CIL**. Esto permitirá nuevamente dividir el trabajo en 2 fases bien separadas. Primero se define un AST de este lenguaje intermedio, que debe ser mucho más sencillo que un AST para **HULK**. A partir de este punto, 2 personas diferentes pueden trabajar en 2 tareas: la transformación del AST semántico al AST de **CIL**, y la transformación de este AST a MIPS.

De modo que existen al menos 4 tareas del compilador que pueden implementarse en paralelo, estableciendo como interfaces de comunicación 2 ASTs, 1 para **HULK** y uno para **CIL**. Las tareas opcionales de inferencia de tipos y optimización de código también ser incluidas en este esquema de forma no disruptiva. Esto queda resumido en la siguiente gráfica:



![](../graphics/image-chap8-1.svg){ #image-chap8-1 width=100% }\


### Flujo de trabajo

El lenguaje **HULK** ha sido diseñado de forma que su compilador pueda implementarse *bottom-up*. Esto es, en vez de implementar cada fase del compilador (_lexer_, _parser_, semántico, generación de código) de forma secuencial, proponemos que se tomen las características del lenguaje (expresiones, funciones, clases) y se vayan adicionando, en cada momento implementando las modificaciones que cada fase requiera. A continuación proponemos un orden para implementar las características del lenguaje. En cada paso, sugerimos implementar _todas_ las fases, es decir, introducir los tipos de _token_ nuevos, producciones en la gramática, nodos del AST, reglas de verificación semántica y generación de código.

Para simplificar aun más la organización, proponemos dividir el desarrollo del compilador en 2 grandes fases: _frontend_ y _backend_. La fase de _frontend_ termina con la verificación semántica en el AST de HULK y la fase de _backend_ comienza justo en la generación de código de HULK a CIL. Ambas fases pueden ser implementadas en paralelo (por personas diferentes), o en serie. En esta sección asumiremos que estas 2 fases se realizan en serie, y por tanto primero ejemplificaremos como implementar todo el _frontend_ y luego todo el _backend_, pero es importante recordar que ambas fases son prácticamente independientes y se pueden ir desarrollando a la par.

La ventaja de comenzar de esta manera, es que muy rápidamente se tocan todos los puntos claves del _frontend_ del compilador y se comienza a trabajar en todas las fases, aunque en cada una es muy sencillo lo que debe implementarse. Esto no quiere decir que más adelante no sea necesario regresar y revisar decisiones de diseño que en este punto no fueron previstas, pero eso es inevitable en cualquier caso. Al obligarse a comenzar el proyecto implementando un primer prototipo funcional _completo_, habrás garantizado "chocar" con la mayoría de los obstáculos temprano.

Veamos entonces una propuesta de organización.

#### Paso 1: Expresiones Aritméticas

Implementar los operadores `+`, `-`, `*`, `/` y `%`, y el tipo `Number`. En este punto tu compilador debe ser capaz de _interpretar_ programas como el siguiente:

```hulk
(34.1 * (123.42 - 208)) / (24 + 9);
```

Para resolver este paso deberás:

- Implementar un tokenizador básico de expresiones aritméticas.
- Diseñar una gramática no-ambigüa de expresiones.
- Construir un AST con soporte para expresiones.
- Construir un visitor para interpretar el AST.

#### Paso 2: Funciones globales

Implementar la invocación (**solo la invocación**) a funciones globales (`print`, `parse`, `max`, `min`, `sin`, `cos`, etc.). En este punto tu compilador debe ser capaz de interpretar programas como el siguiente:

```hulk
print(sin(2 * 3.1415) + cos(1 / (4.54 - 6.72)));
```

Para resolver este paso deberás:

- Adicionar las reglas y producciones a la gramática.
- Añadir un nodo de invocación a funciones.
- Implementar un _visitor_ de verificación semántica que chequee la cantidad de argumentos pasados a una función.
- Añadir al intérprete la implementación de las funciones elementales.

#### Paso 3: Declaración de funciones

Implementar la declaración de funciones, potencialmente _solo_ con la notación compacta. En este punto tu compilador debe ser capaz de interpretar programas como el siguiente:

```hulk
function tan(x) -> sin(x) / cos(x);

print(tan(2 * 3.1415));
```

Para resolver este paso deberás:

- Adicionar reglas y producciones para la declaración.
- Comprobar que la cantidad de parámetros declarados coincida con la invocación.

#### Paso 4:

### Casos de prueba
