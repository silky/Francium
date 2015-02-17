{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE OverloadedStrings #-}

import ToDoList
import ClearCompleted
import Control.Lens ((?=), (%=), at)
import Control.Monad
import Control.Monad.Trans.State.Strict (execState)
import Francium
import Francium.Component
import Francium.HTML hiding (map)
import NewItemAdder
import Prelude hiding (div, span)
import StateFilter
import ToDoItem
import ToggleAll
import Francium.CSS

main :: IO ()
main =
  react (mdo itemAdder <- construct NewItemAdder
             stateFilter <- construct StateFilter
             clearCompleted <-
               construct ClearCompleted
             toggleAll <-
               construct (ToggleAll (allItems (outputs toDoList)))
             toDoList <-
               construct (ToDoList {ToDoList.addItem =
                                      NewItemAdder.addItem (outputs itemAdder)
                                   ,ToDoList.clearCompleted =
                                      ClearCompleted.clearCompleted (outputs clearCompleted)
                                   ,statusFilter =
                                      StateFilter.stateFilterF (outputs stateFilter)
                                   ,setStatuses =
                                      toggleUpdate (outputs toggleAll)})
             let openItemCount =
                   fmap (length .
                         filter (== Incomplete))
                        (allItems (outputs toDoList))
             return (fmap appView
                          (TodoApp <$> render itemAdder <*> render toDoList <*>
                           fmap (not . null)
                                (allItems (outputs toDoList)) <*>
                           render stateFilter <*>
                           openItemCount <*>
                           render clearCompleted <*>
                           render toggleAll)))

mainContainer :: HTML
mainContainer =
  with div
       (attrs .
        at "style" ?=
        "padding: 0px; margin: 0px auto; font-weight: 300; -webkit-font-smoothing: antialiased; max-width: 550px; min-width: 230px; color: rgb(77, 77, 77); line-height: 1.4em; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; font-size: 14px; font-stretch: normal; font-variant: normal; font-style: normal; background-color: rgb(245, 245, 245);")
       []

pageTitle :: HTML
pageTitle =
  with h1
       (do attrs .
             at "style" ?=
             "text-rendering: optimizelegibility; color: rgba(175, 47, 47, 0.14902); text-align: center; font-weight: 100; font-size: 100px; width: 100%; top: -155px; position: absolute;")
       ["todos"]

toDoSummary :: Int -> HTML -> HTML -> HTML
toDoSummary n stateFilter clearCompletedButton =
  with footer
       (do attrs .
             at "style" ?=
             "border-top-color: rgb(230, 230, 230); border-top-style: solid; border-top-width: 1px; text-align: center; height: 20px; padding: 10px 15px; color: rgb(119, 119, 119);")
       [with div
             (attrs .
              at "style" ?=
              "content: ''; position: absolute; right: 0; bottom: 0; left: 0; height: 50px; overflow: hidden; box-shadow: 0 1px 1px rgba(0, 0, 0, 0.2), 0 8px 0 -3px #f6f6f6, 0 9px 1px -3px rgba(0, 0, 0, 0.2), 0 16px 0 -6px #f6f6f6, 0 17px 2px -6px rgba(0, 0, 0, 0.2);")
             []
       ,with span
             (do attrs .
                   at "style" ?=
                   "text-align: left; float: left;")
             [with strong
                   (do attrs .
                         at "style" ?=
                         "font-weight: 300;")
                   [text (show n)]
             ," "
             ,if n == 1
                 then "item"
                 else "items"
             ," left"]
       ,stateFilter
       ,clearCompletedButton
       ,with button
             (do attrs .
                   at "style" ?=
                   "-webkit-font-smoothing: antialiased; -webkit-appearance: none; vertical-align: baseline; font-size: 100%; border-width: 0px; padding: 0px; margin: 0px; outline-style: none; position: relative; visibility: hidden; cursor: pointer; text-decoration-line: none; line-height: 20px; float: right; background-image: none;")
             []]

pageFooter :: HTML
pageFooter =
  with footer
       (do attrs .
             at "style" ?=
             "text-align: center; text-shadow: rgba(255, 255, 255, 0.498039) 0px 1px 0px; font-size: 10px; color: rgb(191, 191, 191); margin: 65px auto 0px;")
       [with p
             (do attrs .
                   at "style" ?=
                   "line-height: 1;")
             ["Double-click to edit a todo"]
       ,with p
             (do attrs .
                   at "style" ?=
                   "line-height: 1;")
             ["Template by "
             ,with a
                   (do attrs .
                         at "style" ?=
                         "font-weight: 400; text-decoration-line: none;"
                       attrs .
                         at "href" ?=
                         "http://sindresorhus.com")
                   ["Sindre Sorhus"]]
       ,with p
             (do attrs .
                   at "style" ?=
                   "line-height: 1;")
             ["Created by "
             ,with a
                   (do attrs .
                         at "style" ?=
                         "font-weight: 400; text-decoration-line: none;"
                       attrs .
                         at "href" ?=
                         "http://todomvc.com")
                   ["you"]]
       ,with p
             (do attrs .
                   at "style" ?=
                   "line-height: 1;")
             ["Part of "
             ,with a
                   (do attrs .
                         at "style" ?=
                         "font-weight: 400; text-decoration-line: none;"
                       attrs .
                         at "href" ?=
                         "http://todomvc.com")
                   ["TodoMVC"]]]

data TodoApp =
  TodoApp {taAddANewItem :: HTML
          ,taToDoList :: HTML
          ,taHasItems :: Bool
          ,taStateFilter :: HTML
          ,taOpenItemCount :: Int
          ,taClearCompleted :: HTML
          ,taToggleAll :: HTML}

appView :: TodoApp -> HTML
appView components =
  into mainContainer
       [with section
             (style %=
              execState (do boxShadows [(px 0,px 2,px 4,px 0,rgba 0 0 0 51)]
                            position relative
                            margin (px 130)
                                   (px 0)
                                   (px 40)
                                   (px 0)
                            backgroundColor (rgb 255 255 255)))
             (into header [pageTitle,taAddANewItem components] :
              case taHasItems components of
                False -> []
                True ->
                  [with section
                        (style %=
                         execState (do borderTop solid
                                                 (px 1)
                                                 (rgb 230 230 230)
                                       zIndex 2
                                       position relative))
                        [taToggleAll components
                        ,with label
                              (do style %=
                                    execState (display none)
                                  attrs .
                                    at "for" ?=
                                    "toggle-all")
                              ["Mark all as complete"]
                        ,taToDoList components]
                  ,toDoSummary (taOpenItemCount components)
                               (taStateFilter components)
                               (taClearCompleted components)])
       ,pageFooter]
