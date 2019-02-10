---
next-chapter: chap1
---

# Introducción {-}




Este documento tiene como objetivo presentar el diseño de un curso de Compilación para estudiantes de Ciencia de la Computación. Este documento no es en absoluto un libro de texto de la asignatura Compilación (ni pretende serlo). Se asume que los profesores y estudiantes cuentan con documentación adicional para profundizar en los conocimientos impartidos. Cuando se presenta una sección de contenido, es más con el objetivo de presentar una guía sobre qué contenido será impartido, ilustrar un posible enfoque para introducir dicho contenido, y quizá además para acotar ciertas cuestiones específicas que consideramos de especial importancia. En cualquier caso, los estudiantes pueden encontrar también en este documento respuestas a preguntas de su interés, no solo desde el punto de vista puramente técnico (preguntas sobre el contenido) sino también desde el punto de vista metodológico (preguntas sobre la forma, o preguntas sobre las preguntas). De esta manera pueden entender mejor qué podemos prometerles como instructores, que se espera de ellos en cambio, y de qué forma pueden sacar el máximo provecho de este curso.

## Diseño del Curso {-}

Este curso fue diseñado bajo una concepción más dinámica e interactiva, más integrada con el resto de las disciplinas, y más práctica, pero sin perder en formalidad, precisión y profundidad en el conocimiento impartido. Para desarrollar este curso, primeramente nos planteamos primerante la siguiente pregunta: *¿Cuáles son las cuestiones fundamentales que esta asignatura ayuda a responder y comprender?*

El objetivo de esta pregunta es cuestionarse primeramente el porqué de un curso de Compilación, antes de decidir qué contenidos específicos se deben incluir. Para ellos analizamos el lugar que ocupa la asignatura dentro del plan general de la carrera de Ciencia de la Computación, y los diversos conocimientos que enlaza. De esta forma pretendemos diseñar un curso más integrado y de mayor utilidad para la formación profesional.

En una primera mirada, el curso de Compilación ocupa un lugar privilegiado dentro de la carrera. Ocurre justo en un momento donde los estudiantes han obtenido la mayor parte de los conocimientos básicos (programación, diseño de algoritmos, lógica y matemática y discreta), y están a punto de comenzar a adentrarse en las cuestiones propias de la Ciencia de la Computación. Esta asignatura viene a ser, de un modo tal vez un poco arrogante, la asignatura más integradora de toda esta primera parte. En este punto los estudiantes conocen cuestiones de muy alto nivel, tales como diseños de algoritmos y estructuras de datos, teoría de la computabilidad y la complejidad computacional, patrones de diseño y diversos paradigmas de programación, así como una creciente colección de lenguajes de programación particulares. Además conocen muchos detalles de bajo nivel, tales como la arquitectura de los procesadores, la memoria, los procesos y los sistemas operativos, lenguajes de máquina y ensambladores y modelos computacionales para la implementación de operaciones aritméticas eficientes.

Compilación viene a ser la asignatura que enlaza estos dos mundos, el de alto nivel, y el de bajo nivel. Por primera vez los estudiantes pueden hacerse una idea del proceso completo que sucede desde la concepción de una idea de un algoritmo o sistema, su análisis, su implementación en un lenguaje de alto nivel (o varios lenguajes, frameworks y bibliotecas), y como todo ello se traduce a un lenguaje de máquina, y se ejecuta encima de un dispositivo de cómputo concreto. Desde este punto de vista, Compilación permite integrar los conocimientos del resto de las disciplinas de esta primera parte de la carrera, y viene a cerrar lo que podemos llamar el perfil básico del Científico de la Computación. Es en cierta forma la última de las asignaturas básicas y la primera de las asignaturas avanzadas.

En una primera enumeración, podemos intentar definir habilidades y conocimientos concretos que los estudiantes pueden aspirar a obtener en esta asignatura. Un buen ejercicio consiste en preguntar a los propios estudiantes qué creen que deberían aprender en esta asignatura. Aunque realmente no tienen una idea clara de cuál es el campo de estudio que tienen delante, o dicho de otra forma, sobre qué *deberían* aprender; hemos encontrado que los estudiantes sí tienen expectativas bastante claras sobre qué *quieren* aprender. Por supuesto, encontrar un balance adecuado entre ambos intereses (los *nuestros* y los *suyos*) debe ser un objetivo a perseguir. Presentamos a continuación una posible e incompleta lista de estas habilidades, que hemos recopilado de varias sesiones de preguntas a estudiantes, edulcoradas con nuestras propias concepciones:

