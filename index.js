import { NativeModules } from 'react-native';
class RNCoreMLClass {
}
const RNCoreML = NativeModules.RNCoreML;
const compileModel = (sourcepath) => {
    return RNCoreML.compileModel(sourcepath);
};
const classifyImage = (imagePath, modelPath) => {
    return RNCoreML.classifyImageWithModel(imagePath, modelPath);
};
const getTopResult = (arr) => {
    let ret = new Promise((resolve, reject) => {
        resolve(arr[0]);
    });
    return ret;
};
const getTopFiveResults = (arr) => {
    let ret = new Promise((resolve, reject) => {
        resolve(arr.slice(0, 4));
    });
    return ret;
};
const classifyTopFive = (imagePath, modelPath) => {
    return RNCoreML.classifyImageWithModel(imagePath, modelPath)
        .then(getTopFiveResults);
};
const classifyTopValue = (imagePath, modelPath) => {
    return RNCoreML.classifyImageWithModel(imagePath, modelPath).then(getTopResult);
};
export default {
    "compileModel": compileModel,
    "classifyImage": classifyImage,
    "classifyTopFive": classifyTopFive,
    "classifyTopValue": classifyTopValue
};
//# sourceMappingURL=index.js.map