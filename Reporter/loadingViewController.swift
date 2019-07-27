//
//  loadingViewController.swift
//  Reporter
//
//  Created by Tareq El Dandachi on 7/15/18.
//  Copyright © 2018 Tareq El Dandachi. All rights reserved.
//

import UIKit

class loadingViewController: UIViewController {
    
    @IBOutlet weak var icon: UIImageView!

    @IBOutlet weak var yConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var proButton: UIButton!
    
    @IBOutlet weak var bullets: UILabel!
    
    let bulletsArray = ["SSS", "Lorem Ipsum Dollor Sit Amet", "SSS"]
    
    func addBullets(stringList: [String], font: UIFont, bullet: String = "\u{2022}", indentation: CGFloat = 20, lineSpacing: CGFloat = 2, paragraphSpacing: CGFloat = 8, textColor: UIColor = .gray, bulletColor: UIColor = .red) -> NSAttributedString {
        
        let textAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: bulletColor]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        //paragraphStyle.firstLineHeadIndent = 0
        //paragraphStyle.headIndent = 20
        //paragraphStyle.tailIndent = 1
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation
        
        let bulletList = NSMutableAttributedString()
        for string in stringList {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)
            
            attributedString.addAttributes(
                [NSAttributedStringKey.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))
            
            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))
            
            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }
        
        return bulletList
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        
        if let dsc = font.fontDescriptor.withSymbolicTraits(.traitItalic) {
            font = UIFont(descriptor: dsc, size: 0)
        }
        
        label.font = font
        
        label.alpha = 0
        
        closeButton.alpha = 0
        
        proButton.alpha = 0
        
        self.bullets.alpha = 0
        
        bullets.attributedText = addBullets(stringList: bulletsArray, font: UIFont.systemFont(ofSize: 16, weight: .semibold))

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.yConstraint.isActive = false
        
        self.icon.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 120).isActive=true
        
        UIView.animate(withDuration: 1, delay: 0.0, options: [], animations: {() -> Void in
            
            self.view.layoutIfNeeded()
            
            self.label.alpha = 0.5
            
            self.closeButton.alpha = 0.5
            
            self.bullets.alpha = 1
            
        }, completion: {(finished: Bool) -> Void in
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {() -> Void in
                
                self.label.alpha = 1
                
                self.closeButton.alpha = 1
                
                self.proButton.alpha = 1
                
            }, completion: {(finished: Bool) -> Void in
                
                self.closeButton.addTarget(self, action: #selector(self.close), for: .touchUpInside)
                
            })
            
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func close() {
        
        dismiss(animated: true, completion: nil)
        
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
