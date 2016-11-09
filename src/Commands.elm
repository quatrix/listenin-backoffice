module Commands exposing (..)

import Task
import Messages exposing (..)
import Time

getTime : Cmd Msg
getTime = 
    Task.perform assertNeverHandler GotTime Time.now

assertNeverHandler : a -> b
assertNeverHandler =
    (\_ -> Debug.crash "This should never happen")
