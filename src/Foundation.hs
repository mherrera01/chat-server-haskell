{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Foundation where

import Data.Text (Text)
import Yesod
import Yesod.Static

data ChatServer = ChatServer
    { getStatic :: Static
    , welcomeMsg :: Text
    }

-- ChatServer is an instance of Yesod, so the data will
-- be accesed using the getYesod function.
instance Yesod ChatServer where
    -- Stores session data on the client in encrypted cookies
    makeSessionBackend _ = Just <$> defaultClientSessionBackend
        120 -- timeout in minutes
        "config/client_session_key.aes"

mkYesodData "ChatServer" $(parseRoutesFile "config/routes")
