//
//  ViewController.swift
//  SwiftUtilityTestApp
//
//  Created by Hyeongkyu Lee on 2021/09/14.
//

import UIKit
import SwiftUtility
import SwiftSoup

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        "https://www.google.com".requestAsURLAsync(type: Document.self) { response in
            if let error = response.error {
                print(error)
            } else {
                print(response.value!)
            }
        }
    }
}
