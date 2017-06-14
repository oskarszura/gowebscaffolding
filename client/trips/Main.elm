port module Trips.Main exposing (..)

import Navigation exposing (Location)
import Array exposing (get, fromList)
import Trips.Model exposing (..)
import Trips.Routing exposing (parseLocation)
import Trips.View exposing (view)
import Trips.Messages exposing (..)
import Trips.Subscriptions exposing (..)
import Trips.Commands exposing (postTrip, fetchTrips, deleteTrip, postPlace, fetchPlaces, deletePlace)

import Debug exposing (..)

init : Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute =
      parseLocation location
  in
    case currentRoute of
      TripsRoute ->
        (initModel currentRoute, fetchTrips)

      TripRoute id ->
        (initModel currentRoute, fetchTrips)

      NotFoundRoute ->
        (initModel currentRoute, fetchTrips)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        case newRoute of
          TripsRoute ->
            ({
              model
              | route = newRoute
            }
            , Cmd.none )

          TripRoute id ->
            let
              trip =
                get (id - 1) (fromList model.trips)
            in
              case trip of
                Just trp ->
                  ({
                    model
                    | route = newRoute
                    , places = trp.places
                  }
                  , Cmd.none )
                Nothing ->
                  ({
                    model
                    | route = newRoute
                  }
                  , Cmd.none )

          NotFoundRoute ->
            ({
              model
              | route = newRoute
            }
            , Cmd.none )

    ChangeTripName newName ->
      ({
        model
        | tripName = newName
      }
      , Cmd.none)

    ChangePlaceName newName ->
      ({
        model
        | placeName = newName
      }
      , Cmd.none)

    ChangePlaceDescription description ->
      ({
        model
        | placeDescription = description
      }
      , Cmd.none)

    AddTrip ->
      let
        tripId =
          toString (List.length model.trips + 1)
        newTrip =
          { name = model.tripName
          , id = tripId
          , places = []}
      in
      ({
        model
        | trips = List.append model.trips [newTrip]
        , tripName = ""
      }
      , postTrip newTrip )

    RemoveTrip id ->
      let
        updatedTrips =
          List.filter (\t -> t.id == id) model.trips
      in
        ({
          model
          | trips = updatedTrips
        }
        , deleteTrip id )

    OnInsertTrip (Ok insertedTrip) ->
        ( model, Cmd.none )

    OnInsertTrip (Err error) ->
        ( model, Cmd.none )

    OnRemoveTrip (Ok removedTrip) ->
        ( model, Cmd.none )

    OnRemoveTrip (Err error) ->
        ( model, Cmd.none )

    OnFetchAllTrips (Ok fetchedTrips) ->
        case model.route of
          TripsRoute ->
            ({
              model
              | trips = fetchedTrips
            }
            , Cmd.none )

          TripRoute id ->
            let
              trip =
                get (id - 1) (fromList fetchedTrips)
            in
              case trip of
                Just trp ->
                  ({
                    model
                    | trips = fetchedTrips
                    , places = trp.places
                  }
                  , Cmd.none )
                Nothing ->
                    ({
                      model
                      | trips = fetchedTrips
                    }
                    , Cmd.none )

          NotFoundRoute ->
            ({
              model
              | trips = fetchedTrips
            }
            , Cmd.none )

    OnFetchAllTrips (Err error) ->
        ( model, Cmd.none )

    AddPlace tripId ->
        let
            newPlace =
              { name = model.placeName
              , id = ""
              , tripId = tripId
              , description = model.placeDescription
              , order =  List.length model.places }
        in
            ( model, postPlace newPlace )

    OnInsertPlace (Ok insertedPlace) ->
      let
        newPlace =
          { name = insertedPlace.name
          , id = insertedPlace.id
          , tripId = insertedPlace.tripId
          , description = insertedPlace.description
          , order = insertedPlace.order }
      in
        ({
          model
          | places = List.append model.places [newPlace]
          , placeName = ""
          , placeDescription = ""
        }
        , Cmd.none )

    OnInsertPlace (Err error) ->
        ( model, Cmd.none )

    RemovePlace id ->
      ( model, deletePlace id )

    OnRemovePlace placeId (Ok removedPlace) ->
      let
        updatedPlaces =
          List.filter (\t -> t.id /= placeId) model.places
      in
        ({
          model
          | places = updatedPlaces
        }
        , Cmd.none )

    OnRemovePlace placeId (Err error) ->
        ( model, Cmd.none )

    OnFetchAllPlaces (Ok fetchedPlaces) ->
        ({
          model
          | places = fetchedPlaces
        }
        , Cmd.none )

    OnFetchAllPlaces (Err error) ->
        ( model, Cmd.none )

    MouseMsg position ->
        ( {
            model
            | mousex = position.x
            , mousey = position.y
        }
        , Cmd.none )

    MouseDragEnd position ->
        ( {
            model
            | drag = ""
        }
        , Cmd.none )

    MouseDragStart placeId ->
        ( {
            model
            | drag = placeId
        }
        , Cmd.none )

    SwapPlace placeId ->
        if model.drag /= "" then
            let
                draggedPlace =
                    case List.head (List.filter (\t -> t.id == model.drag) model.places) of
                        Just y -> y
                        Nothing -> Debug.crash "error: fromJust Nothing"
                hoveredPlace =
                    case List.head (List.filter (\t -> t.id == placeId) model.places) of
                        Just y -> y
                        Nothing -> Debug.crash "error: fromJust Nothing"
                sortedPlaces =
                    model.places
                    |> List.map (\place -> if place.order >= hoveredPlace.order then { place | order = place.order + 1 } else place)
                    |> List.map (\place -> if place.id == draggedPlace.id then { place | order = hoveredPlace.order } else place)
            in
                    ( { model | places = sortedPlaces } , Cmd.none )
        else
            ( model, Cmd.none )

    NoOp ->
        ( model, Cmd.none )


main : Program Never Model Msg
main =
  Navigation.program OnLocationChange
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- Utils
getListElementByString : List a -> String -> Maybe a
getListElementByString list id =
    let
        elementId =
            Result.withDefault 0 (String.toInt id)
        element =
            get elementId (fromList list)
    in
        element