- Reconocer problemas típicos de compilación y teoría de lenguajes.
- Crear reconocedores y generadores de lenguajes.
- Entender el funcionamiento de un compilador.
- Saber cómo se implementan instrucciones de alto nivel.
- Diseñar lenguajes de dominio específico.
- Poder implementar intérpretes y compiladores de un lenguaje arbitrario.
- Entender las diferencias y similaridades entre lenguajes distintos.
- Conectar lenguajes de alto nivel con arquitecturas de máquina.
- Aprender técnicas de procesamiento de lenguaje natural.

Estas habilidades cubren desde los temas más prácticos sobre el diseño de lenguajes y compiladores hasta cuestions más filósoficas y abstractas relacionadas con otras áreas del conocimiento, desde la ingeniería de software hasta la inteligencia artificial. Los estudiantes quieren no sólo ser capaces de _hacer_, sino también, y tal vez más importante, quieren ser capaces de _entender_ cómo funcionan los algoritmos, técnicas, estructuras de datos, patrones de diseño, modelos de razonamiento, que son empleados en esta ciencia.

Para dar forma a un curso que pueda ayudar a los estudiantes a obtener estas habilidades (y otras relacionadas), nos dimos entonces a la tarea de resumir las preguntas o cuestiones fundamentales que debe responder dicho curso. En una primera instancia, parece que una pregunta tan clara cómo _¿qué es un compilador?_ o incluso _¿cómo funciona un compilador?_ puede servir de guía al contenido del curso. Sin embargo, en una mirada más profunda, podemos descubrir que hay cuestiones más primarias, a las cuáles un compilador es ya una respuesta, un medio más que un fin en sí mismo. De hecho, podemos cuestionarnos porqué surgió la necesidad de hacer compiladores en primer lugar, a qué problema intentaron dar respuesta, y tratar de escarbar entonces las preguntas más primarias que subyacen en esta historia.

## Un poco de historia {-}

Podemos comenzar esta historia más o menos así. Hay una gran distancia entre el nivel de razonamiento que ocurre en el cerebro y el nivel de razonamiento que ocurre en una computadora. Los problemas de cualquier dominio se resuelven pensando a un nivel de abstracción con un lenguaje que describe las reglas de ese dominio. Hubo una época en que estos niveles de abstracción tenía que conectarlos el programador. De hecho, en esta época, la diferencia entre analista y programador era justamente que el analista diseñaba la solución en su lenguaje, y el programador la traducía a un programa ejecutable en el lenguaje de máquina.

Por ejemplo, en 1952 Grace Hooper trabajaba en la simulación de trayectorias balísticas. Para dirigir un proyectil a su objetivo, los modelos físicos se describen en un lenguaje de ecuaciones diferenciales y mecánica newtoniana. Sin embargo, para poder implementar estos modelos en un dispositivo de cómputo hay que hablar en un lenguaje de registros, pilas e interrupciones. Esta diferencia es lo que hace que programar sea tan difícil, y hacía extremadamente lento el desarrollo de nuevos modelos porque a cada paso podían haber errores tanto en la modelación como en la codificación. ¿Cuando algo fallaba, de quién era la culpa? ¿Del analista o del programador? ¿O peor, del sistema de cómputo?

Entonces a Grace Hooper se le ocurrió una genial idea: viendo que el proceso de convertir las ecuaciones diferenciales a programas concretos era fundamentalmente mecánico, ¿por qué no dejar que la propia computadora hiciera esta conversión?

Esta idea genial tomaría varios años en perfeccionarse al punto de ser una realidad. El primer compilador de Grace Hooper para el lenguaje A-0 realmente era prácticamente un linker con algunas funciones básicas. Los primeros lenguajes de alto nivel en tener compiladores "serios" son FORTRAN (1957, John Backus), ALGOL (1958, Friedrich Bauer) y COBOL (1960, Grace Hooper). Una ventaja adicional además de reducir el tiempo de desarrollo, era la posibilidad de compilar el mismo programa para múltiples plataformas. En 1960 por primera vez se compiló el mismo programa de COBOL para dos máquinas distintas: UNIVAC II y RCA 501.

