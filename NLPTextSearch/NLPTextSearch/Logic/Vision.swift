//
//  Vision.swift
//  NLPTextSearch
//
//  Created by Mladen Despotovic on 16.07.19.
//  Copyright © 2019 Mladen Despotovic. All rights reserved.
//

import Foundation
import CoreML
import Vision
import UIKit

class ImageVision {
    
    func textFromBundleImage(named name: String, completion: @escaping ((String?) -> Void)) {
        
        guard let imgCg = UIImage(named: name)?.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: imgCg, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            for observation in observations {
                let topCandidate = observation.topCandidates(1)
                if let recognizedText = topCandidate.first {
                    completion(recognizedText.string)
                }
            }
        }
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en","de"]
        
        try? handler.perform([request])
    }
}
