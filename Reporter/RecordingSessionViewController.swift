//
//  RecordingSessionViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/11/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit
import Speech
import AVFoundation
import AudioToolbox

class RecordingSessionViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var preview: UILabel!
    
    @IBOutlet weak var previewPerson: UILabel!
    
    @IBOutlet weak var iconPreview: UIImageView!
    
    @IBOutlet weak var largePreview: UILabel!
    
    @IBOutlet weak var previewPersonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var finishButton: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    let haptic = UINotificationFeedbackGenerator()
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var buttons = [button(), button()]
    
    var users = ["You", "Teacher"]
    
    var count = ["You", "x3"]
    
    var descs = ["Tareq El Dandachi", "Mangala El Charif"]
    
    var pointCenters : [CGPoint] = []
    
    let colors = Constants.colors
    
    var errorLabel = UILabel()
    
    var active = -1
    
    var running = false
    
    var editMode = false
    
    var editSelected = -1
    
    var verticalSuspension : CGFloat = 800
    
    var fixedPoint : CGPoint = CGPoint(x: -1, y: -1)
    
    var userFixed = -1
    
    let appearedLegend = UILabel()
    
    let addPersonButton = UIButton()
    
    var show = true
    
    var audioSession: AVAudioSession!
    
    var audioRecorder: AVAudioRecorder!
    
    var fileName = ""
    
    var recordingData = ""
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        fileName = "RECORDING_" + Constants.randomString(length: 20)
        
        audioSession = AVAudioSession.sharedInstance()
        
        print(view.frame.height)
        
        if view.frame.height > 670 {
            
            verticalSuspension = view.frame.height
            
        } else {
            
            verticalSuspension = 700
            
        }
        
        addPersonButton.setImage(#imageLiteral(resourceName: "plusWhite"), for: [])
        
        addPersonButton.backgroundColor = colors[0]
        
        addPersonButton.setTitle("  Add Speaker", for: [])
        
        addPersonButton.setTitleColor(UIColor.white, for: [])
        
        addPersonButton.adjustsImageWhenHighlighted = false
        
        addPersonButton.addTarget(self, action: #selector(addNewTouchDown), for: [.touchDown,.touchDragInside])
        
        addPersonButton.addTarget(self, action: #selector(addNewTouchComplete), for: [.touchUpInside])
        
        addPersonButton.addTarget(self, action: #selector(addNewTouchUp), for: [.touchUpOutside,.touchDragOutside])
        
        addPersonButton.layer.cornerRadius = 30
        
        addPersonButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        
        addPersonButton.frame = CGRect(x: view.frame.width/2 - 147.5, y: view.frame.height - 100, width: 295, height: 60)
        
        addPersonButton.transform = CGAffineTransform(translationX: 0, y: 100)
        
        view.addSubview(addPersonButton)
        
        appearedLegend.frame = CGRect(x: 35, y: 85, width: 70, height: 70)
        
        appearedLegend.textAlignment = .center
        
        appearedLegend.numberOfLines = 2
        
        appearedLegend.text = "Appeared Before"
        
        appearedLegend.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        errorLabel = UILabel(frame: CGRect(x: 20, y: 0, width: view.frame.width - 40, height: view.frame.height))
        
        errorLabel.text = "Allow Microphone Access From Settings"
        
        errorLabel.textColor = UIColor.gray
        
        errorLabel.font = UIFont.systemFont(ofSize: 33, weight: .heavy)
        
        errorLabel.numberOfLines = 0
        
        errorLabel.textAlignment = .center
        
        buttons[0].frame = CGRect(x: view.frame.width/2-25, y: verticalSuspension-400, width: 50, height: 50)
        
        buttons[0].layer.cornerRadius = 25
        
        buttons[0].backgroundColor = colors[0]
        
        buttons[0].tag = 0
        
        buttons[0].layer.opacity = 0.3
        
        buttons[0].titleLabel.text = users[0]
        
        buttons[0].titleLabel.layer.opacity = 0
        
        //
        
        buttons[1].frame = CGRect(x: view.frame.width/2-25, y: verticalSuspension-525, width: 50, height: 50)
    
        buttons[1].layer.cornerRadius = 25
        
        buttons[1].backgroundColor = colors[1]
        
        buttons[1].tag = 1
        
        buttons[1].layer.opacity = 0.3
        
        //buttons[1].addTarget(self, action: #selector(buttonDown), for: [.touchDown,.touchDragInside])
    
        //buttons[1].addTarget(self, action: #selector(buttonUp), for: [.touchUpInside,.touchDragOutside])
        
        buttons[1].titleLabel.text = users[1]
        
        buttons[1].titleLabel.layer.opacity = 0
        
        iconPreview.image = #imageLiteral(resourceName: "pause")
        
        iconPreview.isUserInteractionEnabled = true
        
        iconPreview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pause)))
        
        editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        
        finishButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        
        largePreview.text = "PAUSED"
        
        //
        
        speechRecognizer.delegate = self
        
        view.isMultipleTouchEnabled = false
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isAllowed = false
            
            switch authStatus {
                
            case .authorized:
                isAllowed = true
                
            case .denied:
                isAllowed = false
                
            case .restricted:
                isAllowed = false
                
            case .notDetermined:
                isAllowed = false
                
            }
            
            OperationQueue.main.addOperation() {
                
                if isAllowed {
                    
                    self.view.addSubview(self.buttons[0])
                    
                    self.view.addSubview(self.buttons[1])
                    
                } else {
                    
                    self.view.addSubview(self.errorLabel)
                    
                }
                
            }
            
        }
        
        haptic.prepare()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setActive(true)
            audioSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        //self.loadRecordingUI()
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    
    @objc func addNewTouchUp() {
        
        addPersonButton.layer.opacity = 1
        
    }
    
    @objc func addNewTouchDown() {
        
        addPersonButton.layer.opacity =  0.8
        
    }
    
    @objc func addNewTouchComplete() {
        
        addNewTouchUp()
        
        if users.count == 4 {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "load") as! loadingViewController
            
            vc.modalTransitionStyle = .coverVertical
            
            self.present(vc, animated: false, completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "New Speaker", message: "Enter the Name of the speaker followed by his Role or Script Name", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Add Speaker", style: .default, handler: {
                alert -> Void in
                let nameField = alertController.textFields![0] as UITextField
                let roleField = alertController.textFields![1] as UITextField
                
                if nameField.text != "", roleField.text != "" {
                    
                    self.descs.append(nameField.text!)
                    
                    self.users.append(roleField.text!)
                    
                    self.count.append("FIX LATER")
                    
                    self.updateDots()
                    
                } else {
                    
                    let errorAlert = UIAlertController(title: "Error", message: "Please input both the name AND the script name of the person.", preferredStyle: .alert)
                    
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        alert -> Void in
                        self.present(alertController, animated: true, completion: nil)
                    }))
                    
                    self.present(errorAlert, animated: true, completion: nil)
                    
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            alertController.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "Name"
                textField.textAlignment = .center
            })
            
            alertController.addTextField(configurationHandler: { (textField) -> Void in
                textField.placeholder = "Role/Script Name"
                textField.textAlignment = .center
            })
            
            self.present(alertController, animated: true, completion: nil)
            
            alertController.view.tintColor = colors[0]
            
        }
        
    }
    
    func clickOnPersonEdit() {
        
        let temp = editSelected
        
        print("ACTUATED ON", temp)
        
        let personAlert = UIAlertController(title: users[temp], message: descs[temp], preferredStyle: .actionSheet)
        
        personAlert.addAction(UIAlertAction(title: "Move", style: .default, handler: {
        
            alert -> Void in
            
            self.editSelected = -1
        
        }))
        
        personAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            
            alert -> Void in
            
            self.users.remove(at: temp)
            
            self.descs.remove(at: temp)
                
            self.count.remove(at: temp)
            
            self.updateDots()
            
            self.editSelected = -1
        
        }))
        
        personAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            alert -> Void in
            
            self.editSelected = -1
            
        }))
        
        self.present(personAlert, animated: true, completion: nil)
        
        personAlert.view.tintColor = colors[3]
        
    }
    
    @objc func finish() {
        
        let alertController = UIAlertController(title: "Recording Completed", message: "", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: {
            
            alert -> Void in
                
            let saveAlert = UIAlertController(title: "Save Recording", message: "Enter a title for the recording", preferredStyle: .alert)
                
            saveAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
                    
                alert -> Void in
                    
                let nameField = saveAlert.textFields![0] as UITextField
                    
                if nameField.text != "" {
                    
                    self.recordingData = "$T:" + nameField.text! + "\n" + self.recordingData
                    
                    self.done()
                    
                    self.dismiss(animated: true, completion: nil)
                        
                } else {
                        
                    let errorAlert = UIAlertController(title: "Error", message: "Please input both the title AND the location of the new point", preferredStyle: .alert)
                        
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                        
                        alert -> Void in
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }))
                        
                    self.present(errorAlert, animated: true, completion: nil)
                        
                }
                    
            }))
            
            saveAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                
                alert -> Void in
                
                self.present(alertController, animated: true, completion: nil)
                
            }))
            
            saveAlert.addTextField(configurationHandler: { (textField) -> Void in
                
                textField.placeholder = "Title"
                
            })
                
            self.present(saveAlert, animated: true, completion: nil)
                
            saveAlert.view.tintColor = self.colors[0]
                    
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            
            alert -> Void in
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {
            
            alert -> Void in
            
            let errorAlert = UIAlertController(title: "Discard Note", message: "Are you sure you want to discard the current note?", preferredStyle: .alert)
            
            errorAlert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: {
                
                alert -> Void in
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            errorAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                
                alert -> Void in
                
                self.present(alertController, animated: true, completion: nil)
                
            }))
            
            self.present(errorAlert, animated: true, completion: nil)
            
        }))
        
        self.present(alertController, animated: true, completion: nil)
        
        //alertController.view.tintColor = colors[0]
    
    }
    
    func updateDots() {
        
        buttons = []
        
        edit()
        
        for sub in view.subviews{
            
            if let personSub = sub as? button {
                
                personSub.removeFromSuperview()
                
            }
            
        }
        
        let count = users.count
        
        for i in 0..<count {
            
            let tempButton = button()
            
            var x : CGFloat = 0, y : CGFloat = 0
            
            if i == 0 {
                
                x = view.frame.width / 2-25
                
                y = verticalSuspension - 400
                
            } else {
                
                if count == 2 {
                    
                    x = view.frame.width/2 - 25
                    
                    y = verticalSuspension - 525
                    
                } else if count == 3 {
                    
                    if i == 1 {
                        
                        x = view.frame.width / 2-110
                        
                        y = verticalSuspension - 510
                        
                    } else {
                        
                        x = view.frame.width / 2+60
                        
                        y = verticalSuspension - 510
                        
                    }
                    
                } else if count == 4 {
                    
                    if i == 1 {
                        
                        x = view.frame.width / 2-140
                        
                        y = verticalSuspension - 490
                        
                    } else if i == 2 {
                        
                        x = view.frame.width/2 - 25
                        
                        y = verticalSuspension - 525
                        
                    } else {
                        
                        x = view.frame.width / 2+90
                        
                        y = verticalSuspension - 490
                        
                    }
                    
                }
                
            }
            
            tempButton.frame = CGRect(x: x, y: y, width: 50, height: 50)
            
            tempButton.layer.cornerRadius = 25
            
            tempButton.backgroundColor = colors[i]
            
            tempButton.tag = 0
            
            tempButton.layer.opacity = 0.3
            
            tempButton.titleLabel.text = users[i]
            
            tempButton.titleLabel.layer.opacity = 0
            
            tempButton.tag = i
            
            view.addSubview(tempButton)
            
            self.buttons.append(tempButton)
            
        }
        
        edit()
        
    }
    
    @objc func pause() {
        
        iconPreview.gestureRecognizers![0] = UITapGestureRecognizer(target: self, action: #selector(play))
        
        iconPreview.image = #imageLiteral(resourceName: "pause")
        
        largePreview.text = "PAUSED"
        
    }
    
    @objc func play() {
        
        iconPreview.gestureRecognizers![0] = UITapGestureRecognizer(target: self, action: #selector(pause))
        
        iconPreview.image = #imageLiteral(resourceName: "play")
        
    }
    
    @objc func edit() {
        
        if editMode {
            
            editButton.setTitle("Edit", for: [])
            
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            
            finishButton.isHidden = false
            
            for sub in view.subviews{
                
                if let personSub = sub as? person {
                    
                    personSub.removeFromSuperview()
                    
                }
                
            }
            
            appearedLegend.removeFromSuperview()
            
            UIView.animate(withDuration: 0.5) {
                
                for i in 0..<self.buttons.count {
                    
                    self.buttons[i].titleLabel.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
                    
                    self.buttons[i].center = self.pointCenters[i]
                    
                    self.buttons[i].transform = CGAffineTransform.identity
                    
                    self.buttons[i].titleLabel.text = self.users[i]
                    
                    self.buttons[i].layer.opacity = 0.3
                    
                    self.buttons[i].titleLabel.layer.opacity = 0
                    
                }
                
                self.preview.transform = CGAffineTransform.identity
                
                self.previewPerson.transform = CGAffineTransform.identity
                
                self.iconPreview.transform = CGAffineTransform.identity
                
                self.largePreview.transform = CGAffineTransform.identity
                
                self.addPersonButton.transform = CGAffineTransform(translationX: 0, y: 100)
                
            }
            
        } else {
            
            editButton.setTitle("Done", for: [])
            
            editButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            
            finishButton.isHidden = true
            
            pointCenters = []
            
            let personKey = person()
            
            personKey.titleLabel.text = "Name"
            
            personKey.descLabel.text = "Role/Script Name"
            
            personKey.layer.opacity = 0
            
            personKey.frame = CGRect(x: 130, y: 85, width: self.view.frame.width - 180, height: 70)
            
            view.addSubview(personKey)
            
            self.view.addSubview(self.appearedLegend)
            
            appearedLegend.layer.opacity = 0
            
            for i in 0..<self.buttons.count {
                
                let personI = person()
                
                let y = CGFloat(200+80*i)
                
                personI.titleLabel.text = self.descs[i]
                
                personI.descLabel.text = self.users[i]
                
                personI.personTag = i
                
                personI.frame = CGRect(x: 130, y: y - 35, width: self.view.frame.width - 180, height: 70)
                
                personI.layer.opacity = 0
                
                self.view.addSubview(personI)
                
            }
            
            UIView.animate(withDuration: 0.5) {
                
                for i in 0..<self.buttons.count {
                    
                    self.pointCenters.append(self.buttons[i].center)
                    
                    let y = CGFloat(200+80*i)
                    
                    self.buttons[i].titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
                    
                    self.buttons[i].center = CGPoint(x: 70, y: y)
                    
                    self.buttons[i].transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
                    
                    self.buttons[i].titleLabel.text = self.count[i]
                    
                    self.buttons[i].layer.opacity = 1
                    
                    self.buttons[i].titleLabel.layer.opacity = 1
                    
                }
                
                for sub in self.view.subviews{
                    
                    if let personSub = sub as? person {
                        
                        personSub.layer.opacity = 1
                        
                    }
                    
                }
                
                self.preview.transform = CGAffineTransform(translationX: 0, y: 250)
                
                self.previewPerson.transform = CGAffineTransform(translationX: 0, y: 250)
                
                self.iconPreview.transform = CGAffineTransform(translationX: 0, y: 250)
                
                self.largePreview.transform = CGAffineTransform(translationX: 0, y: 250)
                
                self.appearedLegend.layer.opacity = 1
                
                personKey.layer.opacity = 1
                
                self.addPersonButton.transform = CGAffineTransform.identity
                
            }
            
            
            
        }
        
        editMode = !(editMode)
        
    }
    
    @objc func buttonDown(sender:UIView) {
        
        if active == -1 {
            
            let tag = sender.tag
            
            if fixedPoint == CGPoint(x: -1, y: -1) {
                
                let center = buttons[tag].center
                
                iconPreview.image = #imageLiteral(resourceName: "play")
                
                AudioServicesPlaySystemSound(SystemSoundID(1519))
                
                largePreview.text = users[tag]
                
                previewPersonWidthConstraint.constant = 0
                
                UIView.animate(withDuration: 0.25) {
                    
                    self.buttons[tag].frame = CGRect(x: 0, y: 0, width: 130, height: 130)
                    
                    self.buttons[tag].center = center
                    
                    self.buttons[tag].layer.cornerRadius = 65
                    
                    self.buttons[tag].layer.opacity = 1
                    
                }
                
                UIView.animate(withDuration: 0.05, delay: 0.1, animations: {
                    
                    self.buttons[tag].titleLabel.layer.opacity = 1
                    
                })
                
                previewPerson.text = users[tag]
                
                if running == false {
                    
                    running = true
                    
                    startRecording()
                    
                }
                
            }
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            if  let point = touches.first?.location(in: self.view) {
                
                if let viewTouched =  self.view.hitTest(point, with: event), viewTouched === view {
                    
                    print("Tapped")
                    
                } else {
                    
                    print("Not Tapped")
                    
                }
                
            }
        
        if fixedPoint != CGPoint(x: -1, y: -1) {
            
            let pop = SystemSoundID(1520)
            AudioServicesPlaySystemSound(pop)
            
            print("Button:", userFixed)
            
            print("Center:", fixedPoint)
            
            buttons[userFixed].center = fixedPoint
            
            fixedPoint = CGPoint(x: -1, y: -1)
            
            buttonUp(sender: buttons[userFixed])
            
            userFixed = -1
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let point = touches.first, editMode == false {
            
            let hitView = self.view.hitTest(point.location(in: self.view), with: event)
            
            var pressed = false
                
            for i in buttons {
                    
                if hitView === i {
                        
                    buttonDown(sender: i)
                    
                    active = i.tag
                    
                    pressed = true
                    
                    if #available(iOS 9.0, *) {
                        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
                            
                            let force = point.force/point.maximumPossibleForce
                            
                            if userFixed == -1 && force > 0.95 {
                                
                                successHaptic()
                                    
                                fixedPoint = buttons[i.tag].center
                                    
                                userFixed = i.tag
                                    
                                view.bringSubview(toFront: buttons[i.tag])
                                    
                                UIView.animate(withDuration: 0.3) {
                                    
                                    self.buttons[i.tag].frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                                        
                                    self.buttons[i.tag].layer.cornerRadius = 0
                                        
                                }
                                
                                self.buttons[i.tag].titleLabel.layer.opacity = 1
                                
                                UIView.animate(withDuration: 1, delay: 0.0, options: [.curveEaseIn, .repeat, .autoreverse, .allowUserInteraction], animations: {() -> Void in
                                    self.buttons[i.tag].titleLabel.layer.opacity = 0.0
                                }, completion: {(finished: Bool) -> Void in
                                })
                                
                            }
                            
                        }
                    }
                        
                }
                    
            }
            
            if active != -1 && pressed == false {
                
                buttonUp(sender: buttons[active])
                
            }
            
        } else if let point = touches.first, editSelected == -1, editMode == true {
            
            let hitView = self.view.hitTest(point.location(in: self.view), with: event)
            
            for sub in view.subviews{
                
                if let personSub = sub as? person {
                    
                    if hitView === personSub {
                        
                        editSelected = personSub.personTag
                        
                        if editSelected != 0 {
                            
                            clickOnPersonEdit()
                            
                        } else {
                            
                            editSelected = -1
                            
                        }
                        
                    }
                    
                } else if let personSub = sub as? button {
                    
                    if hitView === personSub {
                        
                        editSelected = personSub.tag
                        
                        if editSelected != 0 {
                            
                            clickOnPersonEdit()
                            
                        }
                        
                        editSelected = -1
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func successHaptic() {
        
        AudioServicesPlaySystemSound(SystemSoundID(1521))
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if active != -1 && editMode == false {
            
            buttonUp(sender: buttons[active])
            
        }
        
    }
    
    @objc func buttonUp(sender:UIView) {
        
        if fixedPoint == CGPoint(x: -1, y: -1) {
            
            active = -1
        
            pause()
            
            self.previewPersonWidthConstraint.constant = 80
            
            UIView.animate(withDuration: 0.25) {
                
                self.view.layoutIfNeeded()
                
            }
            
            let tag = sender.tag
            
            self.buttons[tag].titleLabel.layer.opacity = 0
            
            let center = buttons[tag].center
            
            UIView.animate(withDuration: 0.25) {
                
                self.buttons[tag].frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                
                self.buttons[tag].center = center
                
                self.buttons[tag].layer.cornerRadius = 25
                
                self.buttons[tag].layer.opacity = 0.3
                
            }
            
        }
        
    }
    
    func done() {
        
        audioRecorder.stop()
        audioRecorder = nil
        
        //SUCCESS
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        running = false
        
    }
    
    func writeToDisk() {
        
        let fileNameWDir = "/" + self.fileName + ".reporter"
        
        let filePath = self.getDocumentsDirectory().path.appending(fileNameWDir)
        
        do {
            
            try recordingData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            
            print(filePath)
            
        } catch {
            
            // error saving file
            
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if !flag {
            
            finish()
            
        }
        
    }
    
    func startRecording() {
        
        print("START")
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName + ".m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            //finishRecording(success: false)
            
            //ERROR
            
        }
        
        if recognitionTask != nil {
            
            recognitionTask?.cancel()
            recognitionTask = nil
            
        }
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.preview.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            
            self.recognitionRequest?.append(buffer)
        }
        
        
        audioEngine.prepare()
        
        do {
            
            try audioEngine.start()
            
        } catch {
            
            print("audioEngine couldn't start because of an error.")
            
        }
        
        preview.text = ""
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
        if available {
            
           self.view.addSubview(self.buttons[0])
            
        } else {
            
            self.view.addSubview(self.errorLabel)
            
        }
        
    }
    
}

class button:UIView {
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        layer.masksToBounds = true
        
        initSubviews()
        
    }
    
    let titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .center
        
        label.textColor = UIColor.white
        
        label.font = UIFont.systemFont(ofSize: 34, weight: .heavy)
        
        label.adjustsFontSizeToFitWidth = true
        
        label.translatesAutoresizingMaskIntoConstraints=false
        
        return label
        
    }()

    
    func initSubviews() {
        
        addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive=true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive=true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive=true
        titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive=true
        
    }
    
}

class person:UIView {
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        layer.masksToBounds = true
        
        initSubviews()
        
    }
    
    let titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .left
        
        label.textColor = UIColor.black
        
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        
        label.adjustsFontSizeToFitWidth = false
        
        label.translatesAutoresizingMaskIntoConstraints=false
        
        return label
        
    }()
    
    let descLabel: UILabel = {
        
        let label = UILabel()
        
        label.textAlignment = .left
        
        label.textColor = UIColor.black
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        label.adjustsFontSizeToFitWidth = false
        
        label.translatesAutoresizingMaskIntoConstraints=false
        
        return label
        
    }()
    
    var personTag = -1
    
    func initSubviews() {
        
        addSubview(titleLabel)
        
        titleLabel.topAnchor.constraint(equalTo: topAnchor,constant: 10).isActive=true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor).isActive=true
        titleLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        titleLabel.heightAnchor.constraint(equalToConstant: 22)
        titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        
        addSubview(descLabel)
        
        descLabel.topAnchor.constraint(equalTo: topAnchor, constant: 39).isActive=true
        descLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 7).isActive=true
        descLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive=true
        descLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        descLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1)
        
    }
    
}
