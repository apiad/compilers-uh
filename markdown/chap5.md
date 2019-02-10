---
previous-chapter: chap4
next-chapter: chap6
---

# Gramáticas Atributadas

Hasta el momento hemos visto como obtener un árbol de derivación de un lenguaje, y luego hemos presentado el árbol de sintaxis abstracta como una descripción más cómoda para realizar análisis semántico. Sin embargo, todavía no tenemos un mecanismo para construir un árbol de sintaxis abstracta a partir de un árbol de derivación. En principio, podemos pensar en estrategias *ad-hoc*, y para cada gramática particular escribir un algoritmo que construye el AST. De forma general estos algoritmos serán estrategias recursivas que irán recorriendo el árbol de derivación y computando fragmentos del AST a partir de los fragmentos obtenidos en los nodos hijos. En este capítulo veremos un esquema formal para describir esta clase de algoritmos, que además nos permitirá resolver varios problemas dependientes del contexto de forma elegante y sencilla.

## Construyendo un AST

Empecemos por mostrar, de forma intuitiva, como construir un AST para un árbol de derivación de una gramática conocida. Usaremos la gramática de expresiones aritméticas tan gastada:

    E -> E + T
       | E - T
       | T

    T -> T * F
       | T / F
       | F

    F -> ( E )
       | i

Una posible jerarquía para el AST de esta gramática es la siguiente:

```cs
public enum Op { Add, Sub, Mult, Div }

public abstract class Expression : {

}

public class BinaryExpr : Expression {
    public Op Operator;
    public Expression Left;
    public Expression Right
}

public class Number : Expression {
    public float Value;
}
```

Supongamos entonces que tenemos un árbol de derivación para una cadena particular. Recordemos que un árbol de derivación es una estructura donde en cada nodo hay un símbolo, y los hijos de dicho nodo coinciden exactamente con los símbolos de la parte derecha de la producción aplicada. Una posible definición de un árbol de derivación para esta gramática particular sería:

```cs
public enum Symbol { E, T, add, sub, mult, div, i, left, right }

public class Node {
    public Symbol Symbol;
    public List<Node> Children = new ...
}
```

Supongamos entonces que tenemos un algoritmo de parsing que nos devuelve este árbol de derivación (LR en este caso, dado la gramática que hemos definido). Queremos entonces adicionar un método `GetAST()` en la clase `Node` que nos devuelve un objeto de tipo `Expression`.

```cs
public class Node {
    // ...

    public Expression GetAST() {
        // ...
    }
}
```

De forma general hay 3 patrones distintos en la gramática que nos generan nodos semánticamente distintos en el árbol de derivación:

* las producciones que derivan en una expresión binaria;
* las producciones que derivan en un solo no-terminal, incluyendo `F -> ( E )`; y
* el símbolo `i` que es el único terminal con una función semántica asociada.

Cada uno de estos tipos de producciones genera un nodo particular del AST. Por lo tanto, nuestro código consiste en identificar en qué caso nos encontrarmos, y construir el nodo correspondiente.

Si la producción es de la forma $X \to Y o Z$, donde $X$, $Y$ y $Z$ son símbolos y $o$ es un operador, creamos un nuevo nodo `BinaryExpr` con el operador adecuado, y los hijos se convierten recursivamente en las expresiones izquierda y derecha:

```cs
public Expression GetAST() {
    // X -> Y o Z
    if (Children.Count == 3 && Children[1].Symbol >= 2) {
        return new BinaryExpr() {
            Left  = Children[0].GetAST(),
            Op    = GetOperator(Children[1]),
            Right = Children[2].GetAST()
        };
    }
}
```

Si la producción es de la forma $X \to Y$, simplemente devolvemos la expresión hija. Notemos que en este caso el resultado que se produce es una "compactación" del árbol de derivación, eliminando las producciones de un solo símbolo:

```cs
public Expression GetAST() {
    // ...
    // X -> Y
    else if (Children.Count == 1) {
        return Children[0].GetAST();
    }
}
```

Si la producción es particularmente `F -> ( E )` también devolvemos la expresión hija:

```cs
public Expression GetAST() {
    // ...
    // F -> ( E )
    else if (Children.Count == 3 && Children[1].Symbol == Symbol.E) {
        return Children[1].GetAST();
    }
}
```

Finalmente, cuando el nodo actual del árbol de derivación es una hoja, tiene que ser un nodo `i` y se crea la expresión unaria `Number`:

```cs
public Expression GetAST() {
    // ...
    // i
    else if (Children.Count == 0 && Symbol == Symbol.i) {
        return new Number() { Value = /* valor del token */ };
    }

    throw new InvalidParseTreeException("xP");
}
```

## Reglas y atributos semánticos

Veamos nuevamente la implementación que hemos hecho para nuestra gramática de expresiones. De forma general, lo que hemos hecho ha sido intentar identificar qué producción concreta está representada en cada nodo, y según el caso, aplicar una regla que nos permite construir el fragmento de AST. Vamos a intentar generalizar este concepto de asociar reglas a producciones. Para ello, adicionaremos a cada símbolo de la gramática un conjunto de atributos, y a cada producción un conjunto de reglas que describen cómo se computan dichos atributos. Llamaremos a estas gramáticas: **gramáticas atributadas**:

