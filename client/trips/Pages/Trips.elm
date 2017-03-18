module Trips.Pages.Trips exposing (..)

import Html exposing (Html, div, ul, li, a, button, input, text)
import Html.Attributes exposing (class, value, href)
import Html.Events exposing (onClick, onInput)
import Trips.Messages exposing (..)
import Trips.Model exposing (..)

tripsPage : Model -> Html Msg
tripsPage model =
  div [ class "trips"]
    [ model.trips
      |> List.map (\l ->
        let
          tripUrl =
            "#/trips/" ++ l.id
        in
          li
            [ class "trips__list-item" ]
            [ a [ href tripUrl ] [ text l.name ] ]
       )
      |> ul [ class "trips__list" ]

    , div
        [ class "trips__adder" ]
        [ input [
            class "trips__name"
          , onInput ChangeTripName
          , value model.tripName ] []
        , div
            [ class "trips__actions" ]
            [ button [
                class "trips__add"
              , onClick AddTrip ]
              [ text "Add trip" ]
            ]
        ]
    ]