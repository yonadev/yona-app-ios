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
    
    private var timeLineAcitivityCompletion : APITimeLineUserGoalsRespons?
    private var timeLineUserCompletion : APITimeLineUserGoalsRespons?
    private var timeLineGoals : [String:[Goal]] = [:]
    
    private init() {}

    /** Call getActivitiesNotAddedWithTheUsersGoals to return to your UI the activties not yet added to display in a the challenges table. Also it will return the users goals in the APIActivitiesGoalsArrayResponse completion block, because to get activities not added you also need to get the goals so we may as well return the goals as well so that your UI does have to call get goals too
     
     - parameter APIActivitiesGoalsArrayResponse Completion block returning the activites not yet added as goals and all the goals the user has to use
     */
    func getActivitiesNotAddedWithTheUsersGoals(onCompletion: APIActivitiesGoalsArrayResponse) {
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
                        onCompletion(true, message, code, self.activitiesNotGoals, goals, nil)
                    } else {
                        onCompletion(false, message, code, self.activitiesNotGoals, goals, nil)
                    }
                })
            }else{
                onCompletion(false, serverMessage, serverCode, nil, nil, nil)
            }
        }
    }
    
    /**
     Returns a self link (used to get an activity not edit) for an activity of a specific type from the get all activities API,
     
     - parameter activityName: CategoryName, Category name such as Social, News or Gambling
     - parameter onCompletion: APIActivityLinkResponse, returns the link for an activity and success or fail and server messages and codes
     */
    func getActivityLinkForActivityName(activityName: CategoryName, onCompletion: APIActivityLinkResponse) {
        self.getActivityCategories{ (success, message, code, activities, error) in
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
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
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
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
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

    /**
     IMplements the Activtiy with ID API call, and returns a specific activity identified by its ID
     
     - parameter activityID: String, activity ID
     - parameter onCompletion: APIActivityResponse, returns the activity requested as an Activities object
     */
    func getActivityCategoryWithLink(link: String, onCompletion: APIActivityResponse){

            //if the newActivites object has been filled then we can get the link to display activity
        self.APIService.callRequestWithAPIServiceResponse(nil, path: link, httpMethod: httpMethods.get) { success, json, error in
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

    /**
    Implements the Activtiy pr day, and combines data with goals and activitytype
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    func getActivityPrDay(size : Int, page : Int,onCompletion: APIActivityGoalResponse){
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            if success {
                if let path = user?.dailyActivityReportsLink {
                    //if the newActivites object has been filled then we can get the link to display activity
                    
                    let aPath = path + "?size=" + String(size) + "&page=" + String(page)
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: aPath, httpMethod: httpMethods.get) { success, json, error in
                        if let json = json {
                            guard success == true else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                return
                            }
                            var newData : [DayActivityOverview] = []
                            newData = self.getActivtyPrDayhandleActivieResponse( json)
                            if newData.count > 0 {
                            
                                self.getActivityCategories(  {(success, ServerMessage, ServerCode, activities, error) in
                                    
                                    if activities?.count > 0 {
                                    
                                        GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (success, servermessage, servercode, nil, goals, error) in
                                            
                                            if success  {
                                                if let theGoals = goals {
                                                    for singleDayActivty in newData {
                                                        for singleActivity in singleDayActivty.activites {
                                                            singleActivity.addGoalsAndActivity(theGoals, activities: self.activities)
                                                        }
                                                    }
                                                }
                                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)

                                            } else {
                                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                                            }
                                        
                                        })
                                    } else {
                                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                    }
                                    })
                            }
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
 
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
    
    private func getActivtyPrDayhandleActivieResponse(theJson : BodyDataDictionary) -> [DayActivityOverview] {
        
        var newData : [DayActivityOverview] = []
        if let embedded = theJson[YonaConstants.jsonKeys.embedded],
            let embeddedActivities = embedded[YonaConstants.jsonKeys.yonaDayActivityOverviews] as? NSArray{
            for activity in embeddedActivities {
                var dateActivity : [ActivitiesGoal] = []
                var theDate : NSDate = NSDate()
                if let activity = activity as? BodyDataDictionary {
                    
                    
                    if let activityDate = activity[YonaConstants.jsonKeys.date] as? String {
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = getMessagesKeys.dateFormatSimple.rawValue
                        if let aDate = dateFormatter.dateFromString(activityDate) {
                            theDate = aDate
                        }
                    }
                    if let dayActivities = activity[YonaConstants.jsonKeys.dayActivities] as? [AnyObject]
                    {
                        for aData in dayActivities {
                            
                            let aActivityGoal = ActivitiesGoal.init(activityData: aData, date: theDate)
                            dateActivity.append(aActivityGoal)
                        }
                    }
                    
                }
                let daysActivities = DayActivityOverview(Date: theDate, theActivities: dateActivity)
 
                

                
                newData.append(daysActivities)
            }
        }

        
        
        return newData
    }

    /**
     Implements the Activity per week, and combines data with goals and activitytype
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    func getActivityPrWeek(size : Int, page : Int,onCompletion: APIActivityWeekResponse){
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            if success {
                if let path = user?.weeklyActivityReportsLink {
                    //if the newActivites object has been filled then we can get the link to display activity
                    
                    let aPath = path + "?size=" + String(size) + "&page=" + String(page)
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: aPath, httpMethod: httpMethods.get) { success, json, error in
                        if let json = json {
                            guard success == true else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                return
                            }
                            var newData : [WeekActivityGoal] = []
                            
                                self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                                    
                                    if activities?.count > 0 {
                                        
                                        GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                                            
                                            if status  {
                                               newData = self.getActivtyPrWeekhandleActivieResponse(json, goals: goals!)
                                            }
                                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)

                                        })
                                    } else {
                                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                    }
                                })
                            
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
    
    
    private func getActivtyPrWeekhandleActivieResponse(theJson : BodyDataDictionary, goals : [Goal]) -> [WeekActivityGoal] {
        
        var newData : [WeekActivityGoal] = []
        if let embedded = theJson[YonaConstants.jsonKeys.embedded],
            let embeddedActivities = embedded[YonaConstants.jsonKeys.weekActivityOverviews] as? [BodyDataDictionary]{
            for object in embeddedActivities  {
                let week = WeekActivityGoal(data:object, allGoals: goals)
                newData.append(week)
                
                
            }
        }
        
        return newData
    }

    //MARK: - buddie pr day activitie
    
    /**
     Implements the Activtiy pr day, and combines data with goals and activitytype
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    func getBuddieActivityPrDay(buddy: Buddies,size : Int, page : Int,onCompletion: APIActivityGoalResponse){
        
        if let path = buddy.dailyActivityReports {
            let aPath = path + "?size=" + String(size) + "&page=" + String(page)
            self.APIService.callRequestWithAPIServiceResponse(nil, path: aPath, httpMethod: httpMethods.get) { success, json, error in
                if let json = json {
                    guard success == true else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        return
                    }
                    var newData : [DayActivityOverview] = []
                    newData = self.getBuddieActivtyPrDayhandleActivieResponse( json)
                    if newData.count > 0 {
                        
                        self.getActivityCategories(  {(success, ServerMessage, ServerCode, activities, error) in
                            
                            if activities?.count > 0 {
                                
                                GoalsRequestManager.sharedInstance.getAllTheBuddyGoals(buddy, activities: activities!, onCompletion: { (success, servermessage, servercode, nil, goals, error) in
                                    
                                    if success  {
                                        if let theGoals = goals {
                                            for singleDayActivty in newData {
                                                for singleActivity in singleDayActivty.activites {
                                                    singleActivity.addGoalsAndActivity(theGoals, activities: self.activities)
                                                }
                                            }
                                        }
                                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                                        
                                    }
                                    
                                })
                            } else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                            }
                        })
                    }
                    
                } else {
                    //response from request failed
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                }
            }

        }
        
    }
    
    private func getBuddieActivtyPrDayhandleActivieResponse(theJson : BodyDataDictionary) -> [DayActivityOverview] {
        
        var newData : [DayActivityOverview] = []
        if let embedded = theJson[YonaConstants.jsonKeys.embedded],
            let embeddedActivities = embedded[YonaConstants.jsonKeys.yonaDayActivityOverviews] as? NSArray{
            for activity in embeddedActivities {
                var dateActivity : [ActivitiesGoal] = []
                var theDate : NSDate = NSDate()
                if let activity = activity as? BodyDataDictionary {
                    
                    
                    if let activityDate = activity[YonaConstants.jsonKeys.date] as? String {
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = getMessagesKeys.dateFormatSimple.rawValue
                        if let aDate = dateFormatter.dateFromString(activityDate) {
                            theDate = aDate
                        }
                    }
                    if let dayActivities = activity[YonaConstants.jsonKeys.dayActivities] as? [AnyObject]
                    {
                        for aData in dayActivities {
                            
                            let aActivityGoal = ActivitiesGoal.init(activityData: aData, date: theDate)
                            dateActivity.append(aActivityGoal)
                        }
                    }
                    
                }
                let daysActivities = DayActivityOverview(Date: theDate, theActivities: dateActivity)
                
                newData.append(daysActivities)
            }
        }
        
        return newData
    }

    
    
    /**
     Implements the Activity per week, and combines data with goals and activitytype
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    func getBuddieActivityPrWeek(buddy: Buddies,size : Int, page : Int,onCompletion: APIActivityWeekResponse){
        if let path = buddy.weeklyActivityReports {
            //if the newActivites object has been filled then we can get the link to display activity
            
            let aPath = path + "?size=" + String(size) + "&page=" + String(page)
            self.APIService.callRequestWithAPIServiceResponse(nil, path: aPath, httpMethod: httpMethods.get) { success, json, error in
                if let json = json {
                    guard success == true else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        return
                    }
                    var newData : [WeekActivityGoal] = []
                    
                    self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                        
                        if activities?.count > 0 {
                            
                            GoalsRequestManager.sharedInstance.getAllTheBuddyGoals(buddy,activities: activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                                
                                if status  {
                                    newData = self.getActivtyPrWeekhandleActivieResponse(json, goals: goals!)
                                }
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                                
                            })
                        } else {
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        }
                    })
                    
                } else {
                    //response from request failed
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                }
            }
            
        } else {
                //response from request failed
            onCompletion(false, YonaConstants.serverMessages.FailedToRetrieveGetUserDetails, String(responseCodes.internalErrorCode), nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
        }
    }

    
    
    //MARK: - Week single day activity
    
    /**
     // Get day network and app activity for a specific goal on a specific week
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    
    func getActivityDetails(buddy: Buddies, activityLink : String,date :NSDate ,onCompletion: APIActivityWeekDetailResponse){
        self.APIService.callRequestWithAPIServiceResponse(nil, path: activityLink, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    return
                }
                var newData : WeekSingleActivityDetail?
                
                self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                    
                    if activities?.count > 0 {
                        
                        GoalsRequestManager.sharedInstance.getAllTheBuddyGoals(buddy, activities: activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                            
                            if status  {
                                newData = WeekSingleActivityDetail(data: json, allGoals: goals!)
                            }
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                            
                        })
                    } else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    }
                })
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
            }
        }
        
    }

    
    
    func getActivityDetails(activityLink : String,date :NSDate ,onCompletion: APIActivityWeekDetailResponse){
                    self.APIService.callRequestWithAPIServiceResponse(nil, path: activityLink, httpMethod: httpMethods.get) { success, json, error in
                        if let json = json {
                            guard success == true else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                return
                            }
                            var newData : WeekSingleActivityDetail?
                            
                            self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                                
                                if activities?.count > 0 {
                                    
                                    GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                                        
                                        if status  {
                                            newData = WeekSingleActivityDetail(data: json, allGoals: goals!)
                                        }
                                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                                        
                                    })
                                } else {
                                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                                }
                            })
                            
                        } else {
                            //response from request failed
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        }
                    }
        
    }
    
    //MARK: - Single day activity
    
    func getBuddyDayActivityDetails(activityLink : String,date :NSDate, buddy: Buddies ,onCompletion: APIActivityDayDetailResponse ){
        
        
        self.APIService.callRequestWithAPIServiceResponse(nil, path: activityLink, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    return
                }
                var newData : DaySingleActivityDetail?
                
                self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                    
                    if activities?.count > 0 {
                        if let _ = buddy.selfLink {
                            GoalsRequestManager.sharedInstance.getAllTheBuddyGoals(buddy, activities: activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                                
                                if status  {
                                    newData = DaySingleActivityDetail(data: json, allGoals: goals!)
                                }
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                                
                            })

                        }
                    }
                })
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
            }
        }
        
    }
 
 
    /**
     // Get week app activity for a specific goal on a specific week
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityWeekDetailResponse, returns the activity requested as an Activities object
     */
    func getWeekActivityDetails(activityLink : String,date :NSDate ,onCompletion: APIActivityWeekDetailResponse){
        self.APIService.callRequestWithAPIServiceResponse(nil, path: activityLink, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    return
                }
                var newData : WeekSingleActivityDetail?
                
                self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                    
                    if activities?.count > 0 {
                        
                        GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                            
                            if status  {
                                newData = WeekSingleActivityDetail(data: json, allGoals: goals!)
                            }
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                            
                        })
                    } else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    }
                })
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
            }
        }
        
    }

    /**
     // Get day app activity for a specific goal on a specific day
     - paramter size : The number of elements to be fetched
     - paramter page : The page to be fetched
     - parameter onCompletion: APIActivityGoalResponse, returns the activity requested as an Activities object
     */
    func getDayActivityDetails(activityLink : String,date :NSDate ,onCompletion: APIActivityDayDetailResponse ){
        self.APIService.callRequestWithAPIServiceResponse(nil, path: activityLink, httpMethod: httpMethods.get) { success, json, error in
            if let json = json {
                guard success == true else {
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    return
                }
                var newData : DaySingleActivityDetail?
                
                self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                    
                    if activities?.count > 0 {
                        GoalsRequestManager.sharedInstance.getAllTheGoals(activities!, onCompletion: { (status, servermessage, servercode, nil, goals, error) in
                            
                            if status  {
                                newData = DaySingleActivityDetail(data: json, allGoals: goals!)
                            }
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), newData, error)
                            
                        })
                        
                    } else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                    }
                })
                
            } else {
                //response from request failed
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
            }
        }
    }
    
    func getTimeLineActivity(size : Int, page : Int,onCompletion: APIActivityTimeLineResponse){
        UserRequestManager.sharedInstance.getUser(GetUserRequest.allowed) { (success, message, code, user) in
            if success && user?.timeLineLink != nil {
                var data : [TimeLineDayActivityOverview] = []
                var link = ""
                if let aLink = user?.timeLineLink {
                    link = aLink
                }
                let aPath = link + "?size=" + String(size) + "&page=" + String(page)
                self.APIService.callRequestWithAPIServiceResponse(nil, path: aPath, httpMethod: httpMethods.get) { success, json, error in
                    if let json = json {
                        guard success == true else {
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                            return
                        }
                        if let embedded = json[YonaConstants.jsonKeys.embedded],
                            let embeddedActivities = embedded[YonaConstants.jsonKeys.yonaDayActivityOverviews] as? NSArray {
                            
                            self.getActivityCategories(  {(status, ServerMessage, ServerCode, activities, error) in
                                if activities?.count > 0 {
                                    for activity in embeddedActivities {
                                        let obj = TimeLineDayActivityOverview(jsonData : activity as! BodyDataDictionary, activities : activities!)
                                        data.append(obj)
                                        
                                    }
                                    // NOW All data load  - Fill out the blanks :-|
                                    self.loadAllGoals(data , completion : {(succes) in
                                        for obj in data {
                                            if let theBuddies = user?.buddies {
                                                obj.configureForTableView(theBuddies,aUser:user!)
                                            }
                                        }
                                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), data, error)
                                        
                                    })
                                }
                                
                            })
                            
                            
                        } else {
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                        }

                    }
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, error)
                }
                
            }
                
            else {
                
                onCompletion(false, message, code, nil, nil)
                
                

            }
        }//)
    }
    
    
    func loadAllGoals(data : [TimeLineDayActivityOverview], completion : APITimeLineUserGoalsRespons) {
    
  /*      var userdataArr : [TimeLinedayActivitiesForUsers] = []
        var activityArr : [TimeLineDayActivities] = []
        for each in data {
            for activiti in each.activites {
                activityArr.append(activiti)
                for aUser in activiti.userData {
                    userdataArr.append(aUser)
                }

            }
        }*/
        loadActivities (data ,section : 0 ,row : 0,completion : {(success) in
            //self.loadGoals (data,section : 0, row : 0, user : 0 ,completion : {(success) in
                completion(true)
            //})
            
        })
        
    }

    
    func loadActivities( userData : [TimeLineDayActivityOverview], section: Int, row : Int, completion :APITimeLineUserGoalsRespons?){
        if completion != nil {
            timeLineAcitivityCompletion = completion
        }
        if section >= userData.count {
            timeLineAcitivityCompletion!(true)
            return
        }
        
        if row >= userData[section].activites.count {
            self.loadActivities(userData, section: section + 1, row:  0, completion:  nil)
            return
        }
        if let link = userData[section].activites[row].activityCategoryLink {
            ActivitiesRequestManager.sharedInstance.getActivityCategoryWithLink(link, onCompletion: {(success, serverMessage, serverCode, activities, error) in
                if success  {
                    if activities != nil {
                        
                        userData[section].activites[row].setActivity(activities!)
                    }
                    var newRow = row
                    var newSection = section
                    if newRow >= userData[section].activites.count {
                        newRow = 0
                        newSection += 1
                    } else {
                        newRow += 1
                    }
                    
                    self.loadActivities(userData, section: newSection, row:  newRow, completion:  nil)
                }

            })
        }
    }
    

    func loadGoals( userData : [TimeLineDayActivityOverview], section : Int, row : Int, user :Int, completion :APITimeLineUserGoalsRespons?){
        if completion != nil {
            timeLineUserCompletion = completion
        }
        if section >= userData.count {
            timeLineUserCompletion!(true)
            return
        }
        if row >= userData[section].activites.count {
            self.loadGoals(userData, section: section + 1, row : 0 ,user: 0, completion:  nil)
            return
        }
        if user >= userData[section].activites[row].userData.count {
            self.loadGoals(userData, section: section, row : (row + 1) ,user: 0, completion:  nil)
            return
        }
        
        if let _ = userData[section].activites[row].userData[user].buddyLink {
            if let link = userData[section].activites[row].userData[user].goalLink {
                if let goals = timeLineGoals[link]  {
                    userData[section].activites[row].userData[user].setGoalData(goals)
                    self.loadGoals(userData, section: section, row : row ,user: (user + 1 ), completion:  nil)
                } else {                
                    GoalsRequestManager.sharedInstance.getAllTheBuddyGoals(link, onCompletion: {(succes, serverMessage, serverCode, goal, goals, error)
                        in
                        if succes {
                            if goal != nil {
                                self.timeLineGoals[link] = [goal!]
                                userData[section].activites[row].userData[user].setGoalData([goal!])
                            }
                            self.loadGoals(userData, section: section, row : row ,user: (user + 1 ), completion:  nil)
                        }
                    })
                }
            }
        } else if let _ = userData[section].activites[row].userData[user].userLink {
            GoalsRequestManager.sharedInstance.getAllTheGoals([], onCompletion: {(succes, serverMessage, serverCode, goal, goals, error)
                in
                if succes {
                    userData[section].activites[row].userData[user].setGoalData(goals!)
                    self.loadGoals(userData, section: section, row : row ,user: (user + 1 ), completion:  nil)
                }
            })

        }
    }
}