//
//  AcitivitiesRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation



//MARK: - Activities APIService
class ActivitiesRequestManager {
    
    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    static let sharedInstance = ActivitiesRequestManager()
    
    private var newActivity: Activities?
    private var activitiesNotGoals: [Activities] = []
    private var activities:[Activities] = [] //array containing all the activities returned by getActivities
    
    private init() {}

    func getActivitiesNotAdded(onCompletion: APIActivitiesArrayResponse) {
        self.getActivityCategories{ (success, serverMessage, serverCode, activities, error) in
            if success{
                GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (success, message, code, nil, goals, error) in
                    if success {
                        if let goalsUnwrap = goals{
                            self.activitiesNotGoals = []
                            let goalsActivityLinks : [String] = goalsUnwrap.map({$0.activityCategoryLink!})
                            for activity in activities!{
                                if !goalsActivityLinks.contains(activity.selfLinks!){
                                    //You don't have it
                                    self.activitiesNotGoals.append(activity)
                                }
                            }
                        }
                        onCompletion(true, message, code, self.activitiesNotGoals, nil)
                    }
                })
            }
        }
    }
    
    /**
     Helper method to return the activities in and array
     
     - parameter none
     - parameter onCompletion: APIActivitiesArrayResponse, the completion body returning array of activites, success or fail and server messages
     */
    func getActivitiesArray(onCompletion: APIActivitiesArrayResponse) {
        self.getActivityCategories(onCompletion)
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
        UserRequestManager.sharedInstance.getUser { (success, message, code, user) in
            if success {
                if let path = user?.activityCategoryLink {
                    if self.activities.count == 0 {
                        self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get, onCompletion: { success, json, error in
                            #if DEBUG
                                print("Get all Activities API call" + String(success))
                            #endif
                            if let json = json {
                                guard success == true else {
                                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                    return
                                }
                                //reset the array so start with new set of activities
                                self.activities = []
                                if let embedded = json[YonaConstants.jsonKeys.embedded],
                                    let embeddedActivities = embedded[YonaConstants.jsonKeys.yonaActivityCategories] as? NSArray{
                                    for activity in embeddedActivities {
                                        if let activity = activity as? BodyDataDictionary {
                                            self.newActivity = Activities.init(activityData: activity)
                                            self.activities.append(self.newActivity!)
                                        }
                                    }
                                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.activities, error)
                                }
                            } else {
                                //response from request failed
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.activities, error)
                            }
                        })
                    } else {
                        onCompletion(true, nil, nil, self.activities, YonaConstants.YonaErrorTypes.Success) //we already have gotten the activities
                    }
                } else {
                    //response from request failed
                    onCompletion(false, YonaConstants.serverMessages.FailedToGetActivityLink, String(responseCodes.internalErrorCode), nil, YonaConstants.YonaErrorTypes.FailedToGetActivityLink)
                }
            } else {
                //response from request failed
                onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode), nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
            }
        }
    }
    
    /**
     IMplements the Activtiy with ID API call, and returns a specific activity identified by its ID
     
     - parameter activityID: String, activity ID
     - parameter onCompletion: APIActivityResponse, returns the activity requested as an Activities object
     */
    func getActivityCategoryWithID(activityID: String, onCompletion: APIActivityResponse){
        UserRequestManager.sharedInstance.getUser { (success, message, code, user) in
            if success {
                if let path = user?.activityCategoryLink {
                    //if the newActivites object has been filled then we can get the link to display activity
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: path, httpMethod: httpMethods.get) { success, json, error in
                        if let json = json {
                            guard success == true else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                return
                            }
                            print(json)
                            self.newActivity = Activities.init(activityData: json)
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.newActivity, error)
                        } else {
                            //response from request failed
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        }
                    }
                }
            } else {
                //response from request failed
                onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode), nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
            }
        }
    }
}