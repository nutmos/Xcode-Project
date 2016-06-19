//
//  SettingsViewController.swift
//  MacThai-iOS
//
//  Created by Nattapong Mos on 18/1/58.
//  Copyright (c) พ.ศ. 2558 Nattapong Mos. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet private weak var readabilitySwitch: UISwitch!
    private var userDefault = NSUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        /*if let readabilityOn = getReadabilitySetting()?["readability"] as? Bool {
            //println("readabilityOn = \(readabilityOn)")
            self.readabilitySwitch.on = readabilityOn
        }*/
        if let readabilityOn = self.userDefault.objectForKey("readability") as? Bool {
            println("readability = \(readabilityOn)")
            self.readabilitySwitch.on = readabilityOn
        }
        else {
            println("no readability")
            self.userDefault.setBool(false, forKey: "readability")
            self.readabilitySwitch.on = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if cell?.textLabel?.text == "About" {
            performSegueWithIdentifier("ToAbout", sender: nil)
        }
        else if cell?.textLabel?.text == "Notifications" {
            performSegueWithIdentifier("ToNotifications", sender: nil)
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //var identifier = segue.identifier
    }
    
    // MARK: - User Interactions

    @IBAction internal func didReadabilitySwitchChanged(sender: UISwitch) {
        //setReadabilitySetting(["readability": sender.on])
        self.userDefault.setBool(sender.on, forKey: "readability")
    }

}
