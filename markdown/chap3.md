---
previous-chapter: chap2
next-chapter: chap4
---

# Parsing Ascendente (*Bottom-Up*)

En la sección anterior vimos las técnicas de parsing descendente, y aprendimos algunas de las limitaciones más importantes que tienen. Dado que el objetivo es poder predecir exactamente que producción es necesario ejecutar en cada momento, las gramáticas LL(1) tienen fuertes restricciones. En particular, deben estar factorizadas, y no pueden tener recursión izquierda (criterios que son necesarios pero no suficientes). Por este motivo, para convertir una gramática "natural" en una gramática LL(1) es necesario adicionar no-terminales para factorizar y eliminar la recursión, que luego no tienen ningún significado semántico. Los árboles de derivación de estas gramáticas son por tanto más complejos, y tienen menos relación con el árbol de sintaxis abstracta que queremos obtener finalmente (aunque aún no hemos definido este concepto formalmente).

Intuitivamente, el problema con los parsers descendentes, es que son demasiado exigentes. En cada momento, se quiere saber qué producción hay que aplicar para obtener la porción de cadena que sigue. En otras palabras, a partir de una forma oracional, tenemos que decidir cómo expandir el no-terminal más a la izquierda, de modo que la siguiente forma oracional esté "más cerca" de generar la cadena. Por este motivo se llama parsing descendente.

¿Qué pasa si pensamos el problema de forma inversa? Comenzamos con la cadena completa, y vamos a intentar reducir fragmentos de la cadena, aplicando producciones "a la inversa" hasta lograr reducir toda la cadena a `S`. En vez de intentar adivinar que producción aplicar "de ahora en adelante", intentaremos deducir, dado un prefijo de la cadena analizado, qué producción se puede "desaplicar" para reducir ese prefijo a una forma oracional que esté "más cerca" del símbolo inicial.  Si pensamos el problema de forma inversa, puede que encontremos una estrategia de parsing que sea más permisiva con las gramáticas.

Veamos un ejemplo. Recordemos la gramática "natural" no ambigua para expresiones aritméticas:

    E = T + E | T
    T = int * T | int | ( E )

Y la cadena de siempre: `int * ( int + int )`. Tratemos ahora de construir una derivación "de abajo hacia arriba", tratando de reducir esta cadena al símbolo inicial `E` aplicando producciones a la inversa. Vamos a representar con una barra vertical `|` el punto que divide el fragmento de cadena que hemos analizado del resto. De modo que empezamos por:

    |int * ( int + int )

Miramos entonces el primer token:

     int|* ( int + int )

El primer token de la cadena es `int`, que se puede reducir aplicando `T -> int` a la inversa. Sin embargo, esta reducción no es conveniente. ¿Por qué? El problema es que queremos lograr reducir hasta `E`, por tanto hay que tener un poco de "luz larga" y aplicar reducciones que, en principio, dejen la posibilidad de seguir reduciendo hasta `E`. Como no existe ninguna producción que derive en `T * w`, si reducimos `T -> int` ahora no podremos seguir reduciendo en el futuro. Más adelante formalizaremos esta idea. Seguimos entonces buscando hacia la derecha en la cadena:

     int *|( int + int )
     int * (|int + int )
     int * ( int|+ int )

En este punto podemos ver que sí es conveniente reducir `T -> int`, porque luego viene un `+` y tenemos, en principio, la posibilidad de seguir reduciendo aplicando `E -> T + E` en el futuro:

     int * ( T|+ int )

Avanzamos hacia el siguiente token reducible:

     int * ( T +|int )
     int * ( T + int|)

Aquí nuevamente podemos aplicar la reducción `T -> int`:

     int * ( T + T|)

Antes de continuar, dado que tenemos justo delante de la barra (`|`) un sufijo `T + T`, deberíamos darnos cuenta que es conveniente reducir `E -> T` para luego poder reducir `E -> T + E`:

     int * ( T + E|)
     int * ( E|)

En este punto, no hay reducciones evidentes que realizar, así que seguimos avanzando:

     int * ( E )|

Hemos encontrado entonces un sufijo `( E )` que podemos reducir con `T -> (E)`:

     int * T|

Luego reducimos `T -> int * T`:

     T|

Y finalmente reducimos `E -> T`:

     E

En este punto hemos logrado reducir al símbolo inicial toda la cadena. Veamos la secuencia de formas oracionales que hemos obtenido:

     int * ( int + int )
     int * ( T + int )
     int * ( T + T )
     int * ( T + E )
     int * ( E )
     int * T
     T
     E

Si observamos esta secuencia en orden inverso, veremos que es una derivación extrema derecha de `E -*-> int * ( int + int )`. Justamente, un parser ascendente se caracteriza porque construye una derivación extrema derecha en orden inverso, desde la cadena hacia el símbolo inicial. Tratemos ahora de formalizar este proceso. Para ello, notemos primero algunas propiedades interesante que cumple todo parser ascendente. Partimos del hecho que hemos dado como definición de un parser bottom-up:

> Un parser bottom-up construye una derivación extrema derecha de $S \rightarrow^* \omega$.

A partir de este hecho, que hemos dado como definición, podemos deducir una consecuencia muy interesante:

> Sea $\alpha \beta \omega$ una forma oracional en un paso intermedio de un parser ascendente.
> Sea $X \rightarrow \beta$ la siguiente reducción a realizar.
> Entonces $\omega$ es una cadena de terminales (formalmente $\omega \in T^*$).

Para ver por qué esto es cierto, basta notar que si la derivación que construiremos es extrema derecha, la aplicación de $X \rightarrow \beta$ en este paso solamente puede ocurrir si $X$ es el no-terminal más a la derecha. O sea, si $\alpha \beta \omega$ es el paso correspondiente, y reducimos por $X \rightarrow \beta$, entonces el siguiente paso es la forma oracional $\alpha X \omega$, donde $X$ es el no-terminal más a la derecha, debido justamente a que estamos construyendo una derivación extrema derecha.

Esta propiedad nos permite entonces entender que en todo paso de un parser ascendente, cada vez que sea conveniente reducir $X \rightarrow \beta$, es porque existe una posición (que hemos marcado con `|`), tal que $\alpha \beta | \omega$ es la forma oracional, donde $\alpha \beta \in \{ N \cup T \}^*$ y $\omega \in T^*$. Tenemos entonces dos tipos de operaciones que podemos realizar, que llamaremos **shift** y **reduce**. La operación **shift** nos permite mover la barra `|` un token hacia la derecha, lo que equivale a decir que analizamos el siguiente token. La operación **reduce** nos permite coger un sufijo de la forma oracional que está antes de la barra `|` y reducirla a un no-terminal, aplicando una producción a la inversa (o "desaplicando" la producción). Veamos nuevamente la secuencia de operaciones que hemos realizado, notando las que fueron **shift** y las que fueron **reduce**:

    |int * ( int + int )         | shift
     int|* ( int + int )         | shift
     int *|( int + int )         | shift
     int * (|int + int )         | shift
     int * ( int|+ int )         | reduce T -> int
     int * ( T|+ int )           | shift
     int * ( T +|int )           | shift
     int * ( T + int|)           | reduce T -> int
     int * ( T + T|)             | reduce E -> T
     int * ( T + E|)             | reduce E -> T + E
     int * ( E|)                 | shift
     int * ( E )|                | reduce T -> ( E )
     int * T|                    | reduce T -> int * T
     T|                          | reduce E -> T
     E                           | OK

Debido a estas operaciones, llamaremos a este tipo de mecanismos *parsers shift-reduce*. Veamos de forma general como implementar este tipo de parsers.

## Parsers *Shift-Reduce*

Notemos que la parte a la izquierda de la barra siempre cambia porque un sufijo es parte derecha de una producción, y se reduce a un no-terminal. La parte derecha solo cambia cuando un terminal "cruza" la barra y se convierte en parte del sufijo que será reducido en el futuro. De forma que la barra que la parte izquierda se comporta como una pila, ya que solamente se introducen terminales por un extremo, y se extraen símbolos (terminales o no-terminales) por el mismo extremo. La parte derecha es simplemente una secuencia de tokens, que se introducen en la pila uno a uno. Formalicemos entonces el funcionamiento de un parser *shift-reduce*.

Un parser *shift-reduce* es un mecanismo de parsing que cuenta con las siguientes estructuras:

* Una pila de símbolos `S`.
* Una secuencia de terminales `T`.

Y las operaciones siguientes:

* **shift**: Si $S = \alpha |$ es el contenido de la pila, y $T = c \omega \$$ la secuencia de terminales, entonces tras aplicar una operación **shift** se tiene en la pila $S' = \alpha c |$, y la secuencia de terminales ahora es $T' = \omega \$$. Es decir, se mete en la pila el token $c$.
* **reduce**: Si $S = \alpha \beta |$ el contenido de la pila, y $X \rightarrow \beta$ es una producción, entonces tras aplicar una operación **reduce $T \rightarrow \beta$** se tiene en la pila $S' = \alpha X |$. La secuencia de terminales no se modifica. Es decir, se extraen de la pila $| \beta |$ símbolos y se introduce el símbolo $X$ correspondiente.

Podemos definir entonces el proceso de parsing como:

> Sea $S = \emptyset$ la pila inicial, $T = \omega \$$ la cadena a reconocer, y $E$ el símbolo inicial, un parser shift-reduce reconoce esta cadena si y solo si existe una secuencia de operaciones **shift** y **reduce** tal que tras aplicarlas se obtiene $S = E$ y $T = \$$.

Es decir, un parser shitf-reduce básicamente tiene que aplicar operaciones *convenientemente* hasta que en la pila solamente quede el símbolo inicial, y se hayan consumido todos los tokens de la cadena de entrada. En este punto, se ha logrado construir una derivación extrema derecha de la cadena correspondiente. Por supuesto, existe un grado importante de no determinismo en esta definición, porque en principio puede haber muchas secuencias de operaciones shift-reduce que permitan llegar al símbolo inicial. Si asumimos que la gramática no es ambigua, y por tanto solo existe una derivación extrema derecha, podemos intuir que debe ser posible construir un parser que encuentre la secuencia de shift-reduce que produce esa derivación. Desgraciadamente esto no es posible para todo tipo de gramáticas libre del contexto, pero existen gramáticas más restringidas para las que sí es posible decidir de forma determinista en todo momento si la operación correcta es **shift** o **reduce**, y en el segundo caso a qué símbolo reducir.

Para simplificar la notación, en ocasiones identificaremos el estado de un parser shift-reduce en la forma $\alpha | \omega$, sobreentendiendo que el estado de la pila es $S = \alpha |$ y la cadena de entrada es $\omega \$$. Diremos además que un estado $\alpha | \omega$ es válido, si y solo si la cadena pertenece al lenguaje, y este estado forma parte de los estados necesarios para completar el parsing de forma correcta.

Este tipo de parsers son en la práctica los más usados, pues permiten reconocer una cadena (y construir la derivación) con un costo lineal en la longitud de la cadena (la misma eficiencia que los parsers LL), y permiten parsear gramáticas mucho más poderosas y expresivas que las gramáticas LL. De hecho, la mayoría de los compiladores modernos usan alguna variante de un parser shift-reduce. La diferencia entre todos ellos radica justamente en cómo se decide en cada paso qué operación aplicar. Formalicemos entonces el problema de decisión planteado. Tomemos de nuevo la gramática anterior, y recordemos que en el paso:

    int|* ( int + int )

Habíamos dicho que aunque era posible reducir `T -> int`, no era convieniente hacerlo, porque caeríamos en una forma oracional que no puede ser reducida a `E`. En particular, en este caso caeríamos en:

    T|* ( int + int )

Y sabemos intuitivamente que esta forma oracional no es reducible a `E`, porque no existe ninguna producción que comience por `T *`, o dicho de otra forma, `*` no pertenece al `Follow(T)`. Tratemos de formalizar entonces este concepto de "momento donde es conveniente reducir". Para ello introduciremos una definición que formaliza esta intuición.

