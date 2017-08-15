//
//  ViewController.swift
//  FaceDetection
//
//  Created by Harry Cao on 16/7/17.
//  Copyright © 2017 Harry Cao. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  var didDetect = false
  
  lazy var imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.frame = self.view.frame
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .white
    return imageView
  }()
  
  var imageSize: CGSize?
  
  var image: UIImage? {
    didSet {
      guard let image = image else { return }
      
      self.imageView.image = image
      if image.size.height/image.size.width < 16/9 {
        self.imageSize = CGSize(width: self.view.frame.width, height: self.view.frame.width/image.size.width*image.size.height)
      } else {
        self.imageSize = CGSize(width: self.view.frame.height/image.size.height*image.size.width, height: self.view.frame.height)
      }
    }
  }
  
  lazy var galleryButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = .white
    button.layer.cornerRadius = 35
    button.layer.borderColor = UIColor.gray.cgColor
    button.layer.borderWidth = 3
    button.layer.zPosition = 2
    button.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
    return button
  }()
  
  lazy var detectFaceRectRequest: VNDetectFaceRectanglesRequest = {
    return VNDetectFaceRectanglesRequest(completionHandler: { (request, error) in
      guard let results = request.results as? [VNFaceObservation] else { return }
      
      results.forEach({ result in
        self.addDectedBox(forRect: result.boundingBox)
      })
    })
  }()
  
  let detectedBoxContainer: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.layer.zPosition = 1
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(detectFace)))
    
    setupViews()
  }
  
  func setupViews() {
    self.view.addSubview(imageView)
    self.view.addSubview(detectedBoxContainer)
    self.view.addSubview(galleryButton)
    
    _ = imageView.constraintAnchorTo(top: self.view.topAnchor, topConstant: 0, bottom: self.view.bottomAnchor, bottomConstant: 0, left: self.view.leftAnchor, leftConstant: 0, right: self.view.rightAnchor, rightConstant: 0)
    _ = galleryButton.constraintSizeToConstant(widthConstant: 70, heightConstant: 70)
    _ = galleryButton.constraintCenterTo(centerX: self.view.centerXAnchor, xConstant: 0, centerY: self.view.centerYAnchor, yConstant: 300)
    _ = detectedBoxContainer.constraintAnchorTo(top: self.view.topAnchor, topConstant: 0, bottom: self.view.bottomAnchor, bottomConstant: 0, left: self.view.leftAnchor, leftConstant: 0, right: self.view.rightAnchor, rightConstant: 0)
  }
  
  @objc func openGallery() {
    didDetect = false
    
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    
    present(imagePickerController, animated: true) {
      for box in self.detectedBoxContainer.subviews {
        box.removeFromSuperview()
      }
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage else { return }
    image = selectedImage
    picker.dismiss(animated: true, completion: nil)
  }
  
  @objc func detectFace() {
    if didDetect { return }
    didDetect = true
    
    guard
      let image = image,
      let cgImage = image.cgImage
    else { return }
    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try requestHandler.perform([self.detectFaceRectRequest])
    } catch {
      fatalError("can't perform VNDetectFaceRectangleRequest")
    }
  }
  
  func addDectedBox(forRect boundingBox: CGRect) {
    guard let imageSize = imageSize else { return }
    
    let screenWidth = self.view.frame.width
    let screenHeight = self.view.frame.height
    let imageWidth = imageSize.width
    let imageHeight = imageSize.height
    
    let bottomLeftOrigin = CGPoint(x: (screenWidth - imageWidth)/2, y: (screenHeight + imageHeight)/2)
    
    let boxWidth = imageWidth*boundingBox.width
    let boxHeight = imageHeight*boundingBox.height
    
    let boxOriginX = bottomLeftOrigin.x + imageWidth*boundingBox.origin.x
    let boxOriginY = bottomLeftOrigin.y - imageHeight*boundingBox.origin.y - boxHeight
    
    let detectedBox = UIView(frame: CGRect(x: boxOriginX, y: boxOriginY, width: boxWidth, height: boxHeight))
    detectedBox.backgroundColor = UIColor(white: 1, alpha: 0.3)
    detectedBox.layer.borderColor = UIColor.red.cgColor
    detectedBox.layer.borderWidth = 2
    detectedBox.layer.cornerRadius = 10
    detectedBox.layer.masksToBounds = true
    
    detectedBoxContainer.addSubview(detectedBox)
    
  }
}