Una **gramática atributada** es una tupla $<G,A,R>$, donde:

* $G = <S,P,N,T>$ es una gramática libre del contexto,
* $A$ es un conjunto de atributos de la forma $X \cdot a$
  donde $X \in N \cup T$ y $a$ es un identificador único entre todos los atributos del mismo símbolo, y
* $R$ es un conjunto de reglas de la forma $<p_i, r_i>$ donde $p_i \in P$ es una producción $X \to Y_1, \ldots, Y_n$, y $r_i$ es una regla de la forma:
    1. $X \cdot a = f(Y_1 \cdot a_1, \ldots, Y_n \cdot a_n)$, o
    2. $Y_i \cdot a = f(X \cdot a_0, Y_1 \cdot a_1, \ldots, Y_n \cdot a_n)$.

    En el primer caso decimos que $a$ es un **atributo sintetizado**, y en el segundo caso, un **atributo heredado**.


Hablemos ahora sobre la notación. Aunque en la definición formal hemos especificado los atributos y reglas como elementos adicionales a la gramática, desde el punto de vista notacional es conveniente especificar las reglas y los atributos directamente asociados a la producción que corresponden:

    X -> YZ { X.a = f(Y.a, Z.a) }

De este modo, tenemos una notación compacta, donde se puede reconocer a simple vista la gramática, los atributos, y las reglas. Por convenio llamamos a estas reglas, **reglas semánticas**, pues nos permiten definir de cierta forma la *función semántica* de cada producción. Consideraremos que los terminales tienen un conjunto de atributos cuyos valores son suministrados por el *lexer*. Cuando tenemos más de un símbolo con el mismo nombre, pondremos índices, por ejemplo:

$X \to cX \{ X_0 \cdot a = f(X_1 \cdot a_1, c \cdot a_2 ) \}$

En realidad es necesario definir algunas restricciones adicionales sobre las reglas para que una gramática atributada sea consistente. En particular, necesitamos que no existan definiciones contradictorias de los atributos (es decir, no haya más de una regla que defina el mismo atributo en la misma producción, y que todo atributo sea o bien sintetizado, o bien heredado), y que todos los atributos estén bien definidos en cualquier árbol de derivación. A este último problema nos dedicaremos más adelante cuando nos preocupemos por la evaluación de los atributos. De momento simplemente digamos que necesitamos definir las reglas de forma que sean consistentes y completas.

En esta definición no hemos especificado de qué naturaleza son los atributos o las reglas. De forma general, asumimos que los atributos son de tipos que sean convenientes computacionalmente: numéricos, conjuntos, diccionarios, listas, o incluso tipos complejos en un entorno orientado a objetos. Las reglas las consideraremos en general como funciones computables en algún sistema de cómputo. Cuando solo nos interese definir formalmente un lenguaje, emplearemos una notación matemática y funciones puras (sin efectos colaterales).

Veamos entonces cómo redefinir la gramática de expresiones vista anteriormente para computar el AST. Usaremos la misma notación para definir árboles que hemos visto en la sección de *parsing* LR: un nodo de tipo $T$ cuyos hijos son los árboles $t_1, \ldots, t_n$ lo representaremos como $T(t_1, \ldots, t_n)$. Es decir, representaremos un árbol según el **recorrido en pre-orden** de sus nodos. Particularmente en esta gramática, usaremos las siguiente notación:

* Un nodo terminal de tipo `Number` lo representaremos mediante el símbolo `n`.
* Un nodo no-terminal de tipo `BinaryExpr` lo representaremos según el tipo del operador, como `exp(op, e1, e2)`

Definiremos un atributo de nombre `ast` en cada símbolo, que almacenará el árbol de sintaxis abstracta. La gramática nos quedaría entonces:

    E -> E + T { E0.ast = exp(+, E1.ast, T.ast) }
       | E - T { E0.ast = exp(-, E1.ast, T.ast) }
       | T     { E0.ast = T.ast }

    T -> T * F { T0.ast = exp(*, T1.ast, F.ast) }
       | T / F { T0.ast = exp(/, T1.ast, F.ast) }
       | F     { T0.ast = F.ast }

    F -> ( E ) {  F.ast = E.ast }
       | i     {  F.ast = n }

Puede parecer que no hemos logrado mucho, más allá de formalizar en una notación una idea que ya sabíamos manejar. Y de alguna manera es cierto, lo que hemos hecho ha sido simplemente formalizar en una notación la idea intuitiva de cómo construir a partir de un árbol de derivación una representación más conveniente. La ventaja de tener esta notación formalizada, además de permitirnos razonar y comunicarnos al respecto, es que hemos simplificado considerablemente la cantidad de "código" a escribir para construir el AST. Hemos quitado del medio toda la sintaxis superflua de definición de métodos, parámetros, variables temporales, etc, y solamente hemos puesto en cada producción exactamente la "línea de código" que iría dentro del `if` correspondiente. De hecho, esta notación es tan conveniente, que la mayoría de los generadores de *parsers* usan una sintaxis similar para describir justamente cómo se construye el AST, y generan todo el engranaje de métodos recursivos, variables, paso de parámetros y demás que son necesarios para hacer funcionar este mecanismo.

