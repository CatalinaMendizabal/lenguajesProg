module Practica where

{-| 

Definir una estructura en Haskell para representar una jerarquía de empleados, junto con el
departamento al cual pertenecen y el sueldo percibido. Un empleado puede tener 0 o más empleados a cargo.

-}

data Worker = Worker String Double [Worker] deriving Show

{-| 

Definir la clase Eq para la estructura

-}

instance Eq Worker where
    -- Employer d s l == Employer d2 s2 l2 = d == d2 && s == s2 && l == l2
    -- Employee d s == Employee d2 s2 = d == d2 && s == s2
    -- _ == _ = False
    Worker d s l == Worker d2 s2 l2 = d == d2 && s == s2 && l == l2

{-| 

Definir una función que devuelva el monto total pagado en sueldos por cada departamento
a empleados sin gente a cargo.

>>> finalFunction (Worker "RRHH" 100.0 [Worker "Ventas" 50.0 [], Worker "Ventas" 40.0 [], Worker "RRHH" 80.0 [Worker "RRHH" 10.0 []]])
[("Ventas",90.0),("RRHH",10.0)]

-}

finalFunction :: Worker -> [(String, Double)]
finalFunction x = costByDepartmentForEmployees (getEmployees [x])

costByDepartmentForEmployees :: [(String, Double)] -> [(String, Double)]
costByDepartmentForEmployees [] = []
costByDepartmentForEmployees [x] = [x]
costByDepartmentForEmployees ((d, s):xs) = result ((d, s) : [(d, s1) | (d1, s1) <- xs, d == d1]) : costByDepartmentForEmployees [(d1, s1) | (d1, s1) <- xs, d /= d1]

getEmployees :: [Worker] -> [(String, Double)]
getEmployees [] = []
getEmployees [Worker d s []] = [(d, s)]
getEmployees [Worker d s l] = getEmployees l
getEmployees (x:xs) = getEmployees [x] ++ getEmployees xs

result :: [(String, Double)] -> (String, Double)
result (x:xs) = (fst x, sum [snd y | y <- x:xs])
