{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeFamilies #-}

module NewItemAdder (NewItemAdder(..), addItem) where

import Clay as CSS hiding (render, style)
import Control.Lens ((?=), (.=), at)
import Control.Monad.Trans.State.Strict (execState)
import Francium
import Francium.Component
import Francium.HTML (attrs, style)
import GHCJS.Types
import KeyPressObserver
import Prelude hiding (div, span)
import Reactive.Banana
import TextInput

-- | The 'NewItemAdder' component allows users to add new items to their to-do
-- list. Visually, it appears as an <input> box, and fires the 'addItem' event
-- when the user presses the return key on their keyboard.
data NewItemAdder t =
  NewItemAdder

instance Component NewItemAdder where
  data Output behavior event NewItemAdder = NewItemOutput{addItem ::
                                                        event JSString}
  construct NewItemAdder =
    mdo -- Pressing return should clear the input field, allowing the user to
        -- add another to-do item.
        let clearOnReturn =
              fmap (const (const "")) complete
        -- Construct an input field component, and transform this component
        -- with the 'KeyPressObserver' component transformer.
        inputComponent <-
          construct (KeyPressObserver
                       (TextInput {initialText = ""
                                  ,updateText = clearOnReturn}))
        let itemValue =
              TextInput.value (passThrough (outputs inputComponent))
            returnKeyCode = 13
            complete =
              filterE (== returnKeyCode) (keyPressed (outputs inputComponent))
        return Instantiation {render =
                                fmap (execState inputAttributes)
                                     (render inputComponent)
                             ,outputs =
                                NewItemOutput {addItem = itemValue <@ complete}}
    where inputAttributes =
            do style .=
                 (do boxSizing borderBox
                     insetBoxShadow inset (px 0) (px (-2)) (px 1) (rgba 0 0 0 7)
                     borderStyle none
                     padding (px 15) (px 15) (px 15) (px 60)
                     outlineStyle none
                     lineHeight (em 1.5)
                     fontSize (px 24)
                     width (pct 100)
                     margin (px 0) (px 0) (px 0) (px 0)
                     position relative
                     backgroundColor (rgba 0 0 0 0))
               attrs .
                 at "placeholder" ?=
                 "What needs to be done?"
               attrs .
                 at "autofocus" ?=
                 ""
