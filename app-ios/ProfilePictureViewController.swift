//
//  ProfilePictureViewController.swift
//  app-ios
//
//  Created by Sinan Ulkuatam on 5/12/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import UIKit
import ImagePicker
import Alamofire
import JSSAlertView

class ProfilePictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    var window = UIWindow()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var imageView: UIImageView = UIImageView()
    
    var selectImageButton: UIButton = UIButton()
    
    let imagePickerController = ImagePickerController()
    
    var txt = UILabel()

    var allowedFileSize:Bool = false
    
    func selectPhotoButtonTapped(sender: AnyObject) {
        
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        presentViewController(imagePickerController, animated: true, completion: { void in
            self.imagePickerController.expandGalleryView()
        })

        activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        selectPhotoButtonTapped(self)
        
        imageView = UIImageView(image: UIImage(named: "IconEmpty"))
        imageView.center = view.center
        imageView.userInteractionEnabled = true
        self.view.addSubview(imageView)
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        txt.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        txt.center = view.center
        txt.textAlignment = .Center
        txt.textColor = UIColor.darkGrayColor()
        txt.text = "No image selected"
        txt.font = UIFont(name: "Avenir-Light", size: 18)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageUploadRequest(uploadedImage: UIImage)
    {
        
        if(userAccessToken != nil) {
            User.getProfile { (user, NSError) in
                
                let endpoint = apiUrl + "/v1/cloudinary/" + (user?.id)! + "/upload"
                
                let parameters = [:]
                
                let img = UIImageJPEGRepresentation(uploadedImage, 1)
                
                if(img==nil)  { return; }
                
                let imageData: NSData = NSData(data: img!)
                
                let fileSize = Float(imageData.length) / 1024.0 / 1024.0
                let fileSizeString = String.localizedStringWithFormat("%.2f", fileSize)
                NSLog("File size is : %.2f MB", fileSize)
                
                if(fileSize > 1.25) {
                    self.allowedFileSize = false
                    self.dismissViewControllerAnimated(true, completion: nil)
                    self.imageView.removeFromSuperview()
                    self.txt.text = "File size " + fileSizeString + "MB too large"
                    self.view.addSubview(self.txt)
                } else {
                    self.allowedFileSize = true
                    Alamofire.upload(.POST, endpoint, multipartFormData: {
                        multipartFormData in
    
                        multipartFormData.appendBodyPart(data: imageData, name: "avatar", fileName: "avatar", mimeType: "image/jpg")
    
                        for (key, value) in parameters {
                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key as! String)
                        }
    
                        }, encodingCompletion: {
                            encodingResult in
    
                            switch encodingResult {
                            case .Success(let upload, _, _):
                                upload.responseJSON(completionHandler: { response in
                                    switch response.result {
                                    case .Success:
                                        print("success")
                                    case .Failure(let error):
                                        print("failure")
                                        self.txt.text = "Error uploading picture"
                                        self.view.addSubview(self.txt)
                                    }
                                })
                            case .Failure(let encodingError):
                                print(encodingError)
                            }
                    })
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // Delegate: Imagepicker
    func wrapperDidPress(images: [UIImage]) {

    }
    
    func doneButtonDidPress(images: [UIImage]) {
        imageView.image = images[0]
        imageUploadRequest(imageView.image!)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.center = self.view.center
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.layer.masksToBounds = true
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        self.dismissViewControllerAnimated(true, completion: nil)
        Timeout(0.3) {
            if let navController = self.navigationController {
                navController.popViewControllerAnimated(true)
            }
        }

    }
    
    func cancelButtonDidPress() {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        self.view.addSubview(txt)
    }
}
