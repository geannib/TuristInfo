//
//  TIMapViewController.swift
//  TuristInfo
//
//  Created by Apple on 08/03/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import AVKit
import AVFoundation
import UserNotifications
import AudioToolbox
import MediaPlayer


class TIMapViewController: UIViewController {
    
    struct Objective{
        var id: String?
        var name: String?
        var nameEn:String?
        var nameBg:String?
        var lat : Double
        var long: Double
        var desc: String?
        var hasVideo: Bool
        var hasAudio: Bool
        var videoLink: String?
        var audioLink: String?
        var city: String?
        var county: String?
        var address: String?
        init(){
            name = "Name not set"
            nameEn = ""
            nameBg = ""
            lat = 44.31
            long = 23.81
            desc = ""
            hasVideo = false
            hasAudio = false
            videoLink = ""
            city = ""
            county = ""
            address = ""
            

        }
    }
    @IBOutlet weak var tableViewSearch: UITableView!
    @IBOutlet weak var playBackSlider: UISlider!
    @IBAction func onActionPlay(_ sender: Any) {
        
        playerQueue.play()
        self.viewPlayer.isHidden = false
    }

    @IBOutlet weak var viewPlayer: UIView!
    @IBAction func onActionStop(_ sender: Any) {
        
        playerQueue.pause()
    }
    @IBAction func onActionCloseSound(_ sender: Any) {
        
        playerQueue.pause()
        self.viewPlayer.isHidden = true
    }
   
    func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        playerQueue.seek(to: targetTime)
        
