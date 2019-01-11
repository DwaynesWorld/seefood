//
//  ViewController.swift
//  SeeFood
//
//  Created by Kyle Thompson on 12/11/17.
//  Copyright © 2017 Kyle Thompson. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifierButton: UIBarButtonItem!
    
    var isCoreML = true
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = pickedImage
            if isCoreML {
                detectCoreML(pickedImage)
            } else {
                detectIbmWatson(pickedImage)
            }
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detectIbmWatson(_ pickedImage: UIImage) {
        // Code For Watson
    }
    
    func detectCoreML(_ pickedImage: UIImage) {
        guard let ciImage = CIImage(image: pickedImage) else {
            fatalError("Could not convert image")
        }
        
        guard
            let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed!")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Could not prepare vision request")
            }
            
            if let topClass = results.first {
                if let result = topClass.identifier.split(separator: Character.init(",")).first {
                    self.navigationItem.title = String(result)
                } else {
                    self.navigationItem.title = "I got nothing 🤷🏿‍♂️"
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch let error {
            print(error)
        }
    }
    
    func chooseSourceType() {        
        let optionMenu = UIAlertController(title: nil, message: "Choose Image Source", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Use Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let photosAction = UIAlertAction(title: "Photos Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(photosAction)
        optionMenu.addAction(cancelAction)
        
        present(optionMenu, animated: true)
    }
    
    @IBAction func classifierButtonTapped(_ sender: Any) {
        if isCoreML {
            isCoreML = false
            classifierButton.title = "IBM Watson"
        } else {
            isCoreML = true
            classifierButton.title = "CoreML"
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        let photosAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        if (cameraAvailable && photosAvailable) {
            chooseSourceType()
        } else if (cameraAvailable || photosAvailable)  {
            if (cameraAvailable) {
                imagePicker.sourceType = .camera
            } else if (photosAvailable) {
                imagePicker.sourceType = .photoLibrary
            }
            present(self.imagePicker, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Device Error", message: "No image sources available!", preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
}

