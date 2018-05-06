var __awaiter =
  (this && this.__awaiter) ||
  function(thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function(resolve, reject) {
      function fulfilled(value) {
        try {
          step(generator.next(value));
        } catch (e) {
          reject(e);
        }
      }
      function rejected(value) {
        try {
          step(generator["throw"](value));
        } catch (e) {
          reject(e);
        }
      }
      function step(result) {
        result.done
          ? resolve(result.value)
          : new P(function(resolve) {
              resolve(result.value);
            }).then(fulfilled, rejected);
      }
      step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
  };
import { NativeModules } from "react-native";
class RNCoreMLClass {}
const RNCoreML = NativeModules.RNCoreML;
const compileModel = sourcepath =>
  __awaiter(this, void 0, void 0, function*() {
    return yield RNCoreML.compileModel(sourcepath);
  });
const classifyImage = (imagePath, modelPath) =>
  __awaiter(this, void 0, void 0, function*() {
    return yield RNCoreML.classifyImageWithModel(imagePath, modelPath);
  });
const getTopResult = arr => {
  return arr[0];
};
const getTopFiveResults = arr => {
  return arr.slice(0, 4);
};
const classifyTopFive = (imagePath, modelPath) =>
  __awaiter(this, void 0, void 0, function*() {
    const arr = yield RNCoreML.classifyImageWithModel(imagePath, modelPath);
    return getTopFiveResults(arr);
  });
const classifyTopValue = (imagePath, modelPath) =>
  __awaiter(this, void 0, void 0, function*() {
    const arr = yield RNCoreML.classifyImageWithModel(imagePath, modelPath);
    return getTopResult(arr);
  });
const predict = (dictionary, modelPath) =>
  __awaiter(this, void 0, void 0, function*() {
    const obj = yield RNCoreML.predictFromDataWithModel(dictionary, modelPath);
    return obj;
  });
export default {
  compileModel: compileModel,
  classifyImage: classifyImage,
  classifyTopFive: classifyTopFive,
  classifyTopValue: classifyTopValue,
  predict: predict
};
//# sourceMappingURL=index.js.map
