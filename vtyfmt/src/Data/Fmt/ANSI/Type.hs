-- | ANSI SGR types using vty's 'Color' for color values.
--
-- Mirrors @System.Console.ANSI.Types@ from @ansi-terminal-types@ but
-- without the @colour@ dependency.  Color values use vty's 'Color'
-- type which already encodes ISO-8, 256-color, and 24-bit RGB.
module Data.Fmt.ANSI.Type
  ( -- * SGR
    SGR(..)
  , ConsoleLayer(..)
  , ConsoleIntensity(..)
  , Underlining(..)
  , BlinkSpeed(..)

    -- * Color (re-exported from vty)
  , Color(..)
  , black, red, green, yellow, blue, magenta, cyan, white
  , brightBlack, brightRed, brightGreen, brightYellow
  , brightBlue, brightMagenta, brightCyan, brightWhite
  , rgbColor, linearColor, color240

  ) where

import Graphics.Vty.Attributes.Color

-- | ANSI foreground/background layer.
data ConsoleLayer
  = Foreground
  | Background
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

-- | ANSI console intensity (bold/faint/normal).
data ConsoleIntensity
  = BoldIntensity
  | FaintIntensity
  | NormalIntensity
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

-- | ANSI text underlining.
data Underlining
  = SingleUnderline
  | DoubleUnderline
  | NoUnderline
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

-- | ANSI blink speed.
data BlinkSpeed
  = SlowBlink
  | RapidBlink
  | NoBlink
  deriving (Eq, Ord, Enum, Bounded, Read, Show)

-- | Select Graphic Rendition (SGR) command.
--
-- Uses vty's 'Color' directly for color values:
--
-- @
-- SetColor Foreground red         -- ISO red
-- SetColor Background (Color240 196)  -- 256-palette
-- SetColor Foreground (RGBColor 255 128 0)  -- 24-bit
-- @
data SGR
  = Reset
  | SetConsoleIntensity !ConsoleIntensity
  | SetItalicized !Bool
  | SetUnderlining !Underlining
  | SetBlinkSpeed !BlinkSpeed
  | SetVisible !Bool
  | SetSwapForegroundBackground !Bool
  | SetColor !ConsoleLayer !Color
  | SetDefaultColor !ConsoleLayer
  deriving (Eq, Read, Show)
