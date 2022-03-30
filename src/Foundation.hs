{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Foundation where

import Data.Text (Text)
import Yesod

newtype ChatServer = ChatServer Text
instance Yesod ChatServer

mkYesodData "ChatServer" $(parseRoutesFile "config/routes")