En este punto los lenguajes se volvieron suficientemente complicados, al punto que ya los compiladores no se podían escribir "a mano". Entonces hizo falta volcarse a la teoría, y desarrollar una ciencia sobre qué tipos de lenguajes de programación se podían compilar, y con qué compiladores. Esto dio nacimiento, en 1960, a la ciencia que hoy conocemos como Compilación. Motivada no solo por un motivo práctico, sino también fundamentada en los principios teóricos más sólidos, la compilación vino a convertirse en una de las primeras justificaciones para que la computación se cuestionara problemas propios, y dejara de ser una mera herramienta de cálculo. Problemas tan distantes como el procesamiento de lenguaje natural y la naturaleza de las funciones computables han caído bajo el diapasón de las problemáticas estudiadas en este campo. Hoy la compilación es una ciencia sólida, fundamentada en años de teoría formal y práctica ingenieril.

Escondida bajo todo este aparataje formal y toda la gama de experiencias y resultados teóricos y prácticos de los últimos 60 años, podemos encontrar una cuestión más fundamental, una pregunta que quizá retroceda hasta el propio Alan Turing, o incluso más allá, hasta Ada Lovelace y Charles Babbage con su máquina analítica. La cuestión es esta:

> **¿Cómo hablar con una computadora?**

Esta pregunta es, a nuestro modo de ver, en última instancia la cuestión a responder en este curso. Todos los intentos de diseñar lenguajes, todos los algoritmos y técnicas descubiertos, todos los patrones de diseño y arquitecturas, están en última instancia ligados al deseo de poder hacer una *pregunta* a la computadora, y obtener una *respuesta* a cambio. No importa si la pregunta es calcular cierta trayectoria de proyectiles, o encontrar la secuencia de parámetros que minimizan cierta función. Todo programa es en cierto modo una conversación con la computadora, un canal de comunicación, que queremos que sea lo suficientemente poderoso como para poder expresar nuestras ideas más complejas, y lo suficientemente simple como para poder ser entendido por una máquina de Turing. Como veremos en este curso, hallar el balance adecuado es un problema sumamente interesante, e intentar responderlo nos llevará por un camino que nos planteará muchas otras interrogantes, entre ellas las siguientes:

- ¿Qué tipos de lenguajes es capaz de *entender* una computadora?
- ¿Cuánto de un lenguaje debe ser *entendido* para poder entablar una conversación?
- ¿Qué es *entender* un lenguaje?
- ¿Es igual de fácil o difícil *entender* que *hablar* un lenguaje?
- ¿Podemos caracterizar los lenguajes en términos computacionales según su complejidad para ser *entendidos* por una computadora?
- ¿Cómo se relacionan estos lenguajes con el lenguaje humano?
- ¿Qué podemos aprender sobre la naturaleza de las computadoras y los problemas computables, a partir de los lenguajes que son capaces de reconocer?
- ¿Qué podemos aprender sobre el lenguaje humano para hacer más inteligentes a las computadoras?
- ¿Qué podemos aprender sobre el lenguaje humano, y la propia naturaleza de nuestra inteligencia, a partir de estudiar los lenguajes entendibles por distintos tipos de máquinas?

Estas preguntas, aunque no serán directamente respondidas en los siguientes capítulos, forman la columna vertebral del contenido del curso, en el sentido en qué todo lo presentado es con la intención de, al menos, poder echar un poco de luz en estos temas. Esperamos que al finalizar el curso, los estudiantes sean capaces de discutir las implicaciones filosóficas de las posibles respuestas a estas preguntas, y no solo a las cuestiones técnicas o más prácticas que el curso ataca. Por este motivo, sí trataremos en la medida de lo posible de, además del contenido técnico, adicionar en ocasiones algunos comentarios o discusiones más filósoficas al respecto de estas preguntas y otras similares.

## Anatomía de un Compilador {-}

