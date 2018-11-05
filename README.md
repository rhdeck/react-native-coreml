# react-native-coreml

Imperative library for leveraging CoreML with React Native

# Usage

```javascript
import * as RNFS from "react-native-fs"
import { compileModel, classifyTopValue } from "react-native-coreml";
(async ()=>{
    ...download file with RNFS
    const { jobid, promise } = RNFS.DownloadFile(...)
    await promise
    const modelPath = await compileModel(MLModelPath)
    const { label, confidence } = await classifyTopValue(pathToImage, modelPath)
    console.log("The image is a " + label + ". I think. ")
})();
```

# API

Exported from `react-native-coreml`. All imperative functions that return a promise. Best used with async/await.

## compileModel(pathToMLModel)

Takes a downloaded .mlmodel file and converts it to a .mlmodelc directory. The latter is always in your temporary files folder, so if you want to then put it somewhere else, recommend using `react-native-fs`.

## classifyImage(pathToImage, pathToMLModelC)

Classifies an image located on local storage with the model specified at the path. Resolves an array of all the possible classifications, most probable first.

## classifyTopFive(pathToImage, pathToMLModelC)

Same as above but only returns the top five results. Helpful for filtering out the junk for performance.

## classifyTopValue(pathToImage, pathToMLModelC)

Same as above but returns only the top result as object `{ probability, label }`.

## predict(dictionaryOfInputValues, pathToMLModelC)

Runs an arbitrary model with inputs defined in the dictionary, and returns a dictionary of the outputs, defined themselves as objects with { type, value, ...}. Note that MLMultiArray values are returned as keys to be retrieved by a different function.

## saveMultiArray(multiArrayKey, filePath)

Saves a multiarray defined by the key to the specified file path for later load or transport. Multiarray values are often very large and are not useful for direct access in JS land.
