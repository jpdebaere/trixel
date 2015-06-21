module Trixel.PostOffice where

import Trixel.Types.General exposing (..)

import Signal exposing (..)
import Keyboard
import Mouse

import Debug


moveOffsetSignal : Signal PostOfficeAction
moveOffsetSignal =
  Signal.map
    (\{x, y} ->
      PostAction (MoveOffset { x = toFloat x, y = toFloat y }))
    Keyboard.arrows


moveMouseSignal : Signal PostOfficeAction
moveMouseSignal =
  Signal.map
    (\(x, y) ->
      PostAction (MoveMouse { x = toFloat x, y = toFloat y }))
    Mouse.position


postOfficeTrashQuery : Mailbox TrixelAction
postOfficeTrashQuery = mailbox None


postOfficeQuery : Mailbox PostOfficeAction
postOfficeQuery = mailbox PostNoAction


handlePostedAction : PostOfficeAction -> PostOfficeState -> TrixelAction
handlePostedAction action state =
  case action of
    PostAction trixelAction ->
      SwitchAction
        { active = state.active
        , action = trixelAction
        }

    PostCondition condition ->
      SwitchAction
        { active = condition /= IdleCondition
        , action = SetCondition condition
        }

    PostNoAction ->
      SwitchAction state


workspacePostOffice : PostOfficeAction -> TrixelAction -> TrixelAction
workspacePostOffice action cachedAction =
  case cachedAction of
    SwitchAction state ->
      handlePostedAction action state

    _ ->
      cachedAction


workspaceSignals : Signal TrixelAction
workspaceSignals =
  mergeMany
    [ postOfficeQuery.signal
    , moveOffsetSignal
    , moveMouseSignal
    ]
  |> Signal.foldp workspacePostOffice
      (SwitchAction { active = False, action = None })


filterPostOfficeSignal : TrixelAction -> Bool
filterPostOfficeSignal trixelAction =
  case trixelAction of
    SwitchAction state ->
      (case state.action of
         SetCondition condition ->
           True

         _ ->
          state.active)

    _ ->
      True

postOfficeSignal : Signal TrixelAction
postOfficeSignal =
  filter
    filterPostOfficeSignal
    None
    workspaceSignals


-- Different actions for the workspace 'post-office'
type PostOfficeAction
  = PostNoAction
  | PostAction TrixelAction
  | PostCondition Condition