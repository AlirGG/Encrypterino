import UIKit
import CoreLocation
class LoginController: UIViewController,UITextFieldDelegate,UIApplicationDelegate,CLLocationManagerDelegate {
    
    private let admGps = CLLocationManager()
    var posicion = CLLocation()
    
    @IBOutlet weak var tfUser: UITextField!
   
    @IBOutlet weak var tfPass: UITextField!
    var tries = 5
    
    @IBOutlet weak var validate: UIButton!
    @IBOutlet weak var login: UIButton!
    var baseDatos: OpaquePointer? = nil;
    
    @IBOutlet weak var new: UIButton!
    @IBAction func validate(_ sender: Any) {
        knownLoc()
        let file = "User.txt"
        
        var arrUtil = [String]()
        var arrUtil2 = [String]()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(file)
            
            print(path)
            do{
                let contents = try String(contentsOf: path, encoding: String.Encoding.utf8)
                arrUtil2 = contents.components(separatedBy: "/")
                arrUtil = arrUtil2[0].components(separatedBy: ",")
               
                print(tries)
                print("\(arrUtil[0]),\(arrUtil[1])")
                if arrUtil[0] == tfUser.text!  && arrUtil[1] == tfPass.text!{
                
                    self.performSegue(withIdentifier:  "login", sender: self)
                 getLoc()
                    
                }else{
                    tries-=1
                    print(tries)
                    
                }
                if tries == 0 {
                createAlert(titleText: "Has alcanzado el numero maximo de intentos", messageText: "todos tus archivos se han borrado, lo sentimos")
                print("oops")
                    let text = ""
                    try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
                    validate.isEnabled = false;
                //ELIMINMAR TODO
                    let sqlCreaTabla = "DROP TABLE IF EXISTS TextoEncriptado"
                    var error: UnsafeMutablePointer<Int8>? = nil
                    if sqlite3_exec(baseDatos, sqlCreaTabla, nil, nil, &error) == SQLITE_OK {
                    } else {
                        sqlite3_close(baseDatos)
                        let msg = String.init(cString: error!)
                        print("Error: \(msg)")
                    }

                }
                
            }catch let error as NSError{
                
                print("fk \(error)")
            }
        }
    }
    func borrarData(){
        //borrar todos los datos de la tabla
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.last!.distance(from: posicion)<10{
            return
        }
        self.posicion = locations.last!
    }
    func getLoc(){
        let fileLoc = "locs.txt"
        
        //var arrUtil2 = [String]()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(fileLoc)
            
            do{
                let long = "\(posicion.coordinate.longitude),\(posicion.coordinate.latitude) "
                
                try long.write(to: path, atomically: false, encoding: String.Encoding.utf8)
               
                print("se agreo localizacion ++++++++++++++++++++++++++++++++++")
                
                            }catch let error as NSError{
                
                print("fk \(error)")
            }
        }
    
    }
    
    
    func knownLoc(){
        let fileLoc = "locs.txt"
        var knownLong = false
        var knownLat = false
        var arrUtil = [String]()
        //var arrUtil2 = [[String]]()
        var longitudes = [String]()
        var latitudes = [String]()
        //var i = 0
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(fileLoc)
            
            do{
                
                let contents = try String(contentsOf: path, encoding: String.Encoding.utf8)
                arrUtil = contents.components(separatedBy: " ")
                //arrUtil.count
                if arrUtil.count<1 {
                    //return
                    print("salio first time")
                    return
                }
                for locations in arrUtil {
                    print(locations.components(separatedBy: ","))
                    if (locations.components(separatedBy: ",")).count<2 {
                        break
                    }
                    //latitudes[i] = locations.components(separatedBy: ",")[1]
                    longitudes.append(locations.components(separatedBy: ",")[0])
                    latitudes.append(locations.components(separatedBy: ",")[1])
                    //i+=1
                }
                
                for coord in longitudes {
                    //print(coord)
                    let longi: Float = Float(coord)!
                    print(longi)
                    print(posicion.coordinate.longitude)
                    let actualLong: Float = Float(posicion.coordinate.longitude)
                    if longi+50>actualLong && actualLong>longi-50{
                        knownLong = true
                    }
                }
                for coord in latitudes {
                    print(coord)
                    let lati: Float = Float(coord)!
                    let actualLati: Float = Float(posicion.coordinate.latitude)
                    
                    if lati+50>actualLati && actualLati>lati-50 {
                        knownLat = true
                    }
                    
                }
                
                if knownLat && knownLong {
                    
                }else{
                
                    self.tries -= 1
                    createAlert(titleText: "No te encuentras en una localización conocida", messageText: "tus intentos se han reducido a 3")
                }

                //let long = posicion.coordinate.longitude
                //let lat = posicion.coordinate.latitude
                
                
                
                
                
                
            }catch let error as NSError{
                
                print("fk \(error)")
            }
        }

    
    
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse{
            admGps.startUpdatingLocation()
            
        }else{
            
            admGps.stopUpdatingLocation()
        }
    }
    private func configurarGPS() {
        admGps.delegate = self
        
        admGps.desiredAccuracy = kCLLocationAccuracyBest
        
        admGps.requestWhenInUseAuthorization()
    }
    
    func obtenerPath(_	salida:	String)	->	URL?	{
        
        if let path =	FileManager.default.urls(for:	.documentDirectory,	in:	.userDomainMask).first {
            return path.appendingPathComponent(salida)
        }
        return nil
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
    func createAlert(titleText: String, messageText: String){
    
        let alert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        
        self.present(alert, animated:true, completion:nil)
    }
    override func viewDidLoad() {
        configurarGPS()
        //knownLoc()
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

        self.tfPass.delegate = self
        self.tfUser.delegate = self
        let file = "User.txt"
        var arrUtil = [String]()
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            let path = dir.appendingPathComponent(file)
            //print(path)
            do{
                let contents = try String(contentsOf: path, encoding: String.Encoding.utf8)
                arrUtil = contents.components(separatedBy: ",")
                //print("\(arrUtil[0]),\(arrUtil[1])")
                if arrUtil[0] != "" && !arrUtil.isEmpty{
                    
                    print("hay usuario")
                    validate.isEnabled = true
                    new.isEnabled = false
                }else{
                    print("no hay usuario")
                    validate.isEnabled = false
                }
            }catch let error as NSError{
                
                print("fk \(error)")
                //login.isEnabled = false
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
        return(true)
    }
    
    
}
