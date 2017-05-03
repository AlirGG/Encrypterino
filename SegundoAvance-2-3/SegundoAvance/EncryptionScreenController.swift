//
//  EncryptionScreenController.swift
//  SegundoAvance
//
//  Created by AdrÍan Flores García on 21/03/17.
//  Copyright © 2017 Roberto. All rights reserved.
//

import UIKit

class EncryptionScreenController: UIViewController {
    //let prueba: Int =  2
    @IBOutlet weak var toEncryptLB: UITextView!
    
    @IBOutlet weak var toDecryptLB: UITextView!
    var baseDatos: OpaquePointer? = nil;
    var textoEncriptado = ""
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var txtID: UITextField!
    var keyPairExists = AsymmetricCryptoManager.sharedInstance.keyPairExists() {
        didSet {
            if keyPairExists {
                print("key exists")
            } else {
                print("key does not exist")
            }
        }
    }
    
    
    @IBAction func GenerateKey(_ sender: Any) {
        if keyPairExists { // delete current key pair
            AsymmetricCryptoManager.sharedInstance.deleteSecureKeyPair({ (success) -> Void in
                if success {
                    self.keyPairExists = false
                }
            })
        } else { // generate keypair
            AsymmetricCryptoManager.sharedInstance.createSecureKeyPair({ (success, error) -> Void in
                if success {
                    self.keyPairExists = true
                }
            })
        }
    }
    
    func obtenerPath(_	salida:	String)	->	URL?	{
        
        if let path =	FileManager.default.urls(for:	.documentDirectory,	in:	.userDomainMask).first {
            return path.appendingPathComponent(salida)
        }
        return nil
    }

    func abrirBaseDatos() -> Bool {
        if let path = obtenerPath("baseDatos.txt") {
            print(path)
            if sqlite3_open(path.absoluteString, &baseDatos) == SQLITE_OK {
                return true
            }
            // Error
            sqlite3_close(baseDatos)
        }
        return false
     }
    @IBAction func EncryptBT(_ sender: UIButton) {
    
        //if toEncryptLB.text!.isEmpty {
            //SEND NOTIFICATION
        //}
        
        
        self.toDecryptLB.text = ""
        print("borrado")
        print("entro")
        AsymmetricCryptoManager.sharedInstance.encryptMessageWithPublicKey(toEncryptLB.text!) { (success, data, error) -> Void in
            if success {
                print("encoded")
                let b64encoded = data!.base64EncodedString(options: [])
                self.toDecryptLB.text = b64encoded
                self.textoEncriptado = b64encoded
                self.toEncryptLB.text = ""
            } else {
                print("notencoded")
                //SEND NOTIFICATION
            }
        }
    }
    
    
    @IBAction func DecryptBT(_ sender: UIButton) {
        guard let encryptedData = Data(base64Encoded: toDecryptLB.text!,options: []) else {
            //SEND NOTIFICATION
            return
        }
        //if toDencryptLB.text!.isEmpty {
        //SEND NOTIFICATION
        //}
        self.toEncryptLB.text = ""
        AsymmetricCryptoManager.sharedInstance.decryptMessageWithPrivateKey(encryptedData) { (success, result, error) -> Void in
            if success {
                self.toEncryptLB.text = result!
                self.toDecryptLB.text = ""
            } else {
                //SEND NOTIFICATION
            }
        }
        
    }
    
    @IBAction func btnGuardar(_ sender: Any) {
        insertarDatos()
    }
    
    
    func insertarDatos() {
        let sqlInserta = "INSERT INTO TextoEncriptado (ID, TEXTO, DESCRIPCION) "
            + "VALUES ('\(txtID.text!)', '\(textoEncriptado)', '\(txtDesc.text!)')"
        var error: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(baseDatos, sqlInserta, nil, nil, &error) != SQLITE_OK {
            mostrarAlerta("Error al insertar datos)")
        }else{
            mostrarAlerta("Registro Insertado Exitosamente")
        }
    }

    func crearTabla(nombreTabla: String) -> Bool {
        let sqlCreaTabla = "CREATE TABLE IF NOT EXISTS \(nombreTabla)" + "(ID TEXT PRIMARY KEY, TEXTO TEXT, DESCRIPCION TEXT)"
        var error: UnsafeMutablePointer<Int8>? = nil
        if sqlite3_exec(baseDatos, sqlCreaTabla, nil, nil, &error) == SQLITE_OK {
            return true
        } else {
            sqlite3_close(baseDatos)
            let msg = String.init(cString: error!)
            print("Error: \(msg)")
            return false
        }
    }
    func mostrarAlerta(_ mensaje: String){
        let alerta = UIAlertController(title: "Aviso", message: mensaje, preferredStyle: .alert)
        let aceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(aceptar)
        
        present(alerta, animated: true, completion: nil)
    }
    
    
    @IBAction func btnBuscar(_ sender: Any) {
        consultarBaseDatos()
    }

    func consultarBaseDatos() {
        if(txtID.text?.isEmpty)!{
            let sqlConsulta = "SELECT * FROM TextoEncriptado"
            var declaracion: OpaquePointer? = nil
            if sqlite3_prepare_v2(baseDatos, sqlConsulta, -1, &declaracion, nil) == SQLITE_OK {
                while sqlite3_step(declaracion) == SQLITE_ROW {
                    let nomina = String.init(cString: sqlite3_column_text(declaracion, 0))
                    let nombre = String.init(cString: sqlite3_column_text(declaracion, 1))
                    let salario = String.init(cString: sqlite3_column_text(declaracion, 2))
                    print("\(nomina), \(nombre), \(salario)")
                }
            }
            
        }else{
            let sqlConsulta = "SELECT * FROM TextoEncriptado WHERE ID = '\(txtID.text!)'"
            var declaracion: OpaquePointer? = nil
            if sqlite3_prepare_v2(baseDatos, sqlConsulta, -1, &declaracion, nil) == SQLITE_OK {
                while sqlite3_step(declaracion) == SQLITE_ROW {
                    let nomina = String.init(cString: sqlite3_column_text(declaracion, 0))
                    let nombre = String.init(cString: sqlite3_column_text(declaracion, 1))
                    let salario = String.init(cString: sqlite3_column_text(declaracion, 2))
                    print("\(nomina), \(nombre), \(salario)")
                    self.toEncryptLB.text = nombre
                    
                }
                
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if abrirBaseDatos(){
            if crearTabla(nombreTabla: "TextoEncriptado"){
                
                
                
                print("------------------")
                //sqlite3_close(baseDatos)
            }else{
                print("no se pudo crear tabla")
            }
        }else{
            print("error")
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
