//
//  GoalsRequestManager.swift
//  Yona
//
//  Created by Ben Smith on 28/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import Foundation


//MARK: - Goal APIService
class GoalsRequestManager {
    var budgetGoals:[Goal] = [] //Array returning budget goals
    var timezoneGoals:[Goal] = [] //Array returning timezone goals
    var noGoGoals:[Goal] = [] //Array returning no go goals
    
    private var newGoal: Goal?
    var allTheGoals:[Goal] = [] //Array returning all the goals returned by getGoals

    let APIService = APIServiceManager.sharedInstance
    let APIUserRequestManager = UserRequestManager.sharedInstance
    
    static let sharedInstance = GoalsRequestManager()
    
    private init() {}
    
    /**
     Helper method for UI to returns the size of the goals arrays, so challenges know how many goals there
     
     - parameter goalType: GoalType, goal type that we want array size for
     - parameter  onCompletion: APIGoalSizeResponse, returns server response messages, and goal array size
     */
    func getGoalsSizeOfGoalType(goalType: GoalType, onCompletion: APIGoalSizeResponse) {
        
        switch goalType {
        case GoalType.BudgetGoalString:
            guard budgetGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(budgetGoals.count)
        case GoalType.TimeZoneGoalString:
            guard timezoneGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(timezoneGoals.count)
        case GoalType.NoGoGoalString:
            guard noGoGoals.isEmpty else {
                onCompletion(0)
                return
            }
            onCompletion(noGoGoals.count)
        }
    }
    
    /**
     Private func used by API service method getGoalsOfType to sort the goals into their appropriate array types and return the array request of that type of goals
     
     - parameter goalType: GoalType, The goaltype that we require the array for
     - parameter onCompletion: APIGoalResponse, Returns the array of goals, and success or fail and server messages
     - return [Goal] and array of goals
     */
     func sortGoalsIntoArray(goalType: GoalType, goals: [Goal]) -> [Goal]{
        budgetGoals = []
        timezoneGoals = []
        noGoGoals = []
        //sort out the goals into their arrays

        for goal in goals {
            switch goal.goalType! {
            case GoalType.BudgetGoalString.rawValue:
                budgetGoals.append(goal)
            case GoalType.TimeZoneGoalString.rawValue:
                timezoneGoals.append(goal)
            case GoalType.NoGoGoalString.rawValue:
                noGoGoals.append(goal)
            default:
                break
            }
        }
        
        //which array shall we send back?
        switch goalType {
        case GoalType.BudgetGoalString:
            return budgetGoals
        case GoalType.TimeZoneGoalString:
            return timezoneGoals
        case GoalType.NoGoGoalString:
            return noGoGoals
        }
    }
    