## Resolviendo dependencias del contexto

En nuestra definición de gramática atributada no hemos dicho nada del AST. Aunque en la práctica usamos los atributos la mayoría de las veces para construir el AST, y luego resolver los problemas dependientes del contexto sobre el AST, en ocasiones es conveniente resolver algunos de estos problemas directamente empleando el mecanismo de gramática atributada. Esto tiene sentido sobre todo si estamos construyendo lenguajes pequeños, con pocas reglas semánticas y no queremos diseñar una jerarquía de AST independiente.

Por ejemplo, tomemos el lenguaje dependiente del contexto canónico $L = a^n b^n c^n$, y veamos como podemos describir mediante una gramática atributada los predicados semánticos que definen este lenguaje. Comenzamos por la gramática:

    S -> ABC
    A -> aA | epsilon
    B -> bB | epsilon
    C -> cC | epsilon

Como convenio, vamos a definir un atributos `S.ok` cuyo valor será `true` si y solo si la cadena reconocida pertenece al lenguaje. En cada no terminal vamos a definir un atributo `cnt` que almacenará la cantidad de veces que este no terminal ha derivado en el terminal correspondiente. De modo que en cada producción de `A`, `B` o `C`, iremos "contando" la cantidad de `a`, `b` o `c` que se van produciendo, y luego en `S` determinaremos si la cadena es correcta. Vamos a usar para la definición de las reglas una notación más parecida a un lenguaje de programación convencional:

    S -> ABC       {   S.ok = (A.cnt == B.cnt && B.cnt == C.cnt) }
    A -> aA        { A0.cnt = 1 + A1.cnt }
       | epsilon   {  A.cnt = 0 }
    B -> bB        { B0.cnt = 1 + B1.cnt }
       | epsilon   {  B.cnt = 0 }
    C -> cC        { C0.cnt = 1 + C1.cnt }
       | epsilon   {  C.cnt = 0 }

En este punto hemos definido una gramática con atributos que reconoce todas las cadenas de la forma $a^*b^*c^*$, pero para las cuales el valor del atributo `S.ok` es `true` solamente en las cadenas exactamente de la forma $a^n b^n c^n$. La forma de resolverlo ha sido definir una gramática libre del contexto, y hemos adicionado la dependencia del contexto en forma de reglas semánticas. Si observamos la gramática definida,  notaremos que nos hemos conformado con reconocer solamente la parte regular del lenguaje, y hemos dejado todo el resto del problema a las reglas semánticas. Un enfoque alternativo consiste en intentar resolver en el análisis sintáctico tanto como sea posible.

Por ejemplo, podemos reconocer $a^n b^n c^*$, en la gramática, y luego solamente verificar la correspondencia entre la cantidad de `b` y la cantidad de `c`. Comencemos por definir una gramática libre del contexto para esto:

    S -> XC
    X -> aXb | epsilon
    C -> cC  | epsilon

Almacenaremos entonces en `X.cnt` la cantidad de `b` que aparecen, y luego lo compararemos con `C.cnt`:

    S -> XC       {   S.ok = (X.cnt == B.cnt) }
    X -> aXb      { X0.cnt = 1 + X1.cnt }
       | epsilon  {  X.cnt = 0 }
    C -> cC       { C0.cnt = 1 + C1.cnt }
       | epsilon  {  C.cnt = 0 }

La pregunta es por supuesto, entre estas dos alternativas, cuál es mejor. Y como casi siempre la respuesta será que depende de qué queremos lograr. Por un lado, una gramática más simple es más fácil de leer y entender, y (en ocasiones) más fácil de parsear. En ese caso la mayor carga queda en la fase semántica, que generalmente es más compleja y tiene un costo computacional mayor. Por otro lado, si la gramática es más compleja, pero captura una mayor cantidad de propiedades del lenguaje, es posible reconocer una mayor cantidad de errores en la fase sintáctica, y probablemente se obtenga un compilador más eficiente. Sin embargo, estas gramáticas son más complejas, y por tanto más difíciles de entender.

Otro factor a tener en cuenta, desde el punto de vista de la ingeniería de software, es la *mantenibilidad* del compilador. En general, es más difícil hacer cambios en las primeras fases, pues es más probable que un cambio en la gramática o en el *lexer* provoquen una disrupción en las fases siguientes. En cambio, por la propia naturaleza de la programación orientada a objetos, con un buen diseño es posible lograr que los cambios en la fase semántica sean lo menos disruptores posibles. Por este motivo, es conveniente definir bien temprano una gramática lo más sencilla posible que englobe todas las propiedades sintácticas del lenguaje en cuestión, y dejar para la fase semántica toda propiedad cuyo significado o implementación tenga una alta probabilidad de variar.

## Computando el valor de los atributos

Una vez definida una gramática atributada, nos queda pendiente el problema de cómo evaluar las reglas semánticas para asignar el valor correcto a los atributos. Como es de esperar, esta evaluación la vamos a realizar una vez construido el árbol de derivación de una cadena particular. De forma general, podemos tener en cualquier nodo tanto atributos sintetizados como atributos heredados. Necesitamos entonces encontrar un orden para evaluar los atributos que garantice que siempre sea posible evaluar las reglas correspondientes. Para esto, necesitamos saber las *dependencias* de cada atributo en una regla particular, es decir, cuales son los otros atributos que es necesario haber evaluado antes. Intuitivamente, estas dependencias son justamente los atributos usados dentro de la función $f$ en la regla semántica.

