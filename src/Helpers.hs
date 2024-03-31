-- -- ------------------------- --
-- --      Decision trees
-- --       HELPERS module
-- -- 
-- --  contains definitions of 
-- --  helper functions
-- -- ------------------------- --
-- -- Sabina Gulcikova, xgulci00
-- -- xgulci00@stud.fit.vutbr.czs
-- --       FLP 2023/2024
-- -- ------------------------- --

module Helpers (
    countLeadingSpaces,
    isDeeper,
    isShallower,
    isLeaf,
    splitLeftSubtree,
    splitRightSubtree,
    calculateGini,
    calculateWeightedGini,
    sortDataOnIndex,
    splitDataOnIndex,
    getMostFrequent,
    countLabels,
    incrementCount,
    calculateThreshold,
    countTrainingDato,
    countAttributes
) where

import DataTypes

import Data.Char (isSpace)
import Data.List (sort, sortBy, group, maximumBy)
import Data.Ord (comparing)

countLeadingSpaces :: String -> Int
countLeadingSpaces = length . takeWhile (\c -> c == ' ')

isDeeper :: Int -> String -> Bool
isDeeper indexOfLine line = countLeadingSpaces line > indexOfLine * 2

isShallower :: Int -> String -> Bool
isShallower indexOfLine line = countLeadingSpaces line < indexOfLine * 2

isLeaf :: String -> Bool
isLeaf str = case words (dropWhile isSpace str) of
    ("Leaf:":_) -> True
    _          -> False

splitLeftSubtree :: [String] -> Int -> ([String], [String])
splitLeftSubtree [] _ = ([], [])
splitLeftSubtree (x:xs) depth = go [x] xs
  where
    go acc [] = (acc, [])
    go acc (y:ys)
      | isDeeper depth y = go (acc ++ [y]) ys
      | otherwise = (acc, y:ys)

splitRightSubtree :: [String] -> Int -> ([String], [String])
splitRightSubtree [] _ = ([], [])
splitRightSubtree (x:xs) depth = go [x] xs
  where
    go acc [] = (acc, [])
    go acc (y:ys)
      | isShallower depth y = (acc, y:ys)
      | otherwise = go (acc ++ [y]) ys

calculateGini :: TrainingDataSet -> Float
calculateGini (TrainingDataSet []) = 0.0
calculateGini (TrainingDataSet dataset) =
  let totalCount = fromIntegral $ length dataset
      sortedLabels = sort $ map label dataset
      labelGroups = group sortedLabels
      labelCounts = map (\grp -> (head grp, fromIntegral $ length grp)) labelGroups
      labelProbabilities = map (\(_, count) -> count / totalCount) labelCounts
      giniSum = sum $ map (\prob -> prob * prob) labelProbabilities
  in 1.0 - giniSum

calculateWeightedGini :: (TrainingDataSet, TrainingDataSet) -> Float
calculateWeightedGini (TrainingDataSet leftData, TrainingDataSet rightData) =
    let leftCount = fromIntegral $ length leftData
        rightCount = fromIntegral $ length rightData
        leftGini = calculateGini (TrainingDataSet leftData)
        rightGini = calculateGini (TrainingDataSet rightData)
    in (leftCount * leftGini + rightCount * rightGini) / (leftCount + rightCount)

sortDataOnIndex :: TrainingDataSet -> Int -> TrainingDataSet
sortDataOnIndex (TrainingDataSet dataset) index =
    TrainingDataSet $ sortBy (comparing (\(TrainingDato feats _) -> feats !! index)) dataset

splitDataOnIndex :: TrainingDataSet -> Int -> (TrainingDataSet, TrainingDataSet)
splitDataOnIndex (TrainingDataSet dataset) index =
    let (left, right) = splitAt index dataset
    in (TrainingDataSet left, TrainingDataSet right)

getMostFrequent :: TrainingDataSet -> String
getMostFrequent (TrainingDataSet dataset) =
    let labelCounts = countLabels dataset
        mostFrequentLabel = fst $ maximumBy (comparing snd) labelCounts
    in mostFrequentLabel

countLabels :: [TrainingDato] -> [(String, Int)]
countLabels dataset =
    let labelCounts = map (\dato -> (label dato, 1 :: Int)) dataset
    in foldl (\acc (l, _) -> incrementCount l acc) [] labelCounts

incrementCount :: String -> [(String, Int)] -> [(String, Int)]
incrementCount label [] = [(label, 1)]
incrementCount label ((l, count):rest)
    | label == l = (l, count + 1) : rest
    | otherwise = (l, count) : incrementCount label rest

calculateThreshold :: (TrainingDataSet, TrainingDataSet) -> Int -> Float
calculateThreshold (leftData, rightData) idx =
  let leftSorted = sortDataOnIndex leftData idx
      leftDato = case leftSorted of
                    TrainingDataSet [] -> error "Empty dataset"
                    TrainingDataSet xs -> last xs
      leftVal = features leftDato !! idx
      rightSorted = sortDataOnIndex rightData idx
      rightDato = case rightSorted of
                    TrainingDataSet [] -> error "Empty dataset"
                    TrainingDataSet xs -> head xs
      rightVal = features rightDato !! idx
    in (leftVal + rightVal) / 2.0

countTrainingDato :: TrainingDataSet -> Int
countTrainingDato (TrainingDataSet dataset) = length dataset

countAttributes :: TrainingDataSet -> Int
countAttributes (TrainingDataSet []) = 0 
countAttributes (TrainingDataSet (x:_)) = length $ features x