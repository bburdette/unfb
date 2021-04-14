module Main exposing (main)

import Browser
import Browser.Events
import Element as E
import Element.Font as EF
import Element.Input as EI
import Element.Region as ER
import Html exposing (Html)
import Url as U
import Url.Parser as UP
import Url.Parser.Query as UPQ


type Msg
    = OnFbUrlChanged String


type alias Model =
    { fburl : String
    }


type alias Flags =
    ()


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { fburl = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnFbUrlChanged url ->
            ( { model | fburl = url }, Cmd.none )


extractSearchArgument : String -> U.Url -> Maybe String
extractSearchArgument key location =
    { location | path = "" }
        |> UP.parse (UP.query (UPQ.string key))
        |> Maybe.withDefault Nothing


docview : Model -> Browser.Document Msg
docview model =
    { title = "unfb"
    , body = [ view model ]
    }


view : Model -> Html Msg
view model =
    E.layout [] <|
        E.column [ E.spacing 10, E.padding 10 ]
            [ EI.text []
                { onChange = OnFbUrlChanged
                , text = model.fburl
                , placeholder = Nothing
                , label = EI.labelLeft [] <| E.text "fb url:"
                }
            , U.fromString model.fburl
                |> Maybe.andThen (\u -> extractSearchArgument "u" u)
                |> Maybe.map
                    (\s ->
                        E.column [ E.spacing 10, E.padding 10 ]
                            [ E.text s
                            , U.fromString s
                                |> Maybe.map
                                    (\u ->
                                        let
                                            earl =
                                                U.toString { u | query = Nothing }
                                        in
                                        E.link
                                            [ EF.color <| E.rgb255 32 74 135
                                            , EF.underline
                                            ]
                                            { url = earl
                                            , label =
                                                E.text <| earl
                                            }
                                    )
                                |> Maybe.withDefault E.none
                            ]
                    )
                |> Maybe.withDefault E.none
            ]


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = docview
        , update = update
        , subscriptions = \_ -> Sub.none
        }