Tomemos entonces a modo de ejemplo la cadena `aabbcc` y veamos un árbol de derivación para la gramática atributada definida anteriormente:

```tree
         S
       / | \
      A  B  C
     /| / \ |\
    a A b B c C
     /|  /|  /|
    a A b B c C
      |   |   |
      e   e   e
```

Vamos entonces a construir sobre este árbol de derivación un *grafo de dependencia* de los atributos asociados. Este grafo se construye de la siguiente forma:

* Los nodos son los atributos de cada símbolo en cada nodo del árbol de derivación
* Existe una arista dirigida entre un par de nodos $v \to w$ del grafo de dependencia, si los atributos correspondientes participan en una regla semántica definida en la producción asociada al nodo del árbol de derivación donde aparece $w$, de la forma $w = f(\ldots, v, \ldots)$. Es decir, si el atributo $w$ *depende* del atributo $v$.

Veamos entonces como quedaría el árbol anterior, una vez señaladas las dependencias entre los atributos. Para simplificar la notación, vamos a representar solamente las aristas del grafo de dependencias, y no las del árbol de derivación en sí.:

         -->  S.ok  <--
         |     ^      |
         |     |      |
       A.cnt  B.cnt  C.cnt
        ^       ^       ^
        |       |       |
     a A.cnt b B.cnt c C.cnt
        ^       ^       ^
        |       |       |
     a A.cnt b B.cnt c C.cnt

        e       e       e

La propiedad más interesante de este grafo de dependencias es que nos dice, en primer lugar, si existe una forma de evaluar los atributos, y en caso de ser posible, nos da un orden para la evaluación. Si existe algún ciclo en este grafo de dependencias, evidentemente no podremos evaluar los atributos que participan en el ciclo. Por lo tanto, decimos que la gramática es evaluable si y solo si el grafo de dependencias es acíclico, es decir, un DAG. En este caso, la evaluación se realiza siguiendo algún *orden topológico* del grafo de dependencia.

En el caso anterior, nuestro grafo de dependencias es justamente un árbol, donde todas las aristas están orientadas de un hijo a un padre en el AST. Esto sucede cada vez que en una gramática todos los atributos son *sintetizados*. Evidentemente, en este caso es posible evaluar siempre los atributos de un nodo padre, una vez evaluados todos los atributos de los hijos. A este tipo de gramática les llamaremos **gramáticas s-atributadas** (la *s* viene de *sintetizado*). Este tipo de gramáticas son las más sencillas de evaluar, y también las más comunes. En general cuando estamos definiendo el AST nos saldrán casi siempre atributos sintetizados, pues como lo que queremos construir es un árbol, es natural que definamos los atributos en este orden. La buena noticia con las gramáticas s-atributadas, es que siempre es posible evaluar los atributos (en todo árbol de derivación), y esto siempre será con un recorrido en post-orden. Formalmente:

> Una gramática atributada es **s-atributada** si y solo si, para toda regla $r_i$ asociada a una producción $X \to Y_1, \ldots, Y_n$, se cumple que $r_i$ es de la forma $X \cdot a = f(Y_1 \cdot a_1, \ldots, Y_n \cdot a_n)$.

Para evaluar los atributos en una gramática s-atributada, podemos seguir una estrategia como la siguiente. Asumiremos que durante la construcción del árbol de derivación, el *parser* introduce en cada nodo una lista de todas las reglas semánticas asociadas a dicha producción, y que los atributos están definidos en cada símbolo.

```cs
public class Node {
    public Symbol Symbol;
    public List<Node> Children;
    public List<Rule> Rules;

    public void EvaluateSynthesized() {
        foreach(var node in Children)
            node.EvaluateSynthesized();

        foreach(var rule in Rules)
            rule.evaluate(Symbol, Children);
    }
}
```

Veamos entonces otro caso un poco más general, donde también podemos decir de antemano que la gramática es evaluable. Este es el caso cuando todo atributo es, o bien sintetizado, o si es heredado, solo depende de atributos de símbolos que le anteceden en la producción. Es decir, si tenemos una regla $Y_i \cdot a_i = f(X \cdot a, Y_1 \cdot a_1, \ldots, Y_{i-1} \cdot a_{i-1})$. A estas gramáticas las llamaremos **gramáticas l-atributadas** (donde *l* viene de *left*), ya que todo atributo depende solo de atributos que se evalúan antes en el pre-orden. En este caso, también podemos siempre evaluar la gramática haciendo un recorrido en profundidad, aunque es un poco más complicado que para el caso anterior. En cada llamado recursivo, primero evaluaremos los atributos heredados, pues solo dependen de atributos en los hermanos anteriores y el padre. Luego descendemos recursivamente en cada hijo, y al retornar, evaluamos los atributos sintetizados en el nodo actual. Formalizando:

