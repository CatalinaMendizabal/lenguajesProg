Tags: #apuntes #lenguajesprog 
Associations:
When: [[09/09/2021]]

## [[Elixir]]
- [[#Introducción]]
- [[#Lenguajes]]
- [[#Java]]
- [[#Erlang]]
- [[#Elixir]]
- [[#Orientado a Actores]]

### Introducción
Es muy probable que el lenguaje que se va a utilizar por años ya existe. Se vuelven populares en poco tiempo después de un tiempo de maduración.
Elixir tiene capacidades que no se encuentran en otros lenguajes (programas que se pueden reparar a si mismos. Más confiable).
Scala lleva la programación funcional a la máquina virtual de Java.

### Lenguajes
Desarrollar los programas como servicios permite la reutilización de utilidades.
A medida que pasa el tiempo, se van necesitando más recursos para realizar lo mismo. Rust es un ejemplo de lenguajes que ataca el manejo de la memoria, para que sea posible controlarlo. La confiabilidad: el software no tiene la misma confiabilidad que un sistema biológico. Elixir y Erlang atacan este problema (Erlang hace como si una célula / componente deja de andar y la reemplaza para que no afecte a todo el organismo). 

#### Estático vs dinámico
Binding: cuando se van poniendo los tipos  

- Estático
    - el binding se da durante la compilación (early)

- Dinámico
    - el binding se da durante la ejecución (late)

#### Fuertemente tipado vs débilmente tipado
- Fuertemente
    - un valor tiene si o si un tipo asociado (java, haskell, scala...)

- Débilmente
    - puede o no tener un tipo asociado (javascript, punteros en c...)

##### En gral:
__estaticos --- fuerte__

__dinamicos --- debil__

#### Compiladores
Es un programa que toma un lenguaje fuente y lo transforma en uno destino. Si compilo C queda en código nativo. No siempre compilamos a un código que se pueda ejecutar. 

#### Interpretadores
Es un programa que transforma un código fuente escrito en un lenguaje fuente a una representación que pueda ser ejecutada inmediatamente. Cada vez que corremos un programa vuelve a analizar el código todo el tiempo haciéndo el árbol de sintáxis... etc. El problema es que por eso el chequeo es muy débil y rápido para que ya se pueda ejecutar

#### Java
![Java](./screenshots/screen1.png)

Hablo un montón sobre GraalVM -%3E más rápida que la de JavaVM

#### Fases de compilación
![Fases de compilación](./screenshots/screen2.png)

##### Análisis Léxico
- Va viendo los tipos de caracteres y los va pasando a tokens (ej: [a = 3 + 5] lo pasa a \%3CID:a> \<ASSIGN> \<NUMBER:3> \<PLUS> \<NUMBER:5>)
- En esta fase detecta errores del estilo "caracter inválido", "string sin cerrar", etc. (errores léxicos -> si las palabras estan bien formadas sin importar lo que significan)
- Existen generadores léxicos
    - eBNF es una forma de expresar reglas léxicas

##### Análisis Sintáctico
- Pasa por el Parser que valida que la estructura de las palabras sea la correcta (orden de sustantivo con verbo, etc.)
- Lo pone en un árbol (Abstract Syntax Tree -> __No__ es lo mismo que el árbol de parseo)
- Podemos usar eBNF devuelta para definir la sintáxis

##### Análisis Semántico
- La entrada es el árbol que devolvió el analisador sintáctico
  - Recorre recursivamente (desde el nodo más bajo / hoja para arriba) el árbol analizando los tipos de los nodos, y viendo que el significado del árbol sea correcto
  - Ejemplo: se fija en una asignación si la hoja izquierda es un ID
    

##### Optimizador
- Va recorriendo el árbol y se va fijando asignaciones que se puedan sacar, transformando el árbol en uno más simple
- Ejemplo: realiza una suma

##### Generador de Código
- Toma el árbol optimizado y genera el código
- Usa un stack (No los registros del CPU)
- Después el JIT compiler probablemente lo pase a código que funcione con los registros

##### Ejecución
- Dentro de una máquina virtual tenemos áreas:
    - Heap -> parte de la máquina virtual que guarda los objetos que su ciclo de vida no esta atado al stackFrame
        - El problema es que no se sabe que se está usando y que no
        - Lo que hace es ir iterando los objetos y los que no están referenciados los toma como que no se está usando (El garbage collector -> es una actividad muy costosa)
    - Stack -> área de memoria local para las variables del thread -> se crea el stackFrame
        - cuando nosotros llamamos un método que llama a otro método recursivo -> el espacio anterior sigue ocupado, y se genera otro espacio para el segundo -> como es recursivo cada llamada genera un stackFrame nuevo
    - Va manejando los stackFrames con punteros, si quiero liberar memoria cambio el puntero (la forma más rápida de liberar memoria)
    (Thread : recorrido secuencial del programa)

### Erlang
Se inventó para desarrollar software para las centrales telefónicas y que no se caigan -> software más confiable -> no falla
Modo de desarrollar los programas totalmente distinto al resto.
El principio del lenguaje no es prevenir los problemas sino "curarlos".
Prohibe compartir obetos, cada uno tiene su propia máquina virtual.

### Elixir
Sintáxis alternativa para la máquina de Erlang
Lenguaje dinámico, las propiedades se conocen en tiempo de ejecución.
Débilmente tipado.
Lenguaje funcional, orientado a objetos puro. 

__levanta un REPL__
```
iex
```

Va siguiendo el número de secuencia

__último valor usado__
```
v
```

__matching__
```
a = 1
1 = a
```

__match específico__
```
^a = 1
^a = 2 => error
```

__igualdad__
```
1 == 1.0 => true
1 === 1.0 => false (estricta) 
```
__átomo__
nombre simbólico que no tiene valor, para no usar espacio en memoria
```
:one

IO
```
__concatenación__
```
"Hola " <> "Mundo!"
```
__referenciar__
```
name = "Juan"
"Hola #{name}"
```
__entrar a modulos__
```
String.upcase("hello")
String.trim(" Hola mundo!") 
String.split("Hola Mundo!", " ")
```
__pipe__
```
" hello world" |> String.trim |> String.split(" ")
```
__multiline__
```
[1,2,3,
4,5,6]
```
Listas son inmutables
```
list = [1,2,3]
[0 | list] => [0, 1, 2, 3]
```
__manejo de listas__
``` 
[1,2,3] ++ [4,5]
[1,2,3] -- [1,2]
```
__resuelve incógnitas__
``` elixir
[x | list] = list2
x = 0

[head | tail] = list
head = 0
tail = [1,2,3]
```

"¿Hay algo más potente que la herencia en la programación funcional?"

__función anónima__
``` elixir
double = fn x -> x * 2 end
double.(12)
Enum.map(list, double)
Enum.each(list, fn x -> IO.puts(x) end)
```
__operador de captura (&)__
``` elixir
Enum.each(list, &IO.puts/1)
Enum.filter(list, &(&1 > 2))
mapped = Enum.map(list, fn x -> x * 2 end)
```
__acumular__
``` elixir
Enum.reduce(mapped, 0, fn x, acc -> x acc end)
```
__lista de lo que sea__
``` elixir
[1, 2, "hello", :one]
```
__tupla__
``` elixir
{1, 2, "hello", :one}
```
__mapa__
``` elixir
words = %{"hello" => "hola", "world" => "mundo"}
words = %{name: "Juan", apellidou:"Carlos"}
words = Map.new([{"hello", "hola"}, {"world", "mundo"}])
```
__fetch que puede tirar excepción__
``` elixir 
Map.fetch!(words, "hello")
```

__usando átomos__
``` elixir
%{:name => "John", :age => 40}
```

__rangos__
``` elixir
range = 1..10
Enum.each(1..10, &IO.puts/1)
```

__cursed__
``` elixir
<<1,2,3>> === "ABC" # true wtf
```
__coso que hace lista como mapa__
``` elixir
person = [name: "John", age: 40]
Keyword.get(person, :name)
```

__*Proceso*__
``` elixir
slow = fn x -> Process.sleep(3000); IO.puts("Process #{x} completed") end

# crear procesos

spawn fn -> slow.(4) end


# puedo usar el id de un proceso para enviar mensajes
pid = spawn fn -> 1 + 2 end

send self(), {:hello, "world"}
receive do x -> IO.inspect(x end)

parent = self()
spawn fn ->
    result = 1 + 2 + 3
    send(parent, {:result, result})
end
flush() # imprime el buzon de mensajes y lo vacia

# para recibir un solo mensaje. Si no hay mensaje se suspende el proceso hasta recibir un mensaje.
receive do
    x - > IO.inspect(x)
end


```

<!-- Clase del 16/09/2021 -->

### Orientado a Actores
Los actores pueden procesar un mensaje a la vez.
Como cada proceso es independiente (propio heap y stack) entonces cuando mando un mensaje se genera una copia, no hay linkeo.
Encapsulación mucho más estricta que en orientado a objetos normal. Más parecido a la pura, según el mensaje recién ahi cambio de estado.

__after__
``` elixir
receive do
    x -> IO.inspect(x)
after # para la respuesta de mensajes o la falta 
    1000 -> "ups"
end
```
__para errores__
``` elixir
spawn fn -> raise "oops" end
```

__linkear procesos__
``` elixir
spawn_link fn -> 1/0 end
```

**Principio importante**: a veces es mejor dejar que se muera un proceso para que se reinicie, porque conocemos el estado inicial.

__monitoreo de procesos__
``` elixir
pid = spawn fn -> Process.sleep(20000) end
ref = Process.monitor(pid)
```

__mix para ejecutar un proyecto__
```
mix new projectaname
```
__inicializar el shell con el script del proyecto__
```
iex -S mix
```

__usar una estructura__
``` elixir
%Point{x: 4, y: 3}
```

__registrar un proceso?__
``` 
Process.register(t1, :translator)
# ahora si se rompe puede restartear solo

Process.whereis(:translator) # buscar en donde esta

Process.unregister(:translator) # desregistrar
```

__levantar una maquina virtual__
```
iex --sname nombredelnodo@nombredelamaquina --cookie abc -S mix
```
__Conectar a otra maquina__
```
Node.spawn(:n2@devbox, fn -> IO.puts("Hello from #{node()}") end)
# cluster de maquinas combinadas para ejecutar programas
# se puede hacer con Node.connect(:n1@devbox) manualmente

---

Process.register(self(), :shell)
t1 = Translator.start
Process.register(t1, :translator)
send(:shell, "hola local")

# desde la otra maquina
send({shell:, :n1@devbox}, "hola remoto")

# para que todas las maquinas conectadas lo conozcan el register
global.register_name(:global_translator, t1)
global.registered_names()
```

__errors__
``` elixir
raise ArgumentError, message: "invalid argument"
```


<!-- Agregado clase del 23/09/2021 -->

yes
