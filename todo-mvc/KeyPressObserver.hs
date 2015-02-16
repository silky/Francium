{-# LANGUAGE TypeFamilies #-}

module KeyPressObserver where

import Francium
import Francium.Component
import Francium.HTML hiding (a, html)

data KeyPressObserver a t =
  KeyPressObserver (a t)

instance Component a => Component (KeyPressObserver a) where
  data Output b e
       (KeyPressObserver a) = KeyPressObserverOut{keyPressed :: e Int,
                                                  passThrough :: Output b e a}
  construct (KeyPressObserver a) =
    do inner <- construct a
       keyPressEv <- newDOMEvent
       return Instantiation {render =
                               fmap (\html ->
                                       with html (onKeyPress keyPressEv) [])
                                    (render inner)
                            ,outputs =
                               KeyPressObserverOut (domEvent keyPressEv)
                                                   (outputs inner)}
