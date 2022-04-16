{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.Home where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation
import Handler.Forms
import Settings.StaticFiles -- StaicR route references

-- Handler for / HomeR GET
getHomeR :: Handler Html
getHomeR = do
    (formWidget, formEncType) <- generateFormPost userForm
    defaultLayout $ do
        setTitle "Free Chat"
        
        -- Gets a message in the user session. After the user form
        -- POST, the user is redirected back to the home page along
        -- a message if an error occurs.
        mmsg <- getMessage
        $(widgetFileNoReload def "home")
