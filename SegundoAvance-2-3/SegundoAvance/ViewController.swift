//
//  ViewController.swift
//  SegundoAvance
//
//  Created by Roberto on 3/20/17.
//  Copyright © 2017 Roberto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func start(_ sender: Any) {
        
        self.performSegue(withIdentifier:  "start", sender: self)

    }


}

