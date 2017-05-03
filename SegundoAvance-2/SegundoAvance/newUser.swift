//
//  newUser.swift
//  SegundoAvance
//
//  Created by Roberto on 3/21/17.
//  Copyright © 2017 Roberto. All rights reserved.
//

import UIKit

class newUser: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tfPassNew: UITextField!
    @IBOutlet weak var tfUserNew: UITextField!
    @IBAction func test(_ sender: Any) {
        let file = "User.txt"
        let text = "\(tfUserNew.text!),\(tfPassNew.text!)/5"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(file)
            print(path)
            do{
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                
            }catch let error as NSError{
                
                print("fk \(error)")
            }
        }
    }
    
    @IBOutlet weak var create: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfPassNew.delegate = self
        self.tfUserNew.delegate = self
        let file = "User.txt"
        var arrUtil = [String]()
        var arrUtil2 = [String]()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(file)
            //print(path)
            do{
                let contents = try String(contentsOf: path, encoding: String.Encoding.utf8)
                arrUtil2 = contents.components(separatedBy: "/")
                arrUtil = arrUtil2[0].components(separatedBy: ",")
                //print("\(arrUtil[0]),\(arrUtil[1])")
                if arrUtil[0] != "" && !arrUtil.isEmpty{
                    
                    print("hay usuario")
                    create.isEnabled = false
                }else{
                    print("no hay usuario")
                    create.isEnabled = true
                }
            }catch let error as NSError{
                
                print("fk \(error)")
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return (true)
    }
}

