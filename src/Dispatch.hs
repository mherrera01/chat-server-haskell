{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Dispatch where

import Yesod

import Foundation
import Handler.Home -- Home route handlers

-- resourcesChatServer created by mkYesodData in Foundation.hs
mkYesodDispatch "ChatServer" resourcesChatServer
