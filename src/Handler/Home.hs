{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.Home where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
    ChatServer text <- getYesod
    setTitle "Free Chat"
    $(widgetFileNoReload def "home")
