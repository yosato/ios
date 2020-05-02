//
//  ViewController.swift
//  WarCardGame
//
//  Created by Yo Sato on 15/04/2020.
//  Copyright © 2020 satoama.co.uk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cpuL: UILabel!
    @IBOutlet weak var playerL: UILabel!
    @IBOutlet weak var rightImageV: UIImageView!
    @IBOutlet weak var leftImageV: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }


    @IBAction func dealTapped(_ sender: Any) {
        playerL.text=""
        let leftNum = arc4random_uniform(13)+2
        let rightNum = arc4random_uniform(13)+2
        if leftNum>rightNum {
            playerL.text = "win!!"
        }
        
        leftImageV.image = UIImage(named: "card\(leftNum)")
        
        rightImageV.image = UIImage(named: "card\(rightNum)")
        
    }
}

