var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
import { NativeModules, Image } from "react-native";
const { resolveAssetSource } = Image;
class RNCoreMLClass {
}
const RNCoreML = NativeModules.RNCoreML;
const { mainBundlePath, mainBundleURL } = RNCoreML;
const fixURL = sourcepath => {
    if (typeof sourcepath === "string") {
        if (sourcepath.includes("/"))
            return sourcepath;
        else
            return mainBundleURL + "/" + sourcepath;
    }
    if (sourcepath.uri) {
        return sourcepath.uri;
    }
    const { uri } = resolveAssetSource(sourcepath);
    return uri;
};
const compileModel = (sourcepath) => __awaiter(this, void 0, void 0, function* () {
    return yield RNCoreML.compileModel(fixURL(sourcepath));
});
const classifyImage = (imagePath, modelPath) => __awaiter(this, void 0, void 0, function* () {
    return yield RNCoreML.classifyImageWithModel(fixURL(imagePath), fixURL(modelPath));
});
const getTopResult = arr => {
    return arr[0];
};
const getTopFiveResults = arr => {
    return arr.slice(0, 4);
};
const classifyTopFive = (imagePath, modelPath) => __awaiter(this, void 0, void 0, function* () {
    const arr = classifyImage(imagePath, modelPath);
    return getTopFiveResults(arr);
});
const classifyTopValue = (imagePath, modelPath) => __awaiter(this, void 0, void 0, function* () {
    const arr = classifyImage(imagePath, modelPath);
    return getTopResult(arr);
});
const predict = (dictionary, modelPath) => __awaiter(this, void 0, void 0, function* () {
    const obj = yield RNCoreML.predictFromDataWithModel(dictionary, fixURL(modelPath));
    return obj;
});
const saveMultiArray = (key, savePath) => __awaiter(this, void 0, void 0, function* () {
    if (!savePath)
        savePath = null;
    const newPath = yield RNCoreML.saveMultiArray(key, savePath);
    return newPath;
});
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
export { compileModel, classifyImage, classifyTopFive, classifyTopValue, predict, saveMultiArray, mainBundlePath, mainBundleURL };
//# sourceMappingURL=index.js.map