
//
//  TimeBucketChallenges.swift
//  Yona
//
//  Created by Chandan on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class TimeBucketChallenges: UIViewController,UIScrollViewDelegate {
    
    enum SelectedCategoryHeader {
        case BudgetGoal
        case BudgetActivity
        case TimeZoneGoal
        case TimeZoneActivity
        case NoGoGoal
        case NoGoActivity
    }
    
    @IBOutlet var gradientView: GradientView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!
    
    @IBOutlet var budgetView: UIView!
    @IBOutlet var budgetBadgeLabel: UILabel!
    
    @IBOutlet var timezoneView: UIView!
    @IBOutlet var timezoneBadgeLabel: UILabel!
    
    @IBOutlet var nogoView: UIView!
    @IBOutlet var nogoBadgeLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var addNewGoalButton: UIButton!
    
    
    @IBOutlet var budgetViewBottomBorder: UIView!
    @IBOutlet var timezoneViewBottomBorder: UIView!
    @IBOutlet var nogoViewBottomBorder: UIView!
    
    
    
    var selectedCategoryView: UIView!
    var activityCategoriesArray = [Activities]()
    
    var budgetArray = [Goal]()
    var timeZoneArray = [Goal]()
    var nogoArray = [Goal]()
    
    var activitySelected: Activities?
    var budgetGoalSelected: Goal?
    
    var categoryHeader = SelectedCategoryHeader.BudgetGoal
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        setTimeBucketTabToDisplay(timeBucketTabNames.budget.rawValue, key: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
        
        self.setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.callActivityCategory()
        setDeselectOtherCategory()
        self.timeBucketData(.BudgetGoalString)
        self.timeBucketData(.TimeZoneGoalString)
        self.timeBucketData(.NoGoGoalString)
        if let tabName = getViewControllerToDisplay(YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay) as? String {
            switch tabName {
            case timeBucketTabNames.budget.rawValue:
                
                setSelectedCategory(self.budgetView)
                
            case timeBucketTabNames.timeZone.rawValue:
                
                setSelectedCategory(self.timezoneView)
                
            case timeBucketTabNames.noGo.rawValue:
                
                setSelectedCategory(self.nogoView)
                
            default:
                self.timeBucketData(.BudgetGoalString)
                setSelectedCategory(self.budgetView)
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
        })
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // MARK: - private functions
    private func setDeselectOtherCategory() {
        self.budgetViewBottomBorder.hidden = true
        self.timezoneViewBottomBorder.hidden = true
        self.nogoViewBottomBorder.hidden = true
        
        budgetView.alpha = 0.5
        timezoneView.alpha = 0.5
        nogoView.alpha = 0.5
    }
    
    private func setSelectedCategory(categoryView: UIView) {
        
        addNewGoalButton.hidden = false
        backButton.hidden = true
        
        selectedCategoryView = categoryView
        
        categoryView.alpha = 1.0
        
        switch categoryView {
            
        case budgetView:
            categoryHeader = .BudgetGoal
            self.budgetViewBottomBorder.hidden = false
            
        case timezoneView:
            categoryHeader = .TimeZoneGoal
            self.timezoneViewBottomBorder.hidden = false
            
        case nogoView:
            categoryHeader = .NoGoGoal
            self.nogoViewBottomBorder.hidden = false
            
        default:
            print("Nothing")
        }
        
        self.setHeaderTitleLabel()
        self.tableView.reloadData()
    }
    
    private func updateUI(goal: GoalType, timeBucketData: [Goal]) {
        switch goal {
        case .BudgetGoalString:
            self.budgetArray = timeBucketData
            self.budgetBadgeLabel.hidden = self.budgetArray.count > 0 ? false : true
            self.budgetBadgeLabel.text = String(self.budgetArray.count)
            
        case .TimeZoneGoalString:
            self.timeZoneArray = timeBucketData
            self.timezoneBadgeLabel.hidden = self.timeZoneArray.count > 0 ? false : true
            self.timezoneBadgeLabel.text = String(self.timeZoneArray.count)
            
            
        case .NoGoGoalString:
            self.nogoArray = timeBucketData
            self.nogoBadgeLabel.hidden = self.nogoArray.count > 0 ? false : true
            self.nogoBadgeLabel.text = String(self.nogoArray.count)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    private func timeBucketData(goal: GoalType) {
        
        APIServiceManager.sharedInstance.getGoalsOfType(goal , onCompletion: { (success, message, code, nil, goals, err) in
            if success {
                if let goalsUnwrap = goals {
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            
                            print(goals)
                            self.updateUI(goal, timeBucketData: goalsUnwrap)
                        })
                        
                        for goal in goals! {
                            print(goal.goalType)
                        }
                        
                        #if DEBUG
                            for goal in goalsUnwrap {
                                print(goal.goalType)
                            }
                        #endif
                }
            }
        })
    }
    
    
    private func callActivityCategory() {
        Loader.Show(delegate: self)
        ActivitiesRequestManager.sharedInstance.getActivitiesNotAdded{ (success, message, code, activities, error) in
            if success{
                dispatch_async(dispatch_get_main_queue()) {
                    Loader.Hide(self)
                }
                self.activityCategoriesArray = activities!
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    Loader.Hide(self)
                    if let message = message {
                        self.displayAlertMessage(message, alertDescription: "")
                    }
                }
            }
        }
    }
    
    private func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //    Looks for single or multiple taps.
        let budgetTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.budgetView.addGestureRecognizer(budgetTap)
        
        let timezoneTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.timezoneView.addGestureRecognizer(timezoneTap)
        
        let nogoTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.nogoView.addGestureRecognizer(nogoTap)
        
        self.budgetBadgeLabel.hidden = true
        self.nogoBadgeLabel.hidden = true
        self.timezoneBadgeLabel.hidden = true
        
        setDeselectOtherCategory()
        setSelectedCategory(self.budgetView)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    
    func setHeaderTitleLabel() {
        switch categoryHeader {
        case .BudgetGoal:
            headerLabel.text = NSLocalizedString("challenges.user.budgetGoalHeader", comment: "")
        case .BudgetActivity:
            headerLabel.text = NSLocalizedString("challenges.user.budgetCategoryHeader", comment: "")
        case .TimeZoneGoal:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneGoalHeader", comment: "")
        case .TimeZoneActivity:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneCategoryHeader", comment: "")
        case .NoGoGoal:
            headerLabel.text = NSLocalizedString("challenges.user.nogoGoalHeader", comment: "")
        case .NoGoActivity:
            headerLabel.text = NSLocalizedString("challenges.user.nogoCategoryHeader", comment: "")
        }
    }
    
    
    // MARK: - Tapgesture category view tap events
    func categoryTapEvent(sender: UITapGestureRecognizer? = nil) {
        setDeselectOtherCategory()
        setSelectedCategory((sender?.view)!)
    }
    
    // MARK: - Actions
    @IBAction func back(sender: AnyObject) {
        self.setSelectedCategory(selectedCategoryView)
    }
    
    @IBAction func addNewGoalbuttonTapped(sender: UIButton) {
        sender.hidden = true
        backButton.hidden = false
        if selectedCategoryView == budgetView {
            categoryHeader = .BudgetActivity
            
        } else if selectedCategoryView == timezoneView {
            categoryHeader = .TimeZoneActivity
        } else if selectedCategoryView == nogoView {
            categoryHeader = .NoGoActivity
        }
        self.setHeaderTitleLabel()
        self.tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(categoryHeader)
        let destinationViewController = segue.destinationViewController
        var isfromActivity:Bool = true
        if categoryHeader == .BudgetGoal || categoryHeader == .TimeZoneGoal || categoryHeader == .NoGoGoal{
            isfromActivity = false
        }
        if let segueIdentifier = segue.identifier,
            let segueIdentifierValue = Segues(rawValue: segueIdentifier) {
            switch segueIdentifierValue {
            case .BudgetChallengeSegue:
                
                let detailView = destinationViewController as! TimeFrameBudgetChallengeViewController
                if let activitySelectedUnwrap = self.activitySelected {
                    detailView.activitiyToPost = activitySelectedUnwrap
                }
                if let budgetGoalSelectedUnwrap = self.budgetGoalSelected {
                    detailView.goalCreated = budgetGoalSelectedUnwrap
                }
                detailView.isFromActivity = isfromActivity
            case .TimeZoneChallengeSegue:
                
                let detailView = destinationViewController as! TimeFrameTimeZoneChallengeViewController
                if let activitySelectedUnwrap = self.activitySelected {
                    detailView.activitiyToPost = activitySelectedUnwrap
                }
                if let timezoneGoalSelectedUnwrap = self.budgetGoalSelected {
                    detailView.goalCreated = timezoneGoalSelectedUnwrap
                }
                detailView.isFromActivity = isfromActivity
                
            case .NoGoChallengeSegue:
                let detailView = destinationViewController as! TimeFrameNoGoChallengeViewController
                if let activitySelectedUnwrap = self.activitySelected {
                    detailView.activitiyToPost = activitySelectedUnwrap
                }
                if let nogoGoalSelectedUnwrap = self.budgetGoalSelected {
                    detailView.goalCreated = nogoGoalSelectedUnwrap
                }
                detailView.isFromActivity = isfromActivity
            }
        }
    }
    
}

