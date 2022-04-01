{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

{-# OPTIONS_GHC -fno-warn-orphans #-} -- mkYesodDispatch warning
module Dispatch
    ( productionMain
    , develMain
    ) where

import Control.Monad
import Control.Concurrent (threadDelay)
import Control.Concurrent.Async (race_)
import System.Directory (doesFileExist)
import System.Environment
import Yesod
import Yesod.Static

import Foundation

-- Route handlers
import Handler.Home

-- resourcesChatServer created by mkYesodData in Foundation.hs
mkYesodDispatch "ChatServer" resourcesChatServer

-- Foundation variable
chatSrv :: IO ChatServer
chatSrv = do
    st <- static "static/"
    return $ ChatServer st "Welcome"

-- Runs the server in a production environment
productionMain :: IO ()
productionMain = do
    cs <- chatSrv
    warp 44444 cs

-- Runs the server with yesod devel for development purposes.
-- The code will be recompiled whenever a file is modified and
-- the server will be relaunched.
develMain :: IO ()
develMain = race_ finishDevel $ do
    port <- read <$> getEnv "PORT"
    displayPort <- getEnv "DISPLAY_PORT"
    putStrLn $ "Running in development mode on port " ++ show port
    putStrLn $ "For testing connect to port " ++ displayPort
    cs <- chatSrv
    warp port cs

-- When the server is killed due to for example a keyboard interrupt
-- signal (Ctrl + C), the file yesod-devel/devel-terminate is created.
-- Checks whenever that file exists for the server shutdown.
finishDevel :: IO ()
finishDevel = loop where
    loop = do
        exists <- doesFileExist "yesod-devel/devel-terminate"
        unless exists $ do
            threadDelay 100000
            loop
