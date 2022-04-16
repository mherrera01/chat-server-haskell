{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}

module Foundation where

import Control.Concurrent.STM
import Data.Monoid ((<>))
import Data.Default
import qualified Data.Map as Map
import Data.Map (Map)
import Text.Hamlet
import Yesod
import Yesod.Static
import Yesod.Default.Util

import Settings.Config
import Settings.StaticFiles -- StaicR route references
import Client

data ChatServer = ChatServer
    { getConfig :: ChatServerConfig
    , getStatic :: Static
    , users :: TVar (Map UserName User) -- Map of name as key and user data
    }

mkYesodData "ChatServer" $(parseRoutesFile "config/routes.yesodroutes")

-- ChatServer is an instance of Yesod, so the data will
-- be accesed using the getYesod function.
instance Yesod ChatServer where
    -- Gets the application root from the configuration settings
    approot = ApprootMaster $ appRoot . getConfig

    -- Stores session data on the client in encrypted cookies
    makeSessionBackend _ = Just <$> defaultClientSessionBackend
        120 -- Timeout in minutes
        "config/client_session_key.aes"

    -- The two hamlet files in templates/default define the default
    -- layout. The contents of the body tag are in default-layout and
    -- the entire page in default-layout-wrapper.
    defaultLayout widget = do
        pc <- widgetToPageContent $ do
            -- The css styling used is the Flatly theme for Bootstrap. It
            -- is applied to all the default layouts.
            -- Check https://bootswatch.com/3/
            addStylesheet $ StaticR css_bootstrap_min_css

            -- Jquery 3.6.0 needed for the Bootstrap javascript.
            -- Check https://jquery.com/
            addScript $ StaticR js_jquery_3_6_0_min_js

            -- Javascript Bootstrap 3.4.1 used.
            -- Check https://getbootstrap.com/docs/3.4/
            addScript $ StaticR js_bootstrap_min_js

            $(widgetFileNoReload def "default/default-layout") -- Add the widget parameter
        withUrlRenderer $(hamletFile "templates/default/default-layout-wrapper.hamlet")

-- Allows HTML forms
instance RenderMessage ChatServer FormMessage where
    renderMessage _ _ = defaultFormMessage

-- Server foundation functions

notifyMessage :: ChatServer -> Message -> STM ()
notifyMessage ChatServer{..} msg = do
    usersMap <- readTVar users
    mapM_ (`sendMessage` msg) (Map.elems usersMap)

-- Adds a new user to the global chat given a name not already
-- in use. The other users are notified by the server.
addUser :: ChatServer -> UserName -> Handler (Maybe User)
addUser cs@ChatServer{..} userName = liftIO . atomically $ do
    usersMap <- readTVar users
    -- Check if the user name is already chosen
    if Map.member userName usersMap
        then return Nothing
        else do
            user <- newUser userName -- Create new user
            writeTVar users $ Map.insert userName user usersMap -- Add user to the server list
            notifyMessage cs $ ServerMessage (userName <> " has connected")
            return (Just user)
