{-# LANGUAGE RecordWildCards #-}

module Client where

import Control.Concurrent.STM
import Data.Text (Text)

type UserName = Text

type Message = Text

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
