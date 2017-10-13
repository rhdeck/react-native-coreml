import Foundation
import Vision
@objc (RNCoreML)
class RNCpreML: NSObject {
    @objc func compileModel(_ source: String, success:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) ->Void {
        let url = URL(fileURLWithPath: source)
        do {
            let tempURL:URL = try MLModel.compileModel(at:url)
            success(tempURL.path);
            return;
        } catch {
            reject(nil, nil, nil);
            return;
        }
        reject(nil, nil, nil);
    }
    @objc func classifyImageWithModel(_ source: String, modelPath: String, success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
        do {
            let imageURL = URL(fileURLWithPath: source)
            let modelURL = URL(fileURLWithPath: modelPath)
            let thisModel = try MLModel(contentsOf: modelURL);
            let vModel = try VNCoreMLModel(for: thisModel);
            let image = CIImage(contentsOf: imageURL);
            let handler = VNImageRequestHandler(ciImage: image!);
            let request = VNCoreMLRequest(model: vModel) { (req, e) -> Void in
                if let results = req.results {
                    if let labels = results as? [VNClassificationObservation] {
                        var out = [[String:Any]]();
                        labels.forEach() { (thisClass) in
                            let value = thisClass.confidence;
                            let key = thisClass.identifier;
                            out.append(["key":key, "value":value]);
                        }
                        success(out);
                        return;
                    }
                }
                reject(nil, nil, nil);
            }
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
            try handler.perform([request]);
        } catch {
            reject(nil, nil, nil);
            
        }
    }
    @objc func predictDataWithModel(_ source: [String:Any], modelPath: String,  success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
        do {
            let modelURL = URL(fileURLWithPath: modelPath)
            let thisModel = try MLModel(contentsOf: modelURL);
            let dp = try MLDictionaryFeatureProvider(dictionary: source);
            let prediction:MLFeatureProvider = try thisModel.prediction(from: dp)
            var out:[String:[String:Any]] = [:];
            for s:String in prediction.featureNames {
                if let v:MLFeatureValue = prediction.featureValue(for: s) {
                    let t:MLFeatureType = v.type
                    var o:Any?;
                    var ts:String = "";
                    switch t {
                    case MLFeatureType.string:
                        ts = "string";
                        o = v.stringValue;
                    case MLFeatureType.double:
                        ts = "double";
                        o = v.doubleValue;
                    case MLFeatureType.int64:
                        ts = "int64";
                        o = v.int64Value;
                    case MLFeatureType.dictionary:
                        ts = "dictionary";
                        o = v.dictionaryValue
                    case MLFeatureType.image:
                        if let cvib:CVImageBuffer = v.imageBufferValue {
                            //yeah I don't know what to do with this
                            ts = "image";
                            // o = ???
                        }
                    case MLFeatureType.invalid:
                        print("This was an invalid answer");
                    case MLFeatureType.multiArray:
                        //don't know what to do with this either
                        if let m = v.multiArrayValue {
                            ts = "multiarray"
                            o = m
                        }
                    default:
                        print("I should have handled all the cases, so this should not happen.")
                    }
                    if(ts.count > 0) {
                        if let obang = o {
                            out[s] = ["type":ts, "value":obang];
                        }
                    }
                }
            }
            success(out);
            return;
        } catch {
            reject(nil, nil, nil);
        }
    }
}
