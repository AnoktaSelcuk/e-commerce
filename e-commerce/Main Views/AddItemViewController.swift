//
//  AddItemViewController.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView


class AddItemViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    

    //MARK: Vars
    var category: Category!
    var gallery: GalleryController!
    let hud = JGProgressHUD(style: .dark)
    
    var activityIndicator: NVActivityIndicatorView?
    
    var itemImages: [UIImage?] = [] 

    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print(category.id)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    

    //MARK: IBActions (item eklemeye hata mesaji ekledik)
    @IBAction func doneBarButtonItemPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        if fieldsAreCompleted() {
            saveToFirebase()
        } else {

            self.hud.textLabel.text = "All Fields Are Required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    
    }

    private func dismissKeyboard() -> () {
        self.view.endEditing(false)
    }


    private func fieldsAreCompleted() -> Bool {
        
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextView.text != "")
    }
    
    private func popTheView() -> Void {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Save Item to firebase
    private func saveToFirebase() -> Void {
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextView.text
        item.price = Double(priceTextField.text!)
        
        if itemImages.count > 0 {
            
            uploadImage(images: itemImages, itemId: item.id) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                
                saveItemToFirebase(item)
                saveItemToAlgolia(item: item)
                self.hideLoadingIndicator()
                self.popTheView()
            }
        } else {
            saveItemToFirebase(item) 
            saveItemToAlgolia(item: item)
            popTheView()
        }
    }
        
    private func showLoadingIndicator() {
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }
    

    //MARK: Show Gallery
    private func showImageGallery() -> Void {
        self.gallery = GalleryController()
        self.gallery.delegate = self 
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 6
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController: GalleryControllerDelegate {

    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 { 
            Image.resolve(images: images) { (resolvedImages) in
                self.itemImages = resolvedImages
                
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil) 
    }
    
}
