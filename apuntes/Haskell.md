Tags: #apuntes #lenguajesprog  
Associations:
When: [[12/08/2021]]

## [[Haskell]]
- [[#Apuntes]]
- [[#Práctica 1]]
- [[#Ejercicios]]


### Apuntes
``` haskell
  -- Esto es un tipo paramétrico 
 data Option a = None | Some a

 isEmpty :: Option a -> Bool
 isEmpty None = True
 isEmpty _ = False

 equals :: (Eq a) => Option a -> Option a -> Bool
 equals None None = True
 equals None _ = False 
 equals _ None = False 
  equals (Some x) (Some y) = x == y

  -- El deriving es como el implements
  data Option a = None | Some a deriving (Show, Read, Eq)

 data Person = Person {
     firstName :: String,
     lastName :: String,
     age :: Int
 } deriving (Eq)

 data Entry k v = Entry {
     key :: k,
     value :: v
 } deriving (Eq)

 class Eq a where
     (==) :: a -> a -> Bool
     (/=) :: a -> a -> Bool
     x == y = not (x /= y)
     x /= y = not (x == y)

 instance Eq (Entry k v) where 
     (Entry x _) == (Entry y _) = x == y

  -- Alias de tipo de dato
 type String = [Char]

 type Map k v = [Entry k v]

  -- Definir tipo de dato recursivamente
  data BinaryTree a = EmptyTree | Leaf a | Branch a (Tree a) (Tree a) deriving (Show, Eq)

 data NestedList a = Elem a | List [NestedList a]

 myFlatten :: NestedList a -> [a]
 myFlatten (List []) = []
 myFlatten (Elem a) = [a]
 myFlatten (List (x:xs)) = (myFlatten x) ++ myFlatten (List xs)

  Clase Functor -- (cualquier tipo de dato que puede ser mapeado)
 class Functor_ f where
     fmap :: (a -> b) -> f a -> f b

 instance Functor_ [] where 
     fmap = map

  -- Ejemplo clarito como el agua
  data Option a = None | Some a deriving (Show)
 instance Functor Option where
     fmap f (None) = None
     fmap f (Just a) = Just (f a) 

 instance Functor Tree where
      fmap f EmptyTree = EmptyTree
      fmap f (Brach a l r) = Branch (f a) (fmap f l) (fmap f r)

 add3 :: (Num a) -> Tree a -> Tree a
 add3 = fmap (+ 3)

 add3 :: (Functor t) => t -> b
 add3 = fmap (+ 3)
 -- Este lo dio de baja

  -- Down in the forest we'll sing our chorus, one that everybody knows

 data BinaryTree a = EmptyTree | Leaf a | Branch a (BinaryTree a) (BinaryTree a) deriving (Show, Eq)
 searchTree :: (Ord k) => k -> Tree k v -> v
 searchTree _ EmptyTree = error "Not found"
 searchTree x (Leaf k v) = if x == k then v else error "Not found"
 searchTree x (Branch k v l r)
    | x == k = v
    | x < k = searchTree x r
    | otherwise = searchTree x l

 data BinaryTree a = EmptyBinaryTree | Node a (BinaryTree a) (BinaryTree a) deriving (Show, Eq)
 addNode :: (Ord a) => BinaryTree a -> a -> BinaryTree a
 addNode EmptyBinaryTree a = Node a EmptyBinaryTree EmptyBinaryTree
 addNode (Node a l r) x 
     | a < x = Node a l (addNode r x)
     | a > x = Node a (addNode l x) r
     | otherwise = Node a l r

 rotateLeft :: BinaryTree a -> BinaryTree a
 rotateLeft EmptyBinaryTree = EmptyBinaryTree
 rotateLeft (Node a l EmptyBinaryTree) = Node a l EmptyBinaryTree
 rotateLeft (Node a l (Node c rl rr)) = Node c (Node a l rl) rr

 rotateRight :: BinaryTree a -> BinaryTree a
 rotateRight EmptyBinaryTree = EmptyBinaryTree
 rotateRight (Node a EmptyBinaryTree r) = Node a l EmptyBinaryTree
 rotateRight (Node a (Node c ll lr) r) = Node c (Node a ll r) lr

 deepTree :: BinaryTree a -> Int
 deepTree EmptyBinaryTree = 0
 deepTree Node a l r
        | deepL > deepR = 1 + deepL
        | otherwise = 1 + deepR
        where deepL = deepTree l
              deepR = deepTree r

 balanceTree :: BinaryTree a -> BinaryTree a
 balanceTree EmptyBinaryTree = EmptyBinaryTree
 balanceTree (Node a l r)
      | (deepL - deepR) > 1 = rotateRight (Node a bl br)
      | (deepR - deepL) > 1 = rotateLeft (Node a bl br)
      | otherwise = Node a bl br
      where bl = BalanceTree l
            br = BalanceTree r
            deepL = deepTree bl
            deepR = deepTree br

 addNode :: (Ord a) => BinaryTree a -> a -> BinaryTree a
 addNode EmptyBinaryTree a = Node a EmptyBinaryTree EmptyBinaryTree
 addNode (Node a l r) x 
     | a < x = balanceTree (Node a l (addNode r x))
     | a > x = balanceTree (Node a (addNode l x) r)
     | otherwise = Node a l r

 countLeaves :: BinaryTree a -> Int
 countLeaves EmptyBinaryTree = 0
 countLeaves (Node a EmptyBinaryTree EmptyBinaryTree) = 1
 countLeaves (Node a l r) = countLeaves l + countLeaves r

 internals :: BinartTree a -> [a]
 internals (Node a l r) = [a] ++ internals l ++ internals r

 stringToBinaryTree :: String -> BinaryTree a
 stringToBinaryTree [] = EmptyBiniaryTree
 stringToBinaryTree "" = EmptyBiniaryTree
 stringToBinaryTree [a] = (Node a EmptyBinaryTree EmptyBinaryTree)
 stringToBinaryTre (x:xs)
  | x == '(' = x
  | x == ',' = x
  | x == ')' = x
  | otherwise = Node x

 -- Representar arbol binario en arreglo: Voy multiplicando la posición por 2 para encontrar los hijos. (la pos arranca en 1)
 -- ej [1,2,3,4,5,6] los hijos de 1 son la pos 2 y 3, los de 2 son ĺa 4 y 5, los de 3 son la 6 ý 7, etc.
 -- Si no tiene hijos va a haber posiciones vacias.

contains :: (Eq a) => [a] -> a -> Bool
contains [] _ = False
contains l y = [z | z <- l, z == y] /= []

 Representación de Grafos
 --¿Qué es un grafo? 
 -- 1.
 -- type Graph = [(Int, [Int])]
 -- 2.
 -- data Node a = Node a [Node a]
 -- type Graph = [Node a]
 -- 3.
 -- data Graph a = Graph [a] [(a,a)] deriving (Eq, Show)
existsNode :: Graph -> Int -> Bool
existsNode [] _ = False
existsNode (x:xs) i
    | fst x == i = True
    | otherwise = existsNode xs i

isAdjacent :: Graph -> Int -> Int -> Bool
isAdjacent [] _ _ = False
isAdjacent (x:xs) s t
    | fst x == s = [y | y <- snd x, y == t] /= []
    | otherwise = isAdjacent xs s t

getAdjacencyList :: Graph -> Int -> (Int, [Int])
getAdjacencyList [] _ = error "Node does not exist"
getAdjacencyList (x:xs) n
    | fst x == n = x 
    | otherwise = getAdjacencyList xs n

remove :: Graph -> Int -> Graph
remove g i = [z | z <- g, fst z /= i]

 remove :: [Int] -> Int -> [Int]
 remove [] _ = []

removeAdj :: Graph -> Int -> Int -> Graph
removeAdj [] _ _ = []
removeAdj (x:xs) n a
    | fst x == n = (n, [z | z <- snd x, z /= a]) : xs
    | otherwise = x : removeAdj xs n a

pathToB :: Graph -> Int -> Int -> [Int]
pathToB [] _ _ = []
pathToB g s t  
    | null [z | z <- g, fst z == s] = []
    | null [z | z <- g, fst z == t] = []
    | null adj = []
    | t `elem` adj = [s,t]
    | t `elem` p = p
    | otherwise = pathToB (map (\x -> (fst x, [z | z <- snd x, z /= f])) g) s t
 | otherwise = s : pathToB (removeAdj g s a ) s t
    where
        node = head [z | z <- g, fst z == s]
        adj = snd node
        f = head adj 
        p = s : pathToB [(\ x -> (fst x, [y | y <- snd x, y /= s])) z | z <- g, fst z /= s] f t


 -- APPLICATIVE
 class (Functor f) => Applicative f where
     pure :: a -> f a
     (<*>) :: f (a -> b) -> f a -> f b

 instance Applicative Maybe where
     pure = Just
     Nothing <*> _ = Nothing 
     (Just f) <*> something = fmap f something

 pure (+3) <*> Just 4
 -- el maybe hace que si no hay nada no se rompa
 -- nos permite que el functor tenga un contexto
 -- puedo hacer una función de un elemento que no es maybe a maybe
 -- transforma una función de opcionales a una de datos -> dijo von
 -- si la función es vacía no pasa na (?
 -- si yo quisiera sumar entre dos optionals que tienen un entero no puedo hacerlo sin hacer otra función -> en java
 -- en este caso le puedo aplicar una función que esta en el contexto, le aplica al valor de adentro la función

 -- ¿Qué pasa cuando tengo algo más complejo?
 fmap :: (Funtor f) => (a -> b) -> f a -> f b
 (<*>) :: (Applicative f) => f (a -> b) -> f a -> f b
 (>>=) :: (Monad m) => m a ->  (a -> m b) -> m b

 -- si pongo una monada con un tipo me devuelve el tipo en el contexto
 let z = \x -> return (x * 10) 
 Just 9 >>= z
 Just 9 >>= \x -> return (x * 10) 
 -- permite aplicar una función que no esta dentro de un tipo paramétrico dentro de un tipo paramétrico
 -- si tengo un tipo que implementa monada puedo hacer una función sobre el tipo que tiene adentro -> dijo locu
 Just "Hola" >>= \x -> return (x ++ " mundo")
 return 3 >>= (\x -> Just (x + 3))
 return x >>= f => f x
 m >>= return => m
 xs >>= f = concat (map f xs) -- ni idea que hace
 [1,2,3,4] >>= \xs -> return f = concat (map f xs) -- no le funciono se olvidó el ejemplo

 -- Para hacer:
 -- 8 reinas
 -- sudoku
```

### Práctica 1
``` haskell
-- 1) Invertir una lista
import System.Directory.Internal.Prelude (Integral)
invert :: [a] -> [a]
invert [] = []
invert (x:xs) = invert xs ++ [x]


-- 2) Sumar todos los elementos de una lista
sumElements :: (Num a) => [a] -> a
sumElements [] = 0
sumElements (x:xs) = x + sumElements xs

-- 3) Obtener el mayor elemento de una lista
maxElement :: (Ord a) => [a] -> a
maxElement [] = error "Empty list"
maxElement [x] = x
maxElement (x:xs)
    | x > m = x
    | otherwise = m
    where m = maxElement xs

-- 4) Implementar la funcion de fibinacci
fibonacci :: Int -> Int
fibonacci 0 = 0
fibonacci 1 = 1
fibonacci i = fibonacci (i - 1) + fibonacci (i - 2)

-- 5) Permutar los valores de una lista, es decir, cambiar el valor de la posicion 1 por la 2, el de la 3 por la 4, etc.
permutation :: [a] -> [a]
permutation [] = []
permutation [x] = [x]
permutation (x:y:xs) = [y, x] ++ permutation xs

-- 6) Ordernar una lista de tuplas a partir de su primer elemento
sortTuple :: (Ord a) => [(a, b)] -> [(a, b)]
sortTuple [] = []
sortTuple (x:xs) = sortTuple [ y | y <- xs, fst x > fst y] ++ [x] ++ sortTuple [ y | y <- xs, fst x <= fst y]

-- 7) Determinar si una lista es capicua
palindrome :: (Eq a) => [a] -> Bool
palindrome [] = True
palindrome [x] = True
palindrome (x:xs)
    | x == last xs = palindrome (init xs)
    | otherwise = False

-- 8) Insertar el valor x en la posicion i de una lista
insertElement :: a -> Int -> [a] -> [a]
insertElement y _ [] = [y]
insertElement y i (x:xs)
    | i == 0 = [y, x] ++ xs
    | otherwise = x : insertElement y (i - 1) xs

-- 9) Calcular el tamano de una lista
listSize :: [a] -> Int
listSize = foldr (\ x -> (+) 1) 0

-- 10) Determinar cuantas veces se repite el valor x en una lista
countElement :: (Eq a) => [a] -> a -> Int
countElement [] _ = 0
countElement (x:xs) y
    | x == y = 1 + z
    | otherwise = z
    where z = countElement xs y

-- 11) Determinar si un numero es primo
isPrime :: Int -> Bool
isPrime n = [y | y <- [1..n], mod n y == 0] == [1, n]

-- 12) Obtener los primeros n numeros primos
nPrimes :: Int -> [Int]
nPrimes n = take n [i | i <- [1 ..], isPrime i]

-- 13) A partir de una lista con elementos repetidos, retornar el elemento que mas se repite en una lista
modeElement :: (Eq a) => [a] -> a
modeElement [] = error "Empty List"
modeElement [x] = x
modeElement (x:xs)
    | countElement (x:xs) x > countElement (x:xs) m = x
    | otherwise = m
    where m = modeElement xs

-- 14) A partir de una lista con elementos repetidos, retornar una lista con todos los elementos de la lista sin repeticiones (una vez cada elemento)
nonRepeatedElements :: (Eq a) => [a] -> [a]
nonRepeatedElements [] = []
nonRepeatedElements x = [y | y <- x, countElement x y == 1]

-- 14') Idem pero eliminar todas las repeticiones de los elementos
cleanRep :: (Eq a) => [a] -> [a]
cleanRep [] = []
cleanRep [x] = [x]
cleanRep (x:xs)
    | countElement (x:xs) x == 1 = x:cleanRep xs
    | otherwise = cleanRep xs

-- tambien:
sinRepetidos :: (Eq a) => [a] -> [a]
sinRepetidos [] = []
sinRepetidos [x] = [x]
sinRepetidos (x:xs) = x : sinRepetidos [z | z <- xs,z /= x]

-- 15) A partir de una lista con elementos repetidos, obtener una lista de tuplas donde el fst sea el elemento y el snd sea la cantidad de repeticiones de dicho elemento
repetitions :: (Eq a) => [a] -> [(a, Int)]
repetitions [] = []
repetitions [x] = [(x, 1)]
repetitions (x:xs) = (x, countElement (x:xs) x) : repetitions [y | y <-xs, y /= x]
```

### Ejercicios
``` haskell
-- 1) Find the last element of a list. 
lastElem :: [a] -> a
lastElem [] = error "Empty list"
lastElem [x] = x
lastElem (x:xs) = lastElem xs

-- 2) Find the last but one element of a list.
lastButOneElem :: [a] -> a
lastButOneElem [] = error "Empty list"
lastButOneElem [x] = error "List with only one element"
lastButOneElem (x:xs)
    | length xs == 1 = x
    | otherwise = lastButOneElem xs

-- 3) Find the K'th element of a list. The first element in the list is number 1. 
kthElem :: [a] -> Int -> a
kthElem [] _ = error "Empty list"
kthElem (x:xs) k
    | k == 1 = x
    | otherwise = kthElem xs (k-1)

-- 4) Find the number of elements of a list. 
numberOfElem :: [a] -> Int
numberOfElem [] = 0
numberOfElem (_:xs) = 1 + numberOfElem xs

-- 5) Reverse a list. 
invert :: [a] -> [a]
invert [] = []
invert (x:xs) = invert xs ++ [x]

-- 6) Find out whether a list is a palindrome. A palindrome can be read forward or backward; e.g. (x a m a x). 
palindrome :: (Eq a) => [a] -> Bool
palindrome [] = True
palindrome [x] = True
palindrome (x:xs)
    | x == last xs = palindrome (init xs)
    | otherwise = False

-- 7) Flatten a nested list structure. 
data NestedList a = Elem a | List [NestedList a]

myFlatten :: NestedList a -> [a]
myFlatten (List []) = []
myFlatten (Elem a) = [a]
myFlatten (List (x:xs)) = myFlatten x ++ myFlatten (List xs)

-- 8) Eliminate consecutive duplicates of list elements. 
elimConsec :: (Eq a) => [a] -> [a]
elimConsec [] = []
elimConsec [x] = [x]
elimConsec (x:xs)
    | x == head xs = elimConsec xs
    | otherwise = x : elimConsec xs

-- 9) Pack consecutive duplicates of list elements into sublists. If a list contains repeated elements they should be placed in separate sublists. 
-- ?????????????????

-- 10) Run-length encoding of a list. Use the result of problem P09 to implement the so-called run-length encoding data compression method. Consecutive duplicates of elements are encoded as lists (N E) where N is the number of duplicates of the element E. 
runLengthEncode :: (Eq a) => [a] -> [(a, Int)]
runLengthEncode [] = []
runLengthEncode [x] = [(x, 1)]
runLengthEncode (x:xs) = (x, countElement (x:xs) x) : runLengthEncode [y | y <-xs, y /= x]

countElement :: (Eq a) => [a] -> a -> Int
countElement [] _ = 0
countElement (x:xs) y
    | x == y = 1 + z
    | otherwise = z
    where z = countElement xs y

-- 11) Modified run-length encoding. Modify the result of problem 10 in such a way that if an element has no duplicates it is simply copied into the result list. Only elements with duplicates are transferred as (N E) lists. 
-- ahre

-- 12) Decode a run-length encoded list. 
runLengthDecode :: (Eq a) => [(a, Int)] -> [a]
runLengthDecode [] = []
runLengthDecode ((x, n) : xs) = repeat' x n ++ runLengthDecode xs

repeat' :: a -> Int -> [a]
repeat' _ 0 = []
repeat' x n = x : repeat' x (n-1)

-- 13) Run-length encoding of a list (direct solution). Implement the so-called run-length encoding data compression method directly. I.e. don't explicitly create the sublists containing the duplicates, as in problem 9, but only count them. As in problem P11, simplify the result list by replacing the singleton lists (1 X) by X. 
-- EH?!¡¿!?¿¡

-- 14) Duplicate the elements of a list. 
duplicateElems :: [a] -> [a]
duplicateElems = foldr (\ x -> (++) [x, x]) []

-- 15) Replicate the elements of a list a given number of times. 
replicateElems :: [a] -> Int -> [a]
replicateElems [] _ = []
replicateElems l 0 = l
replicateElems (x:xs) n = repeat' x n ++ replicateElems xs n

-- 16) Drop every N'th element from a list. 
dropNth :: [a] -> Int -> [a]
dropNth [] _  = []
dropNth _ 1 = []
dropNth l n = init (take n l) ++ dropNth (drop n l) n

-- 17) Split a list into two parts; the length of the first part is given.
split' :: [a] -> Int -> [[a]]
split' l n = [take n l, drop n l]

-- 18) Extract a slice from a list. 
slice' :: [a] -> Int -> Int -> [a]
slice' l i j = take (j-i+1) (drop (i-1) l)

-- 19) Rotate a list N places to the left. 
rotate' :: [a] -> Int -> [a]
rotate' l n = drop n l ++ take n l

-- 20) Remove the K'th element from a list. 
remove' :: [a] -> Int -> [a]
remove' l k = take (k-1) l ++ drop k l

-- 21) Insert an element at a given position into a list. 
insertElement :: a -> Int -> [a] -> [a]
insertElement y _ [] = [y]
insertElement y i (x:xs)
    | i == 0 = [y, x] ++ xs
    | otherwise = x : insertElement y (i - 1) xs

-- 22) Create a list containing all integers within a given range. 
range' :: Int -> Int -> [Int]
range' x y = [x..y]

-- 26)  Generate the combinations of K distinct objects chosen from the N elements of a list 
-- NANA

-- 28) Sorting a list of lists according to length of sublists 
-- KHE  

-- MEGA SKIP EVERYTHING

-- 55) Construct completely balanced binary trees
-- In a completely balanced binary tree, the following property holds for every node: The number of nodes in its left subtree and the number of nodes in its right subtree are almost equal, which means their difference is not greater than one.
-- Write a function cbal-tree to construct completely balanced binary trees for a given number of nodes. The predicate should generate all solutions via backtracking. Put the letter 'x' as information into all nodes of the tree. 

data BinaryTree a = EmptyBinaryTree | Node a (BinaryTree a) (BinaryTree a) deriving (Show, Eq)

addNode :: (Ord a) => BinaryTree a -> a -> BinaryTree a
addNode EmptyBinaryTree a = Node a EmptyBinaryTree EmptyBinaryTree
addNode (Node a l r) x 
    | x > a = balanceTree(Node a l (addNode r x))
    | x < a = balanceTree(Node a (addNode l x) r)
    | otherwise = error "Node already exists"

balanceTree :: BinaryTree a -> BinaryTree a
balanceTree EmptyBinaryTree = EmptyBinaryTree
balanceTree (Node a l r)
     | (deepL - deepR) > 1 = rotateRight (Node a bl br)
     | (deepR - deepL) > 1 = rotateLeft (Node a bl br)
     | otherwise = Node a bl br
     where bl = balanceTree l
           br = balanceTree r
           deepL = deepTree bl
           deepR = deepTree br

deepTree :: BinaryTree a -> Int
deepTree EmptyBinaryTree = 0
deepTree (Node a l r)
       | deepL > deepR = 1 + deepL
       | otherwise = 1 + deepR
       where deepL = deepTree l
             deepR = deepTree r

rotateLeft :: BinaryTree a -> BinaryTree a
rotateLeft EmptyBinaryTree = EmptyBinaryTree
rotateLeft (Node a l EmptyBinaryTree) = Node a l EmptyBinaryTree
rotateLeft (Node a l (Node c rl rr)) = Node c (Node a l rl) rr

rotateRight :: BinaryTree a -> BinaryTree a
rotateRight EmptyBinaryTree = EmptyBinaryTree
rotateRight (Node a EmptyBinaryTree r) = Node a EmptyBinaryTree r
rotateRight (Node a (Node c ll lr) r) = Node c ll (Node a lr r)

-- 57) Binary search trees (dictionaries)
-- Use the predicate add/3, developed in chapter 4 of the course, to write a predicate to construct a binary search tree from a list of integer numbers. 
-- Alto skip

-- 61) Count the leaves of a binary tree
-- A leaf is a node with no successors. Write a predicate count_leaves/2 to count them.
countLeaves :: BinaryTree a -> Int
countLeaves EmptyBinaryTree = 0
countLeaves (Node a EmptyBinaryTree EmptyBinaryTree) = 1
countLeaves (Node a l r) = countLeaves l + countLeaves r 

-- 62) Collect the internal nodes of a binary tree in a list
-- An internal node of a binary tree has either one or two non-empty successors.
internals :: BinaryTree a -> [a]
internals EmptyBinaryTree = []
internals (Node a EmptyBinaryTree EmptyBinaryTree) = []
internals (Node a l r) = [a] ++ internals l ++ internals r

-- 67) A string representation of binary trees 
toStringTree :: (Show a) => BinaryTree a -> String
toStringTree EmptyBinaryTree = ""
toStringTree (Node a EmptyBinaryTree EmptyBinaryTree) = show a
toStringTree (Node a l r) = show a ++ "(" ++ toStringTree l ++ ", " ++ toStringTree r ++ ")"

-- 81) Path from one node to another one
-- Write a function that, given two nodes a and b in a graph, returns all the acyclic paths from a to b. 
data Graph a = Graph [a] [(a, a)] deriving (Show, Eq)

addVertex :: (Eq a) => Graph a -> a -> Graph a
addVertex (Graph vl el) v 
    | find v vl = Graph vl el
    | otherwise = Graph (vl++[v]) el

addEdge :: (Eq a) => Graph a -> (a, a) -> Graph a
addEdge (Graph vl el) e 
    | find (fst e) == False = error "Vertex on Edge does not exist"
    | find (snd e) == False = error "Vertex on Edge does not exist"
    | find e el = Graph vl el
    | otherwise = Graph vl (el ++ [e])

find :: Eq a => a -> [a] -> Bool
find _ [] = False
find n (x:xs)
  | x == n = True
  | otherwise = find n xs

path :: Eq a => Graph a -> a -> a -> [a]
path (Graph vl el) x y = ???
```