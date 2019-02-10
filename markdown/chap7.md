---
previous-chapter: chap6
next-chapter: chap8
---

# Generación de Código

## Código de 3 Direcciones Orientado o Objetos (CIL)

Para la generación de código intermedio de COOL a MIPS vamos
a diseñar un lenguaje de máquina con capacidades orientadas a objeto.
Este lenguaje nos va a permitir generar código de COOL de forma
más sencilla, ya que el salto directamente desde COOL a MIPS es
demasiado complejo. Este lenguaje se denomina CIL, **3-address object-oriented**.

Un programa en CIL tiene 3 secciones:

### Jerarquía de Tipos

La primera es una sección (opcional) de declaración de tipos:

```cil
.TYPES

type A {
    attribute x ;
    method f : f1;
}

type B {
    attribute x ;
    attribute y ;
    method f : f1 ;
    method g : f2 ;
}

type C {
    attribute x ;
    attribute z ;
    method f : f2;
}
```

El "tipo" de los atributos en CIL no importa, pues todos los atributos son de tipo numérico. El único tipo por valor es `Integer` que almacena un entero de 32 bits. Todos los demás tipos son por referencia, y por lo tanto se representan por el valor de 32 bits del lugar de memoria virtual donde se ubican.

El orden de los atributos es muy importante, ya que luego veremos instrucciones para acceder a los atributos que usan realmente la dirección de memoria del atributo. Esta dirección está definida por el orden en que se declaran. Por este motivo, por ejemplo, si la clase `A` hereda de la clase `B`, y la clase `B` tiene un atributo `x`, es importante que en ambas declaraciones de tipos haya un atributo `x` y además que esté en el mismo orden. Lo mismo sucede con los métodos. Más adelante cuando completemos la generación de código veremos estos detalles más en profundidad.

### Datos

En la sección de datos se declaran todas las cadenas de texto constantes que serán usadas durante todo el programa.

```cil
.DATA

msg = "Hello World";
```

### Funciones

> Se toma como convenio que la primera función declarada es la función que se ejecuta al iniciar el programa.

```cil
.CODE

function f1 {
    ...
}

function f2 {
    ...
}
```

El cuerpo de cada función se divide a su vez
en dos secciones. Primero se definen todos los parámetros
y variables locales, y luego las instrucciones en sí:

```cil
function f1 {
    PARAM x;
    PARAM y;

    LOCAL a;
    LOCAL b;

    <body>
}
```

El cuerpo de una función en CIL se compone de una secuencia
de instrucciones, que siempre reciben a lo sumo 3 argumentos,
uno para almacenar el valor de retorno, y 2 operandos.

Entre las instrucciones básicas tenemos:

### Asignación simple

```cil
x = y ;
```

### Operaciones aritméticas

```cil
x = y + z ;
```

### Acceso a atributos

El acceso a atributos se utiliza para obtener el valor de un atributo almacenado en un lugar de la memoria en una variable temporal.

```cil
x = GETATTR y b ;
```

Es equivalente a `x = y.b`.

```cil
SETATTR y b x ;
```

El "atributo" `b` realmente es solamente la dirección de memoria donde está el atributo.

Es equivalente a `y.b = x`.

### Acceso a arrays

Cuando una variable es de un tipo array (o `string`), se puede acceder al iésimo elemento:

```cil
x = GETINDEX a i ;
```

O asignar un valor:

```cil
SETINDEX a i x ;
```

### Manipulación de memoria

Para crear un nuevo objeto existe una instrucción de alocación de memoria:

```cil
x = ALLOCATE T ;
```

Esta instrucción crea en memoria espacio suficiente para alojar un tipo `T` y devuelve en `x` la dirección de memoria de inicio del tipo.

Para obtener el tipo dinámico de una variable se utiliza la sintaxis:

```cil
t = TYPEOF x ;
```

Para crear arrays se utiliza una sintaxis similar:

```cil
x = ARRAY y ;
```

Donde `y` es una variable de tipo numérico (como todas) que define el tamaño del array.

### Invocación de métodos

Para invocar un método se debe indicar el tipo donde se encuentra el método, además del método en concreto que se desea ejecutar.

```cil
x = CALL f ;
```

Este llamado es una invocación estática, es decir, se llama exactamente al método `f`.

Además existe un llamado dinámico, donde el método `f` se buscan en el tipo `T` y se resuelve la dirección del método real al que invocar:

```cil
x = VCALL T f ;
```

Todos los parámetros deben ser pasados de antemano, con la siguiente instrucción:

```cil
ARG a ;
```

