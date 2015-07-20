module Trixel.Views.Menu (view) where

import Trixel.Math.Vector as TrVector
import Trixel.Types.State as TrState
import Trixel.Models.Model as TrModel
import Trixel.Models.Work as TrWork
import Trixel.Models.Work.Actions as TrWorkActions

import Trixel.Graphics as TrGraphics
import Graphics.Element as Element
import Graphics.Input as Input

import Signal

import Material.Icons.Action as ActionIcons
import Material.Icons.Content as ContentIcons
import Material.Icons.File as FileIcons

import Html
import Html.Attributes as Attributes


viewLogo : TrVector.Vector -> Element.Element
viewLogo { y } =
  let dimensions =
        TrVector.construct y y
  in
    TrGraphics.image
      (TrVector.scale 0.8 dimensions)
      (TrVector.construct
        (dimensions.x * 0.2)
        (dimensions.y * 0.1)
      )
      "assets/logo.svg"
    |> TrGraphics.hoverable "Return back to your workspace."
    |> Input.clickable
        (Signal.message TrWork.address
          (TrWorkActions.SetState TrState.Default))


viewSvgButton render label help selected showLabel size model address action =
  TrGraphics.svgButton
    render
    (if showLabel then label else "")
    help
    selected
    size
    model.colorScheme.primary.accentHigh
    model.colorScheme.selection.accentHigh
    model.colorScheme.primary.main.fill
    model.colorScheme.selection.main.fill
    address
    action


makeFlowRelative : Element.Element -> Element.Element
makeFlowRelative flowElement =
  Html.div
    [ Attributes.class "tr-force-position-relative" ]
    [ Html.fromElement flowElement ]
  |> Html.toElement -1 -1


viewLeftMenu : TrVector.Vector -> Bool -> TrModel.Model -> Element.Element
viewLeftMenu dimensions showLabels model =
  let size =
        dimensions.y * 0.95
  in
    Element.flow
      Element.right
      [ viewLogo dimensions
      , viewSvgButton
          ContentIcons.create "New" "Create a new document."
          (model.work.state == TrState.New)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.New)
      , viewSvgButton
          FileIcons.folder_open "Open" "Open an existing document."
          (model.work.state == TrState.Open)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.Open)
      , viewSvgButton
          ContentIcons.save "Save" "Save current document."
          (model.work.state == TrState.Save)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.Save)
      ]
    |> Element.container -1 (round dimensions.y) Element.topLeft
    |> makeFlowRelative


viewRightMenu : TrVector.Vector -> Bool -> TrModel.Model -> Element.Element
viewRightMenu dimensions showLabels model =
  let size =
        dimensions.y * 0.95
  in
    Element.flow
      Element.left
      [ viewSvgButton
          ActionIcons.info_outline "About" "Information regarding this editor."
          (model.work.state == TrState.About)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.About)
      , viewSvgButton
          ActionIcons.help_outline "Help" "Information regarding shortcuts and other relevant content."
          (model.work.state == TrState.Help)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.Help)
      , viewSvgButton
          ActionIcons.settings "Settings" "View and modify your editor settings."
          (model.work.state == TrState.Settings)
          showLabels size model TrWork.address
          (TrWorkActions.SetState TrState.Settings)
      ]
    |> Element.container -1 (round dimensions.y) Element.topRight
    |> makeFlowRelative


makeFloat : String -> Element.Element -> Html.Html
makeFloat float element =
  Html.div
    [ Attributes.style [ ("float", float) ] ]
    [ Html.fromElement element ]


groupMenus : Element.Element -> Element.Element -> Element.Element
groupMenus leftElement rightElement =
  Html.div []
    [ makeFloat "left" leftElement
    , makeFloat "right" rightElement
    ]
  |> Html.toElement -1 -1


view : TrVector.Vector -> TrModel.Model -> Element.Element
view dimensions model =
  let leftMenuDimensions =
        TrVector.construct
          (dimensions.x * 0.4495)
          dimensions.y

      rightMenuDimensions =
        TrVector.construct
          (dimensions.x * 0.5495)
          dimensions.y

      showLabels =
        dimensions.x > 580
  in
    groupMenus
      (viewLeftMenu leftMenuDimensions showLabels model)
      (viewRightMenu rightMenuDimensions showLabels model)
    |> TrGraphics.setDimensions dimensions