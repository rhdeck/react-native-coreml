
import {
  NativeModules
} from 'react-native';
class RNCoreMLClass {
  compileModel: (sourcepath:string) => Promise<string>;
  runOnImage: (imagepath:string, modelpath:string) => Promise<Array<Object>>;
}
const RNCoreML:RNCoreMLClass = NativeModules.RNCoreML;
const compileModel = (sourcepath) => {
  return RNCoreML.compileModel(sourcepath)
}
const classifyImage = (imagePath:string, modelPath:string): Promise<Object> => {
  return RNCoreML.runOnImage(imagePath, modelPath)
}
const getTopResult = (arr:Array<Object>):Promise<Object> => {
  let ret = new Promise<Object>((resolve, reject) => {
    resolve(arr[0])  ;  
  });
  return ret; 
}
const getTopFiveResults = (arr:Array<Object>):Promise<Array<Object>> => {
  let ret = new Promise<Array<Object>>((resolve, reject) => {
    resolve(arr.slice(0,4))  ;  
  });
  return ret;
}
const classifyTopFive = (imagePath:string, modelPath:string):Promise<Array<Object>> => {
  return RNCoreML.runOnImage(imagePath, modelPath)
    .then(getTopFiveResults)
};
const classifyTopValue = (imagePath, modelPath) => {
  return RNCoreML.runOnImage(imagePath, modelPath).then(getTopResult); 
}
export default {
  "compileModel": compileModel,
  "classifyImage": classifyImage,
  "classifyTopFive": classifyTopFive,
  "classifyTopValue": classifyTopValue
}