Cada método espera que los parámetros estén ubicados en la memoria en el mismo orden en que están declarados en el método. Es responsabilidad del que invoca pasar los parámetros de forma adecuada.

En particular, para todos los métodos "de instancia", que tiene un argumento `self` o similar, es responsabilidad del que invoca pasar este `self` como primer parámetro.

### Saltos

Los saltos condicionales en CIL siempre tienen una condición y una instrucción de salto:

```cil
IF x GOTO label ;
```

Donde `label` tiene que ser una etiqueta declarada en algún lugar de la propia función. La etiqueta puede estar declarada después de su uso. Si la etiqueta no está declarada correctamente, el resultado de la operación no está definido.

```cil
LABEL label ;
```

Los saltos incondicionales simplemente se ejecutan con:

```cil
GOTO label ;
```

Como en CIL no existen variables *booleanas*, el valor de verdad de una expresión es realmente que la expresión sea distinta de cero, por lo tanto, los siguientes saltos son equivalentes:

```cil
x = y != z;
IF x GOTO label ;

x = y - z
IF x GOTO label ;
```

### Retorno de Función

Finalmente todas las funciones deben tener una instrucción de retorno:

```cil
RETURN x ;
```

Esta instrucción pone el valor de `x` en la dirección de retorno de `f` y además termina la ejecución de la función. Si esta instrucción no se ejecuta en el cuerpo de una función el resultado de la invocación de la función no está bien definido. Si no importa el valor de retorno de la función, simplemente se puede usar cualquiera de las siguientes dos variantes, (que son equivalentes):

```cil
RETURN ;

RETURN 0 ;
```

### Funciones de cadena

Las cadenas de texto se pueden manipular con funciones especiales. Primero es necesario obtener una dirección a la cadena:

```cil
x = LOAD msg ;
```

Luego se puede operar sobre una cadena con instrucciones
tales como `LENGTH`, `CONCAT` y `SUBSTRING`, con la semántica esperada:

```cil
y = LENGTH x ;
```

Además hay una función STR que computa la representación textual de un valor numérico y devuelve la dirección en memoria:

```cil
z = STR y ;
```

### Operaciones IO

Finalmente, hay 2 instrucciones de entrada-salida, `READ` que lee de la entrada estándar hasta el siguiente cambio de línea (incluído):

```cil
x = READ ;
```

Y `PRINT` que imprime en la salida estándar, sin incluir el cambio de línea.

```cil
PRINT z ;
```

## Programas de ejemplo

Veamos algunos programas de ejemplo directamente escritos en CIL antes de pasar a definir cómo haremos la generación de código.

### Hola Mundo

El "Hola Mundo" en CIL es muy sencillo:

```cil
.DATA

msg = "Hello World!\n" ;

.CODE

function main {
    LOCAL x ;

    x = LOAD msg ;
    PRINT x ;
    RETURN 0 ;
}
```

Ahora, este programa si lo fuéramos a generar desde COOL realmente sería un poco más complejo. En COOL sería necesario tener una clase con un método `main`, y algunos detalles adicionales:

```cool
class Main: IO {
    msg : string = "Hello World!\n";

    function main() : IO {
        self.print(self.msg);
    }
}
```

El programa completo en CIL que representa al programa anterior de COOL sería el siguiente. Hemos tenido cuidado de usar convenios de nombres que luego nos será útil respetar durante la generación de código.

```cil
.TYPES

type Main {
    attribute Main_msg ;
    method Main_main: f1 ;
}

.DATA

s1 = "Hello World!\n";

.CODE

function entry {
    LOCAL lmsg ;
    LOCAL instance ;
    LOCAL result ;

    lmsg = LOAD s1 ;
    instance = ALLOCATE Main ;
    SETATTR instance Main_msg lmsg ;

    ARG instance ;
    result = VCALL Main Main_main ;

    RETURN 0 ;
}

function f1 {
    PARAM self ;

    LOCAL lmsg ;

    lmsg = GETATTR self Main_msg ;
    PRINT lmsg ;

    RETURN self ;
}
```

Podemos ver que el código generado es más ineficiente que el código que se podría concebir manualmente. Este es un resultado necesario del hecho de subir de nivel de abstracción. Un programador humano escribiendo directamente CIL probablemetne pueda generar código más eficiente que nuestro compilador de COOL (al menos hasta que comencemos a aplicar técnicas de optimización de código), pero la ganancia en productividad es tal, que no tiene sentido tal comparación.

## Generando código

