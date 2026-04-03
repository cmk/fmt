{-# LANGUAGE OverloadedStrings #-}

-- | Fast-logger formatting via stringfmt.
--
-- This module provides the bridge between stringfmt's generic 'Fmt'
-- type and fast-logger's 'LogStr'. It re-exports the core stringfmt
-- API plus LogStr-specific runners and combinators.
--
-- @
-- import Data.Fmt.Log
--
-- printf ("Name: " % s % ", Age: " % d) "Alice" 30
-- -- Name: Alice, Age: 30
-- @
module Data.Fmt.Log (
    -- * LogFmt
    LogFmt,
    Term,

    -- * Running
    runLogFmt,
    printf,

    -- * LogStr construction
    logFmt,
    v,

    -- * Re-exports from stringfmt
    module Data.Fmt,

    -- * Re-exports from fast-logger
    LogStr,
    ToLogStr (..),
    fromLogStr,
) where

import Data.Fmt hiding (f, printf)

import qualified Data.ByteString.Char8 as B
import Data.String (IsString, fromString)
import System.Log.FastLogger (LogStr, ToLogStr (..), fromLogStr)

-- | @Fmt@ specialized to 'LogStr'.
type LogFmt = Fmt LogStr

-- | Terminal output.
type Term = IO ()

-- | Run a 'LogFmt' to a polymorphic string type via 'fromLogStr'.
--
-- >>> runLogFmt ("hello " % s) "world" :: String
-- "hello world"
{-# INLINE runLogFmt #-}
runLogFmt :: IsString s => LogFmt s a -> a
runLogFmt (Fmt f) = f (fromString . B.unpack . fromLogStr)

-- | Run a 'LogFmt' and print the result to stdout.
--
-- >>> printf ("Name: " % s % ", Age: " % d) "Alice" 30
-- Name: Alice, Age: 30
{-# INLINE printf #-}
printf :: LogFmt Term a -> a
printf (Fmt f) = f (B.putStrLn . fromLogStr)

-- | Format a value as 'LogStr' using 'ToLogStr'.
--
-- >>> runLogFmt (logFmt "hello") :: String
-- "hello"
{-# INLINE logFmt #-}
logFmt :: ToLogStr m => m -> Fmt LogStr a a
logFmt = fmt . toLogStr

-- | Encode a value using 'ToLogStr'.
--
-- The LogStr equivalent of stringfmt's generic 's' combinator.
--
-- >>> printf ("Value: " % v) 42
-- Value: 42
{-# INLINE v #-}
v :: ToLogStr a => Fmt1 LogStr s a
v = fmt1 toLogStr
