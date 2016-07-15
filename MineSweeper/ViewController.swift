//
//  ViewController.swift
//  MineSweeper
//  CIS/CSE 444/651
//  Homework G
//  Created by Nicklos Serguier on 05/04/16.

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sweeperView: SweeperView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapped")
        doubleTap.numberOfTapsRequired = 2
        sweeperView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTapped")
        singleTap.numberOfTapsRequired = 1
        sweeperView.addGestureRecognizer(singleTap)
        singleTap.requireGestureRecognizerToFail(doubleTap)
    }
    
    //MARK: Methods
    func doubleTapped(){
        sweeperView.doubleTapped()
    }
    
    func singleTapped(){
        sweeperView.flag()
    }
    
    //MARK: Actions
    @IBAction func rebootPressed(sender: UIButton) {
        sweeperView.reboot()
    }

}

