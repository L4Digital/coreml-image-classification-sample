//
//  ViewController.swift
//  CoreML-Vision-Classification
//
//  Created by Adam McDonald on 6/13/17.
//  Copyright © 2017 L4 Digital. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var label: UILabel!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }
    
    func analyzeImage(_ uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else {
            fatalError("Can't create CIImage from UIImage")
        }
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            try? handler.perform([self.classificationRequest])
        }
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            return VNCoreMLRequest(model: model, completionHandler: self.handleClassification)
        } catch {
            fatalError("Can't load Vision ML model: \(error)")
        }
    }()
    
    func handleClassification(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNClassificationObservation]
            else { fatalError("Unexpected result type from VNCoreMLRequest") }
        
        guard let best = observations.first
            else { fatalError("Can't get best result") }
        
        DispatchQueue.main.async {
            self.label.text = "Classification: \"\(best.identifier)\"\nConfidence: \(best.confidence)"
        }
    }
    
    // MARK - IBActions
    
    @IBAction func tappedButton(_ sender: Any) {
        self.label.text = nil
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            analyzeImage(pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

