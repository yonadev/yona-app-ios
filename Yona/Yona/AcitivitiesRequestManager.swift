//
//  AcitivitiesRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


private var newActivity: Activities?
private var activities:[Activities] = [] //array containing all the activities returned by getActivities

//MARK: - Activities APIService
extension APIServiceManager {
    
    /**
     Helper method to return the activities in and array
     
     - parameter none
     - parameter onCompletion: APIActivitiesArrayResponse, the completion body returning array of activites, success or fail and server messages
     */
    func getActivitiesArray(onCompletion: APIActivitiesArrayResponse) {
        self.APIServiceCheck { (success, networkMessage, networkCode) in
            if success {
                self.getActivityCategories{ (success, serverMessage, serverCode, activities, error) in
                    onCompletion(success, serverMessage, serverCode, activities, error)
                }
            } else { //if no network
                //activities not initialised no network fail with no data
                guard activities.isEmpty else {
                    onCompletion(false, networkMessage, networkCode, nil, nil)
                    return
                }
                //if we already got some activities then just send back the ones we have...
                onCompletion(false, networkMessage, networkCode, activities, nil)
                
            }
        }
    }
    
    /**
     Returns a self link (used to get an activity not edit) for an activity of a specific type from the get all activities API,
     
     - parameter activityName: CategoryName, Category name such as Social, News or Gambling
     - parameter onCompletion: APIActivityLinkResponse, returns the link for an activity and success or fail and server messages and codes
     */
    func getActivityLinkForActivityName(activityName: CategoryName, onCompletion: APIActivityLinkResponse) {
        self.getActivitiesArray{ (success, message, code, activities, error) in
            if success {
                var activityCategoryLink:String?
                
                for activity in (activities! as Array) {
                    switch activity.activityCategoryName! {
                    case activityName.rawValue:
                        activityCategoryLink = activity.selfLinks!
                    case activityName.rawValue:
                        activityCategoryLink = activity.selfLinks!
                    case activityName.rawValue:
                        activityCategoryLink = activity.selfLinks!
                    default:
                        break
                    }
                }
                onCompletion(true, activityCategoryLink, message, code)
            } else {
                onCompletion(false, nil, message, code)
            }
        }
    }
    
    /**
     Get all the activities and return them in an array, non user specific set by the admin (YONA)
     
     - parameter onCompletion: APIActivitiesArrayResponse, Returns and array of activities and success or fail and server messages
     */
    func getActivityCategories(onCompletion: APIActivitiesArrayResponse){
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser{ (success, message, code, user) in
                    if success {
                        if let path = user?.activityCategoryLink {
                            self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get, onCompletion: { success, json, err in
                                if let json = json {
                                    guard success == true else {
                                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                        return
                                    }
                                    //reset the array so start with new set of activities
                                    activities = []
                                    if let embedded = json[YonaConstants.jsonKeys.embedded],
                                        let embeddedActivities = embedded[YonaConstants.jsonKeys.yonaActivityCategories] as? NSArray{
                                        for activity in embeddedActivities {
                                            if let activity = activity as? BodyDataDictionary {
                                                newActivity = Activities.init(activityData: activity)
                                                activities.append(newActivity!)
                                            }
                                        }
                                        onCompletion(true, self.serverMessage, self.serverCode, activities, err)
                                    }
                                } else {
                                    //response from request failed
                                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                }
                            })
                        } else {
                            //response from request failed
                            onCompletion(false, self.serverMessage, self.serverCode, nil, YonaConstants.YonaErrorTypes.APILinkRetrievalFail)
                        }
                    } else {
                        //response from request failed
                        onCompletion(false, self.serverMessage, self.serverCode, nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
                    }
                }
            } else {
                //return response from APIService Check, no network
                onCompletion(false, message, code, activities, YonaConstants.YonaErrorTypes.NetworkFail)
            }
        }
    }
    
    /**
     IMplements the Activtiy with ID API call, and returns a specific activity identified by its ID
     
     - parameter activityID: String, activity ID
     - parameter onCompletion: APIActivityResponse, returns the activity requested as an Activities object
     */
    func getActivityCategoryWithID(activityID: String, onCompletion: APIActivityResponse){
        APIServiceCheck { (success, message, code) in
            if success {
                self.getUser{ (success, message, code, user) in
                    if success {
                        if let path = user?.activityCategoryLink {
                            //if the newActivites object has been filled then we can get the link to display activity
                            self.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get) { success, json, err in
                                if let json = json {
                                    guard success == true else {
                                        onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                        return
                                    }
                                    print(json)
                                    newActivity = Activities.init(activityData: json)
                                    onCompletion(true, self.serverMessage, self.serverCode, newActivity, err)
                                } else {
                                    //response from request failed
                                    onCompletion(false, self.serverMessage, self.serverCode, nil, err)
                                }
                            }
                        }
                    } else {
                        //network fail
                        onCompletion(false, message, code, nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
                    }
                }
            } else {
                //network fail
                onCompletion(false, message, code, nil, YonaConstants.YonaErrorTypes.NetworkFail)
            }
        }
    }
}