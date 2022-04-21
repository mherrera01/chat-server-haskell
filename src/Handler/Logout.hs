{-# LANGUAGE OverloadedStrings #-}

module Handler.Logout where

import Yesod

import Foundation

-- Handler for /logout LogoutR GET
getLogoutR :: Handler Html
getLogoutR = redirect HomeR

-- Handler for /logout LogoutR POST
postLogoutR :: Handler Html
postLogoutR = do
    -- Gets the user id from the session
    mUserName <- lookupSession "UserID"
    case mUserName of
        Nothing -> redirect HomeR
        Just userName -> do
            cs <- getYesod

            -- Removes the user from the server list
            removeUser cs userName
            deleteSession "UserID"

            -- Redirects back to the home page
            redirect HomeR
