{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Handler.GlobalChat where

import Data.Monoid ((<>))
import Data.Text (Text)
import Data.Default
import Yesod
import Yesod.Default.Util

import Foundation
import Handler.Forms

-- TODO. https://www.yesodweb.com/book-1.4/sessions#sessions_ultimate_destination

-- Handler for /global GlobalChatR GET
getGlobalChatR :: Handler Html
getGlobalChatR = defaultLayout $ do
    setTitle "Global Chat"
    $(widgetFileNoReload def "global-chat")

-- Handler for /global GlobalChatR POST
postGlobalChatR :: Handler Html
postGlobalChatR = do
    ((result, _), _) <- runFormPost userForm
    case result of
        FormSuccess user -> do
            cs <- getYesod
            userAdded <- addUser cs $ userNameInput user

            -- Retry user form if the name is already chosen
            case userAdded of
                Nothing -> userFormError ("Name " <> userNameInput user
                                          <> " already in use. Type another one.")
                Just userAddedOk -> do
                    -- Creates a web sockets connection for the new user
                    createWSConn cs userAddedOk
                    defaultLayout $ do
                        setTitle "Global Chat"
                        $(widgetFileNoReload def "global-chat")

        -- Form failure
        _ -> userFormError "Incorrect parameter. Try again."
    where
        -- Sets an error message to the session and redirects
        -- to the home page when the user form fails
        userFormError :: Text -> Handler Html
        userFormError msg = do
            setMessage $ toHtml msg -- Session value
            redirect HomeR
