---
previous-chapter: chap0
next-chapter: chap2
---

# Análisis Lexicográfico




En este capítulo vamos a atacar el problema de implementar un *lexer*, y todos los elementos teóricos que nos ayudarán en esta tarea, y que nos servirán además para resolver problemas independientes pero relacionados con esta fase. Vamos a comenzar definiendo formalmente el problema que queremos resolver, y luego veremos como desarrollar una teoría que nos permita atacar su solución. Para ello:

* Definiremos el concepto de [*token*](#tokens).
* Diseñaremos [autómatas finitos deterministas](#dfa) para reconocer lenguajes regulares.
* Caracterizaremos los [lenguajes regulares](#regular).
* Conoceremos las [expresiones regulares](#expreg) para describir esta clase de lenguajes.
* Veremos un algoritmo [convertir expresiones regulares en autómatas](#regnfa).
* Aprenderemos sobre las [operaciones entre lenguajes regulares](#opers).
* Y por si fuera poco, veremos finalmente [los límites de los lenguajes regulares](#pumping).

## Los *tokens* de nuestro lenguaje {#tokens}

Comenzaremos por definir el concepto de *token*, básicamente, como una secuencia de caracteres con cumple con cierta estructura sintáctica. Más adelante impondremos restricciones sobre qué tipos de estructuras son válidas. De momento, pondremos algunos ejemplos:

* Las palabras claves de un lenguaje: **if**, **else**, **function**, **class**, etc.
* Los literales numéricos: `42`, `3.1415`, `0.123e-44`, etc.
* Los literales de cadena: `"hello world!"`, etc.
* Los literales booleanos: `True`, `False`.
* Los operadores: `+`, `-`, `*`, `<`, `<=`, etc.
* Identificadores: `x`, `value`, `someMethodName`, etc.

De modo que queremos idear un mecanismo que reciba como entrada una descripción del conjunto de *tokens* de nuestro lenguaje, y una cadena de caracteres, y nos devuelva la secuencia de *tokens* que aparecen en la cadena.

Un primer análisis nos puede llevar a pensar idea similar a dividir la cadena por espacios en blanco y quedarnos con cada elemento como un *token*, pero es muy sencillo ver por qué esta idea no es suficiente. En primer lugar, existen *tokens* que no necesariamente aparecen separados por espacio, como en el caso de `value<=0.001`. Además, existen *tokens* que son prefijos de otros *tokens*, como `<` y `<=`; o `class` que es una palabra clave y `class1` que es un identificador cualquiera. Esto quiere decir que necesitamos realizar un análisis un poco más complejo para determinar qué parte de una secuencia de caracteres corresponde a un *token* o a *otro*.

Veamos el problema entonces desde el siguiente punto de vista: supongamos que escaneamos la secuencia de caracteres de inicio a fin, un caracter a la vez, y lo que deseamos es en cada momento ser capaces de determinar si estamos en el medio de un *token*, o si acabamos de reconocer un *token* completo. Por ejemplo, tomemos nuevamente la cadena de ejemplo del capítulo anterior:

    if (a<=0) b else c

Vamos a simbolizar con el símbolo `|` el punto que divide el fragmento de la cadena que hemos analizado, de la parte de la cadena que falta por analizar. Es decir, al inicio de nuestro procesamiento, estamos en el siguiente estado:

    |if (a<=0) b else c

Que simboliza que aún no hemos visto ningún caracter de la cadena. Queremos entonces idear una maquinaria que "avance" por la cadena, caracter a caracter, y en cada instante sepa determinar si con los caracteres vistos hasta el momento ya tiene un *token* construido, o si necesita seguir avanzando. Veamos paso a paso cómo podría funcionar un mecanismo así. Comenzamos con el inicio de la cadena, y vamos además a almacenar el fragmento de *token* que estamos construyendo, y la lista de *tokens* que vamos reconociendo como salida:

    CADENA: |if a<=0 then b else c
     TOKEN:
    SALIDA:

El primer paso consiste en analizar el caracter `i`. Cómo acabamos de empezar, no tenemos nada almacenado, entonces la única posibilidad es que este caracter `i` sea parte del *token* que estamos intentando reconocer.

    CADENA: i|f a<=0 then b else c
     TOKEN: i
    SALIDA:

Ahora vemos el caracter `f`. Cómo viene immediatamente después de otro caracter, pudiera ser que estemos viendo un *token* de tipo identificador. Por otro lado, pudiera ser que estuviéramos viendo particularmente el *token* `if`, que es una palabra clave. De momento, lo tomamos.

    CADENA: if| a<=0 then b else c
     TOKEN: if
    SALIDA:

Nos encontramos entonces con un espacio en blanco, lo que nos permite decidir que efectivamente hemos encontrado el *token* `if`, por lo que podemos devolverlo en la secuencia de salida.

    CADENA: if |a<=0 then b else c
     TOKEN:
    SALIDA: [if]

Ahora nos encontramos un caracter `a`, que pudiera ser un identificador, pero todavía no podemos decir nada al respecto pues es posible que el identificador tenga más letras.

    CADENA: if a|<=0 then b else c
     TOKEN: a
    SALIDA: [if]

En este paso nos encontramos un caracter `<`, y como estábamos tratando de reconocer un identificador que empieza con `a`, y nuestras reglas dicen que `<` no puede ser parte del nombre de ningún identificador, entonces podemos concluir que el *token* anterior es justamente `a`, y comenzar un nuevo *token*:

    CADENA: if a<|=0 then b else c
     TOKEN: <
    SALIDA: [if] [a]

Del mismo modo, hemos comenzado a construir un *token* `<`, que pudiera ser el operador en sí, o pudiera ser el operador `<=`, todo depende de lo que le siga. Al ver a continuación el caracter `=`, concluimos que tenemos el *token* `<=` sin necesidad de seguir buscando, pues no existe ningún *token* con prefijo `<=`.

    CADENA: if a<=|0 then b else c
     TOKEN:
    SALIDA: [if] [a] [<=]

Es fácil ver como continúa este proceso, llevando finalmente a la secuencia de *tokens* correcta:

    [if] [a] [<=] [0] [then] [b] [else] [c]

La pregunta consiste entonces en cómo implementamos este mecanismo computacionalmente. De modo general, la decisión que hemos tomado en cada paso depende únicamente de dos factores: el caracter que estamos examinando, y lo que hemos hecho hasta el paso anterior. Para modelar este segundo factor de "lo que hemos hecho hasta el paso anterior", analizemos primero de cuántas formas posibles podemos hablar de lo que hemos hecho hasta el paso anterior. Básicamente, tenemos un conjunto finito de clases de *tokens*, y lo que necesitamos saber es simplemente que clase de *token* estamos intentando construir, para saber si el nuevo caracter puede completar esta clase o no.

De modo que podemos pensar en una especie de **máquina de estados**, donde modelaremos con los estados el hecho de llevar la cuenta de qué clase de *token* estamos construyendo, y por ende, cuáles son los posibles caracteres a esperar a continuación. Esta máquina de estados es una clase particular de máquina de *Turing*, que tiene la característica de que solo puede moverse hacia la izquierda en la cinta y solo puede leer (no está permitido escribir). A las máquinas de estado que solo se mueven en una dirección en la cinta se les llama **autómatas**. Distintos tipos de autómatas se diferencian entonces por los tipos de transiciones que le son permitidas, y los tipos de análisis que pueden realizar para tomar una decisión. En este caso particular, estaremos definiendo la clase más sencilla de autómata, un **autómata finito determinista**.

## Autómatas Finitos Deterministas {#dfa}

Formalizando, un autómata finito determinista es un quíntuplo $A = <Q,q_0,V,F,f>$ con las siguientes características:

* $Q$ es un conjunto finito de estados ($Q = \{ q_0, \ldots, q_n \}$), de ahí el adjetivo de **finito**.
* $q_0 \in Q$ es el estado inicial.
* $V$ es un conjunto finito de símbolos que pueden aparecer en la cinta.
* $F \subseteq Q$ es un subconjunto de estados que denominaremos *estados finales*.
* $f: Q \times V \to Q$ es una *función de transición*, que determina, para cada par posible de estados y símbolos, cuál es el estado de destino. Se denomina un autómata **determinista** justamente porque en un estado particular, para un símbolo particular, existe solamente un estado posible de destino (o ninguno), por lo tanto, siempre existe una única decisión que tomar.

El modo de funcionamiento de un autómata finito determinista es el siguiente. Tenemos una cadena de entrada, que no es más que una secuencia de símbolos de $V$, o sea, un elemento $\omega \in V^k$ para algún valor de $k$ (que será la longitud de la cadena). El estado inicial del autómata es $q^{(0)} = q_0$. Por cada símbolo en $\omega_i \in \omega$, realizamos la operación $q^{(i)} = f(q^{(i-1)}, \omega_i)$. Al concluir, si $q^{(k)} \in V$, decimos que el autómata **acepta** o **reconoce** la cadena $\omega$.

Si en un caso particular la función $f(q_i,a_i)$ no estuviera definida, entonces diremos que el autómata "se traba", y no reconoce la cadena. Este convenio lo tomamos para evitar tener que definir un autómata completamente cuando existen muchos estados "superfluos". Siempre es posible convertir un autómata con algunas transiciones no definidas (*parcialmente especificado*) a un autómata con todas las transiciones definidas (*completamente especificado*), si añadimos un estado adicional $q_{error}$, a dónde apuntan todas las transiciones faltantes, y de donde salen además para el propio estado $q_{error}$ todas transiciones con todos los símbolos. Este estado sirve como especie de "sumidero".

Veamos entonces un ejemplo. Para representar gráficamente un autómata, usaremos un grafo dirigido para visualizar la función de transición, donde el nodo $i$ representa al estado $q_i$, y la artista $(i,j)$ está etiquetada con el símbolo $a_k$ si $f(q_i,a_k) = q_j$. Los estados finales se representan con un borde doble, y el resto de los estados con un borde normal.

Por ejemplo, si tenemos el siguiente autómata $A=<Q,q_0,V,F,f>$, donde:

* $Q = {q_0, q_1, q_2}$
* $V = \{a,b\}$
* $F = \{q_2\}$
* $f$ se define por la siquiente tabla:

    Estado | Símbolo | $f$
   --------+---------+-------
    $q_0$  |  $a$    | $q_1$
    $q_0$  |  $b$    | $q_0$
    $q_1$  |  $a$    | $q_2$
    $q_1$  |  $b$    | $q_0$
    $q_2$  |  $a$    | $q_2$
    $q_2$  |  $b$    | $q_0$

Podemos representar gráficamente el autómata anterior con el siguiente gráfico:



![](../graphics/image-chap1-1.svg){ #image-chap1-1 width=50% }\


En este gráfico queda completamente representado el autómata, sin necesidad de especificar el resto, pues de la función de transición se pueden inferir los estados y el alfabeto, y se toma el convenio de que el estado $q_0$ siempre es el estado inicial.

Cabe preguntarnos entonces la siguiente interrogante:

> ¿Qué lenguajes es capaz de reconocer un autómata finito determinista?

A responder esta pregunta dedicaremos la mayor parte del resto de este capítulo. Para comenzar, debemos formalizar primeramente la pregunta planteada. Necesitamos definir qué es un **lenguaje**, y qué significa que un autómata **reconozca** cierto lenguaje.

Para definir un lenguaje, comenzaremos con la definición de **alfabeto**. Un alfabeto $V$ no es más que un conjunto de símbolos, que son elementos básicos indivisibles. Por ejemplo, $V = \{a, b\}$ es el alfabeto que contiene los símbolos $a$ y $b$. El "significado" de cada símbolo no nos interesa en la teoría de lenguajes formales, solamente nos interesa diferenciar un símbolo de otro. Dejaremos el problema del "significado" para cuando lleguemos a la fase semántica.

Una vez armados con el concepto de alfabeto, podemos definir el concepto de **cadena**. Una cadena $\omega$ es un elemento del conjunto $V^k$ para algún valor de $k$ arbitrario. Por ejemplo, la cadena $abba$ es un elemento del conjunto $\{a,b\}^4$. Se llama *longitud* de la cadena justamente al valor $k$. Si $k=0$, tenemos la *cadena vacía*, que se simboliza generalmente como $\epsilon$ independientemente del conjunto $V$.

Finalmente, definiremos un **lenguaje** $L$, como un conjunto de cadenas sobre un alfabeto particular, o alternativamente, como un subconjunto de la clausura del producto cartesiano de dicho de alfabeto. Es decir, $L \subseteq V^*$, donde:

$$
V^* = \bigcup_{k=0}^{\infty} V^k
$$

Vamos a introducir entonces algo de notación adicional. Sea $A$ un autómata finito determinista, denominaremos $L_A$ al lenguaje de todas las cadenas reconocidas por $A$. Es decir, $\omega \in L_A$ si y solo $A$ reconoce $\omega$. Cabe entonces preguntarnos qué tipos de lenguajes pueden ser reconocidos por este mecanismo. Podemos entonces definir la interrogante anterior de manera más precisa cómo:

> ¿Qué características tienen los lenguajes que son posibles de reconocer por algún autómata finito determinista?

A este tipo de lenguajes les llamaremos **lenguajes regulares**, por motivos históricos que veremos más adelante. A modo definición:

> **Definición (Lenguaje Regular):** Sea $L$ un lenguaje sobre el alfabeto $V$, se dice que $L$ es **regular** si y solo si existe un autómata finito determinista $A=<Q,q_0,V,F,f>$ (sobre el mismo alfabeto), tal que $L = L_A$.

Pasemos entonces a describir algunos ejemplos de lenguajes regulares, que nos darán una idea intuitiva del poder de cómputo de estos autómatas.

## Lenguajes Regulares {#regular}

El más simple de todos los lenguajes que podemos definir sobre un alfabeto $V$ es justamente $V^*$, el lenguaje de todas las cadenas que se pueden construir con los símbolos de $V$. A este lenguaje le llamamos *universo*. Para construir un autómata para este lenguaje, simplemente necesitamos un estado que será a la vez inicial y final, y una transición para cada símbolo del alfabeto desde este estado hacia el propio estado. Por ejemplo, si $V = \{ a, b, c \}$, tenemos el siguiente autómata:



![](../graphics/image-chap1-2.svg){ #image-chap1-2 width=20% }\


Con esta idea podemos demostrar nuestro primer teorema en la teoría de lenguajes formales:

> **Teorema:** El lenguaje *universo* $L = V^*$ es regular.

La demostración se realiza por construcción. Sea $V = \{ a_1, \ldots, a_n \}$ el alfabeto, sea $A$ el autómata $<Q,q_0,F,V,f>$, donde $Q = F = \{ q_0\}$ y $f(q_0, a_i) = q_0$ para todo símbolo $a_i \in V$; entonces $A$ reconoce el lenguaje $V^*$.

Yendo al extremo contrario, vamos a definir el lenguaje que contiene exactamente las palabras claves **if**, **then**, **else**, **fi**. Para este lenguaje también es fácil definir un autómata. Creamos dos estados, uno inicial y uno final, y por cada palabra del lenguaje creamos un camino entre el estado inicial y final con un estado intermedio para cada símbolo de la palabra correspondiente (menos el último, claro):



![](../graphics/image-chap1-3.svg){ #image-chap1-3 width=80% }\


Este autómata nos da una idea para demostrar nuestro segundo teorema:

> **Teorema:** Sea $L = \{ \omega_1, \ldots, \omega_n \}$ un lenguaje *finito*, entonces $L$ es regular.

La demostración es muy sencilla, simplemente necesitamos construir un autómata que contenga un camino por cada cadena del lenguaje. Si existen cadenas con prefijos comunes, los estados correspondientes a los símbolos que participan en los prefijos se comparten (para mantener el determinismo, aunque veremos pronto que esto no es estrictamente necesario).

Para nuestro siguiente ejemplo, vamos a complejizar un poco el lenguaje a reconocer, y de paso veremos una estrategia general para la construcción de autómatas. El lenguaje que queremos reconocer es el lenguaje de las cadenas sobre el alfabeto $V = \{a, b\}$, con exactamente $3$ letras $a$. Antes de lanzarnos a construir el autómata, tratemos de pensar en una solución algorítmica para este problema. De forma general, la estrategia de solución sería algo así:


```python
def match(s: str) -> bool:
    count_a = 0

    for c in s:
        if c == 'a':
            count_a += 1

    return count_a == 3
```



Esta solución es correcta, pero padece de un problema que nos hace imposible convertirla en un autómata finito. El problema es justamente que la cantidad de memoria que usa esta solución es potencialmente *infinita*, o al menos, proporcional al tamaño de la cadena. ¿Por qué? Pues, porque hemos utilizado un contador no acotado superiormente (`count_a`), por lo que, en principio, podemos necesitar hasta $log_2(n)$ bits de memoria para una cadena con longitud $|w|=n$. Claro que en la práctica sabemos que ese entero es de 32 bits, independientemente del tamaño de la cadena, pero la idea que queremos transmitir es que *no hemos acotado la cantidad de memoria*, por lo que no sabemos cuántos estados debería tener un autómata que haga lo mismo que este método.

Una solución mejor consiste en notar que solamente hay 5 posibles situaciones:

* Hemos visto $0$ símbolos $a$.
* Hemos visto $1$ símbolo $a$.
* Hemos visto $2$ símbolos $a$.
* Hemos visto $3$ símbolos $a$.
* Hemos visto $4$ símbolos $a$ _o más_.

Una vez que hayamos visto $4$ veces una $a$ en la cadena, ya sabemos que la cadena es incorrecta, y no es posible que "se arregle" más adelante pues la cantidad de $a$ solo puede aumentar. Con esta idea en mente, cambiemos el método anterior para que solo use, a lo sumo, **5 valores diferentes** de la variable `count_a`:


```python
def match(s: str) -> bool:
    count_a = 0

    for c in s:     # esto es lo nuevo
        if c == 'a' and count_a <= 3:
            count_a += 1

    return count_a == 3
```



Parece que no hemos hecho mucho, pero hemos logrado garantizar que nuestro método solamente tiene a lo sumo **5 valores diferentes** de la variable `count_a`, a saber, $0 \ldots 4$. ¿De qué nos sirve esto? Pues, ahora podemos diseñar un autómata tranquilamente, con la siguiente idea: contamos la cantidad posible de valores que toman *todas las variables locales*, y por *cada combinación de valores* tendremos un estado. Si este número es finito, entonces tenemos un autómata finito (que puede ser o no determinista, ya llegaremos a ese problema).

En este ejemplo, tenemos entonces 5 posibles estados, desde $q_0$ hasta $q_4$. Para determinar las transiciones, veremos cómo cambian los valores en nuestro método. En todo momento, si tenemos un valor `count_a = qi`, en la siguiente iteración o bien `count_a = qi` o de lo contrario `count_a = qi + 1`, y esto solo ocurre si el símbolo recién "visto" es $a$. Esto nos dice entonces que tenemos entre los estados $q_i$ y $q_{i+1}$ siempre una transición con $a$, *excepto* en $q_4$, pues en ese caso no se cumple la condición `count_a <= 3`. Solo nos queda definir el estado final, y en este ejemplo no puede estar más claro, pues la línea `return count_a == 3` nos dice exactamente qué estado (valor de `count_a`) corresponde a un valor `True`. De modo que tenemos nuestro autómata:



![](../graphics/image-chap1-4.svg){ #image-chap1-4 width=70% }\


Lo que hemos hecho es un ejemplo de lo que informalmente llamamos "programar con autómatas". La idea fundamental radica en pensar en una solución algorítmica al problema de reconocer una cadena de cierto lenguaje $L$, y luego extraer de esta solución un autómata. Para que funcione, informalmente, la solución algorítmica debe cumplir:

1. Consiste en un método que recibe una cadena y devuelve verdadero o falso.
2. El método consiste en **una sola iteración** sobre la cadena, que analiza cada símbolo exactamente una vez.
3. La memoria local de dicho método, para cualquier cadena, *tanto si pertenece o no* al lenguaje, debe alcanzar a lo sumo una cantidad **finita** de valores diferentes (estos serán los estados de nuestro autómata).

Para obtener el autómata correspondiente, simplemente contamos *todos* los posibles valores que pueden alcanzar todas las variables locales de nuestro método, y definimos un estado por cada uno. Luego, analizando cómo cambian estos valores en función del símbolo siguiente en la cadena, se definen las transiciones (asumamos que son deterministas de momento). Los estados finales estarán determinidos por las combinaciones de valores para los cuáles el método devuelve `True`.

De manera general, informalmente, podemos decir que los lenguajes regulares son todos aquellos cuyas cadenas pueden ser reconocidas mediante un método (función en un lenguaje de programación) que, usando *un solo recorrido* sobre la cadena, y una *cantidad finita de memoria (independiente del tamaño de la cadena)* es capaz de determinar *para toda cadena*, si pertenece o no al lenguaje. Si tal método existe, podremos construir un autómata equivalente.

## Expresiones Regulares {#expreg}

Ahora que ya sabemos cómo construir autómatas para cualquier lenguaje regular, y sabemos (intuitivamente) que el lenguaje de los *tokens* de un lenguaje de programación se puede definir como un lenguaje regular, nos dedicamos a la pregunta de cómo es mejor definir ese lenguaje. Evidentemente, podemos diseñar un autómata, de forma manual, que reconozca los *tokens*, pero esta tarea, incluso para los lenguajes más sencillos, es muy engorrosa. El problema radica en los autómatas son un mecanismo de cómputo, podemos decir, un mecanismo *procedural* o *imperativo*, para definir lenguajes. Para definir un autómata hay que decidir una cantidad de estados, el conjunto de estados finales y las transiciones. Todo esto no parece intuitivo de antemano. Por otro lado, un autómata es muy difícil de "leer" para un humano. Al mirar un autómata, identificar rápidamente el lenguaje que reconoce no es una tarea sencilla, mucho menos intuitiva.

De forma alternativa, pudiéramos desear tener un mecanismo *declarativo* que nos permita definir lenguajes de forma más sencilla, y de dónde sea posible de forma automática obtener el autómata correspondiente. Como sabemos de la experiencia anterior en otros lenguajes de programación, los humanos somos muchos mejores mientras mayor sea el nivel de abstracción, y las máquinas son mucho mejores mientras menor sea el nivel abstracción. ¡Justamente por esta diferencia es que surgió la ciencia de la compilación en sí misma! Estamos volviendo a enfrentarnos al mismo problema original, pero en una escala menor. Cabe preguntarnos entonces si podemos crear un mecanismo de "alto nivel" para definir lenguajes regulares, y una especie de "compilador" que transforme este mecanismo de alto nivel al autómata correspondiente.

## Convirtiendo expresiones regulares a autómatas finitos {#regnfa}

## Operaciones entre lenguajes regulares {#opers}

## Los límites de los lenguajes regulares {#pumping}
