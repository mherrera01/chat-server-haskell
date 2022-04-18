{-# LANGUAGE OverloadedStrings #-}

module Handler.Login where

import Data.Monoid ((<>))
import Data.Text (Text)
import Yesod

import Foundation
import Handler.Forms

-- Handler for /login LoginR GET
getLoginR :: Handler Html
-- The login user form is in the home page
getLoginR = redirect HomeR

-- Handler for /login LoginR POST
postLoginR :: Handler Html
postLoginR = do
    ((result, _), _) <- runFormPost userForm
    case result of
        FormSuccess user -> do
            cs <- getYesod
            userAdded <- addUser cs $ userNameInput user

            -- Retry user form if the name is already chosen
            if userAdded
                then do
                    -- Sets the user name as id in the session.
                    -- It is after used by the global page.
                    setSession "UserID" (userNameInput user)
                    redirect GlobalChatR
                else
                    userFormError ("Name " <> userNameInput user
                                   <> " already in use. Type another one.")

        -- Form failure
        _ -> userFormError "Incorrect parameter. Try again."
    where
        -- Sets an error message to the session and redirects
        -- to the home page when the user form fails
        userFormError :: Text -> Handler Html
        userFormError msg = do
            setMessage $ toHtml msg -- Session value
            redirect HomeR
