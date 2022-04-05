{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE RecordWildCards #-}

module Settings.Config where

import Data.Aeson
import Data.Text (Text)
import Data.Yaml (decodeEither')
import Data.FileEmbed (embedFile)
import Control.Exception (throw)
import Yesod.Default.Config2

-- Server configuration settings
data ChatServerConfig = ChatServerConfig
    { appStaticDir :: String
    , appRoot :: Text
    , appPort :: Int
    }

-- For loading the settings from a yaml file, they need
-- to be converted from JSON.
instance FromJSON ChatServerConfig where
    -- (.:) The variable must be present.
    -- (.:?) Optional variable.
    -- (.!=) Default value for an optional variable. 
    parseJSON = withObject "ChatServerConfig" $ \o -> do
        appStaticDir <- o .:? "static-dir" .!= "static/"
        appRoot      <- o .:? "approot"    .!= "http://localhost:3000"
        appPort      <- o .:? "port"       .!= 3000

        return ChatServerConfig {..}

-- Decodes the config/settings.yml file in a JSON value for its
-- further conversion.
configSettingsYmlValue :: Value
configSettingsYmlValue = either throw id $ decodeEither' $(embedFile configSettingsYml)

-- Gets the configuration settings during compilation from the
-- config/settings.yml file.
compileChatServerConfig :: ChatServerConfig
compileChatServerConfig =
    case fromJSON $ applyEnvValue False mempty configSettingsYmlValue of
        Error e -> error e
        Success settings -> settings
