//
//  mainScreenViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/15/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit
import AVFoundation

class mainScreenViewController: UIViewController {
    
    @IBOutlet weak var newButton: UIButton!
    
    var show = true
    
    let colors = Constants.colors
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newButton.setImage(#imageLiteral(resourceName: "startNewW"), for: .highlighted)
        
        newButton.setImage(#imageLiteral(resourceName: "startNewR"), for: .normal)
        
        newButton.backgroundColor = UIColor.white
        
        newButton.addTarget(self, action: #selector(tapOn), for: [.touchDown, .touchDragInside])
        
        newButton.addTarget(self, action: #selector(tapOff), for: [.touchUpOutside, .touchDragOutside])
        
        newButton.addTarget(self, action: #selector(tapDone), for: [.touchUpInside])
        
        newButton.layer.cornerRadius = 126

        // Do any additional setup after loading the view.
    }
    
    
    /*
    var myurl : NSURL!
    var audioPlayer = AVPlayer()
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        // Getting sound from Document directory
        
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        if let allItems = try? FileManager.default.contentsOfDirectory(atPath: documentDirectory) {
            print(allItems)
        }
        
        let fileManager = FileManager.default
        
        let docsurl = try! fileManager.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        myurl = docsurl.appendingPathComponent("recording.m4a") as NSURL
        
        playSound(url:  myurl! as NSURL)
        
    }
    // Playing Sound
    
    func playSound(url:NSURL){
        
        let asset = AVURLAsset(url: url as URL, options: nil)
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.audioPlayer.replaceCurrentItem(with: playerItem)
        
        let durationInSeconds = CMTimeGetSeconds(asset.duration)
        
        //self.getSeconds = Int(durationInSeconds)
        
        self.audioPlayer.play()
        
    }*/
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        
        
        
        
        
        /*
        
        let file = "recording.reporter"
        
        print("init")
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            print("READ:", fileURL)
            
            /*
            
            //writing
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {/* error handling here */}*/
            
            
            
            //reading
            
            do {
                
                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                
                print(text2)
                
            } catch {
                
                print("ERROR")
                
            }
            
        }
        
        print("done")
        
        */
        
        
        
        
        
        
        
        
        
        
        
        
        
        if show {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "load") as! loadingViewController
            
            vc.modalTransitionStyle = .coverVertical
            
            vc.modalPresentationStyle = UIModalPresentationStyle.popover
            
            self.present(vc, animated: false, completion: nil)
            
            show = !show
            
        }
        
    }
    
    @objc func tapOn() {
        
        UIView.animate(withDuration: 0.25) {
            
            self.newButton.backgroundColor = self.colors[0]
            
        }
        
    }
    
    @objc func tapOff() {
        
        UIView.animate(withDuration: 0.25) {
            
            self.newButton.backgroundColor = UIColor.white
            
        }
        
    }
    
    @objc func tapDone() {
        
        tapOff()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Record") as! RecordingSessionViewController
        
        vc.modalTransitionStyle = .coverVertical
        
        self.present(vc, animated: true, completion: nil)
        
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
