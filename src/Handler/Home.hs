{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.Home where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
    ChatServer _ text <- getYesod
    setTitle "Free Chat"
    --addStylesheet $ StaticR css_bootstrap_css -- Check https://bootswatch.com/3/
    $(widgetFileNoReload def "home")
