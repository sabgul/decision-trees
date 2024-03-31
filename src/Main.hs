-- -- ------------------------- --
-- --      Decision trees
-- -- ------------------------- --
-- -- Sabina Gulcikova, xgulci00
-- -- xgulci00@stud.fit.vutbr.czs
-- --       FLP 2023/2024
-- -- ------------------------- --

module Main (
  main
) where

import DataTypes
import InputParser
import Helpers

import System.Environment
import Data.List ( elemIndex )

--  -------------------------
--  ---------- Training
--  -------------------------
generateBestDistribution :: TrainingDataSet -> Float -> Int -> DistributionResult 
generateBestDistribution dataset threshold idx =
  let sortedDataset = sortDataOnIndex dataset idx
      vals = [calculateWeightedGini (splitDataOnIndex sortedDataset i) | i <- [1..(countTrainingDato sortedDataset) - 1]]
      minIndex = case elemIndex (minimum vals) vals of
                   Just index -> index + 1
                   Nothing -> error "Unable to find minimum value"
      (leftData, rightData) = splitDataOnIndex sortedDataset minIndex
      newThreshold = calculateThreshold (leftData, rightData) idx
      leftGini = calculateGini leftData
      rightGini = calculateGini rightData
      medianGini = (leftGini + rightGini) / 2.0
  in DistributionResult leftData leftGini rightData rightGini newThreshold medianGini

buildNode :: TrainingDataSet -> Float -> Int -> BinaryTreeRoot 
buildNode (TrainingDataSet [singleDato]) _ _ = L (Leaf (label singleDato)) 
buildNode dataset best_gini depth
  | depth >= countAttributes dataset = 
    let resultingLabel = getMostFrequent dataset
    in  L (Leaf resultingLabel)
  | otherwise = 
    let distributionResult = generateBestDistribution dataset best_gini depth
    in if best_gini == medianGini distributionResult
       then L (Leaf (getMostFrequent dataset))
       else N (Node { index = depth,
                      threshold = newThreshold distributionResult,
                      leftChild = buildNode (leftLines distributionResult) (leftGini distributionResult) (depth + 1),
                      rightChild = buildNode (rightLines distributionResult) (rightGini distributionResult) (depth + 1)
                    })

--  -------------------------
--  ---------- Classification
--  -------------------------
traverseTree :: BinaryTreeRoot -> [Float] -> [String]
traverseTree tree datum =
    case tree of
        L (Leaf label) -> [label]
        N node -> if (datum !! index node) <= threshold node
                     then traverseTree (leftChild node) datum
                     else traverseTree (rightChild node) datum

classifyData :: BinaryTreeRoot -> DataSet -> [String]
classifyData tree (DataSet datalist) = concatMap (traverseTree tree) [datum | Datum datum <- datalist]

--  -------------------------
--  ---------- Display trained tree
--  -------------------------
printTree :: BinaryTreeRoot -> String
printTree (L (Leaf label)) = "Leaf: " ++ label ++ "\n"
printTree (N (Node idx th leftChild rightChild)) =
  "Node: " ++ show idx ++ ", " ++ show th ++ "\n" ++
  printIndentedTree (idx * 2) leftChild ++
  printIndentedTree (idx * 2) rightChild

printIndentedTree :: Int -> BinaryTreeRoot -> String
printIndentedTree indent root = case root of
  L _ -> replicate indent ' ' ++ "  " ++ printTree root
  N _ -> replicate indent ' ' ++ "  " ++ printTree root

-- -- -----------------------

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["-1", treeFile, dataFile] -> do
      [inputTree, inputData] <- mapM readFile [treeFile, dataFile]
      let treeLines = lines inputTree
          tree = parseTree treeLines

      case parseDataSet inputData of
        Just dataSet -> do
          let parsedData = map Datum dataSet
              classifiedData = classifyData tree (DataSet parsedData)
          mapM_ putStrLn classifiedData
        Nothing -> putStrLn "Failed to parse dataset"

    ["-2", trainFile] -> do
      trainingData <- readFile trainFile
      let trainingLines = lines trainingData
          parsedDataSet = parseTrainingDataSet trainingLines

      let base_gini = calculateGini parsedDataSet
          trainedRoot = buildNode parsedDataSet base_gini 0
      
      putStrLn $ printTree trainedRoot 

    _ -> error "Invalid number of args! Please specify necessary files."