{-# LANGUAGE TemplateHaskell #-}

module Settings.StaticFiles where

import Yesod.Static (staticFiles)

-- Generates routes for all the static files in the static/ folder
-- during compilation. The dots, dashes and slashes are replaced by
-- underscores, so that the resource is accesed as follows:
-- css/bootstrap.css -> css_bootstrap_css
staticFiles "static/"
