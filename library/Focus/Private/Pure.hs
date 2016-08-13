module Focus.Private.Pure where

import Focus.Private.Prelude hiding (adjust, update, alter, insert, delete, lookup, Const)


data Focus a b =
  Const (Decision a b) |
  Lookup (Maybe a -> Decision a b)

type Decision a b =
  (b, Instruction a)

-- |
-- What to do with the focused value.
-- 
-- The interpretation of the commands is up to the context APIs.
data Instruction a =
  Keep |
  Remove |
  Set a
  deriving (Functor)


-- * Implementations of the common patterns
-------------------------

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:adjust adjust>@.
{-# INLINE adjust #-}
adjust :: (a -> a) -> Focus a ()
adjust f =
  Lookup (maybe ((), Keep) (\a -> ((), Set (f a))))

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:update update>@.
{-# INLINE update #-}
update :: (a -> Maybe a) -> Focus a ()
update f =
  Lookup (maybe ((), Keep) (\a -> ((), maybe Remove Set (f a))))

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:alter alter>@.
{-# INLINE alter #-}
alter :: (Maybe a -> Maybe a) -> Focus a ()
alter f =
  Lookup (((),) . maybe Remove Set . f)

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:insert insert>@.
{-# INLINE insert #-}
insert :: a -> Focus a ()
insert a =
  Const ((), Set a)

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:delete delete>@.
{-# INLINE delete #-}
delete :: Focus a ()
delete =
  Const ((), Remove)

-- |
-- Reproduces the behaviour of
-- @Data.Map.<http://hackage.haskell.org/package/containers-0.5.5.1/docs/Data-Map-Lazy.html#v:lookup lookup>@.
{-# INLINE lookup #-}
lookup :: Focus a (Maybe a)
lookup =
  Lookup (\a -> (a, Keep))