        if playerQueue.rate == 0
        {
            playerQueue.play()
        }
    }
    
    func resizeImage(_ image: UIImage, scale: CGFloat) -> UIImage {
        let size = image.size
        
        
        let widthRatio  = scale;// targetSize.width  / image.size.width
        let heightRatio = scale //targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func infoClicked(_ sender: Any) {
        geolocate()
       // self.performSegue(withIdentifier: "showDetailsSegue", sender: self)
       // perform(#selector(flip), with: nil, afterDelay: 2)
    }
    @IBOutlet weak var mapViewMain: GMSMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    var firstView: UIView!
    var secondView: UIView!
    var searchText:String = ""
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var objectivesList: [Objective]! = []
    var filteredCandies = [Objective]()
    var selectedObj:Objective = Objective()
    var gloabalIdx:Int = 849
    var latestLocation: CLLocation = CLLocation(latitude: 44, longitude: 25)
    var alertObjectivesNearDisplayed = false
    var currentRoute:GMSPolyline = GMSPolyline()
    var nearObjectives:[Objective] = []
    var isNearObjectivesMode:Bool = false
    var tableTitle:String = ""
    lazy var playerQueue : AVPlayer = {
        return AVPlayer()
    }()
    
    func geolocate()
    {
        self.gloabalIdx += 1;
        
        if(self.gloabalIdx >= self.objectivesList.count)
        {
            return;
        }
        self.selectedObj = self.objectivesList[gloabalIdx]
        let address = self.selectedObj.city! + ", " + self.selectedObj.county!;// + ", " + self.selectedObj.name!;
        
    CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) in
        if error != nil {
            //print(error)
           // print("failed geocoding for address \(self.selectedObj.id)")
             print("\nFAILED: \(address)----\(self.selectedObj.id!),\(self.selectedObj.name!),\(self.selectedObj.city!),\(self.selectedObj.county!),\(self.selectedObj.lat),\(self.selectedObj.long)")
            self.geolocate()
            //self.gloabalIdx -= 1
            return
        }
        if (placemarks?.count)! > 0 {
            let placemark = placemarks?[0]
            let location = placemark?.location
            let coordinate = location?.coordinate
            self.selectedObj.lat = coordinate!.latitude
            self.selectedObj.long = coordinate!.longitude
            //print("\nlat: \(coordinate!.latitude), long: \(coordinate!.longitude)")
            //print("Success geocoding for address \(address)")
            self.selectedObj.lat = coordinate!.latitude
            self.selectedObj.long = coordinate!.longitude
            print("\(self.selectedObj.id!),\(self.selectedObj.name!),\(self.selectedObj.city!),\(self.selectedObj.county!),\(self.selectedObj.lat),\(self.selectedObj.long)")
            
            self.geolocate()
          
        }
    })
    }
    
    func addLogoHeader(){
        let tv:UIView = UIView()
        tv.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        tv.backgroundColor = .clear
        tv.isOpaque = true
        self.navigationController?.navigationBar.addSubview(tv)
        let loadingView = tv
        let parentView = self.navigationController?.navigationBar
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        let pinTop = NSLayoutConstraint(item: loadingView,
                                        attribute: .top,
                                        relatedBy: .equal,
                                        toItem: parentView,
                                        attribute: .top,
                                        multiplier: 1.0,
                                        constant: 0)
        parentView?.addConstraint(pinTop)
        
        let pinBottom = NSLayoutConstraint(item: loadingView,
                                           attribute: .bottom,
                                           relatedBy: .equal,
                                           toItem: parentView,
                                           attribute: .bottom,
                                           multiplier: 1.0,
                                           constant: 0)
        parentView?.addConstraint(pinBottom)
        
        let horizontalConstraint = NSLayoutConstraint(item: loadingView,
                                                      attribute: NSLayoutAttribute.centerX,
                                                      relatedBy: NSLayoutRelation.equal,
                                                      toItem: parentView,
                                                      attribute: NSLayoutAttribute.centerX,
                                                      multiplier: 1,
                                                      constant: 0)
        parentView?.addConstraint(horizontalConstraint)
        
        let widthConstraint = NSLayoutConstraint(item: loadingView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: parentView,
                                                 attribute: .width,
                                                 multiplier: 0.55,
                                                 constant:0)
        parentView?.addConstraint(widthConstraint)
        
        let imgLeft:UIImageView = UIImageView()
        let imgRight:UIImageView = UIImageView()
        imgLeft.image = UIImage(named: "RO_BG_AudioGuideApp")
        imgRight.image = UIImage(named: "footer2_en.jpg")
        loadingView.addSubview(imgLeft)
        loadingView.addSubview(imgRight)
        imgLeft.translatesAutoresizingMaskIntoConstraints = false
        imgRight.translatesAutoresizingMaskIntoConstraints = false
        
        
        let pinTop2 = NSLayoutConstraint(item: imgLeft,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: loadingView,
                                         attribute: .top,
                                         multiplier: 1.0,
                                         constant: 0)
        loadingView.addConstraint(pinTop2)
        
        let pinBottom2 = NSLayoutConstraint(item: imgLeft,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: loadingView,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0)
        loadingView.addConstraint(pinBottom2)
        
        
        
        
        let pinLeading2 = NSLayoutConstraint(item: imgLeft,
                                             attribute: .leading,
                                             relatedBy: .equal,
                                             toItem: loadingView,
                                             attribute: .leading,
                                             multiplier: 1.0,
                                             constant: 0)
        loadingView.addConstraint(pinLeading2)
        
        //        let pinTrailing2 = NSLayoutConstraint(item: imgLeft,
        //                                             attribute: .trailing,
        //                                             relatedBy: .equal,
        //                                             toItem: imgRight,
        //                                             attribute: .trailing,
        //                                             multiplier: 1.0,
        //                                             constant: 0)
        //        loadingView.addConstraint(pinTrailing2)
        
        
        ////////
        let pinTop3 = NSLayoutConstraint(item: imgRight,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: loadingView,
                                         attribute: .top,
                                         multiplier: 1.0,
                                         constant: 0)
        loadingView.addConstraint(pinTop3)
        
        let pinBottom3 = NSLayoutConstraint(item: imgRight,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: loadingView,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0)
        loadingView.addConstraint(pinBottom3)
        
        
        
        
        //        let pinLeading3 = NSLayoutConstraint(item: imgRight,
        //                                             attribute: .leading,
        //                                             relatedBy: .equal,
        //                                             toItem: imgLeft,
        //                                             attribute: .leading,
        //                                             multiplier: 1.0,
        //                                             constant: 0)
        //        loadingView.addConstraint(pinLeading3)
        
        let pinTrailing3 = NSLayoutConstraint(item: imgRight,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: loadingView,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0)
        loadingView.addConstraint(pinTrailing3)
        
        /////
        
        let widthConstraint2 = NSLayoutConstraint(item: imgLeft,
                                                  attribute: .width,
                                                  relatedBy: .equal,
                                                  toItem: loadingView,
                                                  attribute: .width,
                                                  multiplier: 0.45,
                                                  constant:0)
        loadingView.addConstraint(widthConstraint2)
        
        let widthConstraint3 = NSLayoutConstraint(item: imgRight,
                                                  attribute: .width,
                                                  relatedBy: .equal,
                                                  toItem: loadingView,
                                                  attribute: .width,
                                                  multiplier: 0.45,
                                                  constant:0)
        loadingView.addConstraint(widthConstraint3)

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        addLogoHeader()
        
        self.viewPlayer.isHidden = true
        loadObjectives()
        self.tableViewSearch.isHidden = true
        //self.mapViewMain.mapType = kGMSTypeTerrain
        self.setupMap()
        self.title = "Audio travel guide"
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //locationManager.startUpdatingLocation()
        startLocation = nil
        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
//        let navItem = UINavigationItem(title: "Info turist");
//        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.organize, target: nil, action: #selector(flip));
//        navItem.leftBarButtonItem = doneItem;
//        self.navigationController?.navigationBar.setItems([navItem], animated: false);
//        let button1 = UIBarButtonItem(image: UIImage(named: "add_new_button_plus"), style: .plain, target: self, action: Selector("flip")) // action:#selector(Class.MethodName) for swift 3
//        self.navigationItem.leftBarButtonItem  = button1
        
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "side_menu_hamburger_icon"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(flip), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        let btn2 = UIButton(type: .custom)
        let img2:UIImage = resizeImage(UIImage(named: "ic_location_point_white 3")!, scale: 0.2);
        
        btn2.setImage(img2, for: .normal)
        btn2.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn2.addTarget(self, action: #selector(search), for: .touchUpInside)
        let item2 = UIBarButtonItem(customView: btn2)
        
//        let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "Roboto-Medium", size: 18)! ]
//    
//        let attributedTitle = NSMutableAttributedString(string: "Audio travel guilde", attributes: titleFont)
//        self.navigationItem.setValue(attributedTitle, forKey: "attributedTitle")
        
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto-Medium", size: 18)!, NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
    
        
        
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        self.navigationItem.setRightBarButtonItems([item2], animated: true)
        
        
        self.searchBar.tintColor = UIColor.blue;
        firstView = UIView(frame: CGRect(x: 32, y: 32, width: 128, height: 128))
        secondView = UIView(frame: CGRect(x: 32, y: 32, width: 128, height: 128))
        
        firstView.backgroundColor = UIColor.red
        secondView.backgroundColor = UIColor.blue
        
        secondView.isHidden = true
        
        UIApplication.shared.cancelAllLocalNotifications();
        registerLocal()
        
//        view.addSubview(firstView)
//        view.addSubview(secondView)
        
        
        // Do any additional setup after loading the view.
    }

    func composeNearObjMessage() -> (String, Bool, [Objective]){
        
        var mess = ""
        var found = false
        var objectives:[Objective] = []
        for obj in self.objectivesList
        {
            let objLocation = CLLocation(latitude: obj.lat, longitude: obj.long)
            let distance = objLocation.distance(from: latestLocation)
            
            if(distance < 1000 ){
                
                objectives.append(obj)
                mess += obj.name! + ",";
               // mess += String(format:"%f", distance) + ","
                mess += "\n"
                found = true
            }
        }
        
        if mess == "" {
            
            mess = "0 objectives in 1000 m"
            
        } else {
        
            let index = mess.index(mess.endIndex, offsetBy: -2)
            mess = mess.substring(to: index)
        }
        return (mess, found, objectives);
    }
    
    func scheduleLocalNotification()
    {
        let mess = composeNearObjMessage()
        
        self.tableTitle = Localization("Main.notification.title")
        
        self.filteredCandies = mess.2
        
        if(mess.1 == false){
            
            print (Localization("Main.notification.zero"))
            
            return
            
        }
        
        alertObjectivesNearDisplayed = true;
        
        self.tableViewSearch.isHidden = false
        self.tableViewSearch.reloadData()
        
//        let alertController = UIAlertController(title: Localization("Main.notification.title"), message: mess.0, preferredStyle: UIAlertControllerStyle.alert)
//        
//        let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "Roboto-Medium", size: 18)! ]
//        let messageFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 14)! ]
//        
//        let attributedTitle = NSMutableAttributedString(string: Localization("Main.notification.title"), attributes: titleFont)
//        let attributedMessage = NSMutableAttributedString(string: mess.0, attributes: messageFont)
//        
//        alertController.setValue(attributedTitle, forKey: "attributedTitle")
//        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        
        //        // Action.
        //        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        //        action.setValue(UIColor.black, forKey: "titleTextColor")
        //        //action.setValue(myString, forKey: "attributedTitle")
        //        alertController.addAction(action)
        
//        let OKAction = UIAlertAction(title: Localization("OK"), style: .default) { (action) in
//            
//            
//        }
//        alertController.addAction(OKAction)
//        
////        let CancelAction = UIAlertAction(title: Localization("Main.cancel"), style: .default) { (action) in
////            
////        }
////        alertController.addAction(CancelAction)
//        
//        self.present(alertController, animated:true){
//            
//        }
        
        if #available(iOS 10.0, *) {
            let content = UNMutableNotificationContent()
       
        content.title = Localization("Main.notification.title")
            
        content.body = mess.0
        
        // Deliver the notification in five seconds.
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,
                                                        repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        } else {
            // Fallback on earlier versions
        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func i18()
    {
        if currentLanguage.lowercased() == "ro" {
            
            SetLanguage("Romanian_ro")
        }
        SetLanguage(currentLanguage)
        let title = Localization("Main.title")
        let searchPlaceHolder = Localization("Main.search.placeholder")
        
        self.title = title
        self.searchBar.placeholder = searchPlaceHolder
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        i18()
//        self.title =  NSLocalizedString("Main.title", // Unique key of your choice
//            value:"default text", // Default (English) text
//            comment:"Window title")//NSLocalizedString("AAA", tableName: "Localizable.strings", bundle: Bundle.main, value: "", comment: "");
//         let arr = Localisator.sharedInstance.getArrayAvailableLanguages()
//        //Localisator.sharedInstance.currentLanguage = "ro"
//        SetLanguage("Romanian_ro")
//        let strx = Localisator.sharedInstance.currentLanguage;
//        let lstr = Localization("Main.title")
//        self.title = lstr
//        let str = NSLocalizedString("Main.title", // Unique key of your choice
//            value:"Hello, world!", // Default (English) text
//            comment:"Window title")
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
        
        self.viewPlayer.isHidden = true
        self.playerQueue.pause()
    
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func adjustCoordingates(obj: inout Objective){
        
        var found = false;
        
        for tmpObj in self.objectivesList{
            if(tmpObj.lat == obj.lat && tmpObj.long == obj.long){
                
                //move a little
                let randLat = Double(arc4random_uniform(UInt32(10)))/1000
                let randLong = Double(arc4random_uniform(UInt32(10)))/1000
                obj.lat = obj.lat + randLat
                obj.long = obj.long + randLong
                
                found = true
               // print("\(randLat),\(randLong)---Objective \(obj.name) was moved similar to \(tmpObj.name)")
                break;
            }
        }
        
        if found == true{
            adjustCoordingates(obj: &obj)
        }
    }
    
    func loadi18Names(){
    
        if let filepathSplit = Bundle.main.path(forResource: "names_ro_en", ofType: "csv")
        {
            do
            {
                let splitContent = try String(contentsOfFile: filepathSplit)
                let objBlocks = splitContent.components(separatedBy: "\n")
                
                for objBlock in objBlocks {
                    
                    let words = objBlock.components(separatedBy: ",")
                    // 7 we have localitate, judet
                    var code = ""
                    var roName = ""
                    var enName = ""
                    if(words.count == 7)
                    {
                         code = words[0]
                         roName = words[1]
                         enName = words[4]
                    }
                    //9 - we have sat, comuna,judet
                    if(words.count == 9)
                    {
                         code = words[0]
                         roName = words[1]
                         enName = words[5]
                    }
                    
                    // Loop through Objectives and set the name
                    
                    for i in 0 ... self.objectivesList.count - 1 {
                        
                        if self.objectivesList[i].id == code{
                            
                            self.objectivesList[i].nameEn = enName
                            self.objectivesList[i].nameBg = enName
                        }
                    }
                }
            }catch
            {
                // contents could not be loaded
            }
        }else
        {
            print("split.txt was not found")
        }

    }
    func loadObjectives(){
    
        var obj:Objective = Objective()
    
        
    
        if let filepath = Bundle.main.path(forResource: "names_ro_en_bg", ofType: "csv")
        {
            do
            {
                let contents = try String(contentsOfFile: filepath)
                let lines = contents.components(separatedBy: "\n")
                for line in lines {
                    let words = line.components(separatedBy: ",")
                    
                    if(words.count == 10)
                    {
                        obj.id = words[0]
                        obj.name = words[1]
                        obj.nameEn = words[2]
                        obj.nameBg = words[5]
                        obj.city = words[3]
                        
                        let str4 = words[8];
                        if Double(str4) != nil
                        {
                            obj.lat = Double(words[8])!
                        }
                        
                        let index2 = words[9].index(words[9].endIndex, offsetBy: -1)
                        let substring2 = words[9].substring(to: index2)
                        if Double(substring2) != nil
                        {
                            obj.long = Double(substring2)!
                        }
                        adjustCoordingates(obj: &obj);
                        
                        let index1 = words[4].index(words[4].endIndex, offsetBy: 0)
                        
                        let substring1 = words[4].substring(to: index1)
                        obj.county = substring1
                        
                        let address =  obj.city! + ", " + obj.county!
                        obj.address = address
                    
                        self.objectivesList.append(obj)
                    }
                    
                }
                
            }
            catch
            {
                // contents could not be loaded
            }
        }
        else
        {
            // example.txt not found!
        }
        
        
        // Add video flag
        if let filepath = Bundle.main.path(forResource: "video", ofType: "csv")
        {
            do
            {
                let contents = try String(contentsOfFile: filepath)
                let lines = contents.components(separatedBy: "\n")
                for line in lines {
                    
                    let words = line.components(separatedBy: ",")
                    let str4 = words[0];
                    if Double(str4) != nil
                    {
                        let idStr = str4;
                        
                        for i in 0 ... self.objectivesList.count - 1{
                            var tmpObj = self.objectivesList[i]
                            if(tmpObj.id == idStr){
                                self.objectivesList[i].hasVideo = true
                                break;
                            }
                        }

                    }
                }
            }
            catch
            {
                // contents could not be loaded
            }
        }
        
        
        // add audio flag
        // Add video flag
        if let filepath = Bundle.main.path(forResource: "audio", ofType: "csv")
        {
            do
            {
                let contents = try String(contentsOfFile: filepath)
                let lines = contents.components(separatedBy: "\n")
                for line in lines {
                    
                    let words = line.components(separatedBy: ",")
                    let str4 = words[0];
                    if Double(str4) != nil
                    {
                        let idStr = str4;
                        
                        for i in 0 ... self.objectivesList.count - 1{
                            var tmpObj = self.objectivesList[i]
                            if(tmpObj.id == idStr){
                                self.objectivesList[i].hasAudio = true
                                break;
                            }
                        }
                        
                    }
                }
            }
            catch
            {
                // contents could not be loaded
            }
        }

        
        // Add description
        if let filepathSplit = Bundle.main.path(forResource: "split", ofType: "txt")
        {
            do
            {
                let splitContent = try String(contentsOfFile: filepathSplit)
                let objBlocks = splitContent.components(separatedBy: "<obiectiv>")
                
                for objBlock in objBlocks {
                    
                    let headerLen = objBlock.range(of: "\n")
                    if(headerLen == nil){
                        print("invalid block")
                        continue
                    }
                    let headerStr:String = objBlock.substring(to: (headerLen?.lowerBound)!)
                    //let hi = string.index(headerLen?.upperBound, offsetBy: 3)
                    let descStr = objBlock.substring(from: (headerLen?.upperBound)!)

                    
                    let headerComps = headerStr.components(separatedBy: ",")
                    // First word should be the code
                    if headerComps.count > 0
                    {
                        let objId = headerComps[0]
                        for i in 0 ... self.objectivesList.count - 1{
                           var tmpObj = self.objectivesList[i]
                            if(tmpObj.id == objId){
                                self.objectivesList[i].desc = descStr
                                break;
                            }
                        }
                    }
                }
            }catch
            {
                // contents could not be loaded
            }
        }else
        {
            print("split.txt was not found")
        }
        
//        print("EVERYTHING")
//       for obj2 in self.objectivesList
//       {
//        print("\(obj2.name!) lat:\(obj2.lat) long:\(obj2.long) addrr:\(obj2.address!)")
//        }
        
    }
    func registerLocal() {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
        
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
            
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                
                switch setttings.soundSetting{
                case .enabled:
                    
                    print("enabled sound setting")
                    
                case .disabled:
                    
                    print("setting has been disabled")
                    
                case .notSupported:
                    print("something vital went wrong here")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
       
    }
        
    
    func setupMap()
    {

        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 10.
        mapViewMain.isMyLocationEnabled = true
        mapViewMain.delegate = self
        let camera = GMSCameraPosition.camera(withLatitude: 43.41, longitude: 25.54, zoom: 8)
       mapViewMain.animate(to: camera)
        
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
        
        // Creates a marker in the center of the map.
        for obj in self.objectivesList{
            
            let marker = GMSMarker();
            marker.position = CLLocationCoordinate2D(latitude: obj.lat, longitude: obj.long)
            //print("Added marker at lat:\(obj.lat),long: \(obj.long)")
            marker.title = obj.name
            marker.snippet = "";//obj.desc
            marker.userData = obj
            marker.map = mapViewMain
            //marker.icon = GMSMarker.markerImage(with: UIColor.red)
        }


    }
    
    func search(){
        
        let mess = composeNearObjMessage()
        self.tableTitle = Localization("Main.notification.title")
        self.filteredCandies = mess.2

        
        
        if(mess.1 == false){
            
            print (Localization("Main.notification.zero"))
            
            let drawOption : UIAlertController = UIAlertController(title: Localization("Main.notification.zero"), message: "", preferredStyle: .alert)
            let d0 = UIAlertAction(title: "OK", style: .default) { (action) in
                drawOption.dismiss(animated: true, completion: nil)
            }
            drawOption.addAction(d0)
        
            self.present(drawOption, animated: true) {
                // ...
            }
            

            
            return
            
        }
        self.tableViewSearch.isHidden = false
        self.tableViewSearch.reloadData()
        
//        let alertController = UIAlertController(title: Localization("Main.notification.title"), message: mess.0, preferredStyle: UIAlertControllerStyle.alert)
//        
//               let OKAction = UIAlertAction(title: Localization("OK"), style: .default) { (action) in
//            
//        }
//        alertController.addAction(OKAction)
//        
//        self.present(alertController, animated:true){
//            
//        }
        
//        self.tableViewSearch.isHidden = false;
//        self.tableViewSearch.alpha = 0.85;
    }
    func flip() {
        
//        geolocate()
//        return;
        self.tableViewSearch.isHidden = true
        self.performSegue(withIdentifier: "showSettingsSegue", sender: self)
        
//        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
//        
//        UIView.transition(with: firstView, duration: 1.0, options: transitionOptions, animations: {
//            self.firstView.isHidden = true
//        })
//        
//        UIView.transition(with: secondView, duration: 1.0, options: transitionOptions, animations: {
//            self.secondView.isHidden = false
//        })
    }
}

extension TIMapViewController:TICustomMarkerDelegate{
    
    func buttonTapped(_ sender: UIButton!) {
        print("Yeah! Button is tapped!")
    }
    func playAsset(){
        
    }
}

extension TIMapViewController:GMSMapViewDelegate{
    
    func playSound(objective: Objective){
        
         let strUrl = String(format: "%@/%@/%@.wav", Constants.audioPathRO, currentLanguage.lowercased(), objective.id!)
        
        let url = NSURL(string: strUrl)
        print("the url = \(url!)")
        let playerItem = AVPlayerItem.init(url: url as! URL )
        self.playerQueue = AVPlayer(playerItem: playerItem)
        
        self.viewPlayer.isHidden = false;
        
        playBackSlider.minimumValue = 0
        
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.tintColor = UIColor.green
        self.viewPlayer.isHidden = false
        playBackSlider.value = 0
        
        playBackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        self.playerQueue.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.playerQueue.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.playerQueue.currentTime());
                self.playBackSlider!.value = Float ( time );
            }
        }
        
        self.playerQueue.play()

       // downloadFileFromURL(url: url!)
    }

     func playVideo(objective:Objective)
    {
        let strUrl = String(format: "%@/%@/%@.mp4", Constants.videoPathRO, currentLanguage, objective.id!)
        
        let videoURL = NSURL(string: strUrl)
        //"http://www.ebookfrenzy.com/ios_book/movie/movie.mov")
            let player = AVPlayer(url: videoURL! as URL)
        
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }

    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    
//    func downloadFileFromURL(url:NSURL){
//        weak var weakSelf = self
//        var downloadTask:URLSessionDownloadTask
//        downloadTask = URLSession.sharedSession.downloadTaskWithURL(url, completionHandler: { (URL, response, error) -> Void in
//            
//            weakSelf!.play(URL!)
//            
//        })
//        
//        downloadTask.resume()
//        
//    }
//    
//    func play(url:NSURL) {
//        print("playing \(url)")
//        
//        let playerItem = AVPlayerItem.init(url: url as URL)
//        self.playerQueue.insert(playerItem, after: nil)
//        self.playerQueue.play()
//        
//    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        let objective:Objective = (marker.userData as? Objective)!
        self.selectedObj = objective;
        let markerId:String = objective.id! // (marker.userData as? String)!;
        
        var mess = objective.id! + ": "
        
        if(currentLanguage == "En"){
            
            mess += objective.nameEn!;
        }
        if(currentLanguage == "Bg"){
            
            mess += objective.nameBg!;
        }
        if(currentLanguage == "Ro"){
            
            mess += objective.name!;
        }
        mess = mess + ", " + objective.address!
        
        let objLocation = CLLocation(latitude: self.selectedObj.lat, longitude: self.selectedObj.long)
        let distance = objLocation.distance(from: latestLocation)
        let strDistance = String(format:"%.2f", distance/1000)
      
        let titleFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "Roboto-Medium", size: 18)! ]
        let messageFont:[String : AnyObject] = [ NSFontAttributeName : UIFont(name: "Roboto-Regular", size: 14)! ]
        let attributedTitle = NSMutableAttributedString(string: mess, attributes: titleFont)
        let attributedMessage = NSMutableAttributedString(string: "\(strDistance) km", attributes: messageFont)
       
        
        let av : UIAlertController = UIAlertController(title:mess, message: "", preferredStyle: .alert)
        
        let alertController = UIAlertController(title: "Alert Title", message: "This is testing message.", preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        
//        // Action.
//        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
//        action.setValue(UIColor.black, forKey: "titleTextColor")
//        //action.setValue(myString, forKey: "attributedTitle")
//        alertController.addAction(action)
        
        if(self.selectedObj.hasVideo == true)
        {
            let PlayVideoAction = UIAlertAction(title: Localization("Main.downloadVideo"), style: .default) { (action) in
                
                self.playVideo(objective: objective)
            }
            alertController.addAction(PlayVideoAction)
        }
        
        if(self.selectedObj.hasAudio == true)
        {
            let PlayAudioAction = UIAlertAction(title: Localization("Main.downloadAudio"), style: .default) { (action) in
                
                //self.playVideo()
               // self.scheduleLocalNotification()
                self.playSound(objective: objective)
            }
            alertController.addAction(PlayAudioAction)
        }
        
        
        let viewDetailsAction = UIAlertAction(title: Localization("Main.viewDetails"), style: .default) { (action) in
            
            self.searchBar.resignFirstResponder()
            self.performSegue(withIdentifier: "showDetailsSegue", sender: self)
        }
        alertController.addAction(viewDetailsAction)
        
        let drawRouteAction = UIAlertAction(title: Localization("Main.DrawRoute"), style: .default) { (action) in
            
            let orig:CLLocationCoordinate2D = self.latestLocation.coordinate
            
            var dest:CLLocationCoordinate2D = CLLocationCoordinate2D()
            dest.latitude = self.selectedObj.lat
            dest.longitude = self.selectedObj.long
            
            //self.mapViewMain.clear();
            self.currentRoute.map = nil
            let drawOption : UIAlertController = UIAlertController(title: Localization("Main.DrawRoute_mode_title"), message: "", preferredStyle: .alert)
            let d0 = UIAlertAction(title: Localization("Main.DrawRoute_mode_driving"), style: .default) { (action) in
                self.fetchMapData(orig: orig, dest: dest, mode:"driving")
            }
            drawOption.addAction(d0)
            let d1 = UIAlertAction(title: Localization("Main.DrawRoute_mode_walking"), style: .default) { (action) in
                self.fetchMapData(orig: orig, dest: dest, mode: "walking")
            }
            drawOption.addAction(d1)
            let d2 = UIAlertAction(title: Localization("Main.DrawRoute_mode_bicycling"), style: .default) { (action) in
                self.fetchMapData(orig: orig, dest: dest, mode: "bicycling")
            }
            drawOption.addAction(d2)
            
            let d3 = UIAlertAction(title: Localization("Main.DrawRoute_mode_transit"), style: .default) { (action) in
                self.fetchMapData(orig: orig, dest: dest, mode: "transit")
            }
            drawOption.addAction(d3)
            self.present(drawOption, animated: true) {
                // ...
            }
            
            
            alertController.dismiss(animated: false, completion: nil)
            
            //self.performSegue(withIdentifier: "showDetailsSegue", sender: self)
        }
        alertController.addAction(drawRouteAction)
        
        
        let CancelAction = UIAlertAction(title: Localization("Main.cancel"), style: .destructive) { (action) in
            av.dismiss(animated: true, completion: {})
        }
        alertController.addAction(CancelAction)
        
        self.searchBar.resignFirstResponder()
        self.present(alertController, animated: true) {
            // ...
        }
        
        return true;
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker)
    {
        
    }
