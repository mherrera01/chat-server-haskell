{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

--{-# OPTIONS_GHC -fno-warn-orphans #-}
module Dispatch where

import Yesod

import Foundation
import Handler.Home -- Home route handlers

-- resourcesChatServer created by mkYesodData in Foundation.hs
mkYesodDispatch "ChatServer" resourcesChatServer
