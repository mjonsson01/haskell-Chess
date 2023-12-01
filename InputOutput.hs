module InputOutput where

import Chess
import Data.List
import Data.List.Split (splitOn)
import Data.Maybe
import Solver
import System.IO

--                                        SHOWING BOARD

showPiecePretty :: Piece -> String
showPiecePretty (Rook, Black) = " ♖ "
showPiecePretty (Knight, Black) = " ♘ "
showPiecePretty (Bishop, Black) = " ♗ "
showPiecePretty (Queen, Black) = " ♕ "
showPiecePretty (King, Black) = " ♔ "
showPiecePretty (Pawn, Black) = " ♙ "
showPiecePretty (Rook, White) = " ♜ "
showPiecePretty (Knight, White) = " ♞ "
showPiecePretty (Bishop, White) = " ♝ "
showPiecePretty (Queen, White) = " ♛ "
showPiecePretty (King, White) = " ♚ "
showPiecePretty (Pawn, White) = " ♟ "

-- Returns a string representing specified row on the board
showRow :: Int -> Side -> Board -> String
showRow y White board = concat $ [show y, "  "] ++ intersperse "|" [lookupPiece (x, y) board | x <- [1 .. 8]]
showRow y Black board = concat $ [show y, "  "] ++ intersperse "|" [lookupPiece (x, y) board | x <- [8, 7 .. 1]]

-- Returns a string of the piece symbol at the given location on the board
lookupPiece :: Pos -> Board -> String
lookupPiece pos board = case lookup pos board of
  Just piece -> showPiecePretty piece
  Nothing -> "   "

-- Converts a board to a string when printed to output.
-- If not printed to output, newlines and pieces are not displayed properly.

--TODO: change from board -> String to Game -> String
showPrettyGame :: Game -> String
showPrettyGame (board, side, turn) =
  let rows = [showRow y White board | y <- [8, 7 .. 1]]
      separator = "   " ++ replicate (31) '-'
      coordinateLine = intercalate "   " ["", "a", "b", "c", "d", "e", "f", "g", "h"]
      prettyBoard = unlines (intersperse separator rows) ++ "\n " ++ coordinateLine
  in "Current side: " ++ (show side) ++ "\n" ++ "Num of turn left: " ++ (show turn) ++ "\n" ++ prettyBoard    

--                                        TEXT REPRESENTATION
--                                        STRING TO BOARD

stringToPiece :: String -> Maybe Piece
stringToPiece s =
  case s of
    "_" -> Nothing
    "r" -> Just (Rook, Black)
    "n" -> Just (Knight, Black)
    "b" -> Just (Bishop, Black)
    "q" -> Just (Queen, Black)
    "k" -> Just (King, Black)
    "p" -> Just (Pawn, Black)
    "R" -> Just (Rook, White)
    "N" -> Just (Knight, White)
    "B" -> Just (Bishop, White)
    "Q" -> Just (Queen, White)
    "K" -> Just (King, White)
    "P" -> Just (Pawn, White)
    _   -> Nothing

buildSquare :: ((Int, Int), Maybe Piece) -> Maybe Square
buildSquare ((colNum, rowNum), piece) =
  case piece of
    Nothing -> Nothing
    Just p -> Just ((colNum, rowNum), p)

rowToBoard :: String -> Int -> [Square]
rowToBoard rowString rowNum =
  let pieces = splitOn " " rowString
   in catMaybes [buildSquare ((colNum, rowNum), stringToPiece piece) | (colNum, piece) <- zip [1 ..] pieces]

-- parses our simple board notation and converts to a Board
stringToBoard :: String -> Board
stringToBoard boardString =
  let rows = splitOn " \n" boardString
   in concat [rowToBoard row rowNum | (rowNum, row) <- zip [8, 7 .. 1] rows]

--                                        BOARD TO STRING

pieceToString :: Maybe Piece -> String
pieceToString piece =
  case piece of
    Nothing -> "_"
    Just (Rook, Black) -> "r"
    Just (Knight, Black) -> "n"
    Just (Bishop, Black) -> "b"
    Just (Queen, Black) -> "q"
    Just (King, Black) -> "k"
    Just (Pawn, Black) -> "p"
    Just (Rook, White) -> "R"
    Just (Knight, White) -> "N"
    Just (Bishop, White) -> "B"
    Just (Queen, White) -> "Q"
    Just (King, White) -> "K"
    Just (Pawn, White) -> "P"

rowToString :: Board -> Int -> String
rowToString board rowNum = unwords [pieceToString (lookup (colNum, rowNum) board) | colNum <- [1 .. 8]]

boardToString :: Board -> String
boardToString board = unlines [rowToString (filter (\((column, row), piece) -> row == x) board) x | x <- [8, 7 .. 1]]

--                                        GAME TO STRING
readGame :: String -> Game
readGame gameString =
  let (headerRows : boardRows) = lines gameString
      header = splitOn " " headerRows
      side = case (head header) of
        "W" -> White
        "B" -> Black
      turnsLeft = read (last header)
      board = stringToBoard (unlines boardRows)
   in (board, side, turnsLeft)

showGame :: Game -> String
showGame (board, side, turnsLeft) =
  let sideString = case side of
        White -> "W"
        Black -> "B"
   in sideString ++ " " ++ (show turnsLeft) ++ "\n" ++ boardToString board

writeGame :: Game -> FilePath -> IO ()
writeGame game filepath = do
  let gameString = showGame game
  handle <- openFile filepath WriteMode
  hPutStr handle gameString
  hClose handle
  return ()

loadGame :: FilePath -> IO Game
loadGame filepath = do
  gameContent <- (readFile filepath)
  let game = readGame gameContent
  return game

putBestMove :: Game -> IO ()
putBestMove game = do
  let bm = bestMove game
      newGame = makeUnSafeMove game bm
  putStrLn $ "You should make move: " ++ show bm
  putStrLn $ showPrettyGame newGame 

{- main :: IO ()
main =
  do
    args <- getArgs
    let fname = head args
    game@(initialboard, _, _) <- loadGame fname
    putStrLn "initial board: "
    putStrLn $ showBoard initialboard
    putStrLn "new board: "
    putBestMove game
-}