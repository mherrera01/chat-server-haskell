{-# LANGUAGE OverloadedStrings #-}

module Main where

import Yesod
import Yesod.Static

import Dispatch ()
import Foundation

-- Server port
port :: Int
port = 44444

main :: IO ()
main = do
    st <- static "static/"
    warp port $ ChatServer st "Welcome"
