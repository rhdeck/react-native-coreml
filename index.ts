
import {
  NativeModules
} from 'react-native';
class RNCoreMLClass {
  compileModel: (sourcepath:string) => Promise<string>;
  classifyImageWithModel: (imagepath:string, modelpath:string) => Promise<Array<Object>>;
  predictFromDataWithModel: (data:object, modelpath: string) => Promise<object>
}
const RNCoreML:RNCoreMLClass = NativeModules.RNCoreML;
const compileModel = (sourcepath) => {
  return RNCoreML.compileModel(sourcepath)
}
const classifyImage = (imagePath:string, modelPath:string): Promise<object> => {
  return RNCoreML.classifyImageWithModel(imagePath, modelPath)
}
const getTopResult = (arr:Array<object>):Promise<Object> => {
  let ret = new Promise<object>((resolve, reject) => {
    resolve(arr[0])  ;  
  });
  return ret; 
}
const getTopFiveResults = (arr:Array<object>):Promise<Array<object>> => {
  let ret = new Promise<Array<object>>((resolve, reject) => {
    resolve(arr.slice(0,4))  ;  
  });
  return ret;
}
const classifyTopFive = (imagePath:string, modelPath:string):Promise<Array<object>> => {
  return RNCoreML.classifyImageWithModel(imagePath, modelPath)
    .then(getTopFiveResults)
};
const classifyTopValue = (imagePath, modelPath) => {
  return RNCoreML.classifyImageWithModel(imagePath, modelPath).then(getTopResult); 
}
export default {
  "compileModel": compileModel,
  "classifyImage": classifyImage,
  "classifyTopFive": classifyTopFive,
  "classifyTopValue": classifyTopValue
}