//    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView?
//    {
//        //let index:Int! = Int(marker.accessibilityLabel!)
//
//        let customInfoWindow = Bundle.main.loadNibNamed("TICustomMarker", owner: self, options: nil)?[0] as! TICustomMarker
//        customInfoWindow.labelTitle.text = "Here will be the title"
//        customInfoWindow.labelDesc.text = "Here will be some desc"
//        customInfoWindow.buttonPlayAsset.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//        customInfoWindow.delegate = self;
//        
//        return customInfoWindow
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    
        if let objDetails = segue.destination as? TIObjectiveDetailsViewController{
            
            objDetails.objective = self.selectedObj;
            
        }
    }
}
extension TIMapViewController: UITableViewDelegate{
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    self.tableTitle = ""
    let selectedObj = self.filteredCandies[indexPath.row];
    print("Selected obj is \(selectedObj.name)");
    
    self.searchBar.resignFirstResponder()
    self.searchBar.endEditing(true)

    self.selectedObj = self.filteredCandies[indexPath.row]
    tableViewSearch.isHidden = true
    self.searchBar.text = ""
    
    
    let marker = GMSMarker();
    marker.position = CLLocationCoordinate2D(latitude: self.selectedObj.lat, longitude: self.selectedObj.long)
    
    if(currentLanguage == "En"){
        
        marker.title = self.selectedObj.nameEn;
    }
    if(currentLanguage == "Bg"){
        
        marker.title = self.selectedObj.nameBg;
    }
    if(currentLanguage == "Ro"){
        
        marker.title = self.selectedObj.name;
    }
 
