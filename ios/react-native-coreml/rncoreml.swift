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
        } catch
            reject(nil, nil, nil);
            return;
        }
        reject(nil, nil, nil);
    }
    @objc func runOnImage(_ source: String, modelPath: String, success:@escaping RCTPromiseResolveBlock, reject:@escaping RCTPromiseRejectBlock) ->Void {
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
}
