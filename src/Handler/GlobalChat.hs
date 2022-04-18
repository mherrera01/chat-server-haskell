{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.GlobalChat where

import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation

-- Handler for /global GlobalChatR GET
getGlobalChatR :: Handler Html
getGlobalChatR = do
    -- Gets the user id from the session
    mUserName <- lookupSession "UserID"
    case mUserName of
        Nothing -> redirect HomeR
        Just userName -> do
            cs <- getYesod

            -- Gets the user from the server list
            mUser <- getUser cs userName
            case mUser of
                Nothing -> do
                    -- There was a problem between the session variable
                    -- and the server users stored
                    deleteSession "UserID"
                    redirect HomeR
                Just user -> do
                    -- Creates a web sockets connection for the new user
                    createWSConn cs user
                    defaultLayout $ do
                        setTitle "Global Chat"
                        $(widgetFileNoReload def "global-chat")
