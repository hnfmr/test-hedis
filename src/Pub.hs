{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

import qualified Data.ByteString.Lazy as L
import Data.ByteString.Builder
import Database.Redis
import Control.Monad.IO.Class (liftIO)
import System.IO
import Data.Monoid((<>))
import Data.Foldable
import Data.List

import qualified Text.ProtocolBuffers.Basic as P
import qualified Text.ProtocolBuffers.TextMessage as P
import qualified Text.ProtocolBuffers.WireMessage as P
import Text.ProtocolBuffers (defaultValue)


import Data.Test.Foo as Foo

import Data.Test.Bar as Bar

import Control.Concurrent
import Control.Concurrent.Async

connInfo :: ConnectInfo
connInfo = defaultConnectInfo { connectPort = UnixSocket "/tmp/redis.sock" }

renderString :: String -> Builder
renderString cs = charUtf8 '"' <> foldMap escape cs <> charUtf8 '"'
  where
    escape '\\' = charUtf8 '\\' <> charUtf8 '\\'
    escape '\"' = charUtf8 '\\' <> charUtf8 '\"'
    escape c    = charUtf8 c

-- getData :: IO L.ByteString
-- getData = do
--   h <- openFile "data.txt" ReadMode
--   r <- L.hGetContents h
--   return r
pub :: Connection -> IO ()
pub conn = runRedis conn $ do
  let b = defaultValue { Bar.wine = P.uFromString "Bubble", Bar.good = Just True }
  let bs = P.messagePut b

  r <- publish "testchan" (L.toStrict bs)
  liftIO $ putStrLn ("Sent: " ++ show r)
  liftIO $ threadDelay 1500000
  publish "testchan" "quit"
  liftIO $ threadDelay 100000

main = do
  conn <- connect connInfo
  a1 <- async $ pub conn
  wait a1
  -- return ()
