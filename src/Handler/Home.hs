{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.Home where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation
import Handler.Forms

-- Handler for / HomeR GET
getHomeR :: Handler Html
getHomeR = do
    (formWidget, formEncType) <- generateFormPost userForm
    defaultLayout $ do
        setTitle "Free Chat"
        $(widgetFileNoReload def "home")