    /**
     Generic method to get the goals or post a goal, as they require the same actions but just a different httpmethod
     
     - parameter httpmethodParam: httpMethods, The httpmethod enum, POST GET etc
     - parameter body: BodyDataDictionary?, body that is needed in a POST call, can be nil
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    private func goalsHelper(httpmethodParam: httpMethods, body: BodyDataDictionary?, goalLinkAction: String?, onCompletion: APIGoalResponse) {
        //success get our activities
        ActivitiesRequestManager.sharedInstance.getActivityCategories{ (success, message, serverCode, activities, error) in
            if success {
                //get the path to get all the goals from user object
                if let path = goalLinkAction {
                    //do request with specific httpmethod
                    self.APIService.callRequestWithAPIServiceResponse(body, path: path, httpMethod: httpmethodParam, onCompletion: { success, json, error in
                        if let json = json {
                            guard success == true else {
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
                                return
                            }
                            
                            //if we get a goals array response, send back the array of goals
                            self.allTheGoals = []
                            if let embedded = json[YonaConstants.jsonKeys.embedded],
                                let embeddedGoals = embedded[YonaConstants.jsonKeys.yonaGoals] as? NSArray{
                                //iterate embedded goals response
                                for goal in embeddedGoals {
                                    if let goal = goal as? BodyDataDictionary {
                                        self.newGoal = Goal.init(goalData: goal, activities: activities!)
                                        if let goal = self.newGoal {
                                            if !goal.isHistoryItem {
                                            self.allTheGoals.append(goal)
                                            }
                                            
                                        }
                                    }
                                }
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, self.allTheGoals, error)
                            } else { //if we just get one goal, for post goal, just that goals is returned so send that back
                                self.newGoal = Goal.init(goalData: json, activities: activities!)
                                //add the new goal to the goals array
                                self.allTheGoals.append(self.newGoal!)
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.newGoal, nil, error)
                            }
                        } else {
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
                        }
                    })
                }
            } else {
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
            }
        }
    }
    
    
    
    func getAllTheBuddyGoals(path : String, onCompletion: APIGoalResponse) {
        
        
        self.goalsHelper(httpMethods.get, body: nil, goalLinkAction: path) { (success, message, server, goal, goals, error) in
            if success {                
                onCompletion(true, message, server, goal, goals, error)
            } else {
                onCompletion(false, message, server, nil, nil, error)
            }
        }    
    }

    
    
    func getAllTheBuddyGoals(buddy : Buddies, activities: [Activities], onCompletion: APIGoalResponse) {
        if let buddypath = buddy.selfLink {
            let path = "\(buddypath)/goals/"
            
            //success so get the user?
            
            self.goalsHelper(httpMethods.get, body: nil, goalLinkAction: path) { (success, message, server, goal, goals, error) in
                #if DEBUG
                    print("Get all goals API call: " + String(success))
                #endif
                if success {
                    onCompletion(true, message, server, nil, goals, error)
                } else {
                    onCompletion(false, message, server, nil, nil, error)
                }
            }
        }
    }

    /**
     Called to get all the users goals
 
     - parameter activities: [Activities], goals need to know about all the activities so they can ID them and set their activity name in the goal (Social, News etc.)
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    func getAllTheGoals(activities: [Activities], onCompletion: APIGoalResponse) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            //success so get the user?
            if success {
                if let goalLink = user?.getAllGoalsLink {
                    self.goalsHelper(httpMethods.get, body: nil, goalLinkAction: user?.getAllGoalsLink!) { (success, message, server, goal, goals, error) in
                        #if DEBUG
                            print("Get all goals API call: " + String(success))
                        #endif
                        if success {
                            onCompletion(true, message, server, nil, goals, error)
                        } else {
                            onCompletion(false, message, server, nil, nil, error)
                        }
                    }
                } else {
                    onCompletion(false, YonaConstants.YonaErrorTypes.UserRequestFailed.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.UserRequestFailed), nil, nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
                
                }
            } else {
                //response from request failed
                onCompletion(false, YonaConstants.YonaErrorTypes.UserRequestFailed.localizedDescription, self.APIService.determineErrorCode(YonaConstants.YonaErrorTypes.UserRequestFailed), nil, nil, YonaConstants.YonaErrorTypes.UserRequestFailed)
            }
        }
    }
    
    /**
     Posts a new goal of a certain type defined in the body, sends the goal back to the UI
     
     - parameter body: BodyDataDictionary, the body of the goal that needs to be posted, example below:
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    func postUserGoals(body: BodyDataDictionary, onCompletion: APIGoalResponse) {
        UserRequestManager.sharedInstance.getUser(GetUserRequest.notAllowed) { (success, message, code, user) in
            //success so get the user?
            if success {
                //success so get the user
                self.goalsHelper(httpMethods.post, body: body, goalLinkAction: user?.getAllGoalsLink) { (success, message, server, goal, goals, error) in
                    if success {
                        onCompletion(true, message, server, goal, nil, error)
                    } else {
                        onCompletion(false, message, server, nil, nil, error)
                    }
                }
            } else {
                //response from request failed
                onCompletion(false, message, code, nil, nil, nil)
            }
        }
    }
    
    /**
     Updates a goal. UI must send us the editlink of that goal and new body of the goal to update. Sends the updated goal back in a response
     
     - parameter goalEditLink: String? The edit link of the specific goal you want to update
     - parameter body: BodyDataDictionary, the body of the goal that needs to be updated, example above in post user goal
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    func updateUserGoal(goalEditLink: String?, body: BodyDataDictionary, onCompletion: APIGoalResponse) {
        self.goalsHelper(httpMethods.put, body: body, goalLinkAction: goalEditLink) { (success, message, server, goal, goals, error) in
            if success {
                onCompletion(true, message, server, goal, nil, error)
            } else {
                onCompletion(false, message, server, nil, nil, error)
            }
        }
    }
    
    /**
     Implements API call get goal with ID, given the self link for a goal it returns the goal requested
     
     - parameter goalSelfLink: String, the self link for the goal that we require
     - parameter onCompletion: APIGoalResponse, gives response messages and the goal requested
     */
    func getUsersGoalWithSelfLinkID(goalSelfLink: String, onCompletion: APIGoalResponse) {
        self.goalsHelper(httpMethods.get, body: nil, goalLinkAction: goalSelfLink) { (success, message, server, goal, goals, error) in
            if success {
                onCompletion(true, message, server, goal, nil, error)
            } else {
                onCompletion(false, message, server, nil, nil, error)
            }
        }
    }
    
    /**
     Implements API delete goal, given the edit link for the goal (if it exists, as it will not on Mandatory goals)
     
     - parameter goalEditLink: String?, If a goal is not mandatory then it will have and edit link and we will beable to delete it
     - parameter onCompletion: APIResponse, returns success or fail of the method and server messages
     */
    func deleteUserGoal(goalEditLink: String?, onCompletion: APIGoalResponse) {
        
        self.goalsHelper(httpMethods.delete, body: nil, goalLinkAction: goalEditLink) { (success, message, serverCode, goal, goals, error) in
            if success {
                ActivitiesRequestManager.sharedInstance.getActivityCategories({ (success, message, code, activities, error) in
                    if let activities = activities {
                        self.getAllTheGoals(activities) { (success, message, code, nil, goals, error) in
                            onCompletion(success, message, serverCode, goal, goals, error)
                        }
                    }
                })

            } else {
                onCompletion(false, message, serverCode, nil, nil, error)
            }
        }
    }
}
