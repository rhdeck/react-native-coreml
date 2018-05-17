import Foundation
import Vision
@objc(RNCoreML)
public class RNCoreML: NSObject {
    //MARK: Class Members - public for other Swift code
    public static var instance:RNCoreML?
    public class func getMultiArray(_ key: String) -> MLMultiArray? {
        return instance?.multiArrays[key]
    }
    public class func removeMultiArray(_ key: String) {
        guard let i = RNCoreML.instance else { return }
        i.multiArrays.removeValue(forKey: key)
    }
    //MARK: Private Instance Members
    var multiArrays:[String:MLMultiArray] = [:]
    var models:[String:MLModel] = [:]
    override init() {
        super.init()
        RNCoreML.instance = self
    }
    class func requiresMainQueueSetup() -> Bool {
        return false
    }
    func makeMLDictionary(_ source: [String:Any]) -> MLDictionaryFeatureProvider? {
        var newSource:[String:Any] = [:]
        source.forEach() { k, v in
            if let m = multiArrays[k] {
                newSource[k] = m
            } else {
                newSource[k] = v
            }
        }
        let out = try? MLDictionaryFeatureProvider(dictionary: newSource);
        return out
        
    }
    func getModel(_ modelPath: String) -> MLModel? {
        if let m = models[modelPath] { return m }
        let modelURL = URL(fileURLWithPath: modelPath)
        if let m = try? MLModel(contentsOf: modelURL) {
            models[modelPath] = m
            return m
        }
        return nil
    }
    func saveMultiArray(_ key: String, path: String) ->  Bool {
        guard let ma = multiArrays[key] else { return false }
        return react_native_coreml.saveMultiArray(multiArray: ma, path: path);
    }
    func saveMultiArray(_ key: String, url: URL) -> Bool {
        guard let ma = multiArrays[key] else { return false }
        return react_native_coreml.saveMultiArray(multiArray: ma, url: url);
    }
    func makeMultiArrayExtension(_ key: String) -> String? {
        guard let ma = multiArrays[key] else { return nil }
        return makeMultiArrayExtension(multiArray: ma)
    }
    func makeMultiArrayExtension(multiArray: MLMultiArray) -> String {
        var t:String
        switch multiArray.dataType {
        case .double: t = "double";
        case .float32: t = "float32";
        case .int32: t = "int32";
        }
        for n in multiArray.shape {
            t = t.appending(".").appending(n.stringValue)
        }
        t = t.appending(".").appending("s")
        for n in multiArray.strides {
            t = t.appending(".").appending(n.stringValue)
        }
        return t
    }
    //MARK: RN Methods
    @objc func compileModel(_ source: String, success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
        DispatchQueue(label: "RNCoreML").async() {
            let url = URL(fileURLWithPath: source)
            do {
                let tempURL:URL = try MLModel.compileModel(at:url)
                success(tempURL.path);
            } catch {
                reject(nil, nil, error);
            }
        }
    }
    @objc func classifyImageWithModel(_ source: String, modelPath: String, success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
        guard let thisModel = getModel(modelPath) else { reject("no_model", "Could not load model with path" +  modelPath, nil); return }
        do {
            let imageURL = URL(fileURLWithPath: source)
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
            reject("model_error", "Error from model: " + error.localizedDescription, error);
        }
    }
    @objc func predictFromDataWithModel(_ source: [String:Any], modelPath: String,  success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
        do {
            guard
                let dp = makeMLDictionary(source),
                let thisModel = getModel(modelPath)
                else { reject("no_model", "Model or source data incorrect", nil) ; return }
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
                            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
                            let ci = CIImage(cvImageBuffer: cvib)
                            let ui = UIImage(ciImage: ci)
                            guard let _ = try? UIImageJPEGRepresentation(ui, 1.0)?.write(to: tempURL) else { continue }
                            o = tempURL.absoluteString
                            ts = "image";
                        }
                    case MLFeatureType.invalid:
                        ts = "invalid"
                        o = nil
                        print("This was an invalid answer");
                    case MLFeatureType.multiArray:
                        if let m = v.multiArrayValue {
                            ts = "multiarray"
                            let k = UUID().uuidString
                            multiArrays[k] = m
                            var mtype:String = ""
                            switch m.dataType {
                            case .double: mtype = "double";
                            case .int32: mtype = "int32";
                            case .float32: mtype = "float32"
                            }
                            o = [
                                "key": k,
                                "type": mtype,
                                "strides": m.strides,
                                "shape": m.shape
                            ]
                        }
                    }
                    if(ts.count > 0) {
                        out[s] = ["name": s, "type":ts, "value":o];
                    }
                }
            }
            success(out);
            return;
        } catch {
            reject(nil, nil, error);
        }
    }
    @objc func saveMultiArray(_ key: String, path: String?, resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock ) {
        guard let ma = multiArrays[key] else { reject("bad_key", "No multiarray saved with this key", nil); return }
        if let p = path {
            if react_native_coreml.saveMultiArray(multiArray: ma, path: p) {
                resolve(path)
            } else {
                reject("no_save", "Save failed", nil)
            }
        } else {
            //make temp file
            let p = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension(self.makeMultiArrayExtension(multiArray: ma))
            self.saveMultiArray(key, path: p.path, resolve: resolve, reject: reject)
        }
    }
}

func saveMultiArray(multiArray: MLMultiArray, path:String) -> Bool {
    let url = URL(fileURLWithPath: path)
    return saveMultiArray(multiArray: multiArray, url: url);
}

func saveMultiArray(multiArray: MLMultiArray, url: URL) -> Bool {
    var size:Int = 1;
    var unitSize:Int
    switch multiArray.dataType {
    case .double: unitSize = 8;
    case .float32: unitSize = 4;
    case .int32: unitSize = 4;
    }
    for  dim in 1...multiArray.shape.count {
        size = size * (multiArray.shape[dim] as! Int) * (multiArray.strides[dim] as! Int) * unitSize
    }
    let d = NSData(bytes: multiArray.dataPointer, length: size)
    do {
        try d.write(to: url, options: .atomic)
        return true
    } catch  {
        return false
    }
}
