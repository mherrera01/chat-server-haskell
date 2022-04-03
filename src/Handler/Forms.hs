{-# LANGUAGE OverloadedStrings #-}

module Handler.Forms where

import Data.Text (Text)
import Yesod
import Yesod.Form.Bootstrap3

import Foundation

-- User name required
newtype UserForm = UserForm {userName :: Text}

-- Form to access to the global chat.
-- Using the Bootstrap grid to build the horizontal form:
-- https://getbootstrap.com/docs/3.4/css/#forms-horizontal
userForm :: Html -> MForm Handler (FormResult UserForm, Widget)
userForm = renderBootstrap3 (BootstrapHorizontalForm (ColSm 0) (ColSm 2) (ColSm 0) (ColSm 10)) $ UserForm
    <$> areq textField nameField Nothing -- Text input field
    -- Form submit button
    <*  bootstrapSubmit (BootstrapSubmit ("Start chatting" :: Text) "btn btn-primary" [])
    where nameField = withPlaceholder "Type your user name" $ -- Placeholder
                      bfs ("Name" :: Text) -- class="form-control"
