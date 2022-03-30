{-# LANGUAGE OverloadedStrings #-}

module Main where

import Yesod

import Dispatch ()
import Foundation

-- Server port
port :: Int
port = 44444

main :: IO ()
main = warp port $ ChatServer "Welcome"