> Sea $S \rightarrow^* \alpha X \omega \rightarrow \alpha \beta \omega$ una derivación extrema derecha de la forma oracional $\alpha \beta \omega$, y $X \rightarrow \beta$ una producción, decimos que $\alpha \beta$ es un **handle** de $\alpha \beta \omega$.

Intuitivamente, un **handle** nos representa un estado en la pila donde es conveniente reducir, porque sabemos que existen reducciones futuras que nos permiten llegar al símbolo inicial. En la definición anterior la pila sería justamente $\alpha \beta |$, y la cadena de terminales sería $\omega \$$. Sabemos que es posible seguir reduciendo, justamente porque hemos definido un **handle** a partir de conocer que existe una derivación extrema derecha donde aparece ese prefijo. De modo que justamente lo que queremos es identificar cuando tenemos un **handle** en la pila, y en ese momento sabemos que es conveniente reducir.

El problema que nos queda es que hemos definido el concepto de **handle** pero no tenemos una forma evidente de reconocerlos. Resulta que, desgraciadamente no se conoce ningún algoritmo para identificar un **handle** unívocamente en cualquier gramática libre del contexto. Sin embargo, existen algunas heurísticas que nos permiten reconocer algunos **handle** en ciertas ocasiones, y afortunadamente existen gramáticas donde estas heurísticas son suficientes para reconocer todos los **handle** de forma determinista. En última instancia, la diferencia real entre todos los parsers shitf-reduce radica en la estrategia que usen para reconocer los **handle**. Comenzaremos por la más simple.

## Reconociendo **Handles**

La forma en la que hemos definido el concepto de **handle** nos permite demostrar una propiedad interesante:

> En un parser shift-reduce, los **handles** aparecen solo en el tope de la pila, nunca en su interior.

Podemos esbozar una idea de demostración a partir de una inducción fuerte en la cantidad de operaciones **reduce** realizadas. Al inicio, la pila está vacía, y por tanto la hipótesis es trivialmente cierta. Tomemos entonces un estado intermedio de la pila $\alpha \beta |$ que es un **handle**. Además, es el único **handle** por hipótesis de inducción fuerte, ya que de lo contrario tendríamos un **handle** en el interior de la pila. Al reducir, el no-terminal más a la derecha queda en el tope de la pila, ya que es una derivación extrema derecha. Por tanto tendremos un nuevo estado en la pila $\alpha X |$. Ahora pueden suceder 2 cosas, o bien este estado es un **handle** también (y se cumple la hipótesis), o en caso contrario el siguiente **handle** aparecerá tras alguna secuencia solamente de operaciones **shift**. Este nuevo **handle** tiene que aparecer también en el tope de la pila, pues si apareciera en el interior de la pila, tendría que haber estado antes de $X$ (lo que es falso por hipótesis de inducción), o tendría que haber aparecido antes del último terminal al que se le hizo **shift**, pero en tal caso deberíamos haber hecho **reduce** en ese **handle**, lo que contradice el hecho de que solo han sucedido operaciones **shift** desde el último **reduce**.

Este teorema nos permite, en primer lugar, formalizar la intuición de que solamente hacen falta movimientos **shift** a la izquierda. Es decir, una vez un terminal ha entrado en la pila, o bien será reducido en algún momento, o bien la cadena es inválida, pero nunca hará falta sacarlo de la pila y volverlo a colocar en la cadena de entrada.

Por otro lado, este teorema nos describe la estructura de la pila, lo que será fundamental para desarrollar un algoritmo de reconocimiento de **handles**. Dado que los **handles** siempre aparecen en el tope de la pila, en todo momento tendremos, en principio, un prefijo de un **handle**. De modo que una idea útil para reconocer **handles** es intentar reconocer cuales son los prefijos de un **handle**. En general, llamaremos *prefijo viable* a toda forma oracional $\alpha$ que puede aparecer en la pila durante un reconocimiento válido de una cadena del lenguaje. Formalmente:

> Sea $\alpha | \omega$ un estado válido de un parser shift-reduce durante el reconocimiento de una cadena, entonces decimos que $\alpha$ es un prefijo viable.

Intuitivamente, un prefijo viable es un estado en el cual todavía no se ha identificado un error de parsing, por lo que, hasta donde se sabe, la cadena todavía pudiera ser reducida al símbolo inicial. Si podemos reconocer el lenguaje de todos los prefijos viables, en principio siempre sabremos si la pila actual representa un estado válido. Además podemos intuir que esto nos debería ayudar a decidir si hacer un **shift** o un **reduce**, según cual de las dos operaciones nos mantenga el contenido de la pila siendo un prefijo viable. De modo que hemos reducido el problema de identificar **handles** (de forma aproximada) al problema de identificar prefijos viables.

Si analizamos todos los posibles estados válidos de la pila (los posibles prefijos viables), notaremos una propiedad interesante que nos ayudará a reconocer estos prefijos. Supongamos que tenemos un estado $\alpha \beta | \omega$ que es un **handle** para $X \rightarrow \beta$. Entonces por definición $\alpha \beta$ es también un prefijo viable. Además, una vez aplicada la reducción, tendremos el estado $\alpha X | \omega$. Por tanto $\alpha X$ también es un prefijo viable, porque de lo contrario esta reducción sería inválida, contradiciendo el hecho de que hemos reducido correctamente en un **handle**. Por tanto o bien $\alpha X$ es un **handle** en sí, o es un prefijo de un **handle**. En el segundo caso, entonces hay una producción $Y \rightarrow \theta X \phi$, tal que $\alpha = \delta \theta$. Es decir, hay un sufjo de $\alpha X$ que tiene que ser prefijo de la parte derecha de esa producción.

¿Por qué?, pues porque como hemos reducido en un **handle**, esto quiere decir que sabemos que es posible en principio seguir reduciendo, por tanto tiene que haber alguna secuencia de tokens $\phi$, que pudiera o no venir en $\omega$ (aún no sabemos), que complete la parte derecha $\theta X \phi$. Es decir, como sabemos que potencialmente podríamos seguir reduciendo, entonces lo que tenemos en la pila ahora tiene que ser prefijo de la parte derecha de alguna producción. Si no lo fuera, ya en este punto podríamos decir que será imposible seguir reduciendo en el futuro, puesto que solamente introduciremos nuevos tokens en la pila, y nunca tocaremos el interior de la pila (excepto a través de reducciones, que siempre modifican el tope de la pila).

Esta intuición nos dice algo muy importante sobre el contenido de la pila:

> En todo estado válido $\alpha | \omega$ de un parser shift-reduce, la forma oracional $\alpha$ es una secuencia $\alpha = \beta_1 \beta_2 \ldots \beta_n$ donde para cada $\beta_i$ se cumple que existe una producción $X \rightarrow \beta_i \theta$.

Es decir, todo estado válido de la pila es una concatenación de prefijos de partes derechas de alguna producción. En caso contrario, tendríamos una subcadena en la pila que no forma parte de ninguna producción, por tanto no importa lo que pase en el futuro, esta subcadena nunca sería parte de un **reduce**, y por tanto la cadena a reconocer tiene que ser inválida. Más aún, podemos decir exactamente de cuales producciones tienen que ser prefijo esas subcadenas. Dado que en última instancia tenemos que reducir al símbolo inicial $S$, entonces en la pila tenemos necesariamente que encontrar prefijos de todas las producciones que participan en la derivación extrema derecha que estamos construyendo. Formalmente:

> Sea $S \rightarrow^* \alpha \delta \rightarrow^* \omega$ la única derivación extrema derecha de $\omega$, sea $\alpha | \delta$ un estado de un parser shift-reduce que construye esta derivación, sea $X_1 \rightarrow \theta_1, \ldots, X_n \rightarrow \theta_n$ la secuencia de producciones a aplicar tal que $S \rightarrow^* \alpha \delta$, entonces $\alpha = \beta_1 \ldots \beta_n$, donde $\beta_i$ es prefijo de $\theta_i$.

Es decir, en todo momento en la pila lo que tenemos es una concatenación de prefijos de todas las producciones que quedan por reducir. Notemos intuitivamente que esto debe ser cierto, porque el parser va a construir esta derivación al revés. Por tanto en el estado $\alpha | \delta$, que corresponde a la forma oracional $\alpha \delta$ en la derivación, el parser ya ha reconstruido todas las producciones finales, que hacen que $\alpha \delta \rightarrow^* \omega$ (de atrás hacia adelante), y le falta por reconstruir las producciones que hacen que $S \rightarrow^* \alpha \delta$. Luego, lo que está en la pila tiene que reducirse a $S$, y como solo puede pasar que se metan nuevos terminales de $\delta$, todo lo que está en $\alpha$ tiene que de algún modo poderse encontrar en alguna de las producciones que faltan por reducir. De lo contrario, esta reducción sería imposible.

Por supuesto, muchos de los prefijos $\beta_i$ pueden ser $\epsilon$, porque todavía no han aparecido ninguno de los símbolos que forman la producción en la pila (dependen de que reducciones siguientes introduzcan un no-terminal, o de que **shifts** siguientes introduzcan un terminal). De esta forma podemos entender que incluso la pila vacía es una concatenación de prefijos de producciones, todos $\epsilon$. Lo que no puede pasar es que tengamos una subcadena $\beta_k$ que no forme parte de ningún prefijo de ninguna producción, porque entonces nunca podremos reducir totalmente al símbolo inicial. De modo que un prefijo viable no es nada más que una concatenación de prefijos de las producciones que participan en la derivación extrema derecha que queremos construir.

Para ver un ejemplo tomemos nuevamente nuestra gramática favorita:

    E -> T + E | T
    T -> int * T | int | (E)

Y veamos la cadena `( int )`. La derivación extrema derecha que nos genera esta cadena es:

    E -> T -> ( E ) -> ( T ) -> ( int )

Para esta cadena `( E | )` es un estado válido, pues en el siguiente **shift** aparecerá el token `)` que permite reducir (en dos pasos `T -> ( E )` y `E -> T`) al símbolo inicial. Por tanto, `( E` es un prefijo viable. Veamos cómo este prefijo es una concatenación de prefijos de las dos producciones que faltan por reducir. Evidentemente `( E` es prefijo de `T -> ( E )`, y además, $\epsilon$ es prefijo de `E -> T`.

Esta idea es la pieza fundamental que nos permitirá deducir un algoritmo para reconocer prefijos viables. Como un prefijo viable no es más que una concatenación de prefijos de partes derechas de producciones, simplemente tenemos que reconocer *el lenguaje de todas las posibles concatenaciones de prefijos de partes derechas de producciones, que pudieran potencialmente aparecer en una derivación extrema derecha*. Parece una definición complicada, pero dado que conocemos la gramática que queremos reconocer, es de hecho bastante fácil. Notemos que hemos dicho, *que pudieran aparecer en una derivación*, lo cual nos debe dar una idea de cómo construir estas cadenas. Simplemente empezaremos en el símbolo inicial $S$, y veremos todas las posibles maneras de derivar, e iremos rastreando los prefijos que se forman. Para esto nos auxiliaremos de un resultado teórico impresionante, que fundamenta toda esta teoría de parsing bottom-up:

> El lenguaje de todos los prefijos viables de una gramática libre del contexto es regular.

Aunque parece un resultado caído del cielo, de momento podemos comentar lo siguiente. En principio, el lenguaje de todos los posibles prefijos de cada producción es regular (es finito). Y la concatenación de lenguajes regulares es regular. Por tanto, de alguna forma podríamos intuir que este lenguaje de todas las posibles concatenaciones de prefijos debería ser regular. Por tanto debería ser posible construir un autómata finito determinista que lo reconozca. Claro, queda la parte de que no son *todas* las concatenaciones posibles, sino solo aquellas que aparecen en alguna derivación extrema derecha. Tratemos entonces de construir dicho autómata, y a la vez estaremos con esto demostrando que efectivamente este lenguaje es regular. Recordemos que en última instancia lo que queremos es un autómata que lea el contenido de la pila, y nos diga si es un prefijo viable o no.

