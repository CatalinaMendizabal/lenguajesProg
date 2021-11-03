module Practica where

{-| (9) Pack consecutive duplicates of list elements into sublists 

>>> packList [1,1,2,3,3,3,1,1,1,4,5,6,6]
[[1,1],[2],[3,3,3],[1,1,1],[4],[5],[6,6]]

-}

packList :: (Eq a) => [a] -> [[a]]
packList [] = []
packList (x:xs) = dups : packList rest
    where (dups, rest) = span (==x) (x:xs)

{- | (10) Run-length encoding of a list.

>>> runLength [1,1,2,3,3,3,1,1,1,4,5,6,6]
[(1,2),(2,1),(3,3),(4,1),(5,1),(6,2)]

-}

runLength :: (Eq a) => [a] -> [(a, Int)]
runLength [] = []
runLength (x:xs) = (head (head (packList (x:xs))), length (head (packList (x:xs)))) : runLength [y | y <- xs, y /= x]

{- | (11) Modified run-length encoding.

>>> modifiedRunLength [1,1,2,3,3,3,1,1,1,4,5,6,6]
[Tuple (1,2),Single 2,Tuple (3,3),Single 4,Single 5,Tuple (6,2)]

-}

data RunLengthElement a = Single a | Tuple (a, Int) deriving (Show)

modifiedRunLength :: (Eq a) => [a] -> [RunLengthElement a]
modifiedRunLength [] = []
modifiedRunLength (x:xs)
    | l == 1 = Single e : modifiedRunLength xs
    | otherwise = Tuple (e, l) : modifiedRunLength [y | y <- xs, y /= x]
    where 
        e = head (head (packList (x:xs)))
        l = length (head (packList (x:xs)))

{-| (29) Sorting a list of lists according to length of sublists.

>>> lengthSort [[1,2,3], [1,2,3,4,5], [1,2], [1], [1,2,3,4]]
[[1],[1,2],[1,2,3],[1,2,3,4],[1,2,3,4,5]]

-}

lengthSort :: [[a]] -> [[a]]
lengthSort [] = []
lengthSort (x:xs) = lengthSort [y | y <- xs, length y < length x] ++ [x] ++ lengthSort [y | y <- xs, length y > length x]

-- Parcial
{-| Definir el tipo de datos Tree, con datos sólo en las hojas, e implementar la clase Eq 
-}

data Tree a = Empty | Branch (Tree a) (Tree a) | Leaf a

instance (Eq a) => Eq (Tree a) where
    Empty == Empty = True
    Branch l r == Branch l' r' = l == l' && r == r'
    Leaf a == Leaf b = a == b
    _ == _ = False

{-| 2- Implementar la generación del árbol de compresión de Huffman, esto implica el análisis
de repetición de cada letra, y posterior generación del árbol, el cual puede ser generado
balanceado o no. La que se recibe para generar el árbol es un String ([Char]) 

>>> definitive "ATA LA VACA A LA ESTACA"
Node 23 (LeafH ('A',9)) (Node 14 (LeafH (' ',5)) (Node 9 (Node 4 (LeafH ('T',2)) (LeafH ('L',2))) (Node 5 (LeafH ('C',2)) (Node 3 (LeafH ('S',1)) (Node 2 (LeafH ('V',1)) (LeafH ('E',1)))))))

-}

data HuffmanTree = EmptyTree | Node Int HuffmanTree HuffmanTree | LeafH (Char, Int) deriving (Show)

freq :: [Char] -> [(Char, Int)]
freq [] = []
freq [x] = [(x, 1)]
freq (x:xs) = (x, length [y | y <- x:xs, y == x]) : freq [y | y <- xs, y /= x]

sortTuple :: [(Char, Int)] -> [HuffmanTree]
sortTuple [] = []
sortTuple [x] = [LeafH x]
sortTuple (x:xs) = sortTuple [y | y <- xs, snd y < snd x] ++ [LeafH x] ++ sortTuple [y | y <- xs, snd y >= snd x]

treeBuilder :: [HuffmanTree] -> HuffmanTree
treeBuilder [] = EmptyTree
treeBuilder [x] = x
treeBuilder (x:y:xs) = treeBuilder (sortTreeList (Node (getValue x + getValue y) x y : xs))

sortTreeList :: [HuffmanTree] -> [HuffmanTree]
sortTreeList [] = []
sortTreeList [x] = [x]
sortTreeList (x:xs) = sortTreeList [y | y <- xs, getValue y < getValue x] ++ [x] ++ sortTreeList [y | y <- xs, getValue y >= getValue x]

getValue :: HuffmanTree -> Int 
getValue EmptyTree = 0
getValue (LeafH x)= snd x
getValue (Node x _ _) = x

definitive :: [Char] -> HuffmanTree
definitive x = treeBuilder (sortTuple (freq x))
