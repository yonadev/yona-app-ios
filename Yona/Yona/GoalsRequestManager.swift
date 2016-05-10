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
    private var budgetGoals:[Goal] = [] //Array returning budget goals
    private var timezoneGoals:[Goal] = [] //Array returning timezone goals
    private var noGoGoals:[Goal] = [] //Array returning no go goals
    
    private var newGoal: Goal?
    private var allTheGoals:[Goal] = [] //Array returning all the goals returned by getGoals
    private var goalsReturned:[Goal] = [] //Array returning all the goals returned by getGoals

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
    private func sortGoalsIntoArray(goalType: GoalType, goals: [Goal]) -> [Goal]{
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
     Returns to the UI goals of a certain type that the user has set as a challenge
     
     - parameter goalType: GoalType, the GoalType (budget, timezone nogo)
     - parameter onCompletion: APIGoalResponse, returns success or fail, server messages and either an array of goals, or a goal, depending on what is returned which depends on the httpmethod (goals for a GET, a goal for a POST)
     */
    func getGoalsOfType(goalType: GoalType, onCompletion: APIGoalResponse) {
        ActivitiesRequestManager.sharedInstance.getActivitiesArray{ (success, message, serverCode, activities, error) in
            if success {
                switch goalType {
                    //if the goals arrays have been initialised
                case .BudgetGoalString:
                    if self.budgetGoals.count > 0{
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, self.budgetGoals, error)
                        break
                    }
                case .NoGoGoalString:
                    if self.noGoGoals.count > 0{
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, self.noGoGoals, error)
                        break
                    }
                case .TimeZoneGoalString:
                    if self.timezoneGoals.count > 0{
                        onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, self.timezoneGoals, error)
                        break
                    }
                }
                self.getUserGoals(activities!){ (success, serverMessage, serverCode, nil, goals, error) in
                    let tempGoals = self.sortGoalsIntoArray(goalType, goals: goals!)
                    onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, tempGoals, error)
                }

            } else {
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
            }
        }
    }
    
    /**
     Helper method to get all the goals associated to the user logged in
     
     - parameter none
     - parameter onCompletion: APIGoalResponse,returns success or fail, server messages and either an array of goals, or a goal, depending on what is returned which depends on the httpmethod (goals for a GET, a goal for a POST)
     */
    func getAllTheGoalsArray(onCompletion: APIGoalResponse) {
        ActivitiesRequestManager.sharedInstance.getActivitiesArray({ (success, serverMessage, serverCode, activities, error) in
            if success {
                self.getUserGoals(activities!) { (success, serverMessage, serverCode, nil, goals, error) in
                    onCompletion(success, serverMessage, serverCode, nil, goals, error)
                }
            } else {
                onCompletion(false, serverMessage, serverCode, nil, nil, nil)
            }
        })
    }
    
    /**
     Generic method to get the goals or post a goal, as they require the same actions but just a different httpmethod
     
     - parameter httpmethodParam: httpMethods, The httpmethod enum, POST GET etc
     - parameter body: BodyDataDictionary?, body that is needed in a POST call, can be nil
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    private func goalsHelper(httpmethodParam: httpMethods, body: BodyDataDictionary?, goalLinkAction: String?, onCompletion: APIGoalResponse) {
        //success get our activities
        ActivitiesRequestManager.sharedInstance.getActivitiesArray{ (success, message, serverCode, activities, error) in
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
                            self.goalsReturned = []
                            if let embedded = json[YonaConstants.jsonKeys.embedded],
                                let embeddedGoals = embedded[YonaConstants.jsonKeys.yonaGoals] as? NSArray{
                                //iterate embedded goals response
                                for goal in embeddedGoals {
                                    if let goal = goal as? BodyDataDictionary {
                                        self.newGoal = Goal.init(goalData: goal, activities: activities!)
                                        if let goal = self.newGoal {
                                            self.goalsReturned.append(goal)
                                        }
                                    }
                                }
                                self.allTheGoals = self.goalsReturned
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, self.goalsReturned, error)
                            } else { //if we just get one goal, for post goal, just that goals is returned so send that back
                                self.newGoal = Goal.init(goalData: json, activities: activities!)
                                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), self.newGoal, nil, error)
                            }
                        } else if httpmethodParam == .delete{
                            onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
                        }
                    })
                }
            } else {
                onCompletion(success, error?.userInfo[NSLocalizedDescriptionKey] as? String, self.APIService.determineErrorCode(error), nil, nil, error)
            }
        }
    }
    
    /**
     Called to get all the users goals
     
     - parameter activities: [Activities], goals need to know about all the activities so they can ID them and set their activity name in the goal (Social, News etc.)
     - parameter onCompletion: APIGoalResponse, returns either an array of goals, or a goal, also success or fail, server messages and
     */
    func getUserGoals(activities: [Activities], onCompletion: APIGoalResponse) {
        UserRequestManager.sharedInstance.getUser { (success, message, code, user) in
            //success so get the user?
            if success {
                self.goalsHelper(httpMethods.get, body: nil, goalLinkAction: user?.getAllGoalsLink!) { (success, message, server, goal, goals, error) in
                    if success {
                        onCompletion(true, message, server, nil, goals, error)
                    } else {
                        onCompletion(false, message, server, nil, nil, error)
                    }
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
        UserRequestManager.sharedInstance.getUser { (success, message, code, user) in
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
    func deleteUserGoal(goalEditLink: String?, onCompletion: APIResponse) {
        
        self.goalsHelper(httpMethods.delete, body: nil, goalLinkAction: goalEditLink) { (success, message, serverCode, goal, goals, error) in
            if success {
                self.goalsReturned = [] //empty array to repopulate
                self.getAllTheGoalsArray({ (success, message, code, nil, goals, error) in
                    onCompletion(success, message, serverCode)
                })
            } else {
                onCompletion(false, message, serverCode)
            }
        }
    }
}