Para entender como luce este autómata, introduciremos primero un concepto nuevo. Llamaremos **item** a una cadena de la forma $X \rightarrow \alpha . \beta$. Es decir, simplemente tomamos una producción y le ponemos un punto (`.`) en cualquier lugar en su parte derecha. Este **item** formaliza la idea de ver los posibles prefijos de todas las producciones. Por cada producción $X \rightarrow \delta$, tenemos $|\delta|+1$ posibles **items**. Por ejemplo, en la gramática anterior, tenemos los siguientes **items**:

    E -> .T + E
    E ->  T.+ E
    E ->  T +.E
    E ->  T + E.

    E -> .T
    E ->  T.

    T -> .int * T
    T ->  int.* T
    T ->  int *.T
    T ->  int * T.

    T -> .int
    T ->  int.

    T -> .( E )
    T ->  (.E )
    T ->  ( E.)
    T ->  ( E ).

Cada uno de estos **items** nos representa un posible prefijo de una producción. Pero además, cada **item** nos permite también rastrear que esperamos ver a continuación de dicha producción, si es que realmente esa producción fuera la que tocara aplicar a continuación. Veamos entonces qué podemos decir de cómo estos **items** se relacionan entre sí. Tomemos por ejemplo el **item** `E -> T.+ E`. Este **item** nos dice que ya hemos visto algo en la cadena que se reconoce como un `T`, y que esperamos ver a continuación un `+`, si resulta que esta es la producción que realmente tocaba aplicar. El **item** `E -> .T + E` nos dice que si realmente esta es la producción correcta, entonces lo que viene en la cadena debería ser reconocible como un `T`, y luego debería vernir un `+`, y luego algo que se reconozca como un `E`. Por último, un **item** como `T -> ( E ).` nos dice que ya hemos visto toda la parte derecha de esta producción, y por tanto intuitivamente deberíamos poder reducir. De modo que estos **items** nos están diciendo además si es conviente hacer **shift** o hacer **reduce**.

Vamos a utilizar ahora estos **items** para construir el autómata finito no determinista que nos dirá que es lo que puede venir el pila. Cada estado de este autómata es uno de los **items**. Vamos a decir que el estado asociado asociado al **item** $X \rightarrow \alpha . \beta$ representa que en el tope de la pila tenemos el prefijo $\alpha$ de esta producción, o en general, algo que es generado por este prefijo $\alpha$. Por tanto, todos los estados son estados finales, puesto que cada estado corresponde a un prefijo de alguna producción. Lo que tenemos que hacer es definir entonces un conjunto de transiciones que solamente reconozcan aquellas secuencias de prefijos que consituyen prefijos viables.

Suponamos ahora que tenemos cierto estado de un parser shift-reduce, y queremos saber si es un estado válido. Hagamos a nuestro autómata leer esta la pila desde el fondo hacia el tope, como si fuera una cadena de símbolos. Supongamos entonces que durante esta lectura nos encontramos en cierto estado del autómata, asociado por ejemplo al **item** `E -> .T`, y hemos leído ya una parte del fondo de la pila, siguiendo las transiciones que aún no hemos definido del todo. La pregunta entonces es qué puede venir a continuación en la pila, justo encima del último símbolo que analizamos. Evidentemente, en la pila podría venir un  no-terminal `T` directamente, que haya aparecido por alguna reducción hecha anteriormente. Si este fuera el caso, entonces todavía tendríamos un prefijo viable. Entonces podemos añadir una transición del estado `E -> .T` al estado `E -> T.`.

Por otro lado, incluso si no viniera directamente un `T`, de todas formas todavía es posible que tengamos un prefijo viable. ¿Cómo? Supongamos que el no-terminal `T` todavía no ha aparecido porque esa reducción aún no ha ocurrido. Entonces lo que debería venir a continuación en la pila es algo que sea prefijo de alguna producción de `T`, de modo que un **reduce** futuro nos ponga ese `T` en la pila. En ese caso, todavía estaríamos en un prefijo viable, porque tendríamos un prefijo de `E -> T`, y luego un prefijo de algo que se genera con `T`. ¿Cómo reconocer entonces cualquier prefijo de cualquier producción que sale de `T`? Pues afortunadamente tenemos estados que hacen justamente eso, dígase `T -> .int` y `T -> .int * T`, es decir, los **items** iniciales de las producciones de `T`. Dado que estamos construyendo un autómata no-determinista, tenemos la libertad de añadir transiciones $\epsilon$ a estos dos estados. De modo que el estado `E -> .T` tiene tres transiciones, con un `T` se mueve a `E -> T.`, y con $\epsilon$ se mueve a `T -> .int` y a `T -> .int * T`.

Por otro lado, si estuviéramos en el estado `E -> T.+ E`, lo único que podemos esperar que venga en la pila es un terminal `+`. En cualquier otro ya no tendríamos un prefijo viable, pues estábamos esperando tener un prefijo de `E -> T + E`, y ya hemos visto en la pila un `T`. Por tanto si fuera cierto que esta pila es un prefijo viable, tendría que venir algo que continuara este prefijo o empezara un nuevo prefijo. Pero dado que en la producción que estamos esperando lo que viene es un terminal, no existe forma de un **reduce** futuro nos ponga en esa posición a dicho terminal (los **reduce** siempre introducen un no-terminal en la pila). Luego, si no viene exactamente un `+` en la pila, ya podemos estar seguros que este prefijo no es viable (claro, como estamos en un autómata no-determinista puede que existan otros caminos donde sí se reconoce un prefijo viable).

De forma general tenemos las siguientes reglas:

* Si tenemos un estado $X \rightarrow \alpha . c \beta$ donde $c$ es un terminal, añadimos una transición con $c$ al estado $X \rightarrow \alpha c . \beta$.
* Si tenemos un estado $X \rightarrow \alpha . Y \beta$ donde $Y$ es un no-terminal, añadimos una transición con $Y$ al estado $X \rightarrow \alpha Y . \beta$, y además por cada producción $Y \rightarrow \delta$ añadimos una transición con $\epsilon$ al estado $Y \rightarrow .\delta$.

Apliquemos entonces estas reglas al conjunto completo de **items** que hemos obtenido anteriormente. Primero definiremos un estado por cada **item**, y luego iremos adicionando las transiciones:

    [ 1]  E -> .T + E     {  }
    [ 2]  E ->  T.+ E     {  }
    [ 3]  E ->  T +.E     {  }
    [ 4]  E ->  T + E.    {  }
    [ 5]  E -> .T         {  }
    [ 6]  E ->  T.        {  }
    [ 7]  T -> .int * T   {  }
    [ 8]  T ->  int.* T   {  }
    [ 9]  T ->  int *.T   {  }
    [10]  T ->  int * T.  {  }
    [11]  T -> .int       {  }
    [12]  T ->  int.      {  }
    [13]  T -> .( E )     {  }
    [14]  T ->  (.E )     {  }
    [15]  T ->  ( E.)     {  }
    [16]  T ->  ( E ).    {  }

Tomemos entonces el estado `E -> .T + E`. Primero ponemos la transición con `T` hacia `E -> T.+ E`:

    [ 1]  E -> .T + E     { T:2 }

Y luego, dado que `T` es un no-terminal, adicionamos las transiciones $\epsilon$ correspondientes a los estados `T -> .int` y `T -> .int * T`:

    [ 1]  E -> .T + E     { T:2, e:7, e:11 }

Por otro lado, para `E -> T.+ E` la única transición válida es con `+`, hacia el estado `E -> T +.E`:

    [ 2]  E ->  T.+ E     { +:3 }

Para el estado `E -> T+.E` igualmente tenemos una transición con `E` y dos transiciones con $\epsilon$:

    [ 3]  E ->  T +.E     { E:4, e:1, e:5 }

El estado `E -> T + E.` no tiene transiciones salientes, pues representa que se ha reconocido toda la producción. Es responsabilidad de otros estados continuar reconociendo (de forma no-determinista) los prefijos que puedan quedar en la pila.

El estado `E -> .T` se parece mucho al estado `E -> .T + E`. De hecho, tiene las mismas transiciones:

    [ 5]  E -> .T         { T:2, e:7, e:11 }

Finalmente el estado `E -> T.` tampoco transiciones salientes. Ya hemos dicho que todos los estados son finales, pues como las transiciones siempre nos mueven de un prefijo viable a otro, en cualquier momento en que se acabe la pila tenemos un prefijo viable reconocido. Solo queda definir el estado inicial. En principio, deberíamos empezar de forma no-determinista por cualquiera de los estados iniciales de las producciones de `E`. Afortunadamente, en un autómata no-determinista tenemos un recurso para simular esta situación en la que queremos 2 estados iniciales. Simplemente añadimos un estado "dummy", con transiciones $\epsilon$ a cada uno de los estados iniciales que deseamos. Desde el punto de la gramática, esto es equivalente a añadir un símbolo nuevo `E'` con la única producción `E' -> E` y convertirlo en el símbolo inicial. Para esta producción tenemos dos nuevos **items**: `E' -> .E` y `E' -> E.`. El estado `E' -> .E` se convertirá en el estado inicial de nuestro autómata.

El estado `E' -> E.` también es convieniente, pues nos permite reconocer que hemos logrado reducir al símbolo inicial, y deberíamos haber terminado de consumir toda la cadena. De modo que este estado "especial" nos permitirá además saber cuando aceptar la cadena. No podemos simplemente aceptar la cadena en cualquier estado donde se reduzca a `E`, porque es posible que estuviéramos reduciendo a un `E` intermedio, por ejemplo, al `E` que luego de ser reducido en `T -> (E)`.

Ahora que hemos visto como se construyen estas transiciones, veamos directamente el autómata completo.

    [ 0] E' -> .E         { E: 17, e:1, e:5 }
    [ 1]  E -> .T + E     { T:2, e:7, e:11 }
    [ 2]  E ->  T.+ E     { +:3 }
    [ 3]  E ->  T +.E     { E:4, e:1, e:5 }
    [ 4]  E ->  T + E.    {  }
    [ 5]  E -> .T         { T:2, e:7, e:11 }
    [ 6]  E ->  T.        {  }
    [ 7]  T -> .int * T   { int:8 }
    [ 8]  T ->  int.* T   { *:9 }
    [ 9]  T ->  int *.T   { T:10, e:7, e:11 }
    [10]  T ->  int * T.  {  }
    [11]  T -> .int       { int:12 }
    [12]  T ->  int.      {  }
    [13]  T -> .( E )     { (:14 }
    [14]  T ->  (.E )     { E:15, e:1, e:5 }
    [15]  T ->  ( E.)     { ):16 }
    [16]  T ->  ( E ).    {  }
    [17] E' ->  E.

A estos **items** se les denomina también **items LR(0)**, que significa *left-to-right rightmost-derivation look-ahead 0*.

## Autómata LR(0)

Hemos construido finalmente un autómata finito no-determinista que reconoce exactamente el lenguaje de los prefijos viables. Sabemos que existe un autómata finito determinista que reconoce exactamente el mismo lenguaje. Aplicando el algoritmo de conversión de NFA a DFA podemos obtener dicho autómata. Sin embargo, hay una forma más directa de obtener el autómata finito determinista, que consiste en construir los estados aplicando el algoritmo de conversión a medida que vamos analizando las producciones y obteniendo los **items**.

Recordemos que el algoritmo de conversión de NFA a DFA básicamente construye un estado por cada subconjunto de los estados del NFA, siguiendo primero todas las transiciones con el mismo terminal, y luego computando la $\epsilon$-clausura del conjunto de estados resultante. Para cada uno de estos "super-estados" $Q_i$, la nueva transición con un terminal concreto $c$ va hacia el super-estado que representa exactamente al conjunto clausura de todos los estados originales a los que se llegaba desde algún estado $q_j \in Q_i$.

Vamos ahora a reescribir este algoritmo, pero teniendo en cuenta directamente que los estados del NFA son **items**. Por tanto, los super-estados del DFA serán conjuntos de **items**, que son justamente la $\epsilon$-clausura de los **items** a los que se puede llegar desde otro conjunto de **items** siguiendo un símbolo concreto $X$ (terminal o no-terminal). Definiremos entonces dos tipos de **items** para simplicar:

