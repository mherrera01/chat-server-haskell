{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}

module Client where

import Control.Concurrent.STM
import qualified Network.WebSockets as WS
import Data.Aeson
import Data.Text (Text)
import Data.Maybe (fromMaybe)

type UserName = Text

-- The message to be handled by the server and client channels.
-- It is also sent through the WebSockets connection.
data Message = Message
    { -- The type can be "user-status" (when a user connects
      -- or disconnects) or "public-msg" (a user sends a message
      -- to all the users in the chat).
      msgType :: Text
      -- The user who sends the message. It remains empty if it
      -- is a server message.
    , msgFromUser :: Text
      -- The message content
    , msgContent :: Text
    }

-- Message is an instance of ToJSON, for then be encoded
-- when the data is sent through the WebSockets connection.
-- Therefore, it can be parsed in the javascript client with
-- the JSON.parse function.
instance ToJSON Message where
    toJSON Message{..} = object
        [ "type"     .= msgType
        , "fromUser" .= msgFromUser
        , "content"  .= msgContent
        ]

-- Message is an instance of FromJSON, for then be decoded
-- when the data is received through the WebSockets connection.
-- With the JSON.stringify function, the javascript client can
-- send a message to the server.
instance FromJSON Message where
    parseJSON = withObject "Message" $ \o -> Message
        <$> o .: "type"
        <*> o .: "fromUser"
        <*> o .: "content"

-- Message must be an instance of WebSocketsData, so that
-- it can be sent and received by the WebSockets functions.
-- The JSON value needs to be expresed in bytes for its
-- broadcast through the socket.
instance WS.WebSocketsData Message where
    -- Called by WS.receiveData
    fromLazyByteString msg =
        fromMaybe (Message "" "" "") (decode msg) -- instance FromJSON

    -- Called by WS.sendTextData
    toLazyByteString = encode -- instance ToJSON

data User = User
    { userName :: UserName
    , userChan :: TChan Message
    }

newUser :: UserName -> TChan Message -> STM User
newUser userName channel = do
    -- Duplicate the broadcast channel, so that the data written
    -- to either channel will be accessible from both. Each
    -- user channel has its own read end.
    userChan <- dupTChan channel
    return User{..}
