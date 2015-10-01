//
//  SignupViewController.swift
//  Tinder
//
//  Created by Richard Guerci on 01/10/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4

class SignupViewController: UIViewController {

	@IBOutlet weak var profilePicture: UIImageView!
	@IBOutlet weak var interestedInWomen: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//get infos from facebook
		let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
		graphRequest.startWithCompletionHandler( {
			(connection, result, error) -> Void in
			if error != nil {
				print(error)
			} else if let result = result {
				
				//save user info
				PFUser.currentUser()?["gender"] = result["gender"]
				PFUser.currentUser()?["name"] = result["name"]
				do {
					try PFUser.currentUser()?.save()
				} catch { print("cannot save current user") }
				
				
				//get picture from facebook
				let userId = result["id"] as! String
				let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
				if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
					if let data = NSData(contentsOfURL: fbpicUrl) {
						self.profilePicture.image = UIImage(data: data)
						let imageFile:PFFile = PFFile(data: data)
						PFUser.currentUser()?["image"] = imageFile
						do {
							try PFUser.currentUser()?.save()
						} catch { print("cannot save current user") }
						
					}
				}
			}
		})
		/*
		// Create label programatically
		let label = UILabel(frame: CGRectMake(self.view.bounds.width/2 - 100, self.view.bounds.height/2-50, 200, 100))
		label.text = "Drag me"
		label.textAlignment = NSTextAlignment.Center
		view.addSubview(label)
		
		//add gesture
		let gesture = UIPanGestureRecognizer(target: self, action: "drag:")
		label.addGestureRecognizer(gesture)
		label.userInteractionEnabled = true
*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func drag(gesture: UIPanGestureRecognizer){
		//move the object with the finger
		let translation = gesture.translationInView(self.view)
		let label = gesture.view as! UILabel
		label.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
		
		//rotate and scale depending the position
		let xFromCenter = label.center.x - self.view.bounds.width/2
		let scale = min(100/abs(xFromCenter),1)
		let rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
		let stretch = CGAffineTransformScale(rotation, scale, scale)
		label.transform = stretch
		
		//End of gesture
		if gesture.state == UIGestureRecognizerState.Ended {
			//detect side
			if label.center.x < 100 {//left
				print("left")
			}
			else if label.center.x > self.view.bounds.width - 100 {//right
				print("right")
			}
			
			//rest object to initial position
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				let rotation = CGAffineTransformMakeRotation(0)
				let stretch = CGAffineTransformScale(rotation, 1, 1)
				label.transform = stretch
				label.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
			})
		}
		
	}
    

	@IBAction func signUp(sender: AnyObject) {
		PFUser.currentUser()?["interestedInWomen"] = interestedInWomen.on
		do {
			try PFUser.currentUser()?.save()
		} catch { print("cannot save current user") }
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
