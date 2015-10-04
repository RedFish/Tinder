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
	@IBOutlet weak var username: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
		/**
		//Create users to test the application
		let urlArray = ["http://www.thezerosbeforetheone.com/wordpress/wp-content/uploads/2011/07/smurfette-300x225.gif",
			"http://www.polyvore.com/cgi/img-thing?.out=jpg&size=l&tid=44643840",
			"http://www.polyvore.com/cgi/img-thing?.out=jpg&size=l&tid=62956603",
			"http://static.comicvine.com/uploads/square_small/0/2617/103863-63963-torongo-leela.JPG",
			"http://www.theunknownpen.com/wp-content/uploads/2013/03/Velma.jpg",
			"http://assets.makers.com/styles/mobile_gallery/s3/betty-boop-cartoon-576km071213_0.jpg?itok=9qNg6GUd",
			"http://magicdisneyheros.altervista.org/images/midl/97.jpg"]
		
		var counter = 1
		for url in urlArray {
			
			let url = NSURL(string: url)!
			
			if let data = NSData(contentsOfURL: url) {
				let imageFile:PFFile = PFFile(data: data)
				let user = PFUser()
				let name = "user\(counter)"
				user.username = name
				user.password = "pass"
				user["image"] = imageFile
				user["name"] = name
				user["interestedInWomen"] = false
				user["gender"] = "female"
				
				counter++
				do {
					try user.signUp()
					print("\(name) saved")
				} catch { print("cannot save current user") }
				
			}
		}
		**/
		
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
				
				if let name = result["name"] as? String {
					self.username.text = name
				}
				else{
					self.username.text = ""
				}
				
				
				//get picture from facebook
				let userId = result["id"] as! String
				let facebookProfilePictureUrl = "https://graph.facebook.com/" + userId + "/picture?type=large"
				if let fbpicUrl = NSURL(string: facebookProfilePictureUrl) {
					if let data = NSData(contentsOfURL: fbpicUrl) {
						self.profilePicture.image = UIImage(data: data)
						let imageFile:PFFile = PFFile(data: data)
						PFUser.currentUser()?["image"] = imageFile
					}
				}
			}
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
		@IBAction func signUp(sender: AnyObject) {
		PFUser.currentUser()?["interestedInWomen"] = interestedInWomen.on
		do {
			try PFUser.currentUser()?.save()
			self.performSegueWithIdentifier("logUserIn", sender: self)
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
