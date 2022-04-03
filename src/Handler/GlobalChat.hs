{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.GlobalChat where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation
import Handler.Forms

-- Handler for /global GlobalChatR POST
postGlobalChatR :: Handler Html
postGlobalChatR = do
    ((result, _), _) <- runFormPost userForm
    case result of
        FormSuccess user -> do
            cs <- getYesod
            addUser cs $ userName user
            defaultLayout $ do
                setTitle "Global Chat"
                $(widgetFileNoReload def "global-chat")
        _ -> redirect HomeR