> Una gramática atributada es **l-atributada** si y solo si toda regla $r_i$ asociada a una producción $X \to Y_1, \ldots, Y_n$ es de una de las siguientes formas:
> 1. $X \cdot a = f(Y_1 \cdot a_1, \ldots, Y_n \cdot a_n)$, ó
> 2. $Y_i \cdot a_i = f(X \cdot a, Y_1 \cdot a_1, \ldots, Y_{i-1} \cdot a_{i-1})$.

Y un ejemplo de cómo evaluar los atributos, suponiendo que el *parser* es capaz de suministrar en par de listas separadas aquellas reglas que sintetizan atributos de las que los heredan. Supongamos que cada nodo recibe además una referencia al nodo padre en el árbol de derivación (para poder acceder a los hermanos). En el nodo raíz simplemente pasaremos `null` como padre:

```cs
public class Node {
    public Symbol Symbol;
    public List<Node> Children;
    public List<Rule> SyntethicRules;
    public List<Rule> InheritedRules;

    private void EvaluateInherited(Node parent) {
        foreach(var rule in InheritedRules)
            rule.evaluate(Symbol, parent, parent.Children);

        foreach(var node in Children)
            node.EvaluateInherited(this);

        foreach(var rule in SyntheticRules)
            rule.evaluate(Symbol, Children);
    }
}
```

## Evaluando atributos durante el proceso de *parsing* descendente

Cabe preguntarnos entonces sino es posible evaluar las reglas semánticas a medida que se realiza el proceso de parsing. Intuitivamente, al menos para las gramáticas s-atributadas y l-atributadas esto debe ser posible, pues existe un orden claro de dependencia entre los atributos. Por supuesto, esto dependerá también del algoritmo de *parsing* empleado.

Por ejemplo, para gramáticas LL, si estamos empleando un algoritmo recursivo descendente, el orden en que se construye el árbol de derivación es exactamente el mismo que el orden de evaluación de una gramática l-atributada. Tomemos como ejemplo la gramática LL(1) de expresiones aritméticas que hemos visto anteriormente:

    E -> T X
    T -> i Y | ( E )
    X -> + E | - E | epsilon
    Y -> * T | / T | epsilon

 Como hemos visto anteriormente, los árboles de derivación que salen de esta gramática son bastante complicados. Vamos a intentar escribir un conjunto de reglas semánticas que nos calculen directamente el valor de la expresión durante el proceso de parsing. El problema radica en que cuando tenemos la producción `E -> T X`, no sabemos en este punto si la operación a realizar es una suma o una resta. Es solo cuando vemos la producción en que derivó `X` que podemos decidir que operación hacer. Sin embargo, en la producción `X -> + E`, por ejemplo, ya no tenemos el valor de `T` disponible para hacer el cálculo. De modo que tenemos que "pasar" el valor de `T` a `X` en la producción `E -> T X`, para que luego `X` pueda decidir que hacer con este valor.

 Vamos a definir entonces 3 atributos diferentes, de tipo numérico. En primer lugar, el atributo `i.val`, suministrado por el *lexer*, que contiene el valor numérico del token. Tendremos además los atributos `E.sval`, `T.sval`, `X.sval` y `Y.sval`, que son respectivamente los valores de las expresiones aritméticas representadas en cada caso. Los hemos llamado con el prefijo `s` justamente porque estos atributos serán *sintetizados*. Finalmente, vamos a tener los atributos `X.hval` y `Y.hval` que contendrán los valores de las expresiones a la izquierda de `X` o `Y` y son atributos *heredados*.

 Una vez definidos estos atributos, veamos algunas ideas sobre cómo computarlos. Algunos casos bases son fáciles, por ejemplo para `T -> ( E )` simplemente tenemos que "subir" el valor de `E.sval` a `T.sval`. Por otro lado, tomemos por ejemplo la producción `E -> T X`. Sabemos que en `T` tenemos un atributo sintetizado con el valor numérico de lo que sea que haya sido reconocido como `T` por ese lado. Sin embargo, aún no sabemos si sumarlo o restarlo con lo que resta. La estrategia en este caso será "pasar" este valor computado hasta el momento a `X` (por medio del atributo `X.hval`), y luego pedirle a `X` que compute el valor `X.sval` como la suma (o resta) del valor heredado de `T` y lo que sea que `X` en sí haya parseado. Es decir, primero "bajaremos" el valor de `T` hacia `X`, sumando o restando según el caso, hasta llegar a las hojas (donde `X -> epsilon`). En este punto, lo que sea que tengamos acumulado lo "subiremos" hacia la raíz (por medio de `X.sval`).

Veamos entonces toda la lista de reglas semánticas:

    E -> T X      { X.hval = T.sval, E.sval = X.sval }
    T -> i Y      { Y.hval = i.val,  T.sval = Y.sval }
       | ( E )    { T.sval = E.sval }
    X -> + E      { X.sval = X.hval + E.sval }
       | - E      { X.sval = X.hval - E.sval }
       | epsilon  { X.sval = X.hval }
    Y -> * T      { Y.sval = Y.hval * T.sval }
       | / T      { Y.sval = Y.hval / T.sval }
       | epsilon  { Y.sval = Y.hval }

