//
//  TIObjectiveDetailsViewController.swift
//  TuristInfo
//
//  Created by Apple on 10/03/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TIObjectiveDetailsViewController: UIViewController {

    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var imageViewVideo: UIImageView!
    @IBOutlet weak var imageViewAudio: UIImageView!
    @IBOutlet weak var constraintViewPlayerHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintViewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewControls: UIView!
    @IBOutlet weak var viewAudio: UIView!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var viewPlayer: UIView!
    @IBOutlet weak var playBackSlider: UISlider!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonDownloadSound: UIButton!
    @IBOutlet weak var buttonDownloadVideo: UIButton!
    @IBOutlet weak var textViiewDetails: UITextView!
    var objective: TIMapViewController.Objective = TIMapViewController.Objective()
    var audioItemDuration: CMTime = CMTime();
    var player:AVPlayer?
    
 
    @IBAction func onActionCloseSound(_ sender: Any) {
         player?.pause()
        self.viewPlayer.isHidden = true
    }
    @IBAction func onActionPlayButton(_ sender: Any) {
       
        player?.pause()
    }
  
    @IBAction func onActionStop(_ sender: Any) {
        
        player?.play()
        self.viewPlayer.isHidden = false
    }
    func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(seconds, 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
        }
    }
    
    @IBAction func doDownloadVideo(_ sender: Any) {
        
      
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


    @IBAction func doDownloadSound(_ sender: Any) {
        
        let strUrl = String(format: "%@/%@/%@.wav", Constants.audioPathRO, currentLanguage.lowercased(), objective.id!)
        
        let url = NSURL(string: strUrl)
        print("the url = \(url!)")
        let playerItem = AVPlayerItem.init(url: url as! URL )
        self.audioItemDuration = playerItem.duration
        self.player = AVPlayer(playerItem: playerItem);
        
        playBackSlider.minimumValue = 0
        
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        
        playBackSlider.maximumValue = Float(seconds)
        playBackSlider.isContinuous = true
        playBackSlider.tintColor = UIColor.green
        self.viewPlayer.isHidden = false
        playBackSlider.value = 0
        
        playBackSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
      
        player!.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                self.playBackSlider!.value = Float ( time );
            }
        }
        player?.play()
    }
   
     func playerDidFinishPlaying(notification:NSNotification){
        let t = 3;
    }

    func i18(){
        
        //self.title = Localization("Details.title")
        self.buttonDownloadSound.setTitle(Localization("Details.downloadAudio"), for: .normal)
        self.buttonDownloadVideo.setTitle(Localization("Details.downloadVideo"), for: .normal)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewPlayer.isHidden = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor.blue
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.buttonDownloadSound.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 15)
        self.buttonDownloadVideo.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 15)
        self.labelTitle.font = UIFont(name: "Roboto-Medium", size: 20)
        self.textViiewDetails.font = UIFont(name: "Roboto-Medium", size: 15)
        // Do any additional setup after loading the view.
        
        self.viewControls.backgroundColor = UIColor.clear
        self.viewVideo.backgroundColor = UIColor.clear
        self.viewAudio.backgroundColor = UIColor.clear
        self.viewPlayer.backgroundColor = UIColor.clear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated)
        
        self.player?.pause()
        self.viewPlayer.isHidden = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        i18()
   
        self.viewPlayer.isHidden = true
        
        //textViiewDetails.text = self.objective.desc
        let fileName = String(format: "%@", self.objective.id!)
        var resPath = Bundle.main.resourcePath!
        textViiewDetails.text = "Description not found";

        let fileFullPath = String(format:"%@/details/%@/%@.txt",resPath, currentLanguage.lowercased(), self.objective.id!)
        do {
            let fileContent = try   String(contentsOfFile: fileFullPath, encoding: String.Encoding.utf8)
            textViiewDetails.text = fileContent
        
        
    }catch
    {
    // contents could not be loaded
    }
    
        if(currentLanguage == "En"){
    
            self.labelTitle.text = self.objective.id! + ": " + self.objective.nameEn! + ", " + self.objective.address!;
        }
        if(currentLanguage == "Bg"){
    
            self.labelTitle.text = self.objective.id! + ": " + self.objective.nameBg! + ", " + self.objective.address!;
        }
        if(currentLanguage == "Ro"){
    
            self.labelTitle.text = self.objective.id! + ": " + self.objective.name! + ", " + self.objective.address!;
        }
        
        self.buttonDownloadSound.isHidden = !self.objective.hasAudio
        self.buttonDownloadVideo.isHidden = !self.objective.hasVideo
        self.imageViewAudio.isHidden = !self.objective.hasAudio
        self.imageViewVideo.isHidden = !self.objective.hasVideo
      //  self.viewPlayer.isHidden = !self.objective.hasAudio
        self.constraintViewPlayerHeight.constant = self.objective.hasAudio ? 45 : 0
        self.constraintViewHeight.constant -= self.objective.hasAudio ? 0 : 45
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

}
