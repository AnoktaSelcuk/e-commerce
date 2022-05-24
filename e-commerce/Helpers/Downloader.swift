//
//  Downloader.swift
//  internProject
//
//  Created by Alperen Selçuk on 5.09.2021.
//  Copyright © 2021 Alperen Selçuk. All rights reserved.
//

import Foundation
import FirebaseStorage

let storage = Storage.storage()

func uploadImage(images: [UIImage?], itemId: String, completion: @escaping (_ imageLinks: [String]) -> Void) {
    
    if Reachabilty.HasConnection() {
        
        var uploadImagesCount = 0
        var imageLinkArray: [String] = []
        var nameSuffix = 0
        
        for image in images {
            let filenName = "ItemImages/" + itemId + "/" + "\(nameSuffix)" + ".jpg"
            let imageData = image!.jpegData(compressionQuality: 0.5)
            saveImageInFirebase(imageData: imageData!, fileName: filenName) { (imageLink) in
                
                if imageLink != nil {
                    
                    imageLinkArray.append(imageLink!) //eger link var ise imaji listimize ekle
                    
                    uploadImagesCount += 1 //yuklenen resimleri bir arttiriyoruz..
                    
                    if uploadImagesCount == images.count { //butun fotolar arraye yuklendi demektir
                        completion(imageLinkArray) //complet ediyoruz. (call  back)
                    }
                }
            }
            
        }
        
    } else {
         print("No internet bro ")
    }
}




func saveImageInFirebase(imageData: Data, fileName: String, completion: @escaping (_ imageLink: String?) -> Void) {
    
    var task: StorageUploadTask!
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
    
    task = storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
        
        task.removeAllObservers()
        
        
        if error != nil {
            print("error uploading image,",error!.localizedDescription)
            completion(nil)
            return
        }
        
        storageRef.downloadURL{(url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
        }
    }) 
}


func downloadImages(imagesUrls: [String], completiton: @escaping (_ images: [UIImage?]) -> Void) {
    
    var imageArray: [UIImage] = []
    var downloadCounter = 0
    
    for link in imagesUrls {
        
        let url = NSURL(string: link)
        
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        

        downloadQueue.async {
            
            downloadCounter += 1
            
            let data = NSData(contentsOf: url! as URL)
            
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                
      
                if downloadCounter == imageArray.count {
                    
                    DispatchQueue.main.async {
                        completiton(imageArray)
                    }
                }
            } else {
                
                print("imaj dosyalari yuklenmedi..")
                
                completiton(imageArray)
            }
        }
    }
    
}

