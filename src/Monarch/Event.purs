module Monarch.Event (module Monarch.Event) where

import Prelude
import Data.Maybe
import Data.HeytingAlgebra
import Data.Traversable
import Data.Tuple
import Control.Plus
import Control.Apply         ( lift2 )
import Effect
import Effect.Ref                                       as Ref
import Monarch.Monad.Maybe
import Monarch.Web.Window    ( requestTimeout
                             , cancelTimeout
                             , requestAnimationFrame
                             , cancelAnimationFrame
                             , requestIdleCallback'
                             , cancelIdleCallback
                             )
import Unsafe.Reference      ( unsafeRefEq )

type Unsubscribe
  = Effect Unit

newtype Event a
  = Event ((a -> Effect Unit) -> Effect Unsubscribe)

instance functorEvent :: Functor Event where
  map f e = Event \next -> e # subscribe (next <<< f)

instance applyEvent :: Apply Event where
  apply eF eX = Event \next -> do
    fRef <- Ref.new Nothing
    xRef <- Ref.new Nothing
    -- Subscriptions
    unsubscribeF <- eF # subscribe \f -> do
      Ref.write (Just f) fRef
      Ref.read xRef >>= traverse_ (next <<< f)
    unsubscribeX <- eX # subscribe \x -> do
      Ref.write (Just x) xRef
      Ref.read fRef >>= traverse_ (next <<< (_ $ x))
    -- Unsubscribe
    pure $ unsubscribeF *> unsubscribeX

instance applicativeEvent :: Applicative Event where
  pure x = Event \next -> next x *> (pure $ pure unit)

instance altEvent :: Alt Event where
  alt e e' = Event \next -> do
    -- Subscriptions
    unsubscribe  <- e  # subscribe next
    unsubscribe' <- e' # subscribe next
    -- Unsubscribe
    pure $ unsubscribe *> unsubscribe'

instance plusEvent :: Plus Event where
  empty = eNever

instance semigroupEvent :: Semigroup a => Semigroup (Event a) where
  append = lift2 append

instance monoidEvent :: Monoid a => Monoid (Event a) where
  mempty = pure mempty

eNever :: forall a. Event a
eNever = Event $ const mempty

scan :: forall a b. (a -> b -> b) -> b -> Event a -> Event b
scan f b e = Event \next -> do
  resultRef <- Ref.new b
  next b
  e # subscribe \x -> Ref.modify (f x) resultRef >>= next

distinctUntilChanged :: forall a. (a -> a -> Boolean) -> Event a -> Event a
distinctUntilChanged f e = Event \next -> do
  previousXRef <- Ref.new Nothing
  e # subscribe \x -> do
    isDistinct <- maybe true (not <<< f x) <$> Ref.read previousXRef
    when isDistinct (next x)
    Ref.write (Just x) previousXRef

distinctUntilRefChanged :: forall a. Event a -> Event a
distinctUntilRefChanged = distinctUntilChanged unsafeRefEq

debounce :: forall id a. (Effect Unit -> Effect id) -> (id -> Effect Unit) -> Event a -> Event a
debounce request cancel e = Event \next -> do
  requestIdRef <- Ref.new Nothing
  e # subscribe \x -> do
    cancel `whenJustM` Ref.read requestIdRef
    request (next x *> Ref.write Nothing requestIdRef) >>= flip Ref.write requestIdRef <<< Just

debounceTime :: forall a. Int -> Event a -> Event a
debounceTime n = debounce (requestTimeout n) cancelTimeout

debounceAnimationFrame :: forall a. Event a -> Event a
debounceAnimationFrame = debounce requestAnimationFrame cancelAnimationFrame

debounceIdleCallback :: forall a. Event a -> Event a
debounceIdleCallback = debounce requestIdleCallback' cancelIdleCallback

finalize :: forall a. a -> Event a
finalize x = Event \next -> pure $ next x

sampleOn :: forall a b. Event a -> Event (a -> b) -> Event b
sampleOn eX eF = Event \next -> do
  xRef <- Ref.new Nothing
  -- Subscriptions
  unsubscribeX <- eX # subscribe \x -> Ref.write (Just x) xRef
  unsubscribeF <- eF # subscribe \f ->
    Ref.read xRef >>= traverse_ (next <<< f)
  -- Unsubscribe
  pure $ unsubscribeX *> unsubscribeF

subscribe :: forall a. (a -> Effect Unit) -> Event a -> Effect Unsubscribe
subscribe f (Event e) = e f

subscribe_ :: forall a. (a -> Effect Unit) -> Event a -> Effect Unit
subscribe_ f = void <<< subscribe f

subscribe' :: Event (Effect Unit) -> Effect Unsubscribe
subscribe' = subscribe identity

subscribe'_ :: Event (Effect Unit) -> Effect Unit
subscribe'_ = void <<< subscribe'
