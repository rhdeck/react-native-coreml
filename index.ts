import { NativeModules, Image } from "react-native";
const { resolveAssetSource } = Image;
class RNCoreMLClass {
  compileModel: (sourcepath: string) => Promise<string>;
  classifyImageWithModel: (
    imagepath: string,
    modelpath: string
  ) => Promise<Array<Object>>;
  predictFromDataWithModel: (
    data: object,
    modelpath: string
  ) => Promise<object>;
  saveMultiArray: (key: string, savePath: string) => Promise<string>;
  mainBundleURL: string;
  mainBundlePath: string;
}
const RNCoreML: RNCoreMLClass = NativeModules.RNCoreML;
const { mainBundlePath, mainBundleURL } = RNCoreML;
const fixURL = sourcepath => {
  if (typeof sourcepath === "string") {
    if (sourcepath.includes("/")) return sourcepath;
    else return mainBundleURL + "/" + sourcepath;
  }
  if (sourcepath.uri) {
    return sourcepath.uri;
  }
  const { uri } = resolveAssetSource(sourcepath);
  return uri;
};
const compileModel = async sourcepath => {
  return await RNCoreML.compileModel(fixURL(sourcepath));
};
const classifyImage = async (imagePath, modelPath) => {
  return await RNCoreML.classifyImageWithModel(
    fixURL(imagePath),
    fixURL(modelPath)
  );
};
const getTopResult = arr => {
  return arr[0];
};
const getTopFiveResults = arr => {
  return arr.slice(0, 4);
};
const classifyTopFive = async (imagePath, modelPath) => {
  const arr = classifyImage(imagePath, modelPath);
  return getTopFiveResults(arr);
};
const classifyTopValue = async (imagePath, modelPath) => {
  const arr = classifyImage(imagePath, modelPath);
  return getTopResult(arr);
};
const predict = async (dictionary, modelPath) => {
  const obj = await RNCoreML.predictFromDataWithModel(
    dictionary,
    fixURL(modelPath)
  );
  return obj;
};
const saveMultiArray = async (key, savePath) => {
  if (!savePath) savePath = null;
  const newPath = await RNCoreML.saveMultiArray(key, savePath);
  return newPath;
};
export default {
  compileModel,
  classifyImage,
  classifyTopFive,
  classifyTopValue,
  predict,
  saveMultiArray,
  mainBundlePath,
  mainBundleURL
};
export {
  compileModel,
  classifyImage,
  classifyTopFive,
  classifyTopValue,
  predict,
  saveMultiArray,
  mainBundlePath,
  mainBundleURL
};
