---
previous-chapter: chap5
next-chapter: chap7
---

# Semántica de Tipos {#semantics}

En la mayoría de los lenguajes de programación modernos existe el concepto de "tipo". De manera informal, diremos que un tipo es una definición de especifica cuáles operaciones son válidas a realizar sobre un objeto particular. Un objeto en este caso puede ser un valor simple (`int` o `bool` en los lenguajes tipo C), o un objeto compuesto en algún lenguaje orientado a objetos. El paradigma **orientado a objetos** ha venido a convertirse en los últimos años en una de las columnas fundamentales del diseño y la investigación de nuevos lenguajes de programación. En este paradigma, cada "valor" que se puede manipulado en un programa es un *objeto*, y los objetos pueden agruparse para definir objetos más complejos. A cada objeto se le asocia un *tipo*, que define las operaciones válidas a realizar sobre dicho objeto.

La implementación más usual del concepto de tipo es una **clase**. Una clase (en C, C++, C#, Java, Python, Ruby, y tantos otros lenguajes orientados a objetos) es fundamentalmente una definición de las operaciones disponibles para un tipo. En general las clases permiten definir *atributos* que almacenan un valor, y *métodos* (o *funciones*) que permiten realizar una serie de operaciones (con o sin efectos colaterales) sobre el tipo en cuestión y los *argumentos* del método. A todos estos lenguajes los llamados *lenguajes tipados*, porque manejan el concepto de tipo. De forma general, si la operación `f(x)` (o `x.f()`) es válida en algunos contextos, e inválida en otros, aunque en ambos casos `f` y `x` son símbolos definidos, entonces diremos que dicho lenguaje es tipado, pues la validez de una operación no solo depende de que estén definidos los símbolos que participan, sino de **cómo** están definidos dichos símbolos. Un ejemplo de lenguaje no tipado es el lenguaje para expresiones que definimos en la sección *[Diseño de un AST]*.

Una forma usual de clasificar a los lenguajes tipados es la distinción entre tipado *dinámico* y *estático*. En ambos casos cada expresión, variable y método tiene asociado un tipo que define las operaciones válidas. La diferencia fundamental radica en que en los lenguajes con tipado estático, además existe una *declaración explícita* del tipo que deseamos para una expresión, variable, método, etc. Esto lo hacemos con la esperanza de poder capturar en la fase de chequeo semántico la mayor cantidad de errores asociados a inconsistencias de tipos posibles. En los lenguajes con tipado dinámico las inconsistencias de tipos no pasan desapercibidas, simplemente se espera hasta la ejecución para detectarlas.

En general, la discusión entre si es preferible el tipado estático o dinámico es futil. En muchas ocasiones, es conveniente tener lo antes posible una validación de que la expresión que queremos compilar no tendrá inconsistencias de tipos, y por este motivo surgieron los lenguajes con tipado estático. Por otro lado, es inevitable que existan circunstancias en las que el compilador será incapaz de inferir exactamente el tipo real que tendrá una expresión y nos impedirá realizar alguna operación cuando en realidad dicha operación sería posible. Por ejemplo, si tenemos la siguiente declaración de clases en C#:

```cs
class A {
    public void F() { /* ... */ }
}

class B : A {
    public void G() { /* ... */ }
}
```

El siguiente fragmento código da error de compilación pues el tipo declarado para la variable `a` es `A`, donde no está definida la operación `G`, aunque sabemos que en caso de ejecutar, no existiría realmente ningún error de inconsistencia de tipos, pues el tipo real del objeto almancenado en `a` es `B`:

```cs
A a = new B();
a.G();
```

Por analogía, le llamaremos *tipo estático*  al tipo declarado de una variable, atributo, método, o cualquier construcción sintáctica que almacene o produzca un valor, y *tipo dinámico* al tipo asociado a dicho valor durante la ejecución del programa. Es decir, en el caso anterior, `a` es una variable con tipo estático `A`, pero que en tiempo de ejecución almacena un objeto cuyo tipo dinámico es `B`. Más adelante podremos formalizar esta noción.

En esta sección nos dedicaremos entonces a construir un **verificador de tipos**, que nos es más que un algoritmo que nos dirá si todos los usos de tipos en nuestro AST son consistentes. Idealmente, queremos que nuestro verificador de tipos nos permita decidir exactamente cuáles programas hacen un uso consistente de los tipos, pero como hemos visto en el ejemplo anterior, en ocasiones es imposible determinar exactamente cuál será el tipo dinámico de una expresión en tiempo de ejecución. En estos caso, generalmente preferimos errar por exceso, es decir, evitar la ejecución de aquellos programas donde *podría* existir una inconsistencia de tipos, aunque en la realidad no suceda. Cuando un verificador de tipos cumple esta propiedad, decimos que es *consistente*. Es decir, un verificador consistente detecta todos los programas con errores de tipo, aunque puede decidir erróneamente que un programa correcto es incorrecto. Por supuesto, queremos reducir al mínimo posible este segundo caso.

En los lenguajes tipados es muy común que se permita construir *jerarquías de tipos*. Estas jeraquías se construyen mediante una operación, denominada generalmente **herencia**, que define que un tipo `B` es un *subtipo* del tipo `A`. La semántica exacta de la herencia varía de lenguaje en lenguaje, pero en general significa que todas las operaciones definidas para `A` también lo están para `B`, aunque `B` puede introducir nuevas operaciones (métodos, atributos, etc.), o *sobrescribir* la implementación de algunas de las operaciones definidas en `A`.

Esta sobrescritura generalmente se asocia al nombre de **polimorfismo**, que para nuestro interés simplemente será el mecanismo que permite que una expresión `a.f()` se traduzca como la ejecución de una implementacion particular de `f` que depende del tipo dinámico de `a`, y no simplemente la implementación definida en el tipo estático. A este proceso le llamamos *resolución de métodos virtuales*.

Las reglas de la herencia varían en diversos lenguajes de programación, pero en general se distinguen dos grandes paradigmas, los lenguajes con *herencia simple*, donde cada tipo puede heredar de un solo tipo "padre", y los lenguajes con herencia múltiple. En los primeros, la jerarquía de tipos es un árbol (o conjunto de árboles, si no existe un tipo base de todos los tipos), y en el segundo caso la jerarquía de tipos se comporta como un grafo dirgido y acíclico (por supuesto, la herencia cíclica es, en principio, imposible). Del mismo modo que con los lenguajes estáticos y dinámicos, existen argumentos a favor y en contra de cada paradigma, aunque de forma general, los lenguajes con herencia simple son más sencillos de verificar que los lenguajes con herencia múltiple.

En cualquier caso, de forma general existe una relación entre los tipos de una jerarquía, que llamaremos **relación de conformidad**, y denotaremos $B \leq A$, es decir, $B$ *se conforma a* $A$, si se cumple que $B$ hereda de $A$ o, recursivamente, si hereda de algún tipo $C$ que se conforme a $A$. Verificar esta relación de conformidad en una implementación concreta de un verificador de tipos implica recorrer el árbol o grafo de la jerarquía de tipos. De momento asumiremos la relación como dada, y más adelante veremos ideas para su implementación en un ejemplo concreto.

## Verificando tipos

De modo que el problema que tenemos que resolver es, para un nodo particular del AST, si el uso de los tipos es consistente. Este proceso en general lo haremos *bottom-up*, ya que la consistencia del uso de tipos en una expresión particular dependerá de los tipos en sus partes componentes. Por lo tanto, en un recorrido en post-orden del AST, iremos computando los tipos asociados a los nodos "hijos", y en el retorno chequearemos en cada "padre" la consistencia y computaremos el tipo del padre. Por ejemplo, si estamos en un nodo `SumExpr` que representa una expresión binaria de suma, podemos decir que este nodo es consistente si y solo sí cada una de las expresiones son a su vez consistentes, y son de tipo `int`, y la expresión en general es de tipo `int` también:

```cs
class SumExpr : Expression {
    public Expression Left;
    public Expression Right;
    public Type NodeType;

    public bool CheckTypes() {
        if (!Left.CheckTypes() || !Right.CheckTypes()) {
            return false;
        }

        if (Left.NodeType != Type.Integer ||
            Right.NodeType != Type.Integer) {
            return false;
        }

        NodeType = Type.Integer;
        return true;
    }
}
```

De este modo, recursivamente, podemos computar el tipo de todas las expresiones de un lenguaje (todos los posibles nodos de un AST). Vamos a definir a continuación una notación formal para expresar esta noción del chequeo de tipos de forma recursiva. La notación que definiremos tiene la forma de una demostración en el lenguaje de la lógica de predicados. Comienza con una lista de precondiciones lógicas (sobre los tipos de las sub-expresiones), y termina con una conclusión que dice cuál es el tipo de la expresión actual. Por ejemplo, para el caso anterior, podemos escribir:

$$
\begin{array}{l}
e_1 : Integer \\
e_2 : Integer \\
\hline
\vdash e_1 + e_2 : Integer
\end{array}
$$

Podemos leer esta expresión de la siguiente forma: si $e_1$ es una expresión de tipo $Integer$ y $e_2$ es una expresión de tipo $Integer$, entonces se deduce que la expresión $e_1 + e_2$ es de tipo $Integer$. El símbolo $\vdash$ significa "se deduce que".

## Contextos

Una pregunta interesante es ¿qué sucede con las variables? Dado que estamos en un recorrido *bottom-up*, nos encontraremos la declaración de una variable luego de su uso. Luego, si nos encontramos un nodo `VarExpr` que representa el uso de una variable, ¿qué tipo le asociamos? En la sección *[Validando las reglas semánticas]* introdujimos el concepto de *contexto*, para almacenar las declaraciones anteriores, de forma que siempre supiéramos qué símbolo estaba declarado en cualquier expresión. Ahora vamos a extender este contexto, para especificar no solo los símbolos declarados, sino qué tipo está asociado a cada símbolo. Vamos a introducir entonces una función $O$ que llamaremos *contexto de objetos*, y que usaremos de la forma $O(x) = T$ para decir que este nodo existe un símbolo $x$ definido con tipo estático declarado $T$. Por tanto, extenderemos nuestra notación para incluir el contexto de objetos como parte de las precondiciones y la conclusión. Luego, la expresión suma quedaría de la forma:

$$
\begin{array}{l}
O \vdash e_1 : Integer \\
O \vdash e_2 : Integer \\
\hline
O \vdash e_1 + e_2 : Integer
\end{array}
$$

Que podemos leer de la siguiente forma: si dado el contexto de objetos $O$, podemos deducir (recursivamente) que el tipo de $e_1$ es $Integer$ (e igual para $e_2$), entonces en este mismo contexto de objetos podemos deducir que el tipo de $e_1 + e_2$ es $Integer$. Es importante notar que hemos dicho $O \vdash e : T$, y no $O(e) = T$, pues $e$ es una expresión en el sentido general, y $O$ solamente está definido para símbolos (variables, atributos, etc.). Por tanto, $O \vdash e : T$ nos indica que es necesario chequear el tipo de $e$ recursivamente en el contexto $O$ para computar el tipo que tiene la expresión.

Los contextos de objetos se modifican cuando aparecen expresiones (instrucciones) que introducen nuevos símbolos (e.g. declaraciones de variables). Supongamos entonces que tenemos una expresión de la forma $T x \is e$, que indica que la variable $x$ se define con el tipo $T$ y se inicializa con la expresión $e$. Este es el tipo de instrucción que comunmente vemos en lenguajes tipo C para inicializar una variable recién declarada:

```cs
int x = 4 + int.Parse(Console.ReadLine());
```

En esta instrucción se introduce un nuevo símbolo en el contexto de objetos, con el nombre $x$, y el tipo $T$. Luego, es necesario verificar que el tipo de la expresión $e$ se conforme al tipo $T$, y luego definir el tipo de retorno de toda la expresión. En el caso particular de C, una instrucción de tipo asignación como esta no puede ser usada como expresión, y por tanto no devuelve valor, así que usaremos el símbolo $\emptyset$ para especificar que no tiene asociado (equivalente a `void`). Para especificar la modificación del contexto de objetos, introduciremos la sintaxis $O[T/x]$ que significa, informalmente, un nuevo contexto de objetos con las mismas definiciones que tenía $O$, pero además adicionando la definición del símbolo $x$ con tipo $T$. Formalmente:

$$
O[T/x](c) = \left\{ \begin{array}{ll} T & c = x \\ O(c) & c \neq x \end{array} \right.
$$

Armados con esta nueva notación, podemos definir la semántica de un nodo de declaración e inicialización:

$$
\begin{array}{l}
O \vdash e : T' \\
T' \leq T \\
\hline
O[T/x] \vdash T x \is e : \emptyset
\end{array}
$$

Podemos leer esta definición de la siguiente forma: si en el contexto actual el tipo de la expresión $e$ es $T'$, y $T'$ conforma a $T$, entonces en un nuevo contexto definimos $x$ con tipo $T$, y el tipo de retorno de la expresión es `void`.

El otro problema de interés es cuando nos encontramos con la declaración o invocación de un método. De forma general, vamos a considerar que es permitido sobrescribir la implementación de un método $A.f$ en una clase $B \leq A$, siempre y cuando el tipo declarado de los parámetros de $f$ y el tipo de retorno de $f$ no cambien. Esto es lo que sucede en la mayoría de los lenguajes de tipado estático. En este caso, desde el punto de vista del chequeo de tipos, no nos interesa realmente cuál es la implementación concreta de $f$, ya que todas las implementaciones coinciden en cuanto a las definiciones de tipos.

Vamos a introducir entonces un nuevo tipo de contexto $M$, que llamaremos *contexto de métodos*, y que usaremos de la forma $M(T,f) = \left\{ T_1, \ldots, T_{n+1} \right\}$, para expresar que el método $f$ definido en el tipo $T$ (o definido en algún tipo $T'$ tal que $T \leq T'$), tiene $n$ argumentos de tipo $T_1, \ldots, T_n$, y tipo de retorno $T_{n+1}$. El contexto $M$ no se modifica, sino que se construye en un primer recorrido por el AST, y luego simplememente sirve para consultar. De modo que asumiremos que en todo momento durante el chequeo de tipos, ya son conocidos de antemano todos los métodos declarados en todos los tipos accesibles por el programa que está siendo compilado.

Tenemos entonces dos tipos de expresiones interesantes, la *declaración* de un método, y la *invocación*. Comenzaremos por la invocación de un método de instancia. Supongamos una sintaxis de la forma $x \cdot f(e_1, \ldots, e_n)$ para la invocación de métodos. Tenemos entonces que verificar el tipo de la expresión $x$, obtener el método $f$ asociado a ese tipo, verificar la conformación de los tipos de los argumentos, y entonces podemos computar el tipo de $f$:

$$
\begin{array}{l}
O \vdash x : T \\
M(T,f) = \left\{ T_1, \ldots, T_{n+1} \right\} \\
O \vdash e_i : T_i' \,\,\, \forall i = 1 \ldots n \\
T_i' \leq T \,\,\, \forall i = 1 \ldots n \\
\hline
O,M \vdash x \cdot f(e_1, \ldots, e_n) : T_{n+1}
\end{array}
$$

La invocación de un método estático es muy similar. Supongamos una sintaxis de la forma $T \cdot f(e_1, \ldots, e_n)$, la diferencia fundamental es que no es necesario computar el tipo de la expresión a quién se le invoca el método, pues la clase está definida explícitamente. Todo lo demás es prácticamente idéntico.

$$
\begin{array}{l}
M(T,f) = \left\{ T_1, \ldots, T_{n+1} \right\} \\
O \vdash e_i : T_i' \,\,\, \forall i = 1 \ldots n \\
T_i' \leq T \,\,\, \forall i = 1 \ldots n \\
\hline
O,M \vdash T \cdot f(e_1, \ldots, e_n) : T_{n+1}
\end{array}
$$

Para poder formalizar la declaración de métodos, tenemos que introducir un nuevo elemento en nuestra notación, que llamaremos $C$, y que representará la *clase* actual donde se está realizando la verificación de la expresión correspondiente. En los lenguajes sin orientación a objetos (C) o donde no todo el código reside dentro de una clase (C++, Python), podemos definir un tipo especial $\Omega$ que representa el contexto "global". En última instancia, lo que queremos es poder diferenciar un método $f$ de otro del mismo nombre pero definido en un contexto diferente. Las clases son una de las posibles formas de definir un contexto, pero nada nos impide extender esta noción e incluir un contexto global. En algunos lenguajes se le llama *espacio de nombres* o **namespace** a un contexto donde todos los símbolos son de nombre distinto. En Python, por ejemplo, cada módulo define un nuevo espacio de nombres, donde los símbolos definidos ocultan, pero no sobrescriben a los símbolos definidos en otro módulo.

Por otro lado, vamos a extender el concepto de contexto de objetos, para especificar $O_C$ como el contexto específico dentro de la clase $C$. Es decir, en este contexto daremos por supuesto que ya están definidos todos los atributos y métodos de $C$, que son visibles dentro del cuerpo de cada función. Por ejemplo, en C# serían todos los campos declarados en $C$ o declarados en algún padre de $C$ con la visibilidad adecuada (no `private`).

Podemos entonces presentar una formalización de la semántica de tipos la definición de métodos. Supongamos una sintaxis de la forma:

$$f(x_1 : T_1, \ldots, x_n : T_n) : T \{ e \}$$

Donde $x_i : T_i$ representa un argumento de $f$ de nombre $x_i$ y tipo $T_i$, $T$ es el tipo de retorno, y $e$ representa el cuerpo del método (visto como una expresión para simplificar).

A grandes razgos el proceso es el siguiente: se definen los argumentos $x_i$ en el contexto de objetos hijo de $O_C$ donde se va a verificar la expresión $e$ y se verifica que el tipo del cuerpo conforme al tipo declarado de la función. Un tratamiento especial es necesario para el valor asociado a la instancia actual, que generalmente se llama `this` (C#) o `self` (Python). Por definición este símbolo en la instancia donde se está definiendo el método tiene exactamente el tipo $C$:

$$
\begin{array}{l}
M(C,f) = \{ T_1, \ldots, T_n, T \} \\
O_C[T_1/x_1,\ldots,T_n/x_n,C/self] \vdash e : T' \\
T' \leq T \\
\hline
O_C,M,C \vdash f(x_1 : T_1, \ldots, x_n : T_n) : T \{ e \}
\end{array}
$$

Existen disímiles expresiones con reglas de tipos diversas pero, a grandes razgos, hemos mostrado cómo luce la formalización de la semántica de tipos de una expresión arbitraria. Armados con los conceptos de contexto de objetos y métodos, y una definición formal de la semántica de tipos para un lenguaje concreto de ejemplo, ya estamos en condiciones de implementar un verificador de tipos.

## Implementando un verificador de tipos

Para implementar un verificador de tipos necesitamos concretar dos elementos: una clase que nos permita manejar el contexto de objetos y el contexto de métodos, y un algoritmo para recorrer el AST. Vamos a ejemplificar algunos detalles de implementación, asumiendo un lenguaje orientado a objetos muy simple, con las siguientes características:

* Un programa consiste en una lista de definiciones de clases.
* Todas las clases se definen en el mismo espacio de nombres global.
* Cada clase tiene atributos y métodos.
* Los atributos tienen un tipo asociado.
* Los métodos tienen un tipo de retorno (que puede ser `void`), y una lista de argumentos.
* Todos los atributos son privados y todos los métodos son publicos.
* Existe herencia simple.
* Un método se puede sobrescribir sí y solo sí se mantiene exactamente la misma definición para los tipos de retorno y de los argumentos.
* No existen sobrecargas de métodos ni de operadores.
* El cuerpo de todo método es una expresión.

No vamos a especificar formalmente qué tipos de expresiones son válidas en este lenguaje, pero de forma general podemos pensar en ciclos, condicionales, expresiones aritméticas, inicializaciones (`new T()`), invocaciones a métodos, etc. En fin, todos los tipos de expresiones comunes en un lenguaje orientado a objetos moderno. Solamente formalizaremos algunas de estas expresiones cuando nos interese mostrar la implementación.

Comencemos por representar los conceptos de tipo, atributo y método:

```cs
interface IType {
    string Name { get; }
    IAtribute[] Attributes { get; }
    IMethod[] Methods { get; }
    IAttribute GetAttribute(string name);
    IMethod GetMethod(string name);
    bool DefineAttribute(string name, IType type);
    bool DefineMethod(string name, IType returnType,
                      string[] arguments, IType[] argumentTypes);
}

interface IAttribute {
    string Name { get; }
    IType Type { get; }
}

interface IMethod {
    string Name { get; }
    IType ReturnType { get; }
    IAttribute[] Arguments { get; }
}
```

 Para representar un contexto podemos usar la siguiente *interface*, similar al contexto que hemos usado anteriormente en la sección *[Validando las reglas semánticas]*, pero modificada para adaptarse las definiciones anteriores:

```cs
interface IContext {
    IType GetType(string typeName);
    IType GetTypeFor(string symbol);
    IContext CreateChildContext();
    bool DefineSymbol(string symbol, IType type);
    IType CreateType(string name)
}
```

Esta *interface* básicamente nos representa el contexto de objetos. El contexto de métodos realmente lo tenemos modelado como parte de la definición de cada tipo, por lo que no es necesario tener un contexto de métodos global. El propio tipo $C$ nos permitirá acceder al contexto de métodos del tipo actual. Por otro lado, para acceder al contexto de métodos de un tipo específico, basta resolver la instancia de `IType` correspondiente (mediante el método `GetType`).

Vamos a definir entonces un subconjunto de los nodos del AST que nos interesa modelar. Comenzaremos como siempre por una clase base:

```cs
public abstract class Node {

}
```

Nuestro siguiente nodo es un programa, que se compone de una lista de definiciones de clase:

```cs
public class Program : Node {
    public List<ClassDef> Classes;
}
```

Cada definición de clase a su vez define un tipo con un nombre y una lista de atributos y métodos:

```cs
public class ClassDef : Node {
    public string Name;
    public List<AttrDef> Attributes;
    public List<MethodDef> Methods;
}
```

Los atributos se definen como un nombre, tipo asociado, y una expresión de inicialización:

```cs
public class AttrDef : Node {
    public string Name;
    public string Type;
    public Expression Initialization;
}
```

Mientras que los métodos se definen como un nombre, una lista de argumentos (nombres y tipos), un tipo de retorno, y un cuerpo que es una expresión:

```cs
public class MethodDef : Node {
    public string Name;
    public string ReturnType;
    public List<string> ArgNames;
    public List<string> ArgTypes;
    public string ReturnType;
    public Expression Body;
}
```

Luego nos quedarían todos los nodos de la jerarquía de expresiones, que no mostraremos por simplicidad.

Centraremos a continuación nuestra atención en el problema de la verificación en sí. De forma general, primero tenemos que hacer un recorrido por todo el AST para encontrar todas las definiciones de tipos. Este primer paso es necesario antes de verificar los métodos o atributos de un tipo particular, ya que podemos tener una declaración de un tipo `A` con un atributo de tipo `B`, donde la declaración del tipo `B` aparece luego de la declaración de `A`. Por este motivo, es necesario recolectar primero todos los nombres de todas las clases declaradas y adicionarlos al contexto. Luego es necesario volver a recorrer todo el AST pero esta vez recogiendo las declaraciones de métodos y atributos, a quienes ya podemos asociar los tipos correspondientes. Esta segunda vez también es necesaria antes de pasar a analizar el cuerpo de los métodos, pues podemos tener un método `F` llamando a otro método `G` que está definido posteriormente. De esta forma completamos el contexto de métodos, y podemos finalmente recorrer el AST una vez más, esta vez adentrándonos en el cuerpo de los métodos y verificando la semántica de las expresiones.

De modo que necesitamos hacer al menos 3 pasadas por el AST, ya que podemos tener definiciones que usen a su vez símbolos definidos posteriormente. Para evitar esto, en lenguajes como C y C++ es necesario declarar de antemano en archivo *header* (con extensión `.h`) los símbolos que luego serán definidos (en un archivo `.c`).

Una primera aproximación a este problema nos lleva a definir al menos 3 métodos recursivos, uno para buscar las definiciones de tipos, otro para los métodos y atributos, y otro finalmente para la semántica. A medida que nuestro lenguaje crece, la semántica se complica, y aparecen nuevas fases (como la generación de código que veremos más adelante), notaremos que se repite este patrón de recorrer todo el AST buscando algunos nodos particulares y haciendo algunas operaciones en ellos. Por lo tanto, esta solución de definir un método recursivo para cada posible recorrido por el AST se vuelve cada vez menos atractivo. Cada vez que adicionamos algún tipo de chequeo tendremos que modificar la jerarquía del AST para acomodar los métodos recursivos necesarios. Por otro lado, si decidimos introducir un tipo de nodo nuevo (porque nuestra gramática ha cambiado o porque es conveniente especializar alguna función semántica), tendremos que redefinir todos estos métodos de chequeo en consecuencia. Por último, la mayoría de estos métodos recursivos se van a parecer mucho, pues todos tienen que descender recursivamente por los nodos del AST, y realizar alguna operación en pre-orden o post-orden.

El problema que tenemos aquí es un caso típico de acoplamiento, que nos lleva a una replicación de comportamiento similar. Tenemos que reconocer que existen dos responsabilidades diferentes en cada uno de estos casos: una es la que juega cada nodo del AST, que consiste en representar la función semántica correspondiente; y la otra es justamente el procesamiento necesario a realizar en un nodo para verificar algún predicado semántico. Vamos entonces a separar la responsabilidad de procesar a un nodo del nodo en sí, y ponerla en una clase distinta. A este diseño que presentaremos se le denomina el **patrón visitor**, y es uno de los patrones de diseño más populares y útiles, especialmente en la implementación de compiladores.

## El Patrón Visitor

Comenzaremos por definir la siguiente *interface*:

```cs
interface IVisitor<TNode> where TNode : Node {
    void Visit(TNode node);
}
```

La *interface* `IVisitor<TNode>` nos permitirá abstraer el concepto de procesamiento sobre un nodo. En cada implementación particular, escogeremos qué procesamiento realizar sobre cada tipo de nodo particular, y cómo "caminar" sobre la porción de AST correspondiente. Veamos entonces como implementar la primera pasada, que nos permite recolectar todos los tipos definidos. Este *visitor* solamente se interesa en nodos de tipo `Program` y nodos de tipo `ClassDef`. Su tarea consiste en crear un contexto, y definir en este contexto todos los tipos que se encuentre:

```cs
public class TypeCollectorVisitor: IVisitor<Program>,
                                   IVisitor<ClassDef> {
    public IContext Context;

    public void Visit(Program node) {
        Context = new // ...

        foreach(var classDef in node.Classes) {
            this.Visit(classDef);
        }
    }

    public void Visit(ClassDef node) {
        Context.CreateType(node.Name);
    }
}
```

El llamado `this.Visit(classDef)` resolverá estáticamente la sobrecarga adecuada. Veamos ahora como implementar un *visitor* que construya todo el contexto de métodos y atributos. En este caso, nos interesan además los nodos de tipo `AttrDef` y `MethodDef`:

```cs
public class TypeBuilderVisitor : IVisitor<Program>,
                                  IVisitor<ClassDef>,
                                  IVisitor<AttrDef>,
                                  IVisitor<MethodDef> {

    public IContext Context;
    private IType currentType;

    public void Visit(Program node) {
        foreach(var classDef in node.Classes) {
            this.Visit(classDef);
        }
    }

    public void Visit(ClassDef node) {
        currentType = Context.GetType(node.Name);

        foreach(var attrDef in node.Attributes) {
            this.Visit(attrDef);
        }

        foreach(var methodDef in node.Methods) {
            this.Visit(methodDef);
        }
    }

    // ...
}
```

Hasta este punto simplemente hemos descendido por las definiciones de tipos hasta llegar a cada definición de atributo o método. En cada paso, nos hemos asegurado además de mantener una referencia al tipo concreto dentro del cual se están realizando las definiciones. Veamos entonces los métodos restantes:

```cs
public class TypeBuilderVisitor : IVisitor<Program>,
                                  IVisitor<ClassDef>,
                                  IVisitor<AttrDef>,
                                  IVisitor<MethodDef> {

    public IContext Context;
    private IType currentType;

    // ...

    public void Visit(AttrDef node) {
        IType attrType = Context.GetType(node.Type);
        currentType.DefineAttribute(node.Name, attrType);
    }

    public void Visit(MethodDef node) {
        IType returnType = Context.GetType(node.ReturnType);
        var argTypes = node.ArgTypes.Select(t => Context.GetType(t));

        currentType.DefineMethod(node.Name, returnType,
                                 node.ArgNames.ToArray(),
                                 argTypes.ToArray());
    }
}
```

Por último, tendremos un `TypeCheckerVisitor` que verificará finalmente la consistencia de tipos en todos los nodos del AST. Este implementará la *interface* `IVisitor<T>` en cada tipo de nodo que sea capaz de chequear, incluidos todos los tipos de expresiones e instrucciones que no hemos definido. A este `TypeCheckerVisitor` le pasaremos el contexto ya construido anteriormente, y lo dejaremos procesar todo el AST. Este *visitor* además de verificar el tipo de todas las expresiones, será el encargado de computar el tipo asociado a cada expresión y almacenarlo en el nodo `Expression`:

```cs
public abstract class Expression {
    public IType ComputedType;
}
```

Hemos obviado hasta el momento cualquier consideración de error. Si alguno de los tipos definidos para alguno de los atributos o métodos no es válido, o alguno de los tipos aparece declarado más de una vez, o cualquier otro error semántico es detectado, nuestro verificador lanzará una excepción, o peor, fallará silenciosamente. Para manejar los errores de forma consistente, adicionaremos a los métodos `Visit` un argumento `IErrorLogger` con la *interface* siguiente:

```cs
public interface IErrorLogger {
    void LogError(string msg);
}
```

De modo que ante un error cualquier de chequeo de tipos, simplemente nos remitiremos a este objeto para indicar que ocurrió un error. Una vez detectado el error, la pregunta que queda es ¿qué hacer a continuación? Si detenemos el chequeo entonces nuestro compilador solamente será capaz de detectar un error en cada iteración, pero idealmente quisiéramos indicar la mayor cantidad de errores posibles en cada corrida. Por lo tanto, lo que se sugiere es tomar alguna acción de reparo sensata y continuar la verificacion. Por ejemplo:

```cs
public class TypeCheckerVisitor : IVisitor<...> {
    public Context Context;

    public void Visit(BinaryExpr node, IErrorLogger logger) {
        this.Visit(node.Left, logger);
        this.Visit(node.Right, logger);

        if (node.Left.ComputedType != node.Right.ComputedType) {
            logger.LogError("Type mismatch...");
            node.ComputedType = null;
        }
        else {
            node.ComputedType = node.Left.ComputedType;
        }
    }
}
```

Con estas herramientas, podemos adicionar un método en la clase `Program` que realice todas las pasadas correspondientes:

```cs
public class Program : Node {
    // ...

    public void CheckSemantics(IErrorLogger logger) {
        var typeCollector = new TypeCollectorVisitor();
        typeCollector.Visit(this, logger);

        var typeBuilder = new TypeBuilderVisitor() {
            Context = typeCollector.Context
        };

        typeBuilder.Visit(this, logger);

        var typeChecker = new TypeCheckerVisitor() {
            Context = typeBuilder.Context;
        };

        typeChecker.Visit(this, logger);
    }
}
```