Comenzaremos este viaje diseccionando el sistema computacional canónico de la teoría de lenguajes formales: un compilador. A grandes razgos, un compilador no es más que un programa, cuya entrada y salida resultan ser también programas. La entrada es un programa en un lenguaje que llamaremos "de alto nivel", y la salida en un lenguaje de "bajo nivel", que es equivalente al primero. Exactamente qué es alto y bajo nivel dependerá de muchos factores, y no existe una definición formal. De forma general, un lenguaje de alto nivel es aquel que nos es cómodo a los programadores para expresar las operaciones que nos interesa ejecutar. Así mismo, un lenguaje de bajo nivel es aquel que un dispositivo de cómputo puede ejecutar de forma eficiente. Tal vez los ejemplos más típicos sean un lenguaje orientado a objetos y un lenguaje ensamblador respectivamente, pero existen muchas otras combinaciones de lenguaje de entrada y salida de interés.

![Representación abstracta del proceso de compilación.](../graphics/mountain.svg){ width=100% }

Ahora bien, antes de zambullirnos de lleno en la anatomía de un compilador, es conveniente mencionar algunas sistemas de procesamiento de lenguajes relacionados. Podemos intentar categorizarlos según el "tipo" del lenguaje de entrada y salida. En primer lugar, el ejemplo clásico es cuando queremos convertir un lenguaje de alto nivel a otro de bajo nivel, y justamente llamamos a este sistema un **compilador**. El caso contrario, cuando queremos convertir de un lenguaje en bajo nivel a otro en alto nivel, podemos llamarle por analogía un **decompilador**. Este tipo de herramientas son útiles para analizar y realizar ingeniería inversa en programas para los que, tal vez, ya no tenemos el código fuente, y necesitamos entender o modificar. Los otros dos casos, de alto nivel a alto nivel y de bajo nivel a nivel son básicamente **traductores**; y en ocasiones se les llama también **transpiladores**. Por ejemplo, TypeScript es un lenguaje de alto nivel que se "transpila" a JavaScript, otro lenguaje también de alto nivel. Entre lenguajes de bajo nivel podemos tener también traductores. Un ejemplo son los llamados **compiladores JIT** (*just-in-time*), que se usan para traducir un programa compilado a un lenguaje de bajo nivel genérico (por ejemplo **IL**) a un lenguaje de máquina específico para la arquitectura donde se ejecuta.

Volvamos entonces al caso clásico, el **compilador**. o este curso vamos a usar como una guía didáctica el diseño de un compilador para el lenguaje HULK, que compilará a un lenguaje de máquina denominado MIPS. Los detalles de ambos lenguajes serán introducidos a medida que sea conveniente, pero por el momento cabe decir que HULK es un lenguaje orientado a objetos, con recolección automática de basura, herencia simple, polimorfismo, y un sistema de tipos unificado. MIPS es un lenguaje ensamblador de pila para una arquitectura de 32 bits con registros y operaciones aritméticas, lógicas y orientadas a cadenas.

Intentemos entonces definir esta maquinaria paso a paso. De forma abstracta nuestro compilador es una "caja negra" que convierte programas escritos en HULK a programas escritos en MIPS:



![](../graphics/image-chap0-1.svg){ #image-chap0-1 width=50% }\


Para comenzar a destapar esta caja negra, notemos que al menos tenemos dos componentes independientes: uno que opera en lenguaje COOL y otro que opera en lenguaje MIPS. Necesitamos ser capaces de "leer" un programa en COOL y "escribirlo" en MIPS. Al primer módulo, que "lee", le llamaremos *parser*, o analizador sintáctico, por motivos históricos que veremos más adelante. Al segundo componente le llamaremos simplemente el *generador*.



![](../graphics/image-chap0-2.svg){ #image-chap0-2 width=70% }\


De aquí surge immediatamente una pregunta: ¿qué protocolo de comunicación tienen estos módulos? Es necesario diseñar una especie de lenguaje intermedio, un mecanismo de representación que no sea ni COOL ni MIPS, sino algo que esté "a medio camino" entre ambos. Es decir, hace falta traducir el programa en COOL a alguna forma de representación abstracta, independiente de la sintaxis, que luego pueda ser interpretada por el generador y escrita en MIPS. Llamésmole de momento *representación intermedia (IR)*.



![](../graphics/image-chap0-3.svg){ #image-chap0-3 width=75% }\


Pasemos entonces a analizar qué forma debe tener esta representación intermedia. En principio, debe ser totalmente independiente de COOL o de MIPS, en términos de sintaxis. A fin de cuentas, podemos estar generando para cualquier otra plataforma, no solo MIPS. Por otro lado, tiene que ser capaz de capturar todo lo qué es posible expresar en COOL. A este tipo de representación, independiente de la sintaxis, pero que captura todo el significado, le vamos a llamar indistintamente *representación semántica* en ocasiones, justamente por este motivo. ¿Qué va en una representación semántica? Pues todos los conceptos que son expresables en un programa, dígase clases, métodos, variables, expresiones, ciclos. ¿Qué no va? Pues todo lo que sea "superfluo" al significado. Por ejemplo, el hecho de que un método tiene un nombre, pertenece a una clase, y tiene ciertos argumentos de ciertos tipos, es importante semánticamente. Dos métodos se diferencian por alguno de estos elementos. Por otro lado, el hecho de que un método se escribe primero por su nombre, luego por los argumentos entre paréntesis seguidos por los nombres de sus tipos, es poco importante *en este momento*. Daría lo mismo que los tipos fueran delante o detrás de los nombres de los argumentos, ya en esta fase del procesamiento lo que nos interesa es de qué tipo es un argumento, y no si ese tipo se declara antes o después textualmente.

Definir exactamente qué es semánticamente importante en un lenguaje particular no es una tarea fácil, y veremos una vez llegados a ese punto algunas ideas para atacar este problema (qué es en última instancia un problema de diseño, y por lo tanto es más un arte que una ciencia, al menos en el sentido artístico de Donald Knuth). Lo que sí es interesante de momento, es analizar qué tipo de procesamiento es importante, o al menos conveniente, realizar sobre esta representación intermedia.

Cómo justificaremos más adelante, existen estructuras linguísticas que no son fáciles de reconocer, porque son dependientes del contexto. Por ejemplo, la expresión `x = y + z` es muy sencilla de reconocer sintácticamente, pero en un lenguaje con tipado estático esta expresión puede no pertenecer al lenguaje según los tipos de cada variable. Este es un problema clásico de dependencia del contexto, donde la expresión `x = y + z` es válida si existe en el contexto donde, por ejemplo existe, `int x, int y, int z` pero no donde el contexto es `int x, int y, object z`. Hay muchos problemas que son dependientes del contexto, entre ellos:

- Declaración de variables antes de su uso
- Consistencia en los tipos declarados y las operaciones realizadas
- Consistencia entre la declaración de una función y su invocación
- Retornos en todos los caminos de ejecución

La solución de estos problemas empleando las técnicas de la teoría de lenguajes solamente es en general no polinomial, y a veces no computable. Pero muchos de estos problemas se pueden resolver de forma más sencilla analizando la estructura computacional intermedia. ¿Por qué? Veremos más adelante que esta estructura tiene generalmente forma arbórea, y en una estructura arbórea es fácil analizar la consistencia de los tipos y problemas similares recorriendo cada uno de los nodos. De forma recursiva, el nodo raíz (o programa) estará correcto si cada hijo está correcto. Para realizar este tipo de procesamiento, introduciremos una nueva fase, que llamaremos *chequeo semántico*, y que opera justamente sobre la representación semántica del programa.



![](../graphics/image-chap0-4.svg){ #image-chap0-4 width=100% }\


Finalmente, justo antes de generar el código ejecutable final, cabe preguntarse si existe algún tipo de procesamiento adicional conveniente. Descubriremos más adelante varios tipos de optimizaciones que se pueden aplicar en este punto, entre ellas:

- Eliminar código no alcanzable
- Expandir expresiones constantes
- Elimiar asignaciones superfluas
- Desenrrollar ciclos con extremos constantes

Estas optimizaciones a menudo son convenientes de realizar sobre una estructura del programa mucho más cercana al código de máquina que al código original. Son muchos los factores que influyen en esto y que veremos más adelante, pero de forma intuitiva, es fácil entender que optimizar un programa debe ser un proceso muy cercano al código de máquina, pues la propia naturaleza de la optimización requiere explotar características propias de la maquinaria donde será ejecutado el código. Introduciremos entonces una fase de optimización, que de momento visualizaremos de forma *paralela* al proceso de generación, pues en la práctica ambas fases comparten la misma representación y ambos procesos ocurren de forma más o menos simultánea.



![](../graphics/image-chap0-5.svg){ #image-chap0-5 width=100% }\


Antes de terminar vamos a develar una fase adicional, justo antes del proceso de *parsing*. Para entender por qué, debemos introducirnos un poco más profundamente en este proceso. El proceso de *parsing* básicamente de lo que se encarga es convertir cadenas de texto (escritas en el lenguaje origen) a una estructura (arbórea) que captura la semántica del programa. Por ejemplo, supongamos que tenemos la siguiente expresión como parte de un programa en HULK:

```HULK
if (a <= 0)
    b
else
    c
```

Esta expresión, desde el punto de vista semántico, podemos pensar que se transforma a una estructura como la siguiente:



![](../graphics/image-chap0-6.svg){ #image-chap0-6 width=40% }\


De forma simplificada, en esta estructura hemos representado semánticamente el significado de la expresión sintáctica anterior, extrayendo los elementos importantes (el hecho de que una expresión `if` contiene tres elementos: condición, parte del cuerpo `true` y parte del cuerpo `false`) y obviando los detalles de sintaxis que ya no son imporantes (por ejemplo las palabras `then`, `else` y `fi` que solamente sirven para separar los bloques correspondientes).

La solución de este problema (convertir una secuencia de texto en una representación semántica) nos tomará la primera mitad del curso, pues es uno de los temas centrales en toda la teoría de lenguajes y la compilación en particular. Más adelante formalizaremos con exactitud este problema y veremos muchísimas estrategias de solución. Pero antes de llegar a ese punto, es necesario resolver un sub-problema de menor complejidad, que aún así nos dará suficiente trabajo como para desarrollar gran parte de la teoría de lenguajes en su solución. El problema en cuestión es el siguiente.

La cadena de texto de entrada, realmente está formada por una secuencia de caracteres. En el caso anterior, por ejemplo, tenemos la siguiente secuencia:



![](../graphics/image-chap0-7.svg){ #image-chap0-7 width=100% }\


En esta secuencia hemos representado cada caracter por separado, y hemos puesto explícitamente los espacios en blanco (`\s`), cambios de línea (`\n`) y espacios de tabulación (`\t`). Esta secuencia es lo que realmente "ve" el compilador en la entrada. Por lo tanto, desde el punto de vista puramente sintáctico, existen muchas secuencias que son exactamente el mismo programa. Por ejemplo, si existen varios espacios entre dos símbolos, o si no hay cambios de línea, o si los bloques están indentados con 4 espacios en vez con un caracter `\t`, realmente estamos en presencia del mismo programa.

Para simplificar la tarea del *parser*, es conveniente convertir primeramente esta secuencia de caracteres en una secuencia de **tokens**, que no son más que los elementos básicos que componen el lenguaje, lo que pudiéramos llamar las *palabras* o *símbolos* más básicos. Por ejemplo, en el caso anterior, quisiéramos obtener la siguiente secuencia de **tokens**:



![](../graphics/image-chap0-8.svg){ #image-chap0-8 width=45% }\


Introduciremos entonces una primera fase, que llamaremos indistintamente *tokenización*, o análisis lexicográfico, para transmitir la idea de que en esta fase solamente se procesan los elementos *léxicos*, es decir, las palabras, sin llegar todavía a tocar los elementos *sintácticos*, es decir, la estructura. Al mecanismo encargado de resolver este problema le llamaremos entonces *lexer*.



![](../graphics/image-chap0-9.svg){ #image-chap0-9 width=100% }\


A modo de resumen, tenemos entonces cinco fases fundamentales:

Análisis Lexicográfico (*lexer*)
:   donde se realiza la conversión de una secuencia de caracteres a una secuencia de *tokens*.

    En esta fase se detectan los errores relacionados con la escritura incorrecta de símbolos, por ejemplo, un número decimal con más dígitos de los permitidos, una cadena de texto que no termina en `"`, un identificador que usa un caracter inválido (e.j. `$`).

Análisis Sintáctico (*parser*)
:   donde se determina la estructura sintáctica del programa a partir de los *tokens* y se obtiene una estructura intermedia.

    En esta fase se detectan los errores relacionados con la sintaxis, por ejemplo, un paréntesis no balanceado, una función que no tiene cuerpo, un `if-else` con la parte `else` vacía.

Análisis Semántico
:   donde se verifican las condiciones semánticas del programa y se valida el uso correcto de todos los símbolos definidos.

    En esta fase se determinan los errores relacionados con los símbolos y tipos, por ejemplo, variables no declaradas o usadas antes de su declaración o funciones invocadas con un número o un tipo incorrecto de los argumentos.

Optimización
:   donde se eliminan o simplifican secciones del programa en función de la arquitectura de máquina hacian donde se vaya a compilar.

Generación
:   donde se convierte finalmente la estructura semántica y optimizada hacia el lenguaje objetivo en la arquitectura donde será ejecutado.

Comenzaremos entonces a estudiar la fase de análisis lexicográfico, donde introduciremos los primeros elementos de la teoría de lenguajes formales.

## Contenido {-}

Para intentar responder algunas de las interrogantes planteadas arriba, hemos dividido el contenido del curso en 6 temas fundamentales, aunque existen muchos elementos que son trans-temáticos y por tanto no quedarían bien ubicados en ningún lugar particular. Por este mismo motivo, estos temas no deben tomarse como particiones rígidas del contenido, sino más bien guías a grandes razgos que giran alrededor de un concepto común. De hecho, estos temas no son presentados estrictamente en orden, sino que se van entrelazando a medida que avanza el curso. Los motivos para esto quedarán más claros adelante.

Teoría de lenguajes:
:   En este tema trataremos sobre los aspectos teóricos de la teoría de lenguajes formales, entre otras cuestiones:

    - Definiciones matemáticas y computacionales
    - Tipos de lenguajes y características
    - Equivalencias y relaciones entre lenguajes
    - Problemas interesantes sobre lenguajes
    - Relación entre la teoría de lenguajes y la computabilidad

Mecanismos de generación:
:   En este tema trataremos las diferentes clases de gramáticas, sus propiedades, los tipos de lenguajes que pueden generar, y algunos algoritmos de conversión entre ellas:

    - Jerarquía de gramáticas de Chomsky
    - Gramáticas atributadas
    - Formas normales y algoritmos de conversión

Mecanismos de reconocimiento:
:   En este tema trataremos sobre los autómatas como reconocedores de lenguajes, sus propiedades, y los algoritmos de construcción a partir de las gramáticas correspondientes:

    - Tipos de autómatas según el tipo de lenguaje
    - Conversión entre autómatas y expresiones regulares
    - Autómatas para el problema de *parsing*

Análisis semántico:
:   En este tema trataremos los problemas fundamentales de semántica en el contexto de los compiladores y las estrategias de modelación y solución:

    - Representaciones semánticas y problemas típicos
    - Solución de referencias y *aliases*
    - Inferencia de tipos y expresiones
    - Validación de pre- y post-condiciones e invariantes

Generación de código:
:   En este tema trataremos las diferentes arquitecturas de código de máquina y los problemas asociados:

    - Semánticas operacionales
    - Arquitecturas de generación código
    - Optimizaciones

Ejecución de código:
:   En este tema trataremos los problemas que surgen o son resueltos posterior a la generación de código, y que dependen de operaciones especiales por parte del mecanismo de ejecución:

    - Intérpretes y máquinas virtuales
    - Manejo de excepciones
    - Recolección de basura

La guía general del curso será orientada a la tarea canónica de construir un compilador. Para ello usaremos el lenguaje `COOL` diseñado específicamente para este propósito. Con esta guía en mente, iremos presentando los contenidos en el orden que sean necesarios para ir avanzando en el propósito de construir el compilador. Por este motivo, a diferencia de otros cursos, no daremos primero toda la teoría de lenguajes formales y luego los algoritmos de *parsing*, sino que iremos introduciendo elementos teóricos y prácticos según lo vaya requiriendo el compilador que estamos diseñando en clase.

El objetivo de esta forma de ordenar los contenidos es, en primer lugar, brindar una visión más unificada de todo el proceso de compilación y todas las técnicas, elementos teóricos y cuestiones de diseño. Por otro lado, aspiramos con esto a lograr que los estudiantes realmente obtengan las habilidades planteadas al inicio, al tener que poner desde el principio del curso todo el conocimiento en función de un proyecto práctico.

## Evaluación y retroalimentación {-}

Una vez que los estudiantes saben que habilidades obtendrán, entonces se plantea el problema de la evaluación.
En este curso consideramos la evaluación como una necesidad y una ventaja para los estudiantes, no como una obligación o una arbitrariedad del profesor. Por eso hemos diseñado un sistema de evaluación que permita a los estudiantes reconocerlo como un mecanismo de retroalimentación que les permite entender su propio avance y optimizar su estudio. Claro que la evaluación tiene un valor externo, que le permite a la sociedad saber quienes están preparados o no. Pero las notas particulares obtenidas en una asignatura no significan nada fuera del sistema educacional. A nadie se le ofrece un trabajo por las notas que obtuvo. Lo que cuenta es graduarse o no. Entonces, ¿por qué se toma tanto trabajo en cuantificar la evaluación? La respuesta es que el número obtenido en una evaluación es una métrica de retroalimentación para que el estudiante sepa en qué grado fue capaz de cumplir las expectativas del profesor.

Teniendo esta máxima en cuenta, hemos planteado algunos principios básicos que creemos deben guiar el sistema de evaluación del curso. En primer lugar, la idea de que todos los estudiantes deben tener tantas oportunidades como sea posible para experimentar y aprender. Esto significa que deben permitirse fallar sin miedo a ser recriminados. Por tanto, no consideramos ninguna práctica que penalice a los estudiantes por fallar en una evaluación, en particular, todos los estudiantes tienen derecho a todos los exámenes independientemente de los resultados obtenidos anteriormente.

Por otro lado, queremos incentivar un estudio constante y consistente en vez de un maratón de última hora, por lo que sí aprobamos las prácticas que premien por el trabajo continuado, incluso teniendo en cuenta los posibles errores que hayan cometido. De modo que hemos dividido el curso en 3 grandes conjuntos de habilidades:

- Habilidades teóricas de modelación con lenguajes formales.
- Habilidades en el uso y diseño de algoritmos relacionados con lenguajes.
- Habilidades en el diseño de arquitecturas y patrones para sistemas de procesamiento de lenguajes.

De forma aproximada podemos incluir todo contenido dado en el curso en uno de estos conjuntos de habilidades. Consideramos en un estudiante que domine de forma efectiva estos tres conjuntos de habilidades, está preparado para enfrentarse a las preguntas y problemáticas típicas de este campo de estudio. Por el mismo motivo, consideramos que es imprescindible haber vencido las tres habilidades para poder aprobar el curso.

Por tanto, hemos concebido un sistema de evaluación que se compone de 3 exámenes parciales y tres proyectos opcionales, cada par respectivamente orientado a evaluar uno de los tres conjuntos de habilidades mencionados. Los estudiantes que obtienen resultados satisfactorios en cada caso se considera que vencieron dicha habilidad. Al finalizar el curso hay un exámen final que permite a los estudiantes complementar sus resultados hasta el momento, en caso de no haber cumplido todos los objetivos en las evaluaciones parciales.

Así mismo, se orientarán a menudo tareas de menor envergadura que pueden ayudar también a complementar la comprensión (y la consecuente evaluación) en cualquiera de los temas presentados.

## Conclusiones {-}

Este curso es un viaje, un viaje por una de las ramas más espectaculares de la historia de la computación, una rama que definió a la computación como ciencia, y que creó algunos de sus héroes más famosos. Es un viaje lleno de dificultades, pero detrás de cada obstáculo hay algo increíble que descubrir. Los que hemos pasado por este viaje les podemos prometer que vale la pena. Pero la mejor forma de experimentarlo no es como espectador, como un simple pasajero. La mejor forma de experimentarlo es coger el timón y decidir ustedes cuáles son los lugares que quieren explorar. Nosotros haremos el mejor esfuerzo por llevarlos allí, pero no les podemos mantener los ojos abiertos. Mirar, oler y tocar todo lo que puedan es responsabilidad de ustedes.