Intentemos ahora parsear una cadena, a la vez que vamos evaluando los atributos. Vamos a representar por un lado la cadena que vamos parseando, y por otro lado la pila de "llamados" recursivos que se va formando con cada llamado del *parser* recursivo descedente asociado a esta gramática. En cada "llamado" recursivo reprsentaremos también el valor de cada atributo en la forma `S[attr=val]` (un `.` significa que el valor aún no ha sido calculado). Comenzamos por la cadena completa, y el llamado al símbolo `E`. Una advertencia para los débiles de espíritu, cualquiera que haya almorzado recientemente debería saltar al siguiente capítulo...

    |i{2} * ( i{5} - i{3} )

     E[sval=.]

En el primer paso, como `E` solo deriva en `T X`, no queda otra que llamar a `T`. Vamos a representar también el llamado a `X` para no olvidar que al retornar `T` debemos descender recursivamente por `X`.

    |i{2} * ( i{5} - i{3} )

     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Ahora, mirando el token `i` y los $First$ de cada producción, aplicamos `T -> i Y`:

    |i{2} * ( i{5} - i{3} )

     i[val=.] , Y[sval=.,hval=.]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Podemos entonces reconocer `i` y asociar el valor adecuado al atributo:

     i{2}|* ( i{5} - i{3} )

     i[val=2] , Y[sval=.,hval=.]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Al retornar de `i` a `T`, como tenemos ya en `i` el valor asociado al token, aplicamos la regla semántica correspondiente a `Y`:

     i{2}|* ( i{5} - i{3} )

     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Procedemos entonces expandir el símbolo `Y`:

     i{2}|* ( i{5} - i{3} )

     *[] , T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

