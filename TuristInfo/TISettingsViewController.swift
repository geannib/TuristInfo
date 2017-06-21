//
//  TISettingsViewController.swift
//  TuristInfo
//
//  Created by Apple on 10/03/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit


enum AudioLanguages: Int{
    case En = 0
    case Ro = 1
    case Bg = 2
}

struct Constants {
    static let videoPathRO = "http://cdn118.arya.ro/videofiles"
    static let audioPathRO = "http://cdn118.arya.ro/audio"
}

 var currentLanguage = "Ro"
var selIndexPath: IndexPath = NSIndexPath(row: 1, section: 0) as IndexPath;

class TISettingsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var viewRed: UIView!


    @IBOutlet weak var tableView: UITableView!
    var selectedLang:AudioLanguages = .En;
    
    
    func i18(){
        
        //self.title = Localization("Settings.title")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var setLangRes = false
        
        
        var localeLang = currentLanguage
        if(selIndexPath.section == 10)
        {
            let pre = NSLocale.preferredLanguages[0]
            let arr = pre.components(separatedBy: "-")
            
            localeLang = String(arr[0]).lowercased()
        }
        
        switch localeLang
        {
        case "en":
            selIndexPath = NSIndexPath(row: 0, section: 0) as IndexPath;
            setLangRes = SetLanguage("English_en")
            currentLanguage = "En"
            break;
            
        case "ro":
            selIndexPath = NSIndexPath(row: 1, section: 0) as IndexPath;
            setLangRes = SetLanguage("Romanian_ro")
            currentLanguage = "Ro"
            
            break;
            
        case "bg":
            selIndexPath = NSIndexPath(row: 2, section: 0) as IndexPath;
            setLangRes = SetLanguage("Bulgarian_bg")
            currentLanguage = "Bg"
            break;
            
        default:
            currentLanguage = "Ro"
            break;
        }
        
        if(setLangRes == false){
            print("Someting wrong on setting language");
        }
        
        i18();
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = UIColor.white
        self.tableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0)
        tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selIndexPath = indexPath;
        tableView.reloadData();
        
        var setLangRes = false
        
        switch indexPath.row
        {
        case 0:
            setLangRes = SetLanguage("English_en")
            currentLanguage = "En"
            break;
            
        case 1:
            setLangRes = SetLanguage("Romanian_ro")
            currentLanguage = "Ro"
            break;
            
        case 2:
             setLangRes = SetLanguage("Bulgarian_bg")
             currentLanguage = "Bg"
            break;
            
        default:
            setLangRes = SetLanguage("Romanian_ro")
            currentLanguage = "Ro"
            break;
        }
       
        if(setLangRes == false){
            print("Someting wrong on setting language");
        }
        
        i18()
       
    }
}

//extension TISettingsViewController :UITableViewDelegate{
//    
//     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        selIndexPath = indexPath;
//        tableView.reloadData();
//    }
//}


extension TISettingsViewController : UITableViewDataSource {


func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    
    return 1;
}
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 3;
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = UITableViewCell()
    switch indexPath.row {
        
    case 0:
        cell.textLabel?.text = "English"
        cell.imageView?.image = UIImage(named:"us");
        cell.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        break;
        
    case 1:
        cell.textLabel?.text = "Romana"
        cell.imageView?.image = UIImage(named:"ro");
        break;
        
    case 2:
        cell.textLabel?.text = "български"
        cell.imageView?.image = UIImage(named:"bg");
        break
        
    default:
        cell.textLabel?.text = "English"
        break;
    }

    cell.accessoryType = indexPath == selIndexPath ? .checkmark : .none
    
    return cell
}


}

//extension String {
//    var localized: String {
//        if let _ = UserDefaults.standard.string(forKey: "i18n_language") {} else {
//            // we set a default, just in case
//            UserDefaults.standard.set("fr", forKey: "i18n_language")
//            UserDefaults.standard.synchronize()
//        }
//        
//        let lang = UserDefaults.standard.string(forKey: "i18n_language")
//        
//        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
//        let bundle = Bundle(path: path!)
//        
//        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
//    }
//}

