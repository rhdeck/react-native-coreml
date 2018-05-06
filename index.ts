import { NativeModules } from "react-native";
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
}
const RNCoreML: RNCoreMLClass = NativeModules.RNCoreML;
const compileModel = async sourcepath => {
  return await RNCoreML.compileModel(sourcepath);
};
const classifyImage = async (imagePath, modelPath) => {
  return await RNCoreML.classifyImageWithModel(imagePath, modelPath);
};
const getTopResult = arr => {
  return arr[0];
};
const getTopFiveResults = arr => {
  return arr.slice(0, 4);
};
const classifyTopFive = async (imagePath, modelPath) => {
  const arr = await RNCoreML.classifyImageWithModel(imagePath, modelPath);
  return getTopFiveResults(arr);
};
const classifyTopValue = async (imagePath, modelPath) => {
  const arr = await RNCoreML.classifyImageWithModel(imagePath, modelPath);
  return getTopResult(arr);
};
const predict = async (dictionary, modelPath) => {
  const obj = await RNCoreML.predictFromDataWithModel(dictionary, modelPath);
  return obj;
};
export default {
  compileModel: compileModel,
  classifyImage: classifyImage,
  classifyTopFive: classifyTopFive,
  classifyTopValue: classifyTopValue,
  predict: predict
};