En este punto solo es necesario reconocer el token `*`, y luego descendemos recursivamente por `T`, pero esta vez por la producción `( E )`:

     i{2} *|( i{5} - i{3} )

     ([], E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Avanzamos el siguiente token:

     i{2} * (|i{5} - i{3} )

     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y ahora volvemos a descender recursivamente:

     i{2} * (|i{5} - i{3} )

     T[sval=.] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y luego:

     i{2} * (|i{5} - i{3} )

     i[val=.] , Y[sval=.,hval=.]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Reconocemos `i`:

     i{2} * ( i{5}|- i{3} )

     i[val=5] , Y[sval=.,hval=.]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y retornamos recursivamente poniendo el valor de `i` en el atributo `hval` de Y:

     i{2} * ( i{5}|- i{3} )

     Y[sval=.,hval=5]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Dado que `-` está en el $Follow(Y)$, aplicamos `Y -> epsilon`, y aquí veremos la magia de las gramáticas atributadas actuando, pues el valor de `hval` pasa a `sval` justo antes de retornar:

     i{2} * ( i{5}|- i{3} )

     Y[sval=5,hval=5]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y ahora al retornar aplicamos la regla semántica en `X` que "sube" el valor de `Y.sval`:

     i{2} * ( i{5}|- i{3} )

     T[sval=5] , X[sval=.,hval=.]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Una vez parseado `T`, antes de retornar, pasamos su valor a `hval` de `X`:

     i{2} * ( i{5}|- i{3} )

     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Expandimos entonces la producción `X -> - E`:

     i{2} * ( i{5}|- i{3} )

     -[], E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Avanzamos el siguiente token y expandimos:

     i{2} * ( i{5} -|i{3} )

     T[sval=.], X[sval=.,hval=.]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Nuevamente, expandimos `T -> i Y` (ya esto se está volviendo un poquito repetitivo...):

     i{2} * ( i{5} -|i{3} )

     i[val=.], Y[sval=.,hval=.]
     T[sval=.], X[sval=.,hval=.]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y de nuevo hacemos la secuencia de `match` y paso de valor de `i` para `Y`:

     i{2} * ( i{5} - i{3}|)

     Y[sval=.,hval=3]
     T[sval=.], X[sval=.,hval=.]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Ahora vendrá una cascada de evaluaciones y reducciones a $\epsilon$ que disfrutaremos en cámara lenta. Primero, pasamos el valor `Y.hval` para `Y.sval`:

     i{2} * ( i{5} - i{3}|)

     Y[sval=3,hval=3]
     T[sval=.], X[sval=.,hval=.]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Al retornar `Y`, sintetizamos el valor de `T.sval`:

     i{2} * ( i{5} - i{3}|)

     T[sval=3], X[sval=.,hval=.]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y lo pasamos para `X.hval`:

     i{2} * ( i{5} - i{3}|)

     X[sval=.,hval=3]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Como `)` está en el $Follow(X)$, solo queda pasar el valor `X.hval` para `X.sval`:

     i{2} * ( i{5} - i{3}|)

     X[sval=3,hval=3]
     E[sval=.]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y al retornar felizmente este valor va para `E.sval`:

     i{2} * ( i{5} - i{3}|)

     E[sval=3]
     X[sval=.,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Ahora se está poniendo interesante la pila. En el tope tenemos a `E[sval=3]` que debe retornar para `X`. Recordemos que esta producción era justamente `X -> - E`, por lo que al retornar `E` se aplica la regla semántica que computa, por primera vez, la operación resta! LoL! Siguiendo esta regla, tenemos que hacer `X.sval` igual a `X.hval - E.sval`.

     i{2} * ( i{5} - i{3}|)

     X[sval=2,hval=5]
     E[sval=.], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Retornamos entonces "subiendo" el valor de `X.sval`:

     i{2} * ( i{5} - i{3}|)

     E[sval=2], )[]
     T[sval=.]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y ahora al retornar `E`, justo antes de llamar a `match`, "subimos" a `T` el valor correspondiente:

     i{2} * ( i{5} - i{3}|)

     )[]
     T[sval=2]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Luego avanzamos al último token que nos queda de la cadena de entrada:

     i{2} * ( i{5} - i{3} )|

     T[sval=2]
     Y[sval=.,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

Y ahora vuelve a producirse otro paso mágico, pues `Y` al retornar `T` realiza la tan esperada operación de multiplicación!

     i{2} * ( i{5} - i{3} )|

     Y[sval=4,hval=2]
     T[sval=.] , X[sval=.,hval=.]
     E[sval=.]

El retorno de `Y` es recibido de buena gana por `T`:

     i{2} * ( i{5} - i{3} )|

     T[sval=4] , X[sval=.,hval=.]
     E[sval=.]

Que estaba esperando solo para pasarle este valor a `X`:

     i{2} * ( i{5} - i{3} )|

     X[sval=.,hval=4]
     E[sval=.]

Ahora `X`, sin nada más que hacer, debe expandirse en $\epsilon$, pero antes, computará el valor de su atributo `X.sval`:

     i{2} * ( i{5} - i{3} )|

     X[sval=4,hval=4]
     E[sval=.]

Y lo devuelve con gracia a `E`:

     i{2} * ( i{5} - i{3} )|

     E[sval=4]

De modo que hemos terminado de parsear la cadena, y no solo hemos reconocido su bien merecida pertenencia al lenguaje, sino que además nos la hemos ingeniado para obtener, a la misma vez, el valor ya computado de la expresión aritmética! xD.

Si parece que hemos tenido que hacer malabares para calcular el valor de la expresión, intentemos pensar en el código equivalente que realiza esta misma evaluación sobre el árbol de derivación ya creado. Hemos definido un mecanismo formal para expresar el cómputo de atributos sobre un árbol de derivación, que nos ha permitido expresar fácilmente la evaluación de la expresión aritmética, sin tener  que lidiar con todos los detalles de implementación, paso de parámetros, etc. De hecho, este mecanismo es tan formal, que lo hemos ejecutado de forma mecánica, sin pararnos a razonar, solamente siguiendo a ciegas las reglas semánticas, ¡y ha funcionado!

## Evaluando atributos durante el proceso de *parsing* ascendente

Antes de terminar, para aquellos que no quedaron satisfechos con la sección anterior, pues tenemos más... Vamos a realizar un proceso similar, pero esta vez sobre una gramática LR. En este tipo de gramáticas, tenemos que pagar un precio a la hora de definir atributos, pues solamente podemos evaluarlos durante el proceso de parsing si todos los atributos son sintetizados. Intuitivamente, esto es cierto ya que en la pila de símbolos nunca tendremos a un "padre" antes que a un "hijo", debido a la naturaleza *bottom-up* del proceso de *parsing*. Por tanto, los atributos del símbolo "padre" solamente pueden depender de los atributos de sus "hijos", y nunca de su propio "padre". Por otro lado, como se construye el árbol de derivación extrema derecha, tampoco pueden depender de los atributos de los hermanos.

El proceso de evaluación general funcionará de la siguiente manera. Cada vez que se introduce un símbolo en la pila, computaremos el valor de todos sus atributos, a partir de los símbolos hijo que acabamos de sacar de la pila. Los tokens entran a la pila con sus atributos ya evaluados por el *lexer*.

Con esto en mente, vamos a definir entonces la gramática LR de expresiones aritméticas con un único atributo sintetizado `val` en cada nodo. En el proceso de *parsing* ascendente, iremos computando los valores correspondientes a partir de los valores de los hijos. Las reglas semánticas que nos quedan son bastante intuitivas, y no requieren de mayor explicación:

    E -> E + T  { E0.val = E1.val + T.val }
       | E - T  { E0.val = E1.val - T.val }
       | T      { E0.val = T.val }
    T -> T * F  { T0.val = T1.val * F.val }
       | T / F  { T0.val = T1.val / F.val }
       | F      { T0.val = F.val }
    F -> i      {  F.val = i.val }
       | ( E )  {  F.val = E.val }

Vamos entonces a representar para esta gramática en la pila de símbolos además los valores de los atributos, y la cadena de entrada como siempre:

    |i{2} * ( i{5} - i{3} )
    |

No vamos a mostrar aquí la tabla LR, ya que para esta gramática es bastante intuitivo que operación realizar en cada caso. Por tanto nos ahorraremos especificar exactamente en qué estado nos encontramos, y simplemente asumiremos que automáta LR funciona. Comenzamos entonces por introducir `i` en la pila, y calculamos el valor correspondiente (que viene en el token):

        i{2}|* ( i{5} - i{3} )
    i[val=2]|

En este punto podemos reducir `F -> i`, y calcular el valor correspondiente:

        i{2}|* ( i{5} - i{3} )
    F[val=2]|

Seguimos teniendo un *handle*, así que volvemos a reducir:

        i{2}|* ( i{5} - i{3} )
    T[val=2]|

El siguiente paso es un **shift** (pues no hay `*` en el $Follow(E)$):

        i{2} *|( i{5} - i{3} )
    T[val=2] *|

Y el siguiente:

        i{2} * (|i{5} - i{3} )
    T[val=2] * (|

Y el siguiente:

            i{2} * ( i{5}|- i{3} )
    T[val=2] * ( i[val=5]|

Podemos entonces reducir nuevamente (subiendo el valor del atributo):

            i{2} * ( i{5}|- i{3} )
    T[val=2] * ( F[val=5]|

Y de nuevo:

            i{2} * ( i{5}|- i{3} )
    T[val=2] * ( T[val=5]|

Y de nuevo:

            i{2} * ( i{5}|- i{3} )
    T[val=2] * ( E[val=5]|

Seguimos entrando en la pila:

            i{2} * ( i{5} -|i{3} )
    T[val=2] * ( E[val=5] -|

Y el siguiente:

                i{2} * ( i{5} - i{3}|)
    T[val=2] * ( E[val=5] - i[val=3]|

Y ahora vamos a reducir a `F -> i` de nuevo:

                i{2} * ( i{5} - i{3}|)
    T[val=2] * ( E[val=5] - F[val=3]|

Y a `T -> F`:

                i{2} * ( i{5} - i{3}|)
    T[val=2] * ( E[val=5] - T[val=3]|

Y ahora podemos reducir `E -> E - T` y aplicar la regla semántica que computa la resta:

     i{2} * ( i{5} - i{3}|)
    T[val=2] * ( E[val=2]|

Luego no nos queda otra opción que hacer **shift** por última vez:

     i{2} * ( i{5} - i{3} )|
    T[val=2] * ( E[val=2] )|

Y ahora, como es de esperar, reducimos `F -> ( E )` quedándonos con el valor almacenado:

    i{2} * ( i{5} - i{3} )|
       T[val=2] * F[val=2]|

Luego reducimos `T -> T * F` computando el valor correspondiente:

    i{2} * ( i{5} - i{3} )|
                  T[val=4]|

Y por último `E -> T`, dejando en la pila el símbolo inicial, y teniendo computado el valor asociado al atributo `val`:

    i{2} * ( i{5} - i{3} )|
                  E[val=4]|

Como hemos podido ver, el proceso de *parsing* LR es bastante más sencillo (una vez computada la tabla, claro), y además más poderoso en términos de las gramáticas que puede reconocer que el *parsing* LL. Sin embargo, desde el punto de vista de los atributos, el *parsing* LR nos obliga a definir todos nuestros atributos de forma sintetizada, lo que reduce el poder expresivo de las gramáticas atributadas. En la práctica, sin embargo, este es el tipo de *parser* más utilizado, y las reglas semánticas que queremos expresar son lo suficientemente amables como para contentarnos con gramáticas s-atributadas.

## El proceso de *parsing* completo

Hemos visto entonces los conceptos fundamentales que nos permiten llegar desde una cadena, hasta un árbol de sintaxis abstracta. De forma general, el proceso completo es el siguiente:

* Definimos una gramática libre del contexto que capture las propiedades sintácticas del lenguaje, de la forma más "natural" posible (con la menor cantidad de producciones "superfluas").
* Diseñamos un árbol de sintaxis abstracta con los tipos de nodos que representan exactamente las funciones semánticas de nuestro lenguaje.
* Definimos las reglas semánticas que construyen el árbol de sintaxis abstracta, preferiblemente quedando una gramática s-atributada.
* Construimos un *lexer* a partir de las expresiones regulares que definen a los tokens.
* Construimos un *parser*, idealmente LALR (o LR si no es posible) que además de reconocer la cadena, nos evalúe y construya el AST durante el proceso de *parsing*.
* Implementamos los predicados semánticos restantes sobre el AST construido.

Este proceso está tan bien estudiado, que la mayoría de los generadores de *parser* existentes automatizan toda esta parte. A partir de una gramática libre del contexto con reglas semánticas, y una jerarquía de nodos del AST, estos generadores de *parsers* son capaces de construir el autómata LR y devolvernos directamente el AST instanciado. Contar con herramientas de este tipo nos permite iterar muy rápidamente sobre el lenguaje, modificando la gramática o el AST de forma independiente, ya que el único punto de acoplamiento son las reglas semánticas. Por este motivo es preferible tener gramáticas más sencillas, y dejar para la fase semántica la mayor cantidad de problemas.

De modo que prácticamente toda la complejidad de diseñar un lenguaje radica en definir correctamente las funciones semánticas, e implementar la fase de chequeo semántico. De hecho, en los últimos años, casi toda la investigación sobre *parsing* se ha movido a lenguajes ambigüos o lenguaje natural, y la investigación en temas de compilación puros se ha concentrado en implementar funciones semánticas más complejas. En los capítulos siguientes nos concentraremos en problemas típicos del análisis semántico, y veremos estructuras de datos y estrategias para su implementación.