Veamos entonces algunas ideas sobre cómo generar código concreto de COOL en CIL. Primero nos vamos a concentrar en la generación de expresiones concretas y al final veremos cómo combinarlo todo para generar un programa completo, con sus clases y métodos virtuales.

### Un lenguaje plantilla para la generación de código

Para ejemplificar y documentar nuestras reglas de generación de código vamos a expandir el lenguaje CIL y el lenguaje COOL con una notación informal de "plantilla". No vamos a ser muy formales con esta notación, ya que no la usaremos nada más que como documentación. La idea básica es que permitiremos algunas expresiones "vagas", como puntos suspensivos, nombres genéricos, etc., donde nos sea conveniente. Además, no seremos estrictos con escribir todo el código CIL necesario, solamente la parte que corresponda al fragmento de COOL que nos interesa generar, y asumiremos que el lector entiende el contexto. A medida que veamos ejemplos se irá haciendo más claro este "lenguaje".

Supongamos que tenemos una expresión en COOL de la forma:

```cool
let x : Integer = 5 in
    x + 1
end
```

Esta expresión puede ser parte del cuerpo de un método cualquiera, rodeada por cualquier contexto. Asumamos que el método se denomina `f`, a falta de un nombre mejor. Como no hemos especificado exactamente aquí todo el contexto de la expresión, tendremos que ser vagos con la generación de código. Permitiremos entonces obviar las partes "poco importantes" y concentrarnos solo en la parte que nos interesa. Sin más, presentamos el código CIL:

```cil-template
function f {
    ...
    LOCAL x ;
    LOCAL <value> ;

    ...
    x = 5 ;
    <value> = x + 1 ;
    ...
}
```

Aquí hemos tomado por convenio que el valor de la expresión lo guardamos en una variable de nombre `<value>`, que hemos puesto entre angulares `<...>` para indicar que este no es el nombre final que quedará en el código CIL real, sino un nombre plantilla que estamos usando ahora a falta de no tener el contexto completo. Es decir, en la generación real de código ese nombre se sustituirá por algo como `value_017` o cualquier indicador que sea conveniente en ese momento, generado de forma automática.

Por otro lado, supongamos que tenemos una expresión de la forma:

```cil-template
let x : Integer = 5 in
    x + <expr>
end
```

En esta expresión también estamos abusando de la notación, con el uso de `<expr>` para indicar que en COOL aquí va una expresión válida cuya forma exacta no nos interesa. Podemos entonces tomar un convenio como el siguiente:

```cil-template
function f {
    ...
    <expr.locals>
    LOCAL x ;
    LOCAL <value> ;

    ...
    x = 5 ;
    <expr.code>
    <value> = x + <expr.value> ;
}
```

El convenio que estamos tomando aquí, es usar `<expr.locals>` para indicar que se debe rellenar esta parte con todas las inicializaciones de variables locales que sean necesarias para poder computar la expresión `<expr>`. Además, luego en el cuerpo del método usamos `<expr.code>` para indicar que se debe rellenar con todo el código generado para la expresión `<expr>`. Finalmente, asumimos que `<expr.value>` será reemplazado por el nombre de la variable local que haya sido escogida para almacenar temporalmente el valor de `<expr>`.

Esperamos que esta notación se vaya haciendo más clara a medida que veamos más ejemplos. Vamos a comenzar entonces con ejemplos concretos:

### Expresiones Let-In

Sea la expresión genérica de COOL `let-in` con la forma:

```cool-template
let <var> : <type> = <init> in
    <body>
end
```

Supongamos que esta expresión ocurre dentro de un método `f` arbitrario. Podemos entonces definir la generación de código de esta instrucción de la siguiente forma:

```cil-template
function f {
    ...
    <init.locals>
    LOCAL <var> ;
    <body.locals>
    LOCAL <value> ;

    ...
    <init.code>
    <var> = <init.value> ;
    <body.code>
    <value> = <body.value> ;
}
```

Puede parecer que no hemos ganado mucho con esta notación, pero en realidad hemos logrado definir para una expresión de tipo `let-in` arbitraria, exactamente lo que hace falta para su generación de código en CIL. Si interpretamos las expresiones `<init.locals>` y `<body.locals>` como, recursivamente, generar las inicializaciones de variables correspondientes, e igualmente `<init.code>` y `<body.code>` como, recursivamente, generar los fragmentos de código asociados, podemos ver que esta sintaxis nos permite decir de forma precisa en qué orden hay que recorrer el AST generando qué parte de cada tipo de nodo. No es difícil ver cómo este tipo de plantillas se convierten en respectivos llamados a *visitors* adecuados para cada parte del código.
