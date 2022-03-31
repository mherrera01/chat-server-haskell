import Dispatch (develMain)

-- app/devel.hs file needed for yesod devel.
-- $> stack install yesod-bin (If not installed yet)
-- $> yesod devel
main :: IO ()
main = develMain
