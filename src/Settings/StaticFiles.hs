{-# LANGUAGE TemplateHaskell #-}

-- This file needs to be compiled before stack build when the static
-- files are changed.
-- $> stack install yesod-bin (If not installed yet)
-- $> yesod touch Settings/StaticFiles.hs
module Settings.StaticFiles where

import Yesod.Static (staticFiles)

-- Generates routes for all the static files in the static/ folder
-- during compilation. The dots, dashes and slashes are replaced by
-- underscores, so that the resource is accesed as follows:
-- css/bootstrap.css -> css_bootstrap_css
staticFiles "static/"
