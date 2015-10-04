//
//  ContactViewController.swift
//  Tinder
//
//  Created by Richard Guerci on 04/10/2015.
//  Copyright © 2015 Richard Guerci. All rights reserved.
//

import UIKit
import Parse

struct Match {
	var objectId:String
	var username:String
	var email:String
	var image:UIImage
}

class ContactViewController: UITableViewController {

	var matches:[Match] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let query = PFUser.query()
		query?.whereKey("accepted", equalTo: PFUser.currentUser()!.objectId!)
		query?.whereKey("objectId", containedIn: PFUser.currentUser()!["accepted"] as! [String])
		query?.findObjectsInBackgroundWithBlock({ (results, error) -> Void in
			if error != nil {
				print("Error while getting matches")
			}
			else if let results = results {
				for result in results as! [PFUser] {
					self.matches.append(Match(objectId:result.objectId!, username: result["name"] as! String, email:result["email"] as! String, image: UIImage()))
					//getting image
					let imageFile:PFFile = result["image"] as! PFFile
					imageFile.getDataInBackgroundWithBlock {
						(object,error) -> Void in
						if error != nil {
							print(error)
						}
						else {
							if let data = object {
								for (index, element) in self.matches.enumerate() {
									if element.objectId == result.objectId! {
										self.matches[index].image = UIImage(data: data)!
										self.tableView.reloadData()
										break
									}
								}
							}
						}
					}
					self.tableView.reloadData()
				}
			}
		})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matches.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! TableViewCell
		
		myCell.username.text = matches[indexPath.row].username
		myCell.profilePicture.image = matches[indexPath.row].image

        return myCell
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let url = NSURL(string: "mailto:\(matches[indexPath.row].email)")
		UIApplication.sharedApplication().openURL(url!)
	}

}
