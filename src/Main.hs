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
-- ppp :: Connection -> IO ()
-- ppp conn = runRedis conn $
--     pubSub (subscribe ["testchan"]) $ \msg -> do
--       putStrLn $ "Message from " ++ show (msgChannel msg)
--       putStrLn $ "Message content: " ++ show (msgMessage msg)
--       if (msgMessage msg) == "quit"
--         then return $ unsubscribe ["testchan"]
--         else return mempty

ppp :: Connection -> IO ()
ppp conn = runRedis conn $
    pubSub (subscribe ["testchan"]) $ \msg -> do
      putStrLn $ "Message from " ++ show (msgChannel msg)
      -- putStrLn $ "Message content: " ++ show (msgMessage msg)
      if msgMessage msg == "quit"
        then return $ unsubscribe ["testchan"]
        else do
          let (e :: Either String (Bar, L.ByteString)) = P.messageGet (L.fromStrict (msgMessage msg))
          case e of
            Left err -> print $ "Error: " ++ err
            Right (m, bss) -> putStrLn $ "PB MSG: " ++ show m
          return mempty

main = do
  -- let b = defaultValue { Bar.wine = P.uFromString "Bubble", Bar.good = Just True }
  -- print b

  -- let bs = P.messagePut b
  -- print bs

  -- let (e :: Either String (Bar, L.ByteString)) = P.messageGet bs
  -- case e of
  --   Left err -> print $ "Error" ++ err
  --   Right (m, bss) -> print m 

  -- print $ "Custom print: { wine = " ++ P.uToString (wine b) ++ ", good = " ++ show (good b) ++ "}"

  -- let msgTxtB = P.messagePutText b
  -- print msgTxtB

  -- let f = defaultValue { Foo.bar = b, Foo.quux = Just True, Foo.baz = Just 192 }
  -- print f

  -- let msgTxtF = P.messagePutText f
  -- print msgTxtF

  -- let (rF :: Either String Foo) = P.messageGetText msgTxtF
  -- case rF of
  --   Left err -> print $ "Error: " ++ err
  --   Right ff -> print ff
  
  conn <- connect connInfo
  a1 <- async $ ppp conn

  wait a1

  return ()
            -- set "hello" "hello"
            -- set "world" "world"
            -- hello <- get "hello"
            -- world <- get "world"
            -- new <- getset "hello" "bah..."
            -- nHello <- get "hello"
            -- back <- echo "Hello World!"
            -- worldExists <- exists "world"
            -- liftIO $ print (new, world)
            -- liftIO $ print (nHello, world)
            -- liftIO $ print back
            -- liftIO $ print worldExists

            -- pubSub (subscribe ["testchan"]) $ \msg -> do
            --   putStrLn $ "Message from " ++ show (msgChannel msg)
            --   putStrLn $ "Message content: " ++ show (msgMessage msg)
            --   if (msgMessage msg) == "quit"
            --     then return $ unsubscribe ["testchan"]
            --     else return mempty

            -- return ()

      -- liftIO $ threadDelay 5000000

    -- liftIO $ do
    --   a1 <- async $ do
    --           r <- publish "testchan" "blah......"
    --           print $ "publish result: " ++ show r
