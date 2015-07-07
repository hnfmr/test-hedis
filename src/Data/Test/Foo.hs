{-# LANGUAGE BangPatterns, DeriveDataTypeable, FlexibleInstances, MultiParamTypeClasses #-}
{-# OPTIONS_GHC -fno-warn-unused-imports #-}
module Data.Test.Foo (Foo(..)) where
import Prelude ((+), (/))
import qualified Prelude as Prelude'
import qualified Data.Typeable as Prelude'
import qualified Data.Data as Prelude'
import qualified Text.ProtocolBuffers.Header as P'
import qualified Data.Test.Bar as Test (Bar)
 
data Foo = Foo{bar :: !(Test.Bar), quux :: !(P'.Maybe P'.Bool), baz :: !(P'.Maybe P'.Int32), booz :: !(P'.Seq P'.Utf8)}
         deriving (Prelude'.Show, Prelude'.Eq, Prelude'.Ord, Prelude'.Typeable, Prelude'.Data)
 
instance P'.Mergeable Foo where
  mergeAppend (Foo x'1 x'2 x'3 x'4) (Foo y'1 y'2 y'3 y'4)
   = Foo (P'.mergeAppend x'1 y'1) (P'.mergeAppend x'2 y'2) (P'.mergeAppend x'3 y'3) (P'.mergeAppend x'4 y'4)
 
instance P'.Default Foo where
  defaultValue = Foo P'.defaultValue P'.defaultValue P'.defaultValue P'.defaultValue
 
instance P'.Wire Foo where
  wireSize ft' self'@(Foo x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> calc'Size
       11 -> P'.prependMessageSize calc'Size
       _ -> P'.wireSizeErr ft' self'
    where
        calc'Size = (P'.wireSizeReq 1 11 x'1 + P'.wireSizeOpt 1 8 x'2 + P'.wireSizeOpt 1 5 x'3 + P'.wireSizeRep 1 9 x'4)
  wirePut ft' self'@(Foo x'1 x'2 x'3 x'4)
   = case ft' of
       10 -> put'Fields
       11 -> do
               P'.putSize (P'.wireSize 10 self')
               put'Fields
       _ -> P'.wirePutErr ft' self'
    where
        put'Fields
         = do
             P'.wirePutReq 10 11 x'1
             P'.wirePutOpt 16 8 x'2
             P'.wirePutOpt 24 5 x'3
             P'.wirePutRep 34 9 x'4
  wireGet ft'
   = case ft' of
       10 -> P'.getBareMessageWith update'Self
       11 -> P'.getMessageWith update'Self
       _ -> P'.wireGetErr ft'
    where
        update'Self wire'Tag old'Self
         = case wire'Tag of
             10 -> Prelude'.fmap (\ !new'Field -> old'Self{bar = P'.mergeAppend (bar old'Self) (new'Field)}) (P'.wireGet 11)
             16 -> Prelude'.fmap (\ !new'Field -> old'Self{quux = Prelude'.Just new'Field}) (P'.wireGet 8)
             24 -> Prelude'.fmap (\ !new'Field -> old'Self{baz = Prelude'.Just new'Field}) (P'.wireGet 5)
             34 -> Prelude'.fmap (\ !new'Field -> old'Self{booz = P'.append (booz old'Self) new'Field}) (P'.wireGet 9)
             _ -> let (field'Number, wire'Type) = P'.splitWireTag wire'Tag in P'.unknown field'Number wire'Type old'Self
 
instance P'.MessageAPI msg' (msg' -> Foo) Foo where
  getVal m' f' = f' m'
 
instance P'.GPB Foo
 
instance P'.ReflectDescriptor Foo where
  getMessageInfo _ = P'.GetMessageInfo (P'.fromDistinctAscList [10]) (P'.fromDistinctAscList [10, 16, 24, 34])
  reflectDescriptorInfo _
   = Prelude'.read
      "DescriptorInfo {descName = ProtoName {protobufName = FIName \".Test.Foo\", haskellPrefix = [MName \"Data\"], parentModule = [MName \"Test\"], baseName = MName \"Foo\"}, descFilePath = [\"Data\",\"Test\",\"Foo.hs\"], isGroup = False, fields = fromList [FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Test.Foo.bar\", haskellPrefix' = [MName \"Data\"], parentModule' = [MName \"Test\",MName \"Foo\"], baseName' = FName \"bar\"}, fieldNumber = FieldId {getFieldId = 1}, wireTag = WireTag {getWireTag = 10}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = True, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 11}, typeName = Just (ProtoName {protobufName = FIName \".Test.Bar\", haskellPrefix = [MName \"Data\"], parentModule = [MName \"Test\"], baseName = MName \"Bar\"}), hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Test.Foo.quux\", haskellPrefix' = [MName \"Data\"], parentModule' = [MName \"Test\",MName \"Foo\"], baseName' = FName \"quux\"}, fieldNumber = FieldId {getFieldId = 2}, wireTag = WireTag {getWireTag = 16}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 8}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Test.Foo.baz\", haskellPrefix' = [MName \"Data\"], parentModule' = [MName \"Test\",MName \"Foo\"], baseName' = FName \"baz\"}, fieldNumber = FieldId {getFieldId = 3}, wireTag = WireTag {getWireTag = 24}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = False, mightPack = False, typeCode = FieldType {getFieldType = 5}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing},FieldInfo {fieldName = ProtoFName {protobufName' = FIName \".Test.Foo.booz\", haskellPrefix' = [MName \"Data\"], parentModule' = [MName \"Test\",MName \"Foo\"], baseName' = FName \"booz\"}, fieldNumber = FieldId {getFieldId = 4}, wireTag = WireTag {getWireTag = 34}, packedTag = Nothing, wireTagLength = 1, isPacked = False, isRequired = False, canRepeat = True, mightPack = False, typeCode = FieldType {getFieldType = 9}, typeName = Nothing, hsRawDefault = Nothing, hsDefault = Nothing}], keys = fromList [], extRanges = [], knownKeys = fromList [], storeUnknown = False, lazyFields = False}"
 
instance P'.TextType Foo where
  tellT = P'.tellSubMessage
  getT = P'.getSubMessage
 
instance P'.TextMsg Foo where
  textPut msg
   = do
       P'.tellT "bar" (bar msg)
       P'.tellT "quux" (quux msg)
       P'.tellT "baz" (baz msg)
       P'.tellT "booz" (booz msg)
  textGet
   = do
       mods <- P'.sepEndBy (P'.choice [parse'bar, parse'quux, parse'baz, parse'booz]) P'.spaces
       Prelude'.return (Prelude'.foldl (\ v f -> f v) P'.defaultValue mods)
    where
        parse'bar
         = P'.try
            (do
               v <- P'.getT "bar"
               Prelude'.return (\ o -> o{bar = v}))
        parse'quux
         = P'.try
            (do
               v <- P'.getT "quux"
               Prelude'.return (\ o -> o{quux = v}))
        parse'baz
         = P'.try
            (do
               v <- P'.getT "baz"
               Prelude'.return (\ o -> o{baz = v}))
        parse'booz
         = P'.try
            (do
               v <- P'.getT "booz"
               Prelude'.return (\ o -> o{booz = P'.append (booz o) v}))