    //marker.snippet = self.selectedObj.desc
    marker.userData = self.selectedObj
    marker.map = mapViewMain
    
    self.mapViewMain.selectedMarker = marker;
    let camera = GMSCameraPosition.camera(withLatitude: self.selectedObj.lat, longitude: self.selectedObj.long, zoom: 17)
    self.mapViewMain.camera = camera
    //self.performSegue(withIdentifier: "showDetailsSegue", sender: self)
    }
}


extension TIMapViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return self.filteredCandies.count;
       // return self.objectivesList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.tableTitle
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if ( self.tableTitle.characters.count > 0){
            
            return 50.0
            
        }else{
            
            return CGFloat.leastNormalMagnitude
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "SubtitleCell")
        
        let obj = self.filteredCandies[indexPath.row];

        if(currentLanguage == "En"){
            
            cell.textLabel?.text = obj.nameEn;
        }
        if(currentLanguage == "Bg"){
            
            cell.textLabel?.text = obj.nameBg;
        }
        if(currentLanguage == "Ro"){
            
            cell.textLabel?.text = obj.name;
        }
        
        cell.detailTextLabel?.text = obj.address
        return cell;
    }
    
}

extension TIMapViewController: CLLocationManagerDelegate {
   
    

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        
        if status == .authorizedAlways {
            print ("Location manager: authorization when in use success");
            locationManager.startUpdatingLocation()
            mapViewMain.isMyLocationEnabled = true
            mapViewMain.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        self.latestLocation = locations[locations.count - 1]
        
       
        
        if(alertObjectivesNearDisplayed == false){
            
             alertObjectivesNearDisplayed = true;
            _ = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(scheduleLocalNotification), userInfo: nil, repeats: false)
                
        }
        

