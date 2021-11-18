module Parcial where

{-| (1) Dado el tipo de dato "data Bit = ZERO | ONE", definir la suma binaria. 

>>> binarySum [ONE, ZERO] [ONE, ONE]
[ONE,ZERO,ONE]

-}

data Bit = ZERO | ONE deriving (Show)

binarySum :: [Bit] -> [Bit] -> [Bit]
binarySum [] [] = []
binarySum [] l = l
binarySum l [] = l
binarySum a b 
    | carry == ONE = binarySum (binarySum (init a) (init b)) [carry] ++ [res]
    | otherwise = binarySum (init a) (init b) ++ [res]
    where (carry, res) = bitAdder (last a) (last b)

bitAdder :: Bit -> Bit -> (Bit, Bit)
bitAdder ZERO ZERO = (ZERO, ZERO)
bitAdder ZERO ONE = (ZERO, ONE)
bitAdder ONE ZERO = (ZERO, ONE)
bitAdder ONE ONE = (ONE, ZERO)

instance Eq Bit where
    ONE == ONE = True 
    ZERO == ZERO = True 
    _ == _ = False

{-| (2) Definir el tipo de dato TREE (árbol binario con valores solo en las hojas) e implementar la clase Eq 

>>> Branch (Leaf 2) Empty == Branch (Leaf 2) Empty
True

>>> Branch (Leaf 2) Empty == Branch (Leaf 2) (Leaf 3)
False

-}

data Tree a = Empty | Branch (Tree a) (Tree a) | Leaf a deriving (Show)

instance (Eq a) => Eq (Tree a) where
    Empty == Empty = True 
    Leaf x == Leaf y = x == y
    Branch l r == Branch l' r' = l == l' && r == r'
    _ == _ = False 

{-| (3) A partir del los tipos de dato definido en los ejercicios 1 y 2, definir una función donde se le pase un Tree y una 
lista de Bit, retornar un String que sea el recorrer el Tree según la lista de Bit, donde ZERO es izquierda y ONE es derecha. 

>>> huffmanDecode (Branch (Branch (Leaf 'a') (Leaf 'c')) (Leaf 's')) [ZERO, ONE, ZERO, ZERO, ONE, ZERO, ZERO]
"casa"

-}

huffmanDecode :: Tree Char -> [Bit] -> [Char]
huffmanDecode t [] = []
huffmanDecode t c = x : huffmanDecode t xs
    where (x, xs) = decode t c

decode :: Tree Char -> [Bit] -> (Char, [Bit])
decode (Leaf v) [] = (v, [])
decode _ [] = error "invalid code"
decode Empty _ = error "invalid code"
decode (Leaf v) c = (v, c)
decode (Branch l r) (x:xs)
    | x == ZERO = decode l xs
    | otherwise = decode r xs
