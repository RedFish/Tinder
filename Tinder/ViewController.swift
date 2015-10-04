//
//  ViewController.swift
//  Tinder
//
//  Created by Richard Guerci on 28/09/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

class ViewController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func loginWithFB(sender: AnyObject) {
		let permissions = ["public_profile","email"]
		PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
			(user: PFUser?, error: NSError?) -> Void in
			if let user = user {
				if let _ = user["interestedInWomen"] { //user has already signed up
					self.performSegueWithIdentifier("logUserIn", sender: self)
				}
				else {
					self.performSegueWithIdentifier("showSignup", sender: self)
				}
			} else {
				print("Uh oh. The user cancelled the Facebook login.")
			}
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		if let _ = PFUser.currentUser()?.username {
			if let _ = PFUser.currentUser()?["interestedInWomen"] { //user has already signed up
				self.performSegueWithIdentifier("logUserIn", sender: self)
			}
			else {
				self.performSegueWithIdentifier("showSignup", sender: self)
			}
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
}