extension TimeBucketChallenges {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch categoryHeader {
            
        case .BudgetGoal:
            return self.budgetArray.count
            
        case .TimeZoneGoal:
            return self.timeZoneArray.count
            
        case .NoGoGoal:
            return self.nogoArray.count
            
        case .BudgetActivity:
            return self.activityCategoriesArray.count
            
        case .TimeZoneActivity:
            return self.activityCategoriesArray.count
            
        case .NoGoActivity:
            return self.activityCategoriesArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        switch categoryHeader {
        case .BudgetGoal:
            if let activityCategoryNameUnwrap = self.budgetArray[indexPath.row].GoalName,
                let maxDurationMinutesUnwrap = self.budgetArray[indexPath.row].maxDurationMinutes {
                let localizedString = NSLocalizedString("challenges.user.budgetGoalDescriptionText", comment: "")
                let title = NSString(format: localizedString, String(maxDurationMinutesUnwrap), String(activityCategoryNameUnwrap))
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = title as String
                cell.detailTextLabel?.numberOfLines = 0
            }
            
        case .BudgetActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .TimeZoneGoal:
            if let activityCategoryNameUnwrap = self.timeZoneArray[indexPath.row].GoalName {
                var andConcate = [String]()
                for time in self.timeZoneArray[indexPath.row].zonesStore {
                    let arr = time.dashRemoval()
                    let a = arr.joinWithSeparator(NSLocalizedString("challenges.user.TimeZoneGoalDescriptionAndText", comment: ""))
                    andConcate.append(a)
                }
                let localizedString = NSLocalizedString("challenges.user.TimeZoneGoalDescriptionText", comment: "") + andConcate.joinWithSeparator(NSLocalizedString("challenges.user.TimeZoneGoalDescriptionBetweenText", comment: ""))
                
                print(localizedString)
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = localizedString
                cell.detailTextLabel?.numberOfLines = 0
            }
            
        case .TimeZoneActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .NoGoGoal:
            if let activityCategoryNameUnwrap = self.nogoArray[indexPath.row].GoalName,
                let _ = self.nogoArray[indexPath.row].maxDurationMinutes {
                let localizedString = NSLocalizedString("challenges.user.nogoGoalDescriptionText", comment: "")
                let title = NSString(format: localizedString, String(activityCategoryNameUnwrap))
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = title as String
                cell.detailTextLabel?.numberOfLines = 0
            }
            
        case .NoGoActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if categoryHeader == .BudgetGoal || categoryHeader == .BudgetActivity{
            switch categoryHeader {
            case .BudgetActivity:
                self.activitySelected = self.activityCategoriesArray[indexPath.row]
            case .BudgetGoal:
                self.budgetGoalSelected = self.budgetArray[indexPath.row]
            default:
                break
            }
            performSegueWithIdentifier(R.segue.timeBucketChallenges.budgetChallengeSegue, sender: self)
        } else if categoryHeader == .TimeZoneGoal  || categoryHeader == .TimeZoneActivity {
            switch categoryHeader {
            case .TimeZoneActivity:
                self.activitySelected = self.activityCategoriesArray[indexPath.row]
            case .TimeZoneGoal:
                self.budgetGoalSelected = self.timeZoneArray[indexPath.row]
            default:
                break
            }
            performSegueWithIdentifier(R.segue.timeBucketChallenges.timezoneChallengeSegue, sender: self)
        } else if categoryHeader == .NoGoGoal  || categoryHeader == .NoGoActivity {
            switch categoryHeader {
            case .NoGoActivity:
                self.activitySelected = self.activityCategoriesArray[indexPath.row]
            case .NoGoGoal:
                self.budgetGoalSelected = self.nogoArray[indexPath.row]
            default:
                break
            }
            performSegueWithIdentifier(R.segue.timeBucketChallenges.noGoChallengeSegue, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if categoryHeader == .BudgetGoal || categoryHeader == .TimeZoneGoal || categoryHeader == .NoGoGoal {
            return 100.0
        } else {
            return 60.0
        }
    }
}


private extension Selector {
    
    static let categoryTapEvent = #selector(TimeBucketChallenges.categoryTapEvent(_:))
    
    static let back = #selector(TimeBucketChallenges.back(_:))
}


