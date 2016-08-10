//
//  FriendsWeekDetailWeekController.swift
//  Yona
//
//  Created by Anders Liebl on 03/08/2016.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation

class FriendsWeekDetailWeekController : MeWeekDetailWeekViewController {
  
    var buddy : Buddies?
    
    override func loadData (typeToLoad : loadType = .own) {
        // SKAL ALTID HENTE DATA FØRSTE GANG FOR UGEN
        // ALWAYS DOWNLOAD DATA FIRST TIME FOR THE WEEK
        Loader.Show()
        if let theBuddy = buddy {
            if typeToLoad == .own {
                if let data = initialObject  {
                    if let path = data.weekDetailLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                }
                                
                                Loader.Hide()
                                self.tableView.reloadData()
                                
                            } else {
                                Loader.Hide()
                            }
                        })
                    }
                }
            } else  if typeToLoad == .prev {
                if let data = week[currentWeek.yearWeek]  {
                    if let path = data.prevLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                }
                                
                                Loader.Hide()
                                self.tableView.reloadData()
                                
                            } else {
                                Loader.Hide()
                            }
                        })
                    }
                }
            } else  if typeToLoad == .next {
                if let data = week[currentWeek.yearWeek]  {
                    if let path = data.nextLink {
                        ActivitiesRequestManager.sharedInstance.getActivityDetails(theBuddy, activityLink: path, date: currentWeek, onCompletion: { (success, serverMessage, serverCode, activitygoals, err) in
                            if success {
                                
                                if let data = activitygoals {
                                    self.currentWeek = data.date
                                    self.week[data.date.yearWeek] = data
                                    print (data.date.yearWeek)
                                }
                                
                                Loader.Hide()
                                self.tableView.reloadData()
                                
                            } else {
                                Loader.Hide()
                            }
                        })
                    }
                }
                
                
            }
        }
        Loader.Hide()
        self.tableView.reloadData()
        
    }

}