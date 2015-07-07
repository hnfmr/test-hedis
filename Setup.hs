import Distribution.Simple
import System.Process

main = defaultMainWithHooks hooks
  where hooks = simpleUserHooks { preBuild = preBuild' }

preBuild' a b = do
                  callCommand "hprotoc --as test.proto=Data -I ./src/ -d ./src/ test.proto"
                  preBuild simpleUserHooks a b
