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

