//
//  SwipingViewController.swift
//  Tinder
//
//  Created by Richard Guerci on 03/10/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

class SwipingViewController: UIViewController {

	@IBOutlet weak var picture: UIImageView!
	var displayedUserId = ""
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//save geolocation of the user
		PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint, error) -> Void in
			if error != nil {
				print("Error while getting location")
			}
			else if let geopoint = geopoint {
				PFUser.currentUser()?["location"] = geopoint
				do {
					try PFUser.currentUser()?.save()
				} catch { print("error while saving location") }
			}
		}
		
		//Initialize picture
		updateImage()
		
		//add gesture
		let gesture = UIPanGestureRecognizer(target: self, action: "drag:")
		picture.addGestureRecognizer(gesture)
		picture.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func drag(gesture: UIPanGestureRecognizer){
		//move the object with the finger
		let translation = gesture.translationInView(self.view)
		let image = gesture.view
		image!.center = CGPoint(x: self.view.bounds.width/2 + translation.x, y: self.view.bounds.height/2 + translation.y)
		
		//rotate and scale depending the position
		let xFromCenter = image!.center.x - self.view.bounds.width/2
		let scale = min(100/abs(xFromCenter),1)
		let rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
		let stretch = CGAffineTransformScale(rotation, scale, scale)
		image!.transform = stretch
		
		//End of gesture
		if gesture.state == UIGestureRecognizerState.Ended {
			var status = ""
			
			//detect side
			if image!.center.x < 75 {//left
				status = "rejected"
			}
			else if image!.center.x > self.view.bounds.width - 75 {//right
				status = "accepted"
			}
			else{
				//rest object to initial position
				UIView.animateWithDuration(0.25, animations: { () -> Void in
					let rotation = CGAffineTransformMakeRotation(0)
					let stretch = CGAffineTransformScale(rotation, 1, 1)
					image!.transform = stretch
					image!.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
				})
			}
			
			if status != "" {
				print(status)
				picture.hidden = true
				PFUser.currentUser()?.addUniqueObjectsFromArray([displayedUserId], forKey: status)
				do {
					try PFUser.currentUser()?.save()
				} catch { print("error while saving displayedUserId") }
				updateImage()
			}
		}
		
	}

	func updateImage(){
		let rotation = CGAffineTransformMakeRotation(0)
		let stretch = CGAffineTransformScale(rotation, 1, 1)
		picture.transform = stretch
		picture.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
		
		let userQuery = PFUser.query()
		var interestedIn = "male"
		if (PFUser.currentUser()?["interestedInWomen"])! as! Bool == true {
			interestedIn = "female"
		}
		
		var isFemale = true
		if (PFUser.currentUser()?["gender"])! as! String == "male" {
			isFemale = false
		}
		
		userQuery?.whereKey("gender", equalTo: interestedIn)
		userQuery?.whereKey("interestedInWomen", equalTo: isFemale)
		var ignoredUsers = [""]
		if let acceptedUsers = PFUser.currentUser()!["accepted"] {
			ignoredUsers += acceptedUsers as! [String]
		}
		if let rejectedUsers = PFUser.currentUser()!["rejected"] {
			ignoredUsers += rejectedUsers as! [String]
		}
		userQuery?.whereKey("objectId", notContainedIn: ignoredUsers)
		//geolocation filter
		if let userLocation = PFUser.currentUser()!["location"] {
			userQuery?.whereKey("location", nearGeoPoint: userLocation as! PFGeoPoint, withinKilometers: 80)
		}
		userQuery?.limit = 1
		
		userQuery?.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
			if error != nil {
				print(error)
			}
			else if let objects = objects as [PFObject]? {
				for object in objects {
					self.displayedUserId = object.objectId!
					let imageFile:PFFile = object["image"] as! PFFile
					imageFile.getDataInBackgroundWithBlock {
						(object,error) -> Void in
						if error != nil {
							print(error)
						}
						else {
							if let data = object {
								self.picture.hidden = false
								self.picture.image = UIImage(data: data)
							}
						}
					}
				}
			}
		})
	}
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "logOut" {
			PFUser.currentUser()?["accepted"] = []
			PFUser.currentUser()?["rejected"] = []
			do {
				try PFUser.currentUser()?.save()
			} catch { print("error while saving accepted/rejected") }
			PFUser.logOut()
		}
    }
}
