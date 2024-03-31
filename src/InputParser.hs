-- -- ------------------------- --
-- --      Decision trees
-- --    INPUT PARSER module
-- -- 
-- --  contains definitions of 
-- --  functions for parsing 
-- --  the input
-- -- ------------------------- --
-- -- Sabina Gulcikova, xgulci00
-- -- xgulci00@stud.fit.vutbr.czs
-- --       FLP 2023/2024
-- -- ------------------------- --

module InputParser (
  parseLeaf,
  parseNode,
  parseTree,
  parseDato,
  parseDataSet,
  parseTrainingDato,
  parseTrainingDataSet
) where

import DataTypes
import Helpers

import Data.Char (isSpace)
import Text.Read (readMaybe)
import Data.Maybe (mapMaybe)
import Data.List.Split (splitOn)

parseLeaf :: String -> Leaf
parseLeaf line = Leaf $ (drop 6 . dropWhile isSpace) line

parseNode :: String -> Node
parseNode line = Node { index = idx,
                        threshold = th,
                        leftChild = undefined,
                        rightChild = undefined
                      }
  where
    trimmedLine = dropWhile (== ' ') line
    [idxStr, thStr] = splitOn "," trimmedLine
    idx = read $ drop 6 idxStr
    th = read $ drop 1 thStr

parseTree :: [String] -> BinaryTreeRoot
parseTree [] = error "Empty input list"
parseTree [line]
  | isLeaf line = L $ parseLeaf line
  | otherwise = error $ "The tree is in invalid format. Crashing on line: " ++ line
parseTree (currLine:restLines)
  | isLeaf currLine = L $ parseLeaf currLine
  | otherwise = let curr_node = parseNode currLine
                    (leftLines, remainingLines) = splitLeftSubtree restLines ((index curr_node) + 1)
                    (rightLines, _) = splitRightSubtree remainingLines ((index curr_node) + 1)
                    leftChild = parseTree leftLines
                    rightChild = parseTree rightLines
                in N $ curr_node { leftChild = leftChild, rightChild = rightChild }


-- -- Parse data to classify
parseDato :: String -> Maybe [Float]
parseDato line = mapM readMaybe (splitOn "," line)

parseDataSet :: String -> Maybe [[Float]]
parseDataSet input = mapM parseDato (lines input)

parseTrainingDato :: String -> Maybe TrainingDato
parseTrainingDato line =
  case splitOn "," line of
    floatsStrs@(_:_:_:_) -> do
      let floats = mapMaybe readMaybe (init floatsStrs)
      let label = last floatsStrs
      return $ TrainingDato floats label
    _ -> Nothing

parseTrainingDataSet :: [String] -> TrainingDataSet
parseTrainingDataSet trainingLines =
  let trainingDataList = mapMaybe parseTrainingDato trainingLines
  in TrainingDataSet trainingDataList