//
//  ImageScreenController.swift
//  SegundoAvance
//
//  Created by AdrÍan Flores García on 02/05/17.
//  Copyright © 2017 Roberto. All rights reserved.
//

import UIKit
//import File
//import CryptoSwift //meter este modulo

class ImageScreenController: UIViewController,FileManagerDelegate{
    // meter variables de texto y imagen en la pantalla, asi como boton de encrypcion
    
    @IBOutlet weak var textfPath: UITextField!
    
    @IBOutlet weak var textfName: UITextField!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBAction func buscarImagen(_ sender: Any) {
        let path = textfPath.text!
        let name = textfName.text!
        
        let imageUrlPath = path + "/" + name
        
        if FileManager.default.fileExists(atPath: "imageUrlPath") {
            let url = NSURL(string: imageUrlPath)
            let data = NSData(contentsOf: url! as URL)
            imageView.image = UIImage(data: data! as Data)
        }
    }
    
    //llamar boton encrypt para que llama funcion de abajo
    
    @IBAction func cifrarImage(_ sender: Any) {
        var encrypted = false
        let image = imageView.image!
        var imageRef = image.cgImage
        
        let width = imageRef!.width
        let height = imageRef!.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel: UInt = 4
        let bytesPerRow: UInt = bytesPerPixel * UInt(width)
        let bitsPerComponent: UInt = 8
        
        let alphaInfo = imageRef!.alphaInfo // se necesita para pasar la informacion como variable
        
        let sizeOfRawDataInBytes: Int = Int(height * width * 4)
        var rawData = UnsafeMutablePointer<Void>.allocate(capacity: sizeOfRawDataInBytes)
        
        //var context = CGBitmapContextCreate(rawData, width, height, Int(bitsPerComponent), Int(bytesPerRow), colorSpace, CGBitmapInfo(alphaInfo.rawValue) | CGBitmapInfo.ByteOrder32Big)
        //CGContextDrawImage(context, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
        
        var data = NSData(bytes: rawData, length: sizeOfRawDataInBytes)
        //data = encrypted ? data.AES256DecryptWithKey(key) : data.AES256EncryptWithKey(key)
        
        //rawData = data.mutableCopy().mutableBytes  //anySender?
        
        //context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, CGBitmapInfo(alphaInfo.rawValue))
        //imageRef = CGBitmapContextCreateImage(context);
        
        let encryptedImage = UIImage(cgImage: imageRef!)
        
        imageView.image = encryptedImage
        
        encrypted = !encrypted
    }
}

//esto se usara con el file manager en version deluxe que se hara en otr pantalla

//func cargarImagen(){
//    let myimage : UIImage = UIImage(data: data)!
 //   let fileManager = NSFileManager.defaultManager()
   // let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    //let documentDirectory = urls[0] as NSURL
    
    
   // print(documentDirectory)
    //let currentDate = NSDate()
    
   // let dateFormatter = NSDateFormatter()
   // dateFormatter.dateStyle = .NoStyle
   // dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
   // let convertedDate = dateFormatter.stringFromDate(currentDate)
   // let imageURL = documentDirectory.URLByAppendingPathComponent(convertedDate)
    //imageUrlPath  = imageURL.path
    //print(imageUrlPath)
    //UIImageJPEGRepresentation(myimage,1.0)!.writeToFile(imageUrlPath, atomically: true)
//}
