---
previous-chapter: chap3
next-chapter: chap5
---

# Análisis Semántico




En la mayoría de los lenguajes de programación de tercera generación existe el concepto de variable, que en última instancia se mapea a una región de la memoria donde se almacena un valor. Una de las reglas básicas del uso de variables en casi todos los lenguajes tiene que ver con la declaración y/o inicialización de una variable antes de su uso. Por ejemplo, en los lenguajes tipo C (C++, C#, Java), tenemos la siguiente construcción:

```cpp
int x = 5;
int y = 10;
// ....
int z = x + y;
```

Desde el punto de vista sintáctico, podemos pensar que un fragmento de la gramática que genera este lenguaje será algo como:

    <assignment> := <type> <id> "=" <expr> ";" | ...

Una gramática como esta será incapaz de diferenciar situaciones como la anterior, de situaciones como la siguiente:

```cpp
int x = 5;
int y = 10;
// ....
int z = p + q;
```

Donde las variables `p` y `q` no aparecen anteriormente en ninguna parte del método correspondiente. En la práctica es virtualmente imposible diseñar una gramática que tenga en cuenta que el identificador `p` tiene que haber sido usado en la parte derecha de una asignación antes de que aparezca en la parte izquierda.

Peor aún es el problema de determinar qué operaciones son válidas para un tipo determinado. Por ejemplo, impedir el uso del operador `+` entre una variable de tipo `int` y una de tipo `bool`. Incluso más complejo es verificar la consistencia de una invocación `x.F()`. En este caso es necesario saber de qué tipo `T` es `x` para determinar si existe un método `F` declarado en la clase `T`, o peor aún, en algún padre de la clase `T`.

Un ejemplo aún más complicado desde el punto de vista sintáctico es validar si en una invocación `F(a,b,c)` la cantidad de parámetros es correcta, y si los tipos asociados a las expresiones `a`, `b` y `c` son compatibles a los tipos declarados en los parámetros formales de la función (iguales, herederos o existe una conversión implícita). Por ejemplo, distinguir en el fragmento de programa siguiente, que el método `G` es correcto, pero ni `H` ni `I` son correctos:

```cpp
void F(int a, int b) {
    // ...
}

void G() {
    F(1, 2);
}

void H() {
    F(1, "2");
}

void I() {
    F(1, 2, 3);
}
```

Podemos pensar que la gramática "natural" para la declaración e invocación de funciones tiene la forma siguiente:

     <func-decl> := <type> <id> "(" <arg-list> ")" "{" <statement-block> "}"
      <arg-list> := <arg> | <arg> "," <arg-list> | epsilon
           <arg> := <type> <id>

    <func-invok> := <id> "(" <expr-list> ")"
     <expr-list> := <expr> | <expr> "," <expr-list> | epsilon
          <expr> := ...

En esta gramática (o variantes similares) no existe ninguna diferencia que permita distinguir la invocación hecha en `G` de la invocación hecha en `H`.
Intuitivamente no podemos expresar en una gramática libre del contexto las dependencias y relaciones entre los tipos, números de argumentos, y ámbitos de variables, dado que estas relaciones son intrínsicamente *dependientes del contexto*. Esto se debe a que dichas relaciones se ven expresadas, en principio, a todo lo largo del programa. La distancia entre una declaración de variable o función y su uso puede ser arbitrariamente larga. El orden en que las declaraciones y los usos se entrelazan es también arbritario. Por lo tanto, en principio, no deberíamos ser capaces de encontrar gramáticas libres del contexto que nos permitan expresar estas restricciones.

De forma general, el problema de reconocer si una cadena pertenece a cierto lenguaje, podemos verlo como el problema de determinar si dicha cadena cumple una serie de predicados lógicos. Por ejemplo, el lenguaje $a^n b^n$ está formado por las cadenas $\omega = s_1 s_2 \ldots s_n$ que cumplen los predicados siguientes:

* $s_i = a$ o $s_i = b$ (el alfabeto es $\{a,b\}$)
* Si $j > i$ y $s_i = b$ entonces $s_j = b$ (todas las $b$ aparecen luego de todas las $a$)
* $|\{s_i | s_i = a\}| = |\{s_i | s_i = b\}|$ (la cantidad de $a$ y $b$ es la misma)

Para muchas clases de predicados, podemos construir gramáticas que generan los lenguajes correspondientes. A veces, la intersección de estos lenguajes tiene una estructura tal que aún podemos seguir construyendo gramáticas para el lenguaje final. En otras ocasiones, la intersección de varios predicados nos da un lenguaje tal que, aunque somos capaces de reconocer las partes constituyentes, no podemos reconocer el lenguaje como un todo con gramáticas del mismo poder expresivo.

Consideremos entonces un lenguaje de programación determinado para el que queremos construir un compilador. Una de las tareas de este compilador es determinar qué cadenas (programas) son válidas en el lenguaje. Podemos pensar en la gran variedad de predicados que se aplican en estos casos. Por un lado, están todas las reglas que podemos llamar "sintácticas": los métodos empiezan por un identificador y una lista de argumentos entre paréntesis, las instrucciones terminan en un símbolo "punto y coma (;)", etc. Por otro lado, tenemos todas estas reglas que no son sintácticas: la consistencia en el uso de los tipos, que cierta función debe devolver un valor por todos los posibles caminos de ejecución, que las variables deben inicializarse antes de usarse en expresiones. Podemos llamar a estas reglas, "semánticas", porque de cierta forma nos indican cuál es el significado "real" del lenguaje.

Por ejemplo, en la instrucción `int x = 5;` tenemos por un lado el conjunto de reglas que determinan la forma de la instrucción (primero el tipo, luego un identificador, luego un igual, luego una expresión), y las que determinan el significado de la instrucción (almacenar un valor `5` en la zona de memoria asociada a la variable `x`). Podemos entonces imaginar que dividimos todos los predicados que definen los programas válidos en dos conjuntos: aquellos para los que podemos construir una gramática que los reconozca, y los que no. Los primeros serán justamente los *predicados sintácticos*, y los segundos, por analogía, los llamaremos *predicados semánticos*. Para el primer conjunto, tenemos un mecanismo formal que nos permite describirlos: las **gramáticas libres del contexto**. Para el segundo conjunto, desarrollaremos en este capítulo otro mecanismo formal similar, que nos permitirá describir de forma unívoca cuál es el "significado" de un programa.

Justamente, la fase de análisis sintáctico se encarga de validar que los predicados sintácticos se cumplen (y además construir un árbol de derivación). La fase de **análisis semántico**, que comenzaremos a estudiar en este capítulo, se encarga entonces de validar que los predicados semánticos se cumplan (y a su vez construir otras estructuras de datos que veremos más adelante).

Hemos visto que en la fase semántica el poder de las gramáticas libres del contexto es insuficiente. Además, los ejemplos de problemas semánticos que hemos presentado nos muestran la extrema dificultad de expresar estas reglas, incluso con gramáticas dependientes del contexto (para las que además no tenemos mecanismos reconocedores eficientes). Tenemos entonces que cambiar de paradigma.

Recordemos el problema a resolver: verificar los predicados semánticos (que aun no hemos definido completamente), una vez tenemos la seguridad de que la sintaxis es correcta. Recordemos entonces los árboles de derivación, que representan en una estructura computacionalmente cómoda de manipular el conjunto de producciones y el orden en que son aplicadas para producir la oración correspondiente. Este árbol de derivación a menudo se denomina árbol de sintaxis concreta, pues representa exactamente todos los elementos de la sintaxis descritos en la gramática. Intuitivamente, este árbol de derivación contiene todo el contexto del programa, en una estructura conveniente para ser explorada. ¿Y si intentáramos resolver los predicados semánticos, justamente viéndolos como predicados sobre el árbol de derivación, en vez de sobre la cadena de entrada? ¿Dado que tenemos toda cadena representa en una forma que nos expone toda la estructura sintáctica, no debería ser más fácil detectar aquí todos estos predicados que pueden, en principio, depender de *toda* la estructura global de la cadena?

Veamos como podemos reescribir algunos de estos predicados en forma de predicados sobre el árbol. Por ejemplo, la regla de que toda variable debe haber sido declarada antes de usarse. Pensemos en un programa arbitrario de C, por ejemplo:

```cpp
int x = 5;
//...
int y = x + 1;
```

Pudiéramos pensar en un posible árbol de derivación para este programa (para una gramática correcta del lenguaje C), donde habría necesariamente un subárbol con la forma:



![](../graphics/image-chap4-1.svg){ #image-chap4-1 width=40% }\


Y por otro lado, tendríamos un subárbol con la forma:



![](../graphics/image-chap4-2.svg){ #image-chap4-2 width=50% }\


Y ambos subárboles serían hijos de algún nodo que representa a la función correspondiente. Entonces podemos pensar en una estrategia para determinar si todas las variables son declaradas antes de su uso. En un recorrido en pre-orden por dicho árbol, podemos ir recolectando todas las declaraciones hechas en cierta estructura de datos, y luego cada vez que nos encontremos una variable referenciada en parte izquierda de una expresión, ¡simplemente consultamos dicha estructura y verificamos la existencia de una variable con dicho nombre, y de paso la consistencia de los tipos! De forma similar podemos pensar en la verificación de la cantidad de argumentos usados en una función y sus tipos.

## Árboles de Sintaxis Abstracta

En general, una vez tenemos el árbol de derivación, tenemos suficiente información sobre la cadena para reconocer cuáles son todas las variables, métodos, invocaciones, los tipos de cada expresión, etc. El árbol de derivación justamente nos asocia cada token de la cadena a su **función sintáctica**. Nos dice, por ejemplo, que el identificador `x` es el nombre de una variable, mientras que el identificador `printf` pudiera ser el nombre de una función. Además, nos dice cuando este identificador `x` aparece por primera vez, y mejor aún, cuándo aparece en parte derecha o en parte izquierda de una expresión. Tenemos entonces todo el poder expresivo de nuestros algoritmos y estructuras de datos (recorridos de árboles, diccionarios y tablas hash, etc.) para diseñar mecanismos de validación semántica. ¡Justamente es por este motivo que construimos el árbol de derivación en primer lugar!

Sin embargo, antes de que lanzarnos a diseñar algoritmos de validación semántica, revisemos nuestro árbol de derivación, y notaremos que su estructura no es exactamente idónea para esta tarea. Tomemos por ejemplo la siguiente gramática, que genera un lenguaje de expresiones aritméticas simples:

    E = T + E | T
    T = int * T | int | (E)

Y la cadena siguiente:

    2 * (3 + 5)

Como sabemos, esta cadena realmente como secuencia de tokens es:

    int * ( int + int )

De momento no nos preocuparemos por el valor concreto del número almacenado en cada token. Como sabemos del análisis lexicográfico, el lexer asocia a cada token además de la clase correspondiente, el fragmento de cadena original que lo forma. Cuando sea conveniente, podemos ver la cadena anterior como:

    int{2} * ( int{3} + int{5} )

Donde indicamos explícitamente el **lexema**. Durante el análisis sińtáctico hemos obviado este detalle pues solo nos interesaban los símbolos que aparecen en la gramática. Más adelante volveremos a incluir en nuestro análisis el valor concreto de cada token, que en última instancia constituyen los datos del programa a compilar.

Por el momento, concentrémonos nuevamente en la cadena a parsear. Esta cadena es generada **de forma única** por el siguiente árbol de derivación:



![](../graphics/image-chap4-3.svg){ #image-chap4-3 width=40% }\


Este árbol de derivación efectivamente codifica todas las operaciones necesarias a realizar para **evaluar** la expresión (que es en última instancia el problema a resolver). Sin embargo, este árbol representa con demasiado detalle la expresión. Supongamos que queremos diseñar una jerarquía de clases para representar este árbol. Dicha jerarquía tendría varias clases innecesarias, como aquellas que representan a los nodos `(` y `)`. Por otro lado, la estructura del árbol es poco eficiente para representar la expresión, pues hay varios nodos que son redundantes. Por ejemplo, el nodo raíz `E` no nos da ninguna información sobre el tipo concreto de la expresión. De forma general podemos reconocer dos tipos de elementos innecesarios:

* Nodos que representan elementos sintácticos innecesarios (e.j. los paréntesis)
* Nodos que derivan en un solo hijo (e.j. `E -> T`)

Los elementos sintácticos innecesarios, como los paréntesis, se emplean en la gramática para representar la prioridad entre sub-expresiones. Sin embargo, una vez construído el árbol de derivación, la prioridad entre las sub-expresiones queda explícitamente descrita en la propia estructura del árbol. Por otro lado, los nodos que derivan en un solo nodo hijo, tales como `E -> T`, son necesarios desde el punto de vista de la gramática para resolver las ambigüedades, pero una vez que se construye el árbol de derivación, no aportan ninguna información adicional.

Intentemos eliminar estos elementos innecesarios en el árbol de derivación anterior:



![](../graphics/image-chap4-4.svg){ #image-chap4-4 width=35% }\


Este árbol representa exactamente la misma expresión aritmética, y quedan explícitamente descritos el orden y el tipo de las operaciones. Una vez llegado a este punto, podemos notar que hay otro elemento innecesario en el árbol. Si nos fijamos con atención, veremos que el nodo asociado a un operador (`*` o `+`) siempre estará como hijo de exactamente el mismo tipo de nodo (`T` o `E`) respectivamente. Este hecho se desprende directamente de la gramática, pues el terminal `*` solo se genera por `T` y el terminal `+` solo se genera por `E`. Por tanto, ambos nodos respectivos (`T` y `*` o `E` y `+`) siempre aparecerán juntos, y por tanto es redundante tener ambos.

Pensemos ahora en la jerarquía de clases que representa este árbol, y un posible algoritmo recursivo de evaluación. Una vez en el nodo `T`, evaluados recursivamente las expresiones izquierda y derecha, ¿qué operación es necesario aplicar? Evidentemente, dependerá del nodo que representa la operación. Pero este nodo (`*` o `+`) siempre es un terminal, por lo tanto, nunca será necesario "bajar" recursivamente para descubrir que tipo de operación hay que hacer en un nodo `T` o `E`. Podemos entonces conformarnos con un árbol donde la operación a realizar esté explícita en el nodo padre (`T` o `E`) y no como un hijo adicional:



![](../graphics/image-chap4-5.svg){ #image-chap4-5 width=25% }\


Intuitivamente, el árbol anterior es capaz de representar con todo el detalle necesario la semántica de la expresión a evaluar, y no tiene ningún elemento innecesario.

A este tipo de estructura se le denomina **árbol de sintaxis abstracta (AST)**, precisamente porque representa solamente la porción de sintaxis necesaria para evaluar la expresión o programa reconocido. En el AST solamente existen nodos por cada tipo de elemento semántico diferente, es decir, por cada significado distinto.

Por ejemplo, en nuestro lenguaje de expresiones aritméticas, existen tres tipos de "entidades" o conceptos diferentes:

* un número,
* una operación de suma, y
* una operación de multiplicación.

De modo que si el árbol de sintaxis concreta (o árbol de derivación) tiene un tipo de nodo por cada tipo de **función sintáctica** diferente, entonces un árbol de sintaxis abstracta tiene un tipo de nodo por cada tipo de **función semántica** distina. Las diferentes funciones sintácticas se obtienen directamente de la gramática, y por tanto están muy influenciadas por el tipo de *parser* que se use. Las funciones semánticas, por otro lado, se diseñan a partir de la funcionalidad que se quiere obtener en el lenguaje, por lo que se tiene generalmente mayor libertad creativa.

## Diseño de un AST

A modo de ejemplo, vamos a definir un lenguaje muy sencillo, para el que diseñaremos un árbol de sintaxis abstracta. Este lenguaje será sobre el dominio de las expresiones aritméticas. Nos permitirá operar con variables y funciones predefinidas, así como definir nuevas funciones. Comenzaremos por listar de manera informal las características que queremos obtener de este lenguaje, y veremos luego como formalizar cada una.

Veamos primero las reglas **sintácticas**:

* El lenguaje tiene tres tipos de instrucciones: `let`, `def` y `print`:
    - `let <var> = <expr>` define una variable denominada `<var>` y le asigna el valor de `<expr>`
    - `def <func>(<arg1>, <arg2>, ...) -> <expr>` define una nueva función `<func>` con los argumentos `<arg*>`
    - `print <expr>` imprime el valor de una expresión
* Las expresiones pueden ser de varios tipos:
    - Expresiones ariméticas
    - Invocación de funciones predefinidas (`sin`, `cos`, `pow`, ...)
    - Invocación de funciones definidas en el programa

Formalizar estas características sintácticas es relativamente fácil con las herramientas que ya tenemos. Simplemente definiremos una gramática para ello:

       <program> := <stat-list>
     <stat-list> := <stat> ";"
                  | <stat> ";" <stat-list>
          <stat> := <let-var>
                  | <def-func>
                  | <print-stat>
       <let-var> := "let" ID "=" <expr>
      <def-func> := "def" ID "(" <arg-list> ")" "->" <expr>
    <print-stat> := "print" <expr>
      <arg-list> := ID
                  | ID "," <arg-list>
          <expr> := <term> + <expr>
                  | <term> - <expr>
                  | <term>
          <term> := <factor> * <term>
                  | <factor> / <term>
                  | <factor>
        <factor> := <atom>
                  | "(" <expr> ")"
          <atom> := NUMBER
                  | ID
                  | <func-call>
     <func-call> := ID "(" <expr-list> ")"
     <expr-list> := <expr>
                  | <expr> "," <expr-list>

La gramática anterior es bastante "natural", en el sentido de que no contiene reglas "extrañas" para resolver, por ejemplo, los problemas de ambigüedad típicos de las gramáticas LL(1). Este es el tipo de gramáticas que usualmente queremos diseñar para transmitir a otros lectores las reglas sintácticas del lenguaje. Luego, para una implementación concreta de un parser, es posible (y altamente probable), que tengamos que redefinir la gramática añadiendo producciones para convertirla en LL o LR, según el caso. En cualquier modo, como ya sabemos resolver ese problema, nos conformaremos con pensar que alguien nos dará un parser para esta gramática.

Definamos ahora informalmente las reglas **semánticas** de nuestro lenguaje:

* Una variable solo puede ser definida una vez en todo el programa.
* Los nombres de variables y funciones no comparten el mismo ámbito (pueden existir una variable y una función llamadas igual).
* No se pueden redefinir las funciones predefinidas.
* Una función puede tener distintas definiciones siempre que tengan distinta cantidad de argumentos (es decir, funciones del mismo nombre pero con cantidad de argumentos distintos se consideran funciones distintas).
* Toda variable y función tiene que haber sido definida antes de ser usada en una expresión (salvo las funciones pre-definidas).
* Todos los argumentos definidos en una misma función tienen que ser diferentes entre sí, aunque pueden ser iguales a variables definidas globalmente o a argumentos definidos en otras funciones.
* En el cuerpo de una función, los nombres de los argumentos ocultan los nombres de variables iguales.

> **Nota**: Una consecuencia interesante de estas reglas es que no permiten funciones recursivas...

Como vemos, todas estas reglas son de naturaleza dependiente del contexto, pues su alcance puede ser en principio todo el programa. Por lo tanto, no tenemos forma de expresar estas reglas en una gramática libre del contexto. Sin embargo, una vez tengamos el árbol de sintaxis abstracta de un programa concreto, veremos que es relativamente fácil verificar cada una de estas reglas.

Para diseñar el AST de este lenguaje, pensemos en las diferentes funciones semánticas que tiene nuestro programa. Veremos que en muchos casos tenemos un paralelo directo entre un nodo del AST y un símbolo de la gramática, pero en otros casos existirán símbolos que no tienen una función semántica (como los terminales `let`, `def` y `print`) y existirán funciones semánticas (clases de nodos del AST) que no corresponden a ningún símbolo de la gramática.

Comencemos entonces por el inicio. De forma general es convieniente diseñar una jerarquía de clases con una raíz `Node` (o de nombre similar) que nos representa cualquier nodo del AST. Agrupar todos los nodos del AST en una jerarquía común nos permite definir funciones abstractas sobre todos los nodos (que usaremos para el chequeo semántico más adelante). Por tanto, comenzamos por ahí:

```cs
public abstract class Node {
    //...
}
```

A diferencia del árbol de derivación, en esta clase `Node` no hemos puesto explícitamente una propiedad `Children` ni nada similar. Esto se debe a que en el AST en principio cada hijo de un nodo tiene una función semántica propia. Por tanto, en vez de tener una lista de hijos general, es preferible en cada subclase defnir exactamente que nodos (y de qué tipo) son los hijos esperados. De modo que no tendremos un "árbol" en el sentido puro como estructura de datos, sino una colección de clases relacionadas entre sí, cuya estructura en memoria será un árbol.

La primera función semántica que necesitamos es aquella que nos represente a nuestro programa. Como hemos visto en la gramática, un programa simplemente es una colección de instrucciones (*statements*), por lo tanto, necesitamos también definir esta función semántica.

```cs
public class Program {
    public List<Statement> Statements;
}

public abstract class Statement {
    //...
}
```

Notar que hemos definido a `Program` como una clase concreta, pero a `Statement` como a una clase abstracta. Esto se debe a que tenemos diversos tipos de instrucciones concretas, pero la instrucción "base" en sí no es realmente una función semántica propia. Una regla más o menos común es que cuando un no-terminal deriva en más de una producción, cada una de esas producciones puede corresponder a una función semántica distinta. Sin embargo, en otros casos, un no-terminal deriva en más de una producción por motivos puramente sintácticos, como en el caso de `<stat-list>`, cuya única función es describir una lista de instrucciones. En el AST, no tiene mucho sentido tener un nodo particular para una lista de instrucciones, y por tanto en `Program` tenemos esta lista de forma explícita.

Veamos entonces los tres tipos concretos de instrucciones:

```cs
public class LetVar : Statement {
    public string Identifier;
    public Expression Expr;
}

public class DefFunc : Statement {
    public string Identifier;
    public List<string> Arguments;
    public Expression Expr;
}

public Print : Statement {
    public Expression Expr;
}
```

El motivo por el que estos nodos son herederos de `Statement` es justamente para poder definir en `Program` una lista de diferentes tipos de instrucciones. De modo que estamos la herencia solamente para definir estructura, y no para aprovecharnos del polimorfismo (ya que no tenemos comportamiento en los nodos). Esto cambiará más adelante cuando nos interesemos por la verificación semántica.

Vamos a definir la parte de la jerarquía que representa las expresiones en sí. En la gramática tenemos los no-terminales `<expr>`, `<term>`, `<factor>` y `<atom>` que nos sirven para definir la prioridad de los operadores. Sin embargo, desde el punto de vista semántico, todos estos no-terminales juegan el mismo papel. Por ejemplo, las expresiones binarias, desde el punto de vista semántico, son prácticamente idénticas. La única diferencia es el operador concreto a aplicar. De modo que podemos tener **una única clase** de expresión binaria:

```cs
public enum Operator { Add, Sub, Mult, Div }

public abstract class Expression : Node {
    //...
}

public class BinaryExpr : Expression {
    public Operator Op;
    public Expression Left;
    public Expression Right;
}
```

Este diseño puede parecer a algunos "anti-orientado-a-objetos", pues no estamos definiendo una clase por cada tipo de expresión binaria. La discusión de cuál diseño es mejor es mucho más compleja que lo que podemos abordar en este párrafo. Solamente diremos algo a favor de este enfoque, y es que, al menos de momento, si tuviéramos una clase `MultNode` y una clase `AddNode`, estas serían exactamente iguales. Por lo tanto, como no tenemos comportamiento **ni** estructura distintos en ambas clases, no tiene sentido, al menos de momento, tener una clase por cada tipo de operador. Más adelante revisaremos esta hipótesis y tendremos una discusión más profunda al respecto.

Nos quedan entonces tres tipos de expresiones: constante numérica, variable y llamada a una función. Para cada una de estas tendremos una clase distinta, pues tienen estructura diferente:

```cs
public class FuncCall : Expression {
    public string Identifier;
    public List<Expression> Args;
}

public class Variable : Expression {
    public string Identifier;
}

public class Number : Expression {
    public string Value;
}
```

Hemos definido la clase `Number` con un valor de tipo `string`, ya que, en principio, no es hasta el chequeo semántico que nos interesa saber el valor concreto del número que este token representa. Por lo tanto, podemos pensar que ni el *lexer* ni el *parser* se interesarán por obtener este valor.

Y en este punto hemos terminado con nuestro árbol de sintaxis abstracta. Tenemos un total de 11 clases, de las cuáles 3 son abstractas y 8 son concretas. En la gramática tenemos un total de 25 producciones, que en principio son 25 funciones sintácticas diferentes. Algunas de ellas son listas, y por tanto no tienen función semántica asociada. Otras, como en el caso de las expresiones, están para desambigüar y establecer el orden operacional, por lo que tampoco tienen una función semántica asociada. En lenguajes más complejos, podemos tener también varias producciones que simplemente sean formas sintácticas diferentes de expresar la misma función semántica (e.j. **if** con **else** e **if** sin **else**).

Nos queda pendiente la tarea de obtener el AST a partir del árbol de derivación (que es la salida que realmente nos da el *parser*). De momento vamos a asumir que este algoritmo existe, y nos concentraremos en los tipos de análisis que podemos hacer sobre el AST una vez construido. Más adelante veremos un mecanismo formal que nos permite expresar como se construye el AST a partir del árbol de derivación, y un algoritmo para ello.

## Validando las reglas semánticas

Volvamos a la tarea que dio origen a toda esta discusión del AST: validar el cumplimiento de las reglas semánticas. Recordemos nuevamente estas reglas:

* Una variable solo puede ser definida una vez en todo el programa.
* Los nombres de variables y funciones no comparten el mismo ámbito (pueden existir una variable y una función llamadas igual).
* No se pueden redefinir las funciones predefinidas.
* Una función puede tener distintas definiciones siempre que tengan distinta cantidad de argumentos (es decir, funciones del mismo nombre pero con cantidad de argumentos distintos se consideran funciones distintas).
* Toda variable y función tiene que haber sido definida antes de ser usada en una expresión (salvo las funciones pre-definidas).
* Todos los argumentos definidos en una misma función tienen que ser diferentes entre sí, aunque pueden ser iguales a variables definidas globalmente o a argumentos definidos en otras funciones.
* En el cuerpo de una función, los nombres de los argumentos ocultan los nombres de variables iguales.

En esta sección vamos a presentar una solución *ad-hoc* para estos problemas, en el caso particular del lenguaje que hemos definido. Más adelante formalizaremos esta estrategia de solución y mostraremos como extenderla a lenguajes más generales.

De manera general, el enfoque que usaremos será el siguiente. Cada regla semántica realmente se aplica solo a algunos tipos de nodos, pero para cada tipo de nodo podemos determinar qué reglas se aplican. Vamos a definir entonces un método `Validate()` en cada nodo, que nos dirá si dicho nodo es correcto. Por supuesto, ya podemos intuir que la implementación concreta de este método en un nodo dependerá recursivamente de los nodos hijos.

Por otro lado, notemos que la mayoría de las reglas semánticas nos hablan sobre las definiciones y uso de las variables y funciones. De hecho, por este motivo es justamente que dichas reglas son dependientes del contexto. De modo que, intuitivamente, en cada nodo necesitaremos tener acceso a este "contexto", donde pueden estar definidas las funciones y variables que su usan en dicho nodo. Dado que tenemos todo el AST construido, cabe pensar que dicho contexto se puede calcular en un recorrido sobre el árbol. De hecho, como veremos, en el mismo recorrido que vamos validando las reglas semánticas, iremos construyendo el contexto correspondiente.   Vamos entonces a diseñar una estructura de datos que nos represente dicho contexto. En esta estructura tenemos que almacenar las funciones y variables definidas (en el caso de las funciones con la cantidad de argumentos), y poder consultar en todo momento qué es lo definido. Supongamos entonces que tenemos una implementación de la siguiente **interface**:

```cs
public interface IContext {
    bool IsDefined(string variable);
    bool IsDefined(string function, int args);
    bool Define(string variable);
    bool Define(string function, string[] args);
}
```

Agregamos entonces el método siguiente:

```cs
public abstract class Node {
    public abstract bool Validate(IContext context);
}
```

Veamos entonces como se implementa esta validación en los nodos concretos. En el caso de `Program` es muy sencillo, el programa está correcto solo si cada una de las instrucciones que lo componen se valida correctamente:

```cs
public class Program : Node {
    public List<Statement> Statements;

    public override bool Validate(IContext context) {
        foreach(var st in Statements) {
            if (!st.Validate(context)) {
                return false;
            }

            return true;
        }
    }
}
```

Pasemos entonces a la validación de las expresiones, cuyas regla semántica fundamental es que todos los identificadores usados tienen que haber sido definidos antes. En el caso de las expresiones binarias es muy sencillo:

```cs
public class BinaryExpr : Expression {
    public Operator Op;
    public Expression Left;
    public Expression Right;

    public override bool Validate(IContext context) {
        return Left.Validate(context) && Right.Validate(context);
    }
}
```

Ahora, en el caso de las expresiones atómicas es donde realmente sucede lo importante. Comezamos por el caso más sencillo:

```cs
public class Number : Expression {
    public string Value;

    public override bool Validate(IContext context) {
        return true;
    }
}
```

Veamos entonces el caso del nodo `Variable`. Este nodo nos representa una variable siendo usada como parte de una expresión, por lo tanto, como dice la regla semántica, tiene que haber sido definida antes:

```cs
public class Variable : Expression {
    public string Identifier;

    public override bool Validate(IContext context) {
        return context.IsDefined(Identifier);
    }
}
```

Por último, para el caso de una función, la validación es muy similar, pero teniendo en cuenta la cantidad de argumentos. Además, dado que una invocación a función define recursivamente un conjunto de expresiones para los valores de cada argumento, es necesario validar cada una:

```cs
public class FuncCall : Expression {
    public string Identifier;
    public List<Expression> Args;

    public override bool Validate(IContext context) {
        foreach(var expr in Args) {
            if (!expr.Validate(context)) {
                return false;
            }
        }

        return context.IsDefined(Identifier, Args.Count);
    }
}
```

Veamos finalmente la implementación de los nodos `LetVar` y `DefFunc`. Es justamente en estos nodos donde se definen nuevas variables y funciones, por lo que en el momento de validar estos nodos, es donde realmente se calcula este "contexto" del que tanto hemos hablado. El caso de la definición de variable es el más sencillo, así que comenzaremos por ahí:

```cs
public class LetVar : Statement {
    public string Identifier;
    public Expression Expr;

    public override bool Validate(IContext context) {
        if (!Expr.Validate(context)) {
            return false;
        }

        if (!context.Define(Identifier)) {
            return false;
        }

        return true;
    }
}
```

El caso de la definición de función es mucho más interesante. Por un lado es necesario validar que no exista una función con el mismo nombre y la misma cantidad de argumentos, lo que es sencillo. Por otro lado, es necesario validar recursivamente el cuerpo de la función. El problema aquí es que en el cuerpo de la función permitimos no solo usar las variables definidas globalmente, sino además *los argumentos* de la propia función. Es decir, durante la validación del cuerpo de la función, existen unas variables "especiales", que son justamente los argumentos, cuyos nombres sí pueden coincidir con los nombres de variables definidas anteriormente, pero no entre sí.

Una solución rápida a este problema consiste en simplemente definir los argumentos cuyos identificadores sean nuevos (es decir, que no coincidan con una variable global), y al final de la validación, "des-definir" estos argumentos. Por un lado, esto implica adicionar un mecanismo para "des-definir", que es una operación que realmente no tiene un significado real en nuestra semántica. Además, es necesario llevar la cuenta de cuáles fueron los argumentos que se adicionaron al contexto para quitar solamente esos. Pero más importante que todos esos motivos, es el hecho de aunque un argumento tiene el mismo nombre de una variable en realidad es una variable distinta. Como ahora no estamos almacenando en el contexto nada adicional asociado a las variables, realmente esto no importa. Pero en el momento en que para cada variable querramos almacenar algo adicional, tenemos que hacer esta distinción. Por ejemplo, en algún momento vamos a querer ejecutar nuestro programa, y tendremos que asociar a cada variable y argumento un valor numérico concreto.

Una solución mucho más elegante y extensible es introduciendo un nuevo concepto que llamaremos **ámbito** (*scope* en inglés). De manera general, un ámbito es una región de un programa donde están definidos ciertos símbolos (variables, funciones, etc.). Definimos entonces que entre ámbitos distintos puede haber coincidencias de nombres de símbolos, pero dentro del mismo ámbito no. Por ejemplo, podemos tener un ámbito distinto para cada función (básicamente una instancia de `IContext` distinta), y de esta forma nunca tendremos que preocuparnos por la colisión de nombres entre argumentos en diferentes funciones.

Ahora, el otro problema a resolver, es que en el cuerpo de una función sí pueden aparecer referencias a variables definidas fuera de la función. De modo que nos sirve simplemente crear un nuevo `IContext` vacío y definir todos los argumentos ahí. Necesitamos que este `IContext` pueda resolver no solo lo que tiene definido explícitamente, sino todo aquello definido "afuera". Decimos entonces que este nuevo ámbito es "hijo" del ámbito global, de modo que puede sobre-escribir algunos símbolos, pero sigue teniendo acceso a todo lo definido anteriormente.

En el caso actual solamente vamos a tener un ámbito global, y luego un ámbito por cada función; pero en lenguajes más complejos, es posible definir tantos ámbitos anidados como se desee (por ejemplo, en C# cada instrucción **for** crea un nuevo ámbito más interno). De modo que en general podemos pensar en los ámbitos también como una estructura árborea, donde existe un ámbito global, y luego se van creando ámbitos "hijo" según sea necesario. Este patrón de diseño es muy común en la mayoría de los lenguajes de programación existentes, por lo que vale la pena presentarlo aquí. Desde el punto de vista de diseño, simplemente necesitamos adicionar un método a nuestra **interface**:

```cs
public interface IContext {
    bool IsDefined(string variable);
    bool IsDefined(string function, int args);
    bool Define(string variable);
    bool Define(string function, string[] args);

    IContext CreateChildContext(); // <- esto es lo nuevo
}
```

Sin embargo, desde el punto de implementación, ahora los métodos `IsDefined` deben modificarse para buscar no solo en el diccionario de símbolos del ámbito actual, sino recursivamente en el ámbito padre. Aunque esta implementación es sencilla, no es del todo trivial, por lo que vamos a mostrar una posible solución:

```cs
public class Context : IContext {
    IContext parent;
    HashSet<string> variables = new ...
    Dictionary<string, string[]> functions = new ...

    bool IsDefined(string variable) {
        return variables.Contains(variables) ||
               (parent != null && parent.IsDefined(variable));
    }

    bool IsDefined(string function, int args) {
        if (functions.ContainsKey(function) &&
            functions[function].Length == args) {
            return true;
        }

        return parent != null && parent.IsDefined(function, args);
    }

    bool Define(string variable) {
        return variables.Add(variable);
    }

    bool Define(string function, string[] args) {
        if (functions.ContainsKey(function) &&
            functions[function].Length == args) {
            return false;
        }

        functions[function] = args;
        return true;
    }

    IContext CreateChildContext() {
        return new Context() { parent = this };
    }
}
```

Nuestra implementación de contexto nos garantiza que no es posible definir la misma variable o la misma función (con igual cantidad de argumentos) en un mismo contexto, pero sí nos permite sobreescribir los símbolos existentes en el contexto padre. Varios autores llaman a esta estructura de datos **tabla de símbolos**, ya que almacena todos los símbolos definidos en el programa. Nosotros le llamamos **contexto**, pues consideramos que es un nombre más general que da la idea de que en esta estructura se almacena la información dependiente del contexto que es útil para cada elemento semántico del programa.

Haciendo uso de esta estructura, podemos entonces finalmente implementar la validación del nodo `DefFunc`:

```cs
public class DefFunc : Expression {
    public string Identifier;
    public List<string> Args;
    public Expression Body;

    public override bool Validate(IContext context) {
        var innerContext = context.CreateChildContext();

        foreach(var arg in Args) {
            innerContext.Define(arg);
        }

        if (!Body.Validate(innerContext)) {
            return false;
        }

        if (!context.Define(Identifier, Args.ToArray())) {
            return false;
        }

        return true;
    }
}
```

En este punto, ya tenemos toda la semántica de nuestro lenguaje validada, y solamente quedaría el problema de realmente ejecutar las instrucciones existentes. Siguiendo el mismo enfoque visto hasta ahora, podemos pensar en una solución que vaya recursivamente evaluando cada expresión, y almacenando en una especie de "contexto de ejecución" los valores de las expresiones definidas hasta el momento. Dado que no es posible redefinir variables, es totalmente válido calcular el valor de una variable tan pronto como se define, y almacenarlo. Para el caso de las funciones, lo más conveniente es almacenar directamente la expresión que se refiere al cuerpo de la función, para poder ejecutarla cuando sea necesario. En ese caso, un problema interesante de resolver es qué los argumentos de la función se definen en el nodo `DefFunc`, pero los valores que tendrán realmente solo se conocen en algún nodo `FuncCall`. Por lo tanto, en cada invocación, es necesario poder acceder al nodo `DefFunc` correspondiente para poder asignar los valores concretos que en esa invocación serán usados. Dejamos como sugerencia intentar implementar este mecanismo de evaluación.