* Un **item kernel** es aquel de la forma $E' \rightarrow .E$ si $E'$ es nuevo símbolo inicial, o cualquier item de la forma $X \rightarrow \alpha . \beta$ con $|\alpha|>1$.

* Un **item no kernel** es aquel de la forma $X \rightarrow .\beta$ excepto el **item** $E' \rightarrow .E$.

Hemos hecho estas definiciones, porque de cierta forma los **items kernel** son los realmente importantes. De hecho, podemos definir dado un conjunto de **items kernel**, el conjunto clausura, que simplemente añade todos los **items no kernel** que se derivan de este conjunto.

> Sea $I$ un conjunto de **items** (kernel o no), el conjunto clausura de $I$ se define como $CL(I) = I \cup \{ X \rightarrow .\beta \}$ tales que $Y \rightarrow \alpha .X \delta \in CL(I)$.

Es decir, el conjunto clausura no es más que la formalización de la operación mediante la cuál añadimos todos los **items** no-kernel que puedan obtenerse de cualquier **item** en $I$. Nótese que la definición es recursiva, es decir, el conjunto clausura de $I$ se define a partir del propio conjunto clausura de $I$. Para computarlo, simplemente partimos de $CL(I) = I$ y añadimos todos los items no-kernel que podamos, mientras cambie el conjunto. Por ejemplo, computemos el conjunto clausura del item asociado estado inicial $E' \rightarrow .E$. Partimos del conjunto singleton que solo contiene a este item:

    I = { E' -> .E }

Ahora buscamos todas las producciones de `E` y añadimos sus items iniciales:

    I = { E' -> .E,
           E -> .T,
           E -> .T + E }

Ahora buscamos todas las producciones de `T` y añadimos sus items iniciales:

    I = { E' -> .E,
           E -> .T,
           E -> .T + E,
           T -> .int,
           T -> .int * T,
           T -> .( E ) }

Como no hemos añadido ningún item que tenga un punto delante de un no-terminal nuevo, este es el conjunto final. Notemos que esta definición no es nada más que la definición de $\epsilon$-clausura usada en la conversión de un NFA a un DFA, solo que la hemos definido en función de los **items** directamente. Si aplicamos la $\epsilon$-clausura al estado $q_0$ de nuestro NFA definido anteriormente, llegaremos exactamente al mismo conjunto de **items**.

Una vez que tenemos este conjunto clausura de **items**, podemos definir entonces cómo añadir transiciones. Para ello definiremos la función $Goto(I,X) = J$, que nos mapea un conjunto de items a otro conjunto de items a partir de un símbolo $X$, de la siguiente forma:

> $Goto(I,X) = CL(\{ Y \rightarrow \alpha X. \beta | Y \rightarrow \alpha .X \beta \in I \})$

La función $Goto(I,X)$ simplemente busca todos los items en $I$ donde aparece un punto delante del símbolo $X$, crea un nuevo conjunto donde el punto aparece detrás del símbolo $X$, y luego calcula la clausura de este conjunto. Básicamente lo que estamos es formalizando la misma operación $Goto$ que usábamos en la conversión de NFA a DFA, pero esta vez escrita en función de los **items**. Por ejemplo, si $I$ es el conjunto calculado anteriormente, entonces:

    Goto(I,T) = { E -> T., E -> T. + E }

Dado que no existe ningún punto delante de un no-terminal, no es necesario computar la clausura.

Una vez que tenemos estas dos definiciones, podemos dar un algoritmo para construir el autómata finito determinista que reconoce los prefijos viables. El estado inicial de nuestro autómata será justamente $CL({ E' \rightarrow .E })$. Luego, repetimos la siguiente operación mientras sea necesario: por cada estado $I$ y cada símbolo $X$, añadimos el estado $Goto(I,X)$ si no existe, y añadimos la transición $I \rightarrow^X J$. El algoritmo termina cuando no hay cambios en el autómata.

Apliquemos entonces este algoritmo a nuestra gramática para expresiones. Partimos del estado $I_0$ ya computado:

    I0 = { E' -> .E,
            E -> .T,
            E -> .T + E,
            T -> .int,
            T -> .int * T,
            T -> .( E ) }

Calculemos ahora $Goto(I_0, E)$:

    I1 = { E' -> E. }

Como no hay ningún punto delante de un no-terminal, la clausura se mantiene igual. Calculemos entonces $Goto(I_0, T)$:

    I2 = { E -> T.,
           E -> T.+ E }

Igualmente la clausura no añade items. Calculemos ahora $Goto(I_0, int)$:

    I3 = { T -> int.,
           T -> int.* T }

Y ahora $Goto(I_0, ( )$:

    I4 = { T -> (.E ) }

A este estado si tenemos que calcularle su clausura:

    I4 = { T ->  (.E ),
           E -> .T,
           E -> .T + E,
           T -> .int,
           T -> .int * T,
           T -> .( E ) }

De modo que ya terminamos con $I_0$. Dado que en $I_1$ no hay símbolos tras un punto, calculemos entonces $Goto(I_2,+)$, y aplicamos la clausura directamente:

    I5 = { E ->  T +.E,
           E -> .T,
           E -> .T + E,
           T -> .int,
           T -> .int * T,
           T -> .( E ) }

Calculamos $Goto(I_3, *)$:

    I6 = { T ->  int *.T,
           T -> .int,
           T -> .int * T,
           T -> .( E ) }

Calculamos $Goto(I_4, E)$:

    I7 = { T -> ( E.) }

Si ahora calculamos $Goto(I_4, T)$, y nos daremos cuenta que es justamente $I_2$. Por otro lado, afortunadamente $Goto(I_4, int) = I_3$. Y finalmente $Goto(I_4, ()$ es el propio estado $I_4$! Por otro lado, $Goto(I_5, E)$ es:

    I8 = { E -> T + E. }

Mientras que $Goto(I_5,T)$ nos lleva de regreso a $I_3$, y $Goto(I_5, ()$ a $I_4$. Saltamos entonces para $Goto(I_6, T)$ que introduce un estado nuevo:

    I9 = { T -> int * T. }

Por otro lado, $Goto(I_6, int) = I_3$ nuevamente, mientras que $Goto(I_6, ()$ nos regresa nuevamente a $I_4$. Finalmente, $Goto(I_7, ))$ nos da el siguiente, y último estado del autómata (ya que $I_8$ e $I_9$ no tienen transiciones salientes):

    I10 = { T -> ( E ). }

Para agilizar este algoritmo, podemos notar que, como dijimos anteriormente, solamente los item kernel son importantes. De hecho, podemos probar fácilmente que dos estados son iguales sí y solo si sus item kernel son iguales, dado que las operaciones de clausura sobre conjuntos de items kernel iguales nos darán el mismo conjunto final. Por lo tanto, en una implementación computacional (o un cómputo manual), si distinguimos los items kernel del resto de los items, cuando computamos un nuevo estado a partir de la función $Goto$, antes de computar su clausura vemos si su conjunto de items kernel coincide con el kernel de otro estado ya creado. En caso contrario, hemos descubierto un nuevo estado y pasamos a computar su clausura.

## Parsing LR(0)

Una vez construido el autómata, podemos finalmente diseñar un algoritmo de parsing bottom-up. Este algoritmo se basa en la idea de verificar en cada momento si el estado de la pila es un prefijo viable, y luego, según el terminal que corresponda en $\omega$, decidimos si la operación a realizar es **shift** o **reduce**. Para determinar si la pila es un prefijo viable, simplemente corremos el autómata construido en el contenido de la pila. Supongamos que este autómata se detiene en el estado $I$. Vamos que nos dicen los items de este estado sobre la operación más conveniente a realizar.

Si en este estado tenemos un item $X \leftarrow \alpha .c \beta$, y $c \omega$ es la cadena de entrada (es decir, $c$ es el próximo terminal a analizar), entonces es evidente que una operación de **shift** me seguirá manteniendo en la pila un prefijo viable. ¿Por qué? Pues porque al hacer **shift** el contenido de la pila ahora crece en $c$, y si vuelvo a correr el autómata desde el inicio de la pila, llegaré nuevamente al estado $I$ justo antes de analizar $c$. Pero sé que desde $I$ hay una transición con $c$ a cierto estado $J$, que es justamente $Goto(I, c)$, por lo tanto terminaré en el estado $J$ habiendo leído toda la pila. Luego, por definición de prefijo viable, como he podido reconocer el contenido de la pila, todo está bien.

Por otro lado, si en el estado $I$ tengo un item de la forma $X \leftarrow \beta.$, entonces es conveniente hacer una operación de **reduce** justamente en la producción $X \rightarrow \beta$. Para ver por qué esta operación me sigue manteniendo en la pila un prefijo viable, notemos que $X \rightarrow \beta.$ quiere decir que hemos reconocido en la pila toda la parte derecha de esta producción. Entonces en la pila lo que tenemos en un **handle**, y por su propia definición reducir en un **handle** siempre es correcto.

De modo que tenemos un algoritmo. En cada iteración, corremos el autómata en el contenido de la pila, y analizamos cuál de las estrategias anteriores es válida según el contenido del estado en que termina el autómata. Si en algún momento el autómata no tiene una transición válida, tiene que ser con el último terminal que acabamos de hacer **shift** (ya que de lo contrario se hubiera detectado en una iteración anterior). Luego, este algoritmo reconoce los errores sintácticos lo antes posible. Es decir, nunca realiza una reducción innecesaria.

Por otro lado, puede suceder que en un estado del autómata tenga items que nos sugieran operaciones contradictorias. Llamaremos a estas situaciones, **conflictos**. En general, podemos tener 2 tipos de conflictos:

* Conflicto **shift-reduce** si ocurre que tengo un item que me sugiere hacer **shift** y otro que me sugiere hacer **reduce**.
* Conflicto **reduce-reduce** si ocurre que tengo dos items que me sugieren hacer **reduce** a producciones distintas.

En cualquiera de estos casos, tenemos una fuente de no-determinismo, pues no sabemos por cuál de estas operaciones se pudiera reconocer la cadena. Este no-determinismo se debe a que en el autómata no-determinista había más de un camino posible que reconocía la cadena, y al convertirlo a determinista, estos caminos se expresan como items contradictorios en el mismo estado. En estos casos, decimos que la gramática no es LR(0). Luego:

> Sea $G=<S,N,T,P>$ una gramática libre del contexto, $G$ es LR(0) si y solo si en el autómata LR(0) asociado no existen conflictos **shift-reduce** ni conflictos **reduce-reduce**.

Notemos que no es posible que tengamos conflictos **shift-shift**, pues solamente hay un caracter $c$ en la cadena $\omega$, y por tanto hay un solo estado hacia donde hacer **shift**.

Desgraciadamente nuestra gramática favorita de expresiones no es LR(0). Sin ir más lejos, en el estado $I_3$ tenemos un conflicto **shift-reduce**. Podemos reducir `T -> int`, o hacer **shift** si viene un terminal `*`. Intuitivamente el problema es que la operación de **reduce** es demasiado permisiva. Donde quiera que encontremos un item **reduce** diremos que es conveniente reducir en esa producción, aunque sabemos que esto no siempre es cierto. De hecho, ya hemos tenido que lidiar con este problema anteriormente, en el algoritmo de parsing LL.

## Parsing SLR(1)

Recordemos que en el parsing LL teníamos la duda de cuando era conveniente aplicar una producción $X \rightarrow \epsilon$, y definimos para ello el conjunto $Follow(X)$, que justamente nos decía donde era conveniente eliminar $X$. Pues en este caso, este conjunto también nos ayudará. Intuitivamente, si tenemos $X \rightarrow \beta.$, solamente tiene sentido reducir si en el $Follow(X)$ aparece el terminal que estamos analizando. ¿Por qué? Pues porque de lo contrario no es posible que lo que nos quede en la pila sea un prefijo viable.

Supongamos que $c$ es el terminal a analizar, $c \notin Follow(X)$ y hacemos la reducción. Entonces en el próximo **shift** tendremos en el tope de la pila la forma oracional $Xc$. Pero esta forma oracional no puede aparecer en niguna derivación extrema derecha, porque de lo contrario $c$ sería parte del $Follow(X)$. Por tanto, si esta forma oracional no es válida, entonces ningún **handle** puede tener este prefijo. Por tanto ya no tenemos un prefijo viable. Incluso si lo siguiente que hacemos tras reducir en $X$ no es **shift** sino otra secuencia de operaciones **reduce**, en cualquier caso si lo que queda una vez hagamos **shift** es un prefijo viable, entonces es porque $c \in Follow(X)$ (intuitivamente, aplicando las producciones en las que redujimos hasta que vuelva a aparecer X, obtendremos la forma oracional $Xc$ nuevamente).

Justamente a esta estrategia denominaremos SLR(1), o *Simple LR look-ahead 1*, dado que usamos un terminal de look-ahead para decidir si vale la pena reducir. Con esta estrategia, podemos comprobar que ya en el estado $I_2$ no hay conflicto, pues $* \notin Follow(T)$, porque cuando viene un terminal $*$ solo tiene sentido hacer **shift**, nunca **reduce**.

De forma análoga llamamos gramáticas SLR(1) a aquellas gramáticas donde, bajo estas reglas, no existen conflictos.

Intentemos entonces reconocer la cadena `int * ( int + int )` con nuestro parser SLR(1). Comenzamos por el estado inicial:

    |int * ( int + int )

Como la pila está vacía, el autómata termina en el estado $I_0$. Dado que viene un terminal `int`, buscamos la transición correspondiente, que es justamente hacia el estado $Goto(I_0,int) = I_3$. Por tanto, como existe esta transición, significa que la acción a realizar es **shift**.

     int|* ( int + int )

Ahora corremos nuevamente el autómata, ya sabemos que caerá en el estado $I_3$. Ahora podemos potencialmente reducir o hacer **shift**. Calculamos el $Follow(T)$

    Follow(T) = { +, ), $ }

Por tanto, como `*` no está incluido en el `Follow(T)`, no hay conflicto, solamente no queda hacer **shift**, en este caso al estado $I_6$.

     int *|( int + int )

Corremos de nuevo y sabemos que acabaremos en $I_6$. Aquí no hay reducciones, así que solo queda hacer **shift** hacia el estado $I_4$:

     int * (|int + int )

En $I_4$ tampoco hay reducciones, así que hacemos **shift** hacia el estado $I_3$:

     int * ( int|+ int )

Ahora interesantemente si tenemos que `+` pertenece al `Follow(X)`, por tanto la reducción aplica. Afortunadamente no hay transiciones en este estado con `+`, por lo que no hay conflicto. Aplicamos entonces la reducción:

     int * ( T|+ int )

Ahora corremos el autómata nuevamente desde el inicio, siguiendo las transiciones (recordemos que mienstras estamos leyendo el contenido de la pila no nos importan los items). Terminamos en el estado $I_2$. En este estado podemos reducir a `E` o hacer **shift**. Pero resulta que `Follow(E)` no contiene al terminal `+`, por lo que la reducción no tiene sentido. Hacemos **shift** entonces:

     int * ( T +|int )

Ahora el autómata termina en el estado $I_5$. En este estado, viniendo `int`, solamente tiene sentido hacer **shift** hacia el estado $I_3$:

     int * ( T + int|)

Ahora estamos en una situación conocida. Pero en este caso, `)` sí está en el `Follow(T)`, y no hay transiciones con este símbolo, luego lo que queda es reducir:

     int * ( T + T|)

Al correr el autómata, en vez de $I_3$ como en la última vez, ahora de $I_5$ pasaríamos directamente a $I_2$, donde nuevamente estamos en territorio conocido. Sin embargo, de nuevo en este caso `)` sí está en el `Follow(E)`, luego podemos reducir (y no hay transiciones con `)`):

     int * ( T + E|)

Ahora volvemos a correr el autómata, pero en vez de el estado $I_2$, terminaríamos en el estado $I_8$, donde la única opción es reducir (una vez comprobamos el `Follow(E)`):

     int * ( E|)

En este caso, al correr el autómata desde el inicio, terminamos en $I_7$, que nos dice **shift**:

     int * ( E )|

Ahora de $I_7$ saltaríamos para $I_{10}$, que nos indica la reducción (dado que `$` sí está en el `Follow(X)`):

     int * T|

En este caso, rápidamente caeremos en el estado $I_9$, que nos indica reducir:

     T|

El autómata con esta pila termina en el estado $I_2$ nuevamente, pero ahora `$` es el terminal a analizar, por lo que hacemos la reducción:

     E|

Y finalmente, en esta entrada el autómata nos deja en el estado $I_1$, que nos permite reducir por completo al símbolo especial `E'` y aceptar la cadena:

     E'|

De esta forma, el algoritmo de parsing SLR(1) ha logrado obtener una derivación extrema derecha de nuestra cadena favorita, pero empleando una gramática mucho más expresiva y "natural" que la gramática LL correspondiente.

De todas formas, muchas gramáticas medianamente complicadas no son SLR(1), por lo que necesitaremos un parser de mayor potencia. Para ello, tendremos que refinar aún más el criterio con el cuál se producen los **reduce**.

## Parsing LR(1)

Veamos a continuación un ejemplo de una gramática clásica que no es SLR(1):

    S -> E
    E -> A = A | i
    A -> i + A | i

Esta gramática representa un subconjunto del lenguaje de las ecuaciones algebraicas, donde tanto en la parte derecha como en la izquierda del token `=` podemos tener una expresión aritmética cualquiera. Veamos que sucede al construir el autómata SLR(1):

    I0 = {
        S -> .E
        E -> .A = A
        E -> .i
        A -> .i + A
        A -> .i
    }

Viendo los items de este estado, ya podemos intuir dónde podría haber problemas. Al hacer `Goto(I0, i)` aparecerán dos items **reduce** con parte izquierda distinta:

    Goto(I0, i) = {
        E -> i.
        A -> i.+ A
        A -> i.
    }

En este estado aperece entonces un conflicto **reduce-reduce**, ya que $Follow(E) = \{ \$ \}$, y $\$ \in Follow(A)$, puesto que `A` aparece como parte derecha de una producción de `E`. Por tanto esta gramática no es SLR(1). Sin embargo, la gramática no es ambigua, y esto es fácil de demostrar. Intuitivamente, la única cadena donde pudiera haber ambiguedad es justamente la cadena `i` (es el único token que es generado por más de un no-terminal). Sin embargo, para esta cadena, la única derivación posible es `S -> E -> i`. Aunque `A -> i` es una producción, la forma oracional `i` no es **handle** de `A`. Si solo existe un `i` en la pila, este tiene que ser generado por el no-terminal `E`, pues de lo contrario no sería posible reducir a `S`.

Sin embargo, nuestro parser SLR(1) no es suficientemente inteligente para determinar esto. Al encontrarse con la forma oracional `i` en la pila, en principio, el autómata dice que `A -> i` es una reducción posible. Sin embargo, sabemos que esta reducción es inválida, porque luego quedaría `A` en la pila, que no es una forma oracional válida en ninguna derivación extrema derecha. De la producción `E -> A = A` podemos ver que esta gramática nunca genera una `A` sola. En otras palabras, nuestra heurística SLR(1) para detectar **handles** (reducir en `X` para todo terminal en el `Follow(X)`) es demasiado débil para manejar esta situación, y produce un falso positivo, al determinar que la forma oracional `ì$` es un **handle** de `A`, cuando realmente no lo es.

La pregunta es entonces, ¿por qué surge este conflicto? Qué falla en la heurística SLR(1) que produce estos falsos positivos? Evidentemente el conjunto Follow es en ocasiones demasiado grande, y contiene tokens para los cuáles no es válida una operación **reduce** en ese estado particular. Tratemos de rastrear, durante la construcción del autómata, dónde es que se introducen estos tokens inválidos.

Comenzamos por el estado inicial nuevamente, pero viéndolo paso a paso a medida que se computa la clausura. Comenzamos por el *kernel*:

    I0 = {
        S -> .E
        ...
    }

En este punto, el único item de este estado indica que esperamos encontrar en la cadena una forma oracional que se reduzca a `E`. Por tanto, añadimos las producciones de `E`:

    I0 = {
        S -> .E
        E -> .A = A
        E -> .i
        ...
    }

Hasta aquí no hay problemas, pues ni siquiera hay dos items con la misma parte derecha. Entonces tenemos que adicionar las producciones de `A`:

    I0 = {
        S -> .E
        E -> .A = A
        E -> .i
        A -> .i + A
        A -> .i
    }

Y aquí es donde podemos tener la primera pista de que viene un conflicto. Tenemos dos items que tienen la misma parte derecha (`E -> .i` y `A -> .i`). Por tanto, tras el próximo **shift** llegaremos a un estado con dos **reduce** a no-terminales distintos. Ahora, recordemos que el conflicto va a suceder porque `$` está en la intersección de los Follow. Sin embargo, veamos por qué motivo aparece `A -> .i` en este estado. Justamente, es por culpa de la producción `E -> .A = A` que tenemos que expandir los items de `A`. Recordemos entonces qué significa este item para nosotros: básicamente representa que a partir de este punto en la cadena de entrada, estamos esperando que aparezca *algo que se pueda reducir* a la forma oracional `A = A`. Por tanto, como esta forma oracional empieza con `A`, debemos expandir sus producciones.

Pero sí analizamos cuidadosamente el significado del item anterior, veremos que no tiene sentido reducir a este `A` si aparece `$` como *look-ahead*. ¿Por qué? Pues precisamente, el item nos dice que lo que viene en la cadena, si resultara que es correcta, debería reducirse a la forma oracional `A = A`. Por tanto, la primera parte de esa supuesta cadena, que se debería reducir al primer `A` de la forma oracional, solamente sería correcta si justo detrás de ese `A` viniera un token `=`. De lo contrario no podríamos seguir reduciendo el resto de la forma oracional.

Es decir, en el momento qué por culpa del item `E -> .A = A` nos toca adicionar el item `A -> .i`, lo que estamos esperando es que ese `i` se reduzca a `A` e inmediatamente después venga un `=`. El propio item nos está diciendo eso. Por tanto, si en el siguiente estado resultara que felizmente apareció el token `i` en la pila, antes de reducirlo ingenuamente a `A`, deberíamos verificar si justo detrás viene el `=` que estábamos esperando. De lo contrario, podríamos decir que la reducción no tiene sentido, porque el item "padre" de este item (es decir, `E -> .A = A`) se va a quedar esperando un `=` que no viene en la cadena.

El problema con la heurística SLR radica justamente en que calculamos el Follow de cualquier no-terminal de forma *global*. Es decir, no tenemos en cuenta qué según las producciones que se vayan aplicando, solamente una parte de ese Follow es la que realmente puede aparecer a continuación. En este caso particular $Follow(A) = \{ =, \$\}$. Pero cada uno de esos tokens está en el Follow por un motivo *distinto*. Justamente `=` aparece en el `Follow(A)` por culpa de la *primera* `A` en la producción `E -> A = A`. Pero `$` aparece por culpa de la *segunda* `A` de esa producción. De cierta forma, es como si tuviéramos *dos instancias* distintas del mismo no-terminal `A`, aquella que aparece delante del token `=` y aquella que aparece detrás. Entonces cuando estamos parseando una cadena, y el autómata pasa al estado `E -> .A = A`, estamos esperando una `A`, pero no cualquier `A`, sino aquella *instancia* de `A` que viene delante del `=`. El error en la heurística SLR es justamente que no puede identificar estas situaciones distintas. Para el autómata SLR toda `A` es la misma `A`, por tanto tiene sentido reducir siempre con el mismo *look-ahead*.

¿Cómo podemos entonces identificar de forma distinta a cuál de las posibles `A` nos estamos refiriendo? Precisamente, durante la construcción del autómata, cuando el item `E -> .A = A` nos genera un item `A -> .i`, sabemos a "cuál" `A` nos referimos. Es justamente aquella que estaba detrás del punto. Por tanto, podemos en este momento decir qué es lo que puede venir detrás de esa `A` particular si se aplica esta producción particular. Lo que haremos entonces es adicionar a cada item un conjunto de tokens, que nos dirán explícitamente cuándo es que tiene sentido hacer **reduce**. Y este conjunto de tokens lo iremos calculando a medida que se crean los nuevos items, justamente mirando en el item "padre" que lo generó qué es lo que puede venir detrás de cada no-terminal.

Vamos a introducir entonces el concepto de **item LR(1)**, que no es más que un **item LR(0)** normal junto a token:

> Sea $G=<S,N,T,P>$ una gramática libre del contexto, un **item LR(1)** es una expresión de la forma $X \rightarrow \alpha \cdot \beta, c$ donde $X \rightarrow \alpha \beta$ es una producción ($\alpha, \beta \in (N \cup T)^*$), y $c \in T$.

El nuevo token que hemos adicionado a cada item nos servirá para ir rastreando qué terminales pueden aparecer el Follow de la forma oracional que estamos intentando reducir. De modo que un item de la forma $X \rightarrow \alpha \cdot \beta, c$ en un estado del autómata representa que ya hemos reconocido la parte $\alpha$ de la forma oracional, y esperamos reconocer la parte $\beta$, y que una vez reconocida toda esta porción $\beta$, esperamos que venga exactamente un terminal $c$. Por tanto, en algún momento tendremos un item $X \rightarrow \delta \cdot, c$, y entonces la operación de **reduce** la aplicaremos solamente si el siguiente terminal es $c$. A este token asociado a cada item le llamaremos *look-ahead*, y a la parte $X \rightarrow \alpha \cdot \beta$ le llamaremos centro. De modo que un item LR(1) está compuesto por un centro, que es un item LR(0), y un token *look-ahead*.

A partir de este nuevo tipo de item, vamos a construir un autómata similar al SLR(1), que llamaremos **LR(1) canónico** o simplemente LR(1). Para ello, necesitaremos definir cuál es el item inicial, y cómo se computan nuevos items a partir de los items ya existentes. El item LR(1) inicial es fácil de definir. El centro es idéntico al item inicial del autómata SLR: es decir, $S \rightarrow \cdot E$ (siendo `S` el nuevo símbolo inicial de la gramática aumentada, y `E` el símbolo inicial de la gramática original). Ahora, para definir el token *look-ahead*, volvamos al significado de este item. Básicamente $S \rightarrow \cdot E$ significa que esperamos encontrar una forma oracional que se pueda reducir a `E`, y por tanto lo único que puede venir posteriormente es justamente `$`. De este modo el item LR(1) inicial significamente exactamente que queremos reducir **toda** la cadena a un simbolo `E`.

> Sea $G=<S,N,T,P>$ una gramática libre del contexto, $S'$ el símbolo inicial de la gramática autmentada, entonces el item LR(1) inicial es $S' \rightarrow \cdot S, \$$.

Veamos entonces qué sucede con cualquier otro item LR(1). Recordemos que en SLR teníamos dos tipos de items, los *kernel* y los *no-kernel*. Aquí tendremos la misma separación. Si tenemos un item LR(1) $X \rightarrow \alpha \cdot x \beta, c$, donde $x \in T$, la operación **shift** nos generará el item $X \rightarrow es\alpha x \cdot \beta, c$. Dado que todavía estamos reconociendo la parte derecha de esta producción, el *look-ahead* se mantiene igual. Por otro lado, si tenemos $X \rightarrow \alpha \cdot Y \beta, c$ con $Y \in N$, entonces tenemos que computar (además de correr el punto) todos los items con centro $Y \rightarrow \cdot \delta$. La pregunta es entonces cuál es el *look-ahead* correspondiente. Básicamente la pregunta es, si logramos reducir a $\delta$ al $Y$ que estamos esperando, ¿qué puede venir detrás? La respuesta es, en principio, todo terminal en el $First(\beta)$, y *nada más*.

Ahora, puede suceder que $\beta \rightarrow^* \epsilon$, es decir, que la parte detrás de $Y$ no exista, o que desaparezca en el futuro. En este caso, tendremos que $\epsilon \in First(\beta)$. Pero no tiene sentido alguno decir que detrás de $Y$ esperamos que venga $\epsilon$ (incluso definimos anteriormente que $\epsilon \notin Follow(Y)$ para todo $Y$). Sin embargo, en este caso, si $\beta$ desaparece, entonces lo único que puede venir detrás de $Y$, es justamente el *look-ahead* de $X$. Por ejemplo, para el item $X \rightarrow \alpha \cdot Y, c$ generamos el item $Y \rightarrow \cdot \delta, c$, pues como $Y$ está al final del $X$, le sigue lo mismo que habíamos decidido que seguía a $X$. Podemos generalizar de la siguiente manera, extendiendo los conceptos definidos para SLR:

> Sea $I$ un conjunto de **items LR(1)** (kernel o no), el conjunto clausura de $I$ se define como $CL(I) = I \cup \{ X \rightarrow .\beta, b\}$ tales que $Y \rightarrow \alpha .X \delta, c \in CL(I)$ y $b \in First(\delta c)$.

> Sea $I$ un conjunto de **items LR(1)**, se define la función $Goto(I,X) = CL(\{ Y \rightarrow \alpha X. \beta, c | Y \rightarrow \alpha .X \beta, c \in I \})$

Para construir el autómata, seguimos el mismo algoritmo que para SLR. La función **Goto** para un conjunto de items (un estado) se define de igual forma como el conjunto de items (estado) que se obtienen de aplicar **Goto** a cada item en el conjunto origen. La función **Clausura** igualmente se define de forma recursiva como la clausura transitiva de cada uno de los items del propio conjunto. De la misma forma, tendremos conflictos **shift-reduce** o **reduce-reduce** en algún estado, si los *look-ahead* de algunas producciones **reduce** coinciden con otras, o con una de las transiciones salientes.

Pasemos entonces a construir el autómata LR(1) de la gramática anterior:

    S -> E
    E -> A = A | i
    A -> i + A | i

Comenzamos por el estado inicial:

    I0 = {
        S -> .E, $
    }

Vamos a añadir entonces las producciones de `E`. Notemos que como en `S -> E` detrás de `E` no viene nada, el *look-ahead* será justamente `$`:

    I0 = {
        S -> .E,     $
        E -> .A = A, $
        E -> .i,     $
    }

Hasta el momento hemos obtenido un estado inicial equivalente al del autómata SLR correspondiente. Adicionamos entonces las producciones de `A`, y veremos el primer cambio importante. El centro de estos items serán (de forma equivalente al caso SLR), `A -> .i + A` y `A -> .i`. Sin embargo, al calcular el *look-ahead*, aplicando la definición, tenemos que computar $First(=\$)$ que es el token `=`. Luego:

    I0 = {
        S -> .E,     $
        E -> .A = A, $
        E -> .i,     $
        A -> .i + A, =
        A -> .i,     =
    }

Y ya podemos intuir cómo el autómata LR resolverá el conflicto **reduce-reduce** que teníamos anteriormente, ya que las producciones a reducir en el próximo estado tienen *look-ahead* distinto. Por completitud, continuemos con el resto del autómata.

    I1 = Goto(I0, E) = {
        S -> E., $
    }

    I2 = Goto(I0, A) = {
        E -> A.= A, $
    }

    I3 = Goto(I0, i) = {
        E -> i.,    $
        A -> i.+ A, =
        A -> i.,    =
    }

Como intuíamos, el estado $I_3$, que anteriormente tenía un conflicto **reduce-reduce**, ahora es válido. Veamos el resto de los estados:

    I4 = Goto(I2, =) = {
        E ->  A =.A, $
        A -> .i + A, $
        A -> .i,     $
    }

    I5 = Goto(I3, +) = {
        A ->  i +.A, =
        A -> .i + A, =
        A -> .i,     =
    }

Ahora veamos los estados que se derivan de estos. Comenzaremos a notar que aparecen estados muy similares a los anteriores, pero con conjuntos *look-ahead* distintos:

    I6 = Goto(I4, A) = {
        E -> A = A., $
    }

    I7 = Goto(I4, i) = {
        A -> i.+ A, $
        A -> i.,    $
    }

    I8 = Goto(I5, A) = {
        A -> i + A., =
    }

    I9 = Goto(I5, i) = {
        A -> i.+ A, =
        A -> i.,    =
    }

Como vemos, $S_7$ y $S_9$ son estados en principio idénticos, excepto porque los *look-ahead* asociados a cada item son distintos. Esta repetición de estados casi iguales será el próximo problema a resolver, pero por el momento continuemos con el autómata:

    I10 = Goto(I7, +) = {
        A ->  i +.A, $
        A -> .i + A, $
        A -> .i,     $
    }

    Goto(I9, +) = S5

    I11 = Goto(I10, A) = {
        A ->  i + A., $
    }

    Goto(I10, i) = S7

El autómata resultante tiene 12 estados. A modo de comparación, el autómata SLR correspondiente tiene 9 estados. Como ya tenemos práctica, lo mostraremos sin más explicación:

    I0 = {
        S -> .E
        E -> .A = A
        E -> .i
        A -> .i + A
        A -> .i
    }

    I1 = Goto(I0, E) = {
        S -> E.
    }

    I2 = Goto(I0, A) = {
        E -> A.= A
    }

    I3 = Goto(I0, i) = {
        E -> i.
        A -> i.+ A
        A -> i.
    }

    I4 = Goto(I2, =) = {
        E ->  A =.A
        A -> .i+ A
        A -> .i
    }

    I5 = Goto(I3, +) = {
        A ->  i +.A
        A -> .i + A
        A -> .i
    }

    I6 = Goto(I4, A) = {
        E -> A = A.
    }

    I7 = Goto(I4, i) = {
        A -> i.+ A
        A -> i.
    }

    I8 = Goto(I5, A) = {
        A -> i + A.
    }

    Goto(I5, i) = I7

    Goto(I7, +) = I5

Los estados adicionales necesarios en LR son justamente aquellos donde existen conflictos.

## Parsing LALR(1)

Si observamos el autómata LR(1) nuevamente, notaremos algunos estados que son muy semejantes, y solo se diferencian en los conjuntos de *look-aheads*. En particular, el estado $I_7$ y el estado $I_9$ tienen los mismos centros:

    I7 = Goto(I4, i) = {
        A -> i.+ A, $
        A -> i.,    $
    }

    I9 = Goto(I5, i) = {
        A -> i.+ A, =
        A -> i.,    =
    }

Al igual que los estados $I_5$ e $I_10$:

    I5 = Goto(I3, +) = {
        A ->  i +.A, =
        A -> .i + A, =
        A -> .i,     =
    }

    I10 = Goto(I7, +) = {
        A ->  i +.A, $
        A -> .i + A, $
        A -> .i,     $
    }

Y los estados $I_8$ e $I_11$:

    I8 = Goto(I5, A) = {
        A -> i + A., =
    }

    I11 = Goto(I10, A) = {
        A -> i + A., $
    }

Intuitivamente, estos son los estados que ayudan a desambiguar el autómata SLR, pues separan en diferentes subconjuntos de terminales lo que antes era el Follow de un no-terminal. De cierta forma este es el precio a pagar por el poder adicional del autómata LR sobre el SLR: es necesario separar en mútiples estados lo que antes era un solo estado, para poder discriminar con exactitud qué tokens activan una reducción.

Afortunadamente, en ocasiones podemos obtener lo mejor de ambos mundos. ¿Qué sucede si intentamos "compactar" estos estados "duplicados"? Idealmente, si esta compactación no introdujera nuevos conflictos, lograríamos un autómata con menos estados y el mismo poder de reconocimiento. Veamos como podríamos proceder. Tomemos por ejemplo los estados $I_7$ e $I_9$ y definamos un nuevo estado $I_{7,9}$. Para ello simplemente combinamos los *look-ahead* de cada par de items iguales en un conjunto:

    I7-9 = {
        A -> i.+ A, =$
        A -> i.,    =$
    }

De la misma forma, podemos hacer con los pares de estados restantes:

    I5-10 = {
        A ->  i +.A, =$
        A -> .i + A, =$
        A -> .i,     =$
    }

    I8-11 = {
        A -> i + A., =$
    }

La primera verificación que necesitamos hacer es si estos nuevos estados crean conflictos en sí mismos. Es decir, si al combinar, aparece un conflicto **reduce-reduce** que antes no existía, dado por dos reducciones distintas cuyos *look-ahead* ahora tengan intersección. En este caso vemos que no sucede, pues en los estados donde hay reducciones, afortunadamente son al mismo no-terminal, por tanto no hay ambigüedad.

Luego tenemos que ver cómo se comporta el autómata si reemplazamos los estados originales por estos nuevos "estados combinados". Para ello, tenemos que ver que sucede con las transiciones entrantes y salientes. En principio, todas las transiciones que iban a parar a alguno de los estados originales, irán a parar al nuevo estado combinado. Veamos entonces qué aristas entrantes tenía cada estado original:

    I7-9  | I7  = Goto(I4, i) = Goto(I10, i)
          | I9  = Goto(I5, i)

    I5-10 | I5  = Goto(I3, +) = Goto(I9, +)
          | I10 = Goto(I7, +)

    I8-11 | I8  = Goto(I5, A)
          | I11 = Goto(I10, A)

Tenemos entonces que factorizar todas estas aristas entrantes hacia los nuevos estados, y comprobar que no ocurran conflictos. Por ejemplo, como `Goto(I4, i) = I7`, ahora esa arista irá hacia `I7-9`. Por otro lado, como `Goto(I5, i) = I9`, esa arista también irá para `I7-9`. Y en este segundo caso, como en estado de salida también va a ser parte de un estado combinado, realmente lo que sucederá es que tendremos una arista de `I5-10` hacia `I7-9`. Pero para que esto sea posible, necesitamos que la otra arista que salía de `I10` también caiga en el nuevo estado combinado, pues de lo contrario tendríamos una ambigüedad. Afortunadamente, en este caso `Goto(I10, i) = I7`, por lo que no existe conflicto. Luego, procedamos a compactar todas las transiciones entrantes:

    I7-9  = Goto(I4, i) = Goto(I5-10, i)
    I5-10 = Goto(I3, +) = Goto(I7-9, +)
    I8-11 = Goto(I5-10, A)

En principio, nos queda ver las aristas salientes de estos estados combinados. En este caso particular todas las aristas salientes ya han sido analizadas, como aristas entrantes de otros estados. En el caso general, es posible que existan aristas salientes de un estado combinado de vayan a parar a estados distintos. Por ejemplo, si hubiera una arista de $I_7$ con un token `c` hacia un estado $I_i$, y otra arista desde $I_9$ con el mismo token `c` hacia otro estado $I_j$, que no fueran combinables (no tuvieran el mismo centro), entonces no sería posible realizar esta compactación.

Veamos el autómata final que hemos obtenido al combinar los estados con el mismo centro:

    I0 = {
        S -> .E,     $
        E -> .A = A, $
        E -> .i,     $
        A -> .i + A, =
        A -> .i,     =
    }

    I1 = Goto(I0, E) = {
        S -> E., $
    }

    I2 = Goto(I0, A) = {
        E -> A.= A, $
    }

    I3 = Goto(I0, i) = {
        E -> i.,    $
        A -> i.+ A, =
        A -> i.,    =
    }

    I4 = Goto(I2, =) = {
        E ->  A =.A, $
        A -> .i + A, $
        A -> .i,     $
    }

    I5-10 = Goto(I3, +) = Goto(I7-9, +) {
        A ->  i +.A, =$
        A -> .i + A, =$
        A -> .i,     =$
    }

    I6 = Goto(I4, A) = {
        E -> A = A., $
    }

    I7-9 = Goto(I4, i) = Goto(I5-10, i) {
        A -> i.+ A, =$
        A -> i.,    =$
    }

    I8-11 = Goto(I5-10, A) = {
        A -> i + A., =$
    }

El nuevo autómata que hemos construido tiene exactamente 9 estados, la misma cantidad que el autómata SLR, y sin embargo no presenta conflictos. Este autómata se denomina LALR, y constituye el resultado más importante en la práctica para la construcción de compiladores, ya que la mayoría de los generadores de parsers autómaticos usados en la industria construyen este tipo de autómatas. Esto se debe a que combina de forma ideal un poder reconocedor muy similar al LR, con una cantidad de estados mucho menor, proporcional al SLR.

Intuitivamente, el motivo por el que este autómata no presenta conflictos, y el SLR sí, se debe a que en este caso hemos hecho un análisis más riguroso de los Follow primero (construyendo el autómata LR), y solo entonces hemos intentado combinar los estados. Esto fue posible ya que los estados con los mismos centros no eran aquellos donde se producían los conflictos **reduce-reduce** en el autómata SLR. Es decir, al aplicar la técnica LR, y analizar cuidadosamente los Follow, logramos evitar el conflicto en el estado $I_3$, pero luego esa misma técnica nos llevó a crear estados independientes innecesarios. De cierta forma, la técnica LR es demasiado rigurosa, y nos lleva incluso a intentar evitar conflictos que en realidad no van a ocurrir. La técnica LALR entonces reconoce estas situaciones donde tenemos "demasiado rigor" y simplifica el autómata tanto como sea posible.

Siguiendo esta línea de pensamiento, debería ser posible construir el autómata LALR directamente, sin necesidad de primero construir el LR para luego combinar los estados innecesarios. De hecho, esto es posible, y es lo que hacen los generadores de parsers usados en la práctica. Aunque no presentaremos un algoritmo detallado para esto, podemos ver intuitivamente que los estados se pueden ir combinando "sobre la marcha", a medida que se descubren estados con el mismo centro que otros ya creados, y arreglando las transiciones existentes en caso de ser necesario.

Un punto de importancia en el autómata LALR, es que no se puede hacer "una parte" de este. Es decir, o bien todos los estados con el mismo centro de combinan, y no aparece ningún conflicto nuevo, o no se combina ninguno y el autómata se queda LR. De modo que no existen "grados" de LALR.

## Implementación del parser LR

Veamos entonces como construir un algoritmo de parsing lineal que obtenga el árbol de derivación correspondiente. Recordemos que lo que tenemos hasta el momento es un autómata que nos permite reconocer si el contenido de la pila es un prefijo viable. En principio, en cada iteración, tras realizar un **shift** o un **reduce**, es necesario volver a correr el autómata en todo el contenido de la pila, para determinar en qué estado termina, y poder decidir la próxima operación. Esto es innecesariamente costoso. Intuitivamente, dado que tras una operación **shift** o **reduce** sabemos exactamente como cambia la pila, deberíamos poder "hacer backtrack" en el autómata, y solamente ejecutar la parte necesaria para reconocer el nuevo sufijo de la pila.

Por ejemplo, supongamos que tenemos un estado del parser $\alpha | c \omega$, y al ejecutar el autómata, terminamos en un estado $I_i$ que indica **shift** con el token `c`. Si $Goto(I_i, c) = I_j$, entonces sabemos que la siguiente iteración terminaremos en el estado $I_j$. Efectivamente, tras un **shift** tendremos un nuevo estado en la pila $\alpha c | \omega$, y como el autómata es determinista, tras reconocer $\alpha$ tendrá que terminar necesariamente en el estado $I_i$. Luego, el token `c` lo envía al estado $I_j$, precisamente porque esa es la definición de la función **Goto**. Por tanto, tras una operación de **shift**, no es necesario volver a correr el autómata en todo el contenido de la pila. Simplemente podemos transitar directamente al estado $Goto(I_i, c)$.

Veamos que sucede tras una operación **reduce**. Sea $\alpha \beta | \omega$ el estado de la pila antes del **reduce**, y $\alpha X | \omega$ el estado después de reducir $X \rightarrow \beta$. Supongamos que el autómata, tras reconocer $\alpha$, cae en el estado $I_i$. Entonces tras reconocer $\alpha X$ debe caer en el estado $Goto(I_i, X)$ por definición. Por tanto, una vez sacados $|\beta|$ terminales de la pila, solamente necesitamos ser capaces de "recordad" en que estado estaba el autómata cuando reconoció los primeros $|\alpha|$ terminales, y de ahí movernos una sola transición. Para ello, sencillamente almacenaremos en la pila, además de la forma oracional que se está construyendo, también los estados que transita el autómata en cada símbolo (ya sea almacenando pares $<X,i>$ o con una pila paralela para los estados). Por tanto, cuando extraemos los $|\beta|$ terminales de la pila, en el tope está justamente el estado $I_i$.

Con estas dos estrategias, podemos demostrar que tenemos un algoritmo de parsing lineal. Definamos entonces de una vez y por todas este algoritmo formalmente. Para ello vamos a construir una tabla, que llamaremos **tabla LR**, y que nos indicará en cada situación qué hacer (al estilo de la **tabla LL**). Mostraremos a continuación la **tabla LR** para el autómata construido anteriormente, y luego veremos paso a paso los detalles sobre su construcción:

Estado  =             +        i        $             E       A
------- ------------- -------- -------- ------------- ------- --------
0                              S3       S->E          1       2
1                                       OK
2       S4
3       A->i                   S5                     E->i
4                              S7                             6
5                              S9                             8
6                                       E -> A = A
7                     S10               A -> i
8       A -> i + A
9       A -> i                 S5
10                             S7                             11
11                                      A -> i + A
------- ------------- -------- -------- ------------- ------- --------

La tabla LR contiene una fila por cada estado del autómata, y una columna por cada símbolo (terminales y no-terminales). Usaremos la notación $T[i,x]$ para referirnos a la entrada asociada al símbolo $x$ en el estado $I_i$:

* Si $S \rightarrow E \cdot, \$$ pertenece al estado $I_i$, entonces la entrada $T[i,\$] = OK$.
* Si $Goto(I_i, X) = I_j$:t
    * Si $X \in N$, entonces $T[i,X] = j$.
    * Si $X \in T$, entonces $T[i,X] = S_j$ (**shift**):
* Si el item $Y \rightarrow \beta \cdot, c$ está en el estado $I_i$, entonces $T[i,c] = Y \rightarrow \beta$ (**reduce**).

Para usar la tabla, veamos qué significa cada posible valor en una entrada. Sea $S = \alpha | c \omega$ el estado de la pila de símbolos, e $I_i$ el estado del autómata en el tope de la pila de estados (asumiendo una implementación basada en dos pilas paralelas). Buscamos entonces la entrada $T[i,c]$, y según su valor realizamos la siguiente operación:

* Si $T[i,c] = OK$, entonces terminamos de parsear y la cadena se reconoce.
* Si $T[i,c] = S_j$, entonces hacemos **shift**, la pila de símbolos se convierte en $\alpha c | \omega$, y ponemos el estado $I_j$ en el tope de la pila de estados.
* Si $T[i,c] = X \rightarrow \delta$, entonces se garantiza que $\alpha = \beta \delta$. Extraemos $|\delta|$ elementos de la pila de símbolos **y** de la pila de estados. Sea $I_k$ el estado que queda en el tope de la pila de estados; colocamos a $X$ en el tope de la símbolos y colocamos $T[k,X]$ en el tope de la pila de estados.
* En cualquier otro caso, se ha encontrado un error.

Para entender por qué el algoritmo descrito anteriormente funciona, tratemos de interpretar qué significa cada entrada en la tabla. Una entrada de la forma $S_j$ significa que con el token correspondiente existe una transición hacia el estado $I_j$. Por tanto, la operación a realizar es **shift**, y como ya hemos visto anteriormente, en la pila de estados sabemos que el siguiente estado hacia el que transitar será justamente $j$. Una entrada de la forma $X \rightarrow \beta$ significa que existe un item **reduce** con el token correspondiente de *look-ahead*. Por lo tanto se realiza la operación de **reduce**. Como vimos anteriormente, en el tope de la pila de estados quedará el estado $I_j$ que habíamos transitado justo antes de reconocer la producción reducida. Por tanto, de ese estado anterior, el nuevo estado al que transitaremos es justamente $T[j,X]$.

El único punto que nos queda por discutir, es cómo se construye el árbol de derivación. Esbozaremos un algoritmo para esto, que ejemplificaremos más adelante. Dado que la derivación se construye de abajo hacia arriba, intuitivamente puede verse que construiremos el árbol empezando por las hojas. La idea general consiste en mantener una tercera pila donde se irán acumulando sub-árboles de derivación. Cada vez que se haga una operación **reduce** $X \rightarrow \beta$, tendremos en el tope de esta pila $|\beta$ sub-árboles de derivación, que agruparemos bajo una nueva raíz $X$. Al finalizar el reconocimiento, en la pila quedará solamente un árbol, que será la derivación de toda la cadena.

Veamos ahora un ejemplo de cómo funciona el algoritmo de parsing bottom-up con la cadena `i = i + i`, usando la tabla definida anteriormente. Ilustraremos la ejecución del algoritmo, representando el estado de la pila de símbolos de la forma usual, y además representando las dos pilas correspondientes a los estados y los sub-árboles de derivación. Para representar un árbol, usaremos la notación $X(t_1,t_2,\ldots,t_n)$, donde $X$ es el símbolo de la raíz, y $t_i$ es una hoja, o un árbol a su vez. Comenzamos entonces con todas las pilas en su estado inicial:

    Symbols ::  |i = i + i $
    States  :: 0|
    Trees   ::  |

Consultamos la tabla. En el estado 0, con *look-ahead* `i`, la operación es **shift 3**. Notemos cómo en este estado inicial, todos los demás token darían error. Colocamos el terminal, el estado, y el árbol recién creado en el tope de las respectivas pilas:

    Symbols ::   i|= i + i $
    States  :: 0 3|
    Trees   ::   i|

Nos encontramos ahora en el estado 3, con *look-ahead* `=`, la operación es **reduce** `A -> i`. Entonces sacamos el token `i` de la pila y lo reemplazamos por `A`. El estado 3 también se saca y se reemplaza por $Goto(0, A) = 2$ (0 es el estado que queda justo debajo de 3 en la pila). El árbol $i$ se ubica como único hijo del nuevo árbol $A$ creado:

    Symbols ::    A|= i + i $
    States  ::  0 2|
    Trees   :: A(i)|

Consultamos de nuevo la tabla, $T[2,=]$ es **shift 4**:

    Symbols ::    A =|i + i $
    States  ::  0 2 4|
    Trees   :: A(i) =|

Consultamos de nuevo, $T[4,i]$ es **shift 7**. En la pila de árboles se nos han ido acumulando sub-árboles distintos, que serán mezclados en el futuro:

    Symbols ::    A = i|+ i $
    States  ::  0 2 4 7|
    Trees   :: A(i) = i|

Ahora $T[7,+]$ nos dice **shift 10**:

    Symbols ::    A = i +|i $
    States  :: 0 2 4 7 10|
    Trees   :: A(i) = i +|

Por último, $T[10,i]$ nos dice nuevamente **shift 7**:

    Symbols ::    A = i + i|$
    States  :: 0 2 4 7 10 7|
    Trees   :: A(i) = i + i|

Volvemos entonces al estado $I_7$, pero ahora con *look-ahead* `$` la operación indicada es **reduce** `A -> i`. El nuevo estado será $Goto(10,A) = 11$.

    Symbols ::       A = i + A|$
    States  ::   0 2 4 7 10 11|
    Trees   :: A(i) = i + A(i)|

Ahora $T[11,$]$ también nos indica **reduce** pero en este caso en `A -> i + A`. Vamos a sacar entonces 3 elementos de cada pila. En la pila de símbolos, sustituímos `i + A` por `A`. En la pila de estados, sacamos los tres últimos elementos, y ponemos $Goto(4, A) = 6$. En la pila de árboles, sacamos los tres árboles del tope y creamos un nuevo árbol $A$ con esos tres como hijos:

    Symbols ::              A = A|$
    States  ::            0 2 4 6|
    Trees   :: A(i) = A(i,+,A(i))|

Hemos dado un gran salto de fé, pues al sacar los últimos tres estados, hemos confiado en que la pila de estados nos recordará dónde estaba el autómata justo antes de hacer el primer **shift** que dio paso a toda la forma oracional `i + A`. Continuemos entonces con $T[6,\$]$ que nos dice justo lo que esperábamos: **reduce** `E -> A = A`. Repetimos toda la operación de reducción que ya conocemos, siendo $Goto(0,E) = 1$ el último estado que tendremos que analizar:

    Symbols ::                     E|$
    States  ::                   0 1|
    Trees   :: E(A(i),=,A(i,+,A(i)))|

Finalmente, $T[1,E]$ nos dice que la cadena ha sido parseada. En el tope de la pila de símbolos queda el símbolo inicial, y en la pila de árboles hay un solo árbol que contiene la derivación que hemos construido. Honestamente, en una implementación computacional concreta la pila de símbolos es innecesaria, pues todas las decisiones se toman mirando solamente la pila de estados, y el resultado necesario se computa en la pila de árboles. De cierta forma, esta pila de árboles es un *upgrade* de la pila de símbolos. Hemos hecho la distinción en este ejemplo por cuestiones puramente didácticas, pero en la práctica, la pila de símbolos no se usa.

## Comparaciones entre LL, SLR, LR y LALR

Hemos visto hasta el momento los dos paradigmas fundamentales para el parsing determinista de gramáticas libres del contexto. Hagamos entonces una reflexión final sobre los resultados que hemos obtenido, y las herramientas que hemos desarrollado.

El parser LL es posiblemente el más sencillo de todos los parsers que es útil. En muchos contextos donde se tiene que diseñar un lenguaje bien sencillo (por ejemplo, un DSL integrado en un sistema más complejo), este parser puede brindar una solución fácil y eficiente. La mayor ventaja es que se puede escribir directamente, sin necesidad de usar un generador de parser. Los conjuntos First y Follow se computan a mano, y luego se escriben cada uno de los métodos recursivos asociados a las producciones. Para cualquier lenguaje de complejidad algo mayor, recurriremos entonces a construir un parser LR.

De manera general, el autómata SLR tiene una cantidad considerablemente menor de estados que el autómata LR correspondiente. En los casos donde la gramática es SLR(1) es preferible usar dicho autómata. Desgraciadamente, la mayoría de las construcciones sintácticas de interés para los lenguajes de programación usuales tienen gramáticas "naturales" que no son SLR, pero sí LR, y generalmente LALR. Por este motivo, el parser LR(1) es, en la práctica, el más usado. Su mayor desventaja radica en el elevado número de estados, que dificultan su almacenamiento. Este problema era especialmente complejo en el año 1965, cuando Donald Knuth propuso este parser. Por tal motivo, aunque teóricamente es una solución adecuada, en la práctica no se usó hasta que en 1969 James DeRemer propuso el parser LALR, que reduce considerablemente la cantidad de estados hasta un nivel comparable con el SLR, sin perder prácticamente en expresividad con respecto con al LR. Más adelante en 1971 el propio DeRemer propondría el SLR como una variante más sencilla de construir algo parecido al LALR de forma más sencilla.

De modo que, en una situación real, la primera decisión podría ser intentar directamente construir un parser LALR. Si esto funciona, no hay nada más que hacer. En caso contrario, deberíamos probar entonces a construir un parser LR, aunque tenga una cantidad mucho mayor de estados. En el caso peor en que esto no sea posible, tendremos que modificar la gramática. En la práctica esto no sucede comúnmente. Aunque es cierto que es fácil encontrar lenguajes didácticos que no sean LR y sean bien pequeños, los lenguajes de programación reales tienen construcciones que generalmente sí son LR. Incluso en los casos en que esto no sucede, veremos más adelante que es posible "pasar" algunos de los problemas del lenguaje para la fase semántica, y simplificar la gramática, haciéndola LR.

Desde el punto de vista teórico, tenemos una jerarquía de gramáticas que se comporta de la siguiente forma:

    +------------------+
    |        LR        |
    |     +------+     |
    |     |  LL  |     |
    | +---|------|---+ |
    | |   | LALR |   | |
    | | +-|------|-+ | |
    | | | | SLR  | | | |
    | | +-|------|-+ | |
    | +---|------|---+ |
    |     +------+     |
    +------------------+

Es decir, las gramáticas LR son un conjunto estrictamente superior a las gramáticas LL, SLR y LALR. Entre las gramáticas SLR, LALR y LR hay una relación de inclusión que es un orden total. Sin embargo, aunque las gramáticas LL están estrictamente incluidas en las LR, existen gramáticas LL que no son ni SLR ni LALR.

Desde el punto de vista de la implementación, los parsers SLR, LALR y LR son idénticos. Solamente se diferencian en la forma en que se construye el autómata, que en última instancia determina la tabla obtenida. De la tabla en adelante el algoritmo de parsing es el mismo que hemos visto. De modo que, en una implementación concreta, es posible desacoplar el mecanismo que genera la tabla, del mecanismo que la ejecuta, y reutilizar toda la segunda parte para cualquiera de los tres tipos de parsers.

Otra cuestión interesante es qué sucede con los errores de parsing. Knuth demostró que el autómata LR reconoce los errores de parsing lo antes posible, para cualquier clase de parser determinista. Esto quiere decir que con la misma cadena (incorrecta) de entrada, ningún algoritmo de parsing podrá darse cuenta de que la cadena es errónea antes que el algoritmo LR. De hecho, los parsers LALR y SLR son más permisivos. Dada una cadena incorrecta, es posible que el parser SLR o LALR haga algunas reducciones de más, antes de darse cuenta de que la cadena es inválida. Al final ninguno de estos parsers deja pasar incorrectamente una cadena inválida, por supuesto. Pero reconocer un error lo antes posible, además de la ventaja en eficiencia, es también muy conveniente para brindar al programar un mensaje de error lo más acertado posible.

Cabe preguntarse entonces si al inventar el autómata LR hemos definitivamente terminado con el problema de parsing. Pues resulta que la respuesta teórica para esta pregunta es **sí**. En 1965 Knuth demostró que para todo lenguaje libre del contexto determinista tiene que existir una gramática LR(k). Los lenguajes libres del contexto deterministas son aquellos tales que existe un algoritmo de parsing lineal en la longitud de la cadena en caso peor. Por otro lado, toda gramática LR(k) puede ser convertida a LR(1), con la adición de nuevos no-terminales y producciones. De modo que tenemos un resultado teórico que dice: si un lenguaje puede ser parseado en tiempo lineal, entonces puede ser parseado con un parser LR(1). Aquellos lenguajes libres del contexto que no son LR(1) tienen que ser por necesidad ambiguos, o al menos es imposible diseñar un algoritmo de parsing con tiempo lineal. De cierta forma, podemos decir que hemos terminado, pues todo lenguaje "sensato" es LR(1).

Este resultado es de hecho impresionante, pero la historia no acaba ahí. Incluso aunque teóricamente LR(1) es suficiente, en la práctica hay lenguajes deterministas cuyas gramáticas LR(1) son tan complicadas, que es preferible usar una gramática más flexible, incluso incluyendo algo de ambiguedad que pueda ser resuelto en una fase superior. Afortunadamente, el problema de encontrar un árbol de derivación para cualquier gramática libre del contexto tiene solución con caso peor $O(n^3)$ con respecto a la longitud de la cadena. Es decir, existen parsers generales que pueden reconocer cualquier lenguaje libre del contexto, *incluso lenguajes ambiguos*, y en estos casos se pueden obtener **todos** los árboles de derivación que existen. En la práctica sin embargo, para diseñar lenguajes de programación, queremos parsers lineales por motivos de eficiencia. Estos parsers más generales se emplean sobre todo en tareas de procesamiento de lenguaje natural (p.e. traducción automática).
