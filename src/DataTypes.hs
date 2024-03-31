-- -- ------------------------- --
-- --      Decision trees
-- --        DATA module
-- -- 
-- --  contains definitions of 
-- --  data types
-- -- ------------------------- --
-- -- Sabina Gulcikova, xgulci00
-- -- xgulci00@stud.fit.vutbr.czs
-- --       FLP 2023/2024
-- -- ------------------------- --

module DataTypes (
  Leaf(..),
  Node(..),
  BinaryTreeRoot(..),
  Dato(..),
  DataSet(..),
  TrainingDato(..),
  TrainingDataSet(..),
  DistributionResult(..)
) where

data Leaf = Leaf String deriving (Show)

data Node = Node { index :: Int,
                  threshold :: Float,
                  leftChild :: BinaryTreeRoot,
                  rightChild :: BinaryTreeRoot
                 } deriving (Show)

data BinaryTreeRoot = L Leaf | N Node deriving (Show)

data Dato = Datum [Float] deriving (Show)

data DataSet = DataSet [Dato] deriving (Show)

data TrainingDato = TrainingDato
                      { features :: [Float],
                        label :: String
                      } deriving (Show)

data TrainingDataSet = TrainingDataSet [TrainingDato] deriving (Show)

data DistributionResult = DistributionResult
                        { leftLines :: TrainingDataSet,
                          leftGini :: Float,
                          rightLines :: TrainingDataSet,
                          rightGini :: Float,
                          newThreshold :: Float,
                          medianGini :: Float
                        } deriving (Show)
