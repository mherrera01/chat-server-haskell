{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}

module Foundation where

import Control.Concurrent.STM
import Data.Default
import Data.Text (Text)
import Text.Hamlet
import Yesod
import Yesod.Static
import Yesod.Default.Util

import Settings.StaticFiles

data ChatServer = ChatServer
    { getStatic :: Static
    , users :: TVar [Text]
    }

mkYesodData "ChatServer" $(parseRoutesFile "config/routes")

-- ChatServer is an instance of Yesod, so the data will
-- be accesed using the getYesod function.
instance Yesod ChatServer where
    -- Stores session data on the client in encrypted cookies
    makeSessionBackend _ = Just <$> defaultClientSessionBackend
        120 -- Timeout in minutes
        "config/client_session_key.aes"

    -- The two hamlet files in templates/default define the default
    -- layout. The contents of the body tag are in default-layout and
    -- the entire page in default-layout-wrapper.
    defaultLayout widget = do
        -- Gets a message in the user session. For example, after a
        -- form POST, the user can be redirected to another page along
        -- with a “Form submission complete” message.
        mmsg <- getMessage

        pc <- widgetToPageContent $ do
            -- The css styling used is the Flatly theme for Bootstrap. It
            -- is applied to all the default layouts.
            -- Check https://bootswatch.com/3/
            addStylesheet $ StaticR css_bootstrap_css
            $(widgetFileNoReload def "default/default-layout") -- Add the widget parameter
        withUrlRenderer $(hamletFile "templates/default/default-layout-wrapper.hamlet")

-- Allows HTML forms
instance RenderMessage ChatServer FormMessage where
    renderMessage _ _ = defaultFormMessage

addUser :: ChatServer -> Text -> Handler ()
addUser cs userName =
    liftIO . atomically $ modifyTVar (users cs) $ \ names -> userName : names