        // print ("location updated\(latestLocation.coordinate.latitude), \(latestLocation.coordinate.longitude)")
    }
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        
    }
}


extension TIMapViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        
        if (self.filteredCandies.count > 0){
            
            self.tableView(self.tableViewSearch, didSelectRowAt: IndexPath(row: 0, section: 0))
      
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        let test = 4;
        self.tableTitle = ""
        
       
        if(searchText.characters.count) > 0{
            
            self.tableViewSearch.isHidden = false
            
            let srcText = searchText.lowercased()
            
            let fullNameArr = srcText.characters.split {$0 == " "}.map(String.init)
            for word in fullNameArr {
                
                switch currentLanguage.lowercased(){
                    
                case "ro":
                    self.filteredCandies =  self.objectivesList.filter { ($0.name?.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(word))! }
                    break;
                    
                case "en":
                    self.filteredCandies =  self.objectivesList.filter { ($0.nameEn?.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(word))! }
                    break;
                    
                case "bg":
                    self.filteredCandies =  self.objectivesList.filter { ($0.nameBg?.lowercased().folding(options: .diacriticInsensitive, locale: .current).contains(word))! }
                    break;
                    
                default:
                    self.filteredCandies =  self.objectivesList.filter { ($0.name?.lowercased().contains(word))! }
                    break;
                }
                
                self.filteredCandies += self.objectivesList.filter{($0.id?.lowercased().contains(word))!}
                
            }// for
            let orderedSet:NSOrderedSet = NSOrderedSet(array: self.filteredCandies)
            //self.filteredCandies
          
            
            self.tableViewSearch.reloadData()
            }else{
                self.tableViewSearch.isHidden = true
            }
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        
        self.searchBar.resignFirstResponder()
     
        let test = 4;
    }
    func fetchMapData(orig: CLLocationCoordinate2D, dest:CLLocationCoordinate2D, mode: String) {
        

      
        
        
        let origStr:String = String(format: "%f,%f", orig.latitude, orig.longitude)
        let destStr:String = String(format:"%f,%f", dest.latitude, dest.longitude)
        
        //&waypoints=48.4833428800255,35.0710221379995|48.4887622031403,35.0573639944196
        let plainStr =  NSString(format:"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&key=%@&mode=%@",
                                 origStr,
                                 destStr,
                                 "AIzaSyAQHlVJRsNSzMQ98ZTpOXS6jzOb4Nl9hsU",
                                 mode)
        
        let url = URL(string: plainStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            print("Entered the completionHandler")
            
            guard let data = data, err == nil else {
                print(err?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let JSON = responseJSON as? [String: Any] {
                print(JSON)

                let mapResponse: [String: AnyObject] = JSON as! [String : AnyObject]
                
                let status = mapResponse["status"];
//                if(status != "OK"){
//                    print("route failed");
//                }
                let routesArray = (mapResponse["routes"] as? Array) ?? []
                
                if(routesArray.count == 0){
                    
                    let drawOption : UIAlertController = UIAlertController(title: Localization("Main.noRoute"), message: "", preferredStyle: .alert)
                    let d0 = UIAlertAction(title: "OK", style: .default) { (action) in
                        
                        drawOption.dismiss(animated: true, completion: nil)
                    }
                    drawOption.addAction(d0)
                    
                    self.present(drawOption, animated: true) {
                        // ...
                    }

                }
                
                let routes = (routesArray.first as? Dictionary<String, AnyObject>) ?? [:]
                
                let overviewPolyline = (routes["overview_polyline"] as? Dictionary<String,AnyObject>) ?? [:]
                let polypoints = (overviewPolyline["points"] as? String) ?? ""
                let line  = polypoints
                
                self.addPolyLine(encodedString: line)
           }

            }.resume()

        
        
    }
    
    func addPolyLine(encodedString: String) {
        
        let path = GMSMutablePath(fromEncodedPath: encodedString)
        currentRoute = GMSPolyline(path: path)
        currentRoute.strokeWidth = 5
        currentRoute.strokeColor = .blue
        currentRoute.map = self.mapViewMain
        
        //GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:yourPath];
     
        let bounds = GMSCoordinateBounds(path: path!)
        let cameraUpdate = GMSCameraUpdate.fit(bounds)
        mapViewMain.animate(with: cameraUpdate)
      
        return;
        let hydeParkLocation = CLLocationCoordinate2D(latitude: -33.87344, longitude: 151.21135)
        let camera = GMSCameraPosition.camera (withTarget: hydeParkLocation, zoom: 16)
//        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//        mapView.animate(to: camera)
        
        let hydePark = "tpwmEkd|y[QVe@Pk@BsHe@mGc@iNaAKMaBIYIq@qAMo@Eo@@[Fe@DoALu@HUb@c@XUZS^ELGxOhAd@@ZB`@J^BhFRlBN\\BZ@`AFrATAJAR?rAE\\C~BIpD"
        let archibaldFountain = "tlvmEqq|y[NNCXSJQOB[TI"
        let reflectionPool = "bewmEwk|y[Dm@zAPEj@{AO"
        
        let polygon = GMSPolygon()
        let pathDecoded = GMSPath(fromEncodedPath: encodedString)
        polygon.path = GMSPath(fromEncodedPath: encodedString)
        polygon.holes = [GMSPath(fromEncodedPath: archibaldFountain)!, GMSPath(fromEncodedPath: reflectionPool)!]
        polygon.fillColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        polygon.strokeColor = UIColor(colorLiteralRed: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        polygon.strokeWidth = 2
        polygon.map = self.mapViewMain
        //view = self.mapViewMain

       
        
//        let path = GMSMutablePath()
//        path.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
//        path.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.0))
//        path.add(CLLocationCoordinate2D(latitude: 37.45, longitude: -122.2))
//        path.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.2))
//        path.add(CLLocationCoordinate2D(latitude: 37.36, longitude: -122.0))
//        
//        let rectangle = GMSPolyline(path: path)
//        rectangle.map = self.mapViewMain
//        let camera = GMSCameraPosition.camera(withLatitude: 48.48, longitude: 35.06, zoom: 8)
//        self.mapViewMain.camera = camera
        
        
        //remove path
//        let camera = GMSCameraPosition.camera(withLatitude: -33.8683,
//                                              longitude: 151.2086,
//                                              zoom:12)
//        let mapView = GMSMapView.map(withFrame: self.view.bounds, camera: camera)
//            ...
//            mapView.clear()
        //https://developers.google.com/maps/documentation/ios-sdk/shapes
    }
}

extension String {
    func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.upperBound
        }
        return result
    }
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.upperBound
        }
        return result
    }
}

