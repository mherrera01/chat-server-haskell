{-# LANGUAGE TemplateHaskell #-}

-- This file needs to be recompiled when the static files
-- are changed or new ones are added. Otherwise, they cannot
-- be accessed by their references or their contents would
-- be outdated.
-- $> stack clean
-- $> stack build
module Settings.StaticFiles where

import Yesod.Static (staticFiles)
import Settings.Config (appStaticDir, compileChatServerConfig)

-- Generates routes, during compilation, for all the static files
-- in the folder defined by the configuration variable static-dir
-- (by default static/). The dots, dashes and slashes are replaced by
-- underscores, so that the resource is accesed as follows:
-- css/bootstrap.css -> css_bootstrap_css
staticFiles $ appStaticDir compileChatServerConfig
