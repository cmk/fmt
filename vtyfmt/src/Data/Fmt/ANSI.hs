{-# LANGUAGE OverloadedStrings #-}

-- | ANSI terminal formatting via stringfmt + vty color types.
--
-- Provides 'Fmt'-style combinators that wrap content in ANSI escape
-- sequences. Works with any @(Semigroup m, IsString m)@ accumulator:
-- 'Text', 'Builder', 'ByteString', 'String', etc.
--
-- Colors use vty's 'Color' type — no @ansi-terminal@ or @colour@ dependency.
--
-- @
-- import Data.Fmt.ANSI
--
-- -- Red text:
-- runTextFmt (fg red (fmt s)) "hello"
--
-- -- Bold green on black:
-- runTextFmt (bg black (fg green (bold (fmt s)))) "status: ok"
-- @
module Data.Fmt.ANSI
  ( -- * Foreground / background
    fg
  , bg

    -- * Emphasis
  , bold
  , faint
  , italic
  , underline
  , blink

    -- * Compound
  , code
  , codes

    -- * Cursor / screen
  , erase
  , shift
  , scroll

    -- * Re-exports from stringfmt
  , module Data.Fmt

    -- * Re-exports from ANSI types
  , module Data.Fmt.ANSI.Type
  ) where

import Data.String (IsString, fromString)

import Data.Fmt
import Data.Fmt.ANSI.Code (setSGRCode, clearFromCursorToLineEndCode, clearLineCode,
                            cursorForwardCode, cursorBackwardCode,
                            scrollPageUpCode, scrollPageDownCode)
import Data.Fmt.ANSI.Type

-- ---------------------------------------------------------------------------
-- SGR combinators

-- | Wrap content with a single SGR command.
code :: (Semigroup m, IsString m) => SGR -> Fmt m s a -> Fmt m s a
code = codes . pure

-- | Wrap content with multiple SGR commands, reset afterward.
codes :: (Semigroup m, IsString m) => [SGR] -> Fmt m s a -> Fmt m s a
codes sgrs = enclose
  (fromString $ setSGRCode sgrs)
  (fromString $ setSGRCode [Reset])

-- ---------------------------------------------------------------------------
-- Color

-- | Set foreground color.
--
-- @
-- fg red (fmt s) :: (Semigroup m, IsString m) => Fmt m s (String -> s)
-- @
fg :: (Semigroup m, IsString m) => Color -> Fmt m s a -> Fmt m s a
fg col = code (SetColor Foreground col)

-- | Set background color.
bg :: (Semigroup m, IsString m) => Color -> Fmt m s a -> Fmt m s a
bg col = code (SetColor Background col)

-- ---------------------------------------------------------------------------
-- Emphasis

-- | Bold text.
bold :: (Semigroup m, IsString m) => Fmt m s a -> Fmt m s a
bold = code (SetConsoleIntensity BoldIntensity)

-- | Faint (dim) text.
faint :: (Semigroup m, IsString m) => Fmt m s a -> Fmt m s a
faint = code (SetConsoleIntensity FaintIntensity)

-- | Italic text.
italic :: (Semigroup m, IsString m) => Fmt m s a -> Fmt m s a
italic = code (SetItalicized True)

-- | Underlined text.
underline :: (Semigroup m, IsString m) => Fmt m s a -> Fmt m s a
underline = code (SetUnderlining SingleUnderline)

-- | Blinking text.
blink :: (Semigroup m, IsString m) => Fmt m s a -> Fmt m s a
blink = code (SetBlinkSpeed SlowBlink)

-- ---------------------------------------------------------------------------
-- Cursor / screen

-- | Erase part of the current line.
--
-- @LT@ = to beginning, @EQ@ = whole line, @GT@ = to end.
erase :: (Semigroup m, IsString m) => Ordering -> Fmt m s a -> Fmt m s a
erase GT = suffix $ fromString clearFromCursorToLineEndCode
erase EQ = suffix $ fromString clearLineCode
erase LT = suffix $ fromString clearFromCursorToLineEndCode

-- | Shift cursor horizontally.
--
-- @Left n@ = backward, @Right n@ = forward.
shift :: (Semigroup m, IsString m) => Either Int Int -> Fmt m s a -> Fmt m s a
shift = prefix . fromString . either cursorBackwardCode cursorForwardCode

-- | Scroll the page.
--
-- @Left n@ = up, @Right n@ = down.
scroll :: (Semigroup m, IsString m) => Either Int Int -> Fmt m s a -> Fmt m s a
scroll = prefix . fromString . either scrollPageUpCode scrollPageDownCode
