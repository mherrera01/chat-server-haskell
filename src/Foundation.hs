{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RecordWildCards #-}

module Foundation where

import Control.Concurrent.STM
import Control.Monad (forever)
import Data.Monoid ((<>))
import Data.Default
import qualified Data.Map as Map
import Data.Map (Map)
import Conduit
import Text.Hamlet
import Yesod
import Yesod.Static
import Yesod.WebSockets
import Yesod.Default.Util

import Settings.Config
import Settings.StaticFiles -- StaicR route references
import Client

data ChatServer = ChatServer
    { getConfig :: ChatServerConfig
    , getStatic :: Static
    -- Map of name as key and user data
    , users :: TVar (Map UserName User)
    -- A write-only broadcast channel for the global chat messages
    , globalChatChannel :: TChan Message
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

-- Gets the user, if possible, given its name
getUser :: ChatServer -> UserName -> Handler (Maybe User)
getUser ChatServer{..} userName = liftIO . atomically $ do
    usersMap <- readTVar users
    -- Looks up the user name in the server list
    return $ Map.lookup userName usersMap

-- Adds a new user to the global chat given a name not already
-- in use. If the user could be added, it returns true and the
-- other users are notified by the server.
addUser :: ChatServer -> UserName -> Handler Bool
addUser ChatServer{..} userName = liftIO . atomically $ do
    usersMap <- readTVar users
    -- Checks if the user name is already chosen
    if Map.member userName usersMap
        then return False
        else do
            user <- newUser userName globalChatChannel -- Create new user
            writeTVar users $ Map.insert userName user usersMap -- Add user to the server list
            writeTChan globalChatChannel $ userName <> " has connected"
            return True

-- Opens a web sockets connection with a user client for
-- displaying the global chat messages.
createWSConn :: ChatServer -> User -> Handler ()
createWSConn cs usr =  webSockets $ globalChatWS cs usr

globalChatWS :: ChatServer -> User -> WebSocketsT Handler ()
globalChatWS ChatServer{..} User{..} = do
    -- Runs two actions concurrently and return when one has finished
    race_
        -- Waits for reading messages through the channel and sends them
        -- to the web sockets connection. Therefore, the chat messages will
        -- be updated for all the clients without refreshing the web page.
        (forever $ do
            msg <- liftIO . atomically $ readTChan userChan
            sendTextData msg)

        -- Writes in the channel the messages received through the web sockets
        -- connection. They will be seen by all the other clients.
        (sourceWS $$ mapM_C (\msg ->
            liftIO . atomically $ writeTChan globalChatChannel $ userName <> ": " <> msg))

    -- Web sockets connection closed
    liftIO . atomically $ writeTChan globalChatChannel $ userName <> " has left the chat"
