-- | ANSI escape code generation.
--
-- Mirrors @System.Console.ANSI.Codes@ from @ansi-terminal-types@ but
-- works with the local 'SGR' type (which uses vty's 'Color').
module Data.Fmt.ANSI.Code
  ( -- * Types (re-exported from Type)
    module Data.Fmt.ANSI.Type

    -- * SGR code generation
  , setSGRCode
  , sgrToCode

    -- * CSI primitives
  , csi

    -- * Cursor movement
  , cursorUpCode
  , cursorDownCode
  , cursorForwardCode
  , cursorBackwardCode

    -- * Screen clearing
  , clearLineCode
  , clearFromCursorToLineEndCode
  , clearScreenCode

    -- * Scrolling
  , scrollPageUpCode
  , scrollPageDownCode
  ) where

import Data.List (intercalate)
import Data.Word (Word8)

import Data.Fmt.ANSI.Type
import Graphics.Vty.Attributes.Color (Color(..))

-- ---------------------------------------------------------------------------
-- CSI primitives

-- | Build a CSI (Control Sequence Introducer) escape sequence.
csi :: [Int] -> String -> String
csi args code = "\ESC[" ++ intercalate ";" (map show args) ++ code

-- ---------------------------------------------------------------------------
-- SGR code generation

-- | Generate the escape code string for a list of SGR commands.
--
-- An empty list is equivalent to @[Reset]@.
setSGRCode :: [SGR] -> String
setSGRCode [] = setSGRCode [Reset]
setSGRCode sgrs = csi (concatMap sgrToCode sgrs) "m"

-- | Map an SGR command to its numeric parameter(s).
sgrToCode :: SGR -> [Int]
sgrToCode Reset = [0]
sgrToCode (SetConsoleIntensity i) = case i of
  BoldIntensity   -> [1]
  FaintIntensity  -> [2]
  NormalIntensity -> [22]
sgrToCode (SetItalicized True)  = [3]
sgrToCode (SetItalicized False) = [23]
sgrToCode (SetUnderlining u) = case u of
  SingleUnderline -> [4]
  DoubleUnderline -> [21]
  NoUnderline     -> [24]
sgrToCode (SetBlinkSpeed s) = case s of
  SlowBlink  -> [5]
  RapidBlink -> [6]
  NoBlink    -> [25]
sgrToCode (SetVisible False) = [8]
sgrToCode (SetVisible True)  = [28]
sgrToCode (SetSwapForegroundBackground True)  = [7]
sgrToCode (SetSwapForegroundBackground False) = [27]
sgrToCode (SetColor layer color) = colorParams layer color
sgrToCode (SetDefaultColor Foreground) = [39]
sgrToCode (SetDefaultColor Background) = [49]

-- | Map a layer + color to SGR parameter(s).
colorParams :: ConsoleLayer -> Color -> [Int]
colorParams lay (ISOColor n)
  | n < 8     = [layerBase lay + fromIntegral n]
  | otherwise = [brightBase lay + fromIntegral n - 8]
colorParams lay (Color240 n)   = [extBase lay, 5, fromIntegral n]
colorParams lay (RGBColor r g b) = [extBase lay, 2, fi r, fi g, fi b]

layerBase :: ConsoleLayer -> Int
layerBase Foreground = 30
layerBase Background = 40

brightBase :: ConsoleLayer -> Int
brightBase Foreground = 90
brightBase Background = 100

extBase :: ConsoleLayer -> Int
extBase Foreground = 38
extBase Background = 48

fi :: Word8 -> Int
fi = fromIntegral

-- ---------------------------------------------------------------------------
-- Cursor movement

cursorUpCode, cursorDownCode, cursorForwardCode, cursorBackwardCode
  :: Int -> String
cursorUpCode n      = if n == 0 then "" else csi [n] "A"
cursorDownCode n    = if n == 0 then "" else csi [n] "B"
cursorForwardCode n = if n == 0 then "" else csi [n] "C"
cursorBackwardCode n = if n == 0 then "" else csi [n] "D"

-- ---------------------------------------------------------------------------
-- Screen clearing

clearFromCursorToLineEndCode :: String
clearFromCursorToLineEndCode = csi [0] "K"

clearLineCode :: String
clearLineCode = csi [2] "K"

clearScreenCode :: String
clearScreenCode = csi [2] "J"

-- ---------------------------------------------------------------------------
-- Scrolling

scrollPageUpCode, scrollPageDownCode :: Int -> String
scrollPageUpCode n   = if n == 0 then "" else csi [n] "S"
scrollPageDownCode n = if n == 0 then "" else csi [n] "T"
