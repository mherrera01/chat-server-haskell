{-# LANGUAGE RecordWildCards #-}

module Client where 

import Control.Concurrent.STM
import Data.Text (Text)

type UserName = Text

data Message = ServerMessage Text
             | UserMessage UserName Text

data User = User
    { userName :: UserName
    , userSendChan :: TChan Message
    }

newUser :: UserName -> STM User
newUser userName = do
    userSendChan <- newTChan
    return User{..}

sendMessage :: User -> Message -> STM ()
-- Point free of the message variable
sendMessage User{..} = writeTChan userSendChan
