
//
//  TimeBucketChallenges.swift
//  Yona
//
//  Created by Chandan on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


class TimeBucketChallenges: BaseViewController, UIScrollViewDelegate, BudgetChallengeDelegate, TimeZoneChallengeDelegate, NoGoChallengeDelegate {
    
    enum SelectedCategoryHeader {
        case budgetGoal
        case budgetActivity
        case timeZoneGoal
        case timeZoneActivity
        case noGoGoal
        case noGoActivity
    }
    
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
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var addNewGoalButton: UIButton!
    
    @IBOutlet var budgetViewBottomBorder: UIView!
    @IBOutlet var timezoneViewBottomBorder: UIView!
    @IBOutlet var nogoViewBottomBorder: UIView!
    
    var selectedCategoryView: UIView!
    var activityCategoriesArrayBudget = [Activities]()
    var activityCategoriesArrayTimeZone = [Activities]()
    var activityCategoriesArrayNoGoGoal = [Activities]()
    
    var budgetArray = [Goal]()
    var timeZoneArray = [Goal]()
    var nogoArray = [Goal]()
    
    var activitySelected: Activities?
    var budgetGoalSelected: Goal?
    
    var categoryHeader = SelectedCategoryHeader.budgetGoal
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //It will select NoGo tab by default
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "TimeBucketChallenges")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as! [AnyHashable: Any])
        
        self.tableView.estimatedRowHeight = 100
        self.setupUI()
        self.callActivityCategory()
        setDeselectOtherCategory()
        
        budgetGoalSelected = nil
        
        if let tabName = getTabToDisplay(YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay) {
            switch tabName {
            case timeBucketTabNames.budget.rawValue:
                
                setSelectedCategory(self.budgetView)
                
            case timeBucketTabNames.timeZone.rawValue:
                
                setSelectedCategory(self.timezoneView)
                
            case timeBucketTabNames.noGo.rawValue:
                
                setSelectedCategory(self.nogoView)
                
            default:
                self.timeBucketData(.NoGoGoalString )
                setSelectedCategory(self.nogoView)
            }
        } else {
            self.timeBucketData(.NoGoGoalString )
            setSelectedCategory(self.budgetView)
        }
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    //Delegate fires
    func callGoalsMethod() {
        self.callActivityCategory()
    }
    
    // MARK: - private functions
    
    fileprivate func setDeselectOtherCategory() {
        self.budgetViewBottomBorder.isHidden = true
        self.timezoneViewBottomBorder.isHidden = true
        self.nogoViewBottomBorder.isHidden = true
        
        budgetView.alpha = 0.5
        timezoneView.alpha = 0.5
        nogoView.alpha = 0.5
    }
    
    fileprivate func setSelectedCategory(_ categoryView: UIView) {
        //        self.addNewGoalButton.hidden = !(self.activityCategoriesArray.count > 0)
        self.navigationItem.leftBarButtonItem = nil
        
        selectedCategoryView = categoryView
        
        categoryView.alpha = 1.0
        
        switch categoryView {
            
        case budgetView:
            addNewGoalButton.isHidden = !(self.activityCategoriesArrayBudget.count > 0)
            categoryHeader = .budgetGoal
            self.budgetViewBottomBorder.isHidden = false
            
            UserDefaults.standard.set(timeBucketTabNames.budget.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
            
            
        case timezoneView:
            addNewGoalButton.isHidden = !(self.activityCategoriesArrayTimeZone.count > 0)
            categoryHeader = .timeZoneGoal
            self.timezoneViewBottomBorder.isHidden = false
            UserDefaults.standard.set(timeBucketTabNames.timeZone.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
            
        case nogoView:
            addNewGoalButton.isHidden = !(self.activityCategoriesArrayNoGoGoal.count > 0)
            categoryHeader = .noGoGoal
            self.nogoViewBottomBorder.isHidden = false
            UserDefaults.standard.set(timeBucketTabNames.noGo.rawValue, forKey: YonaConstants.nsUserDefaultsKeys.timeBucketTabToDisplay)
            
        default:
            print("")
        }
        
        self.setHeaderTitleLabel()
        self.tableView.reloadData()
    }
    
    fileprivate func updateUI(_ goal: GoalType, timeBucketData: [Goal]) {
        let arrayData = timeBucketData.sorted { $0.GoalName < $1.GoalName }
        switch goal {
        case .BudgetGoalString:
            self.budgetArray = arrayData
            self.budgetBadgeLabel.isHidden = self.budgetArray.count > 0 ? false : true
            self.budgetBadgeLabel.text = String(self.budgetArray.count)
            
        case .TimeZoneGoalString:
            self.timeZoneArray = arrayData
            self.timezoneBadgeLabel.isHidden = self.timeZoneArray.count > 0 ? false : true
            self.timezoneBadgeLabel.text = String(self.timeZoneArray.count)
            
        case .NoGoGoalString:
            self.nogoArray = arrayData
            self.nogoBadgeLabel.isHidden = self.nogoArray.count > 0 ? false : true
            self.nogoBadgeLabel.text = String(self.nogoArray.count)
        }
        self.tableView.reloadData()
    }
    
    fileprivate func timeBucketData(_ goaltype: GoalType) {
        //switch statemetn for goaltype here, update UI with teh array of goal type
        switch goaltype {
        case .BudgetGoalString:
            self.updateUI(goaltype, timeBucketData: self.budgetArray)
        case .TimeZoneGoalString:
            self.updateUI(goaltype, timeBucketData: self.timeZoneArray)
        case .NoGoGoalString:
            self.updateUI(goaltype, timeBucketData: self.nogoArray)
            
        }
    }
    
    //    private func callGoals(activities: [Activities], goals: [Goal]?) {
    fileprivate func callGoals( _ goals: [Goal]?) {
        #if DEBUG
        print("****** GOALS CALLED ******")
        #endif
        
        if let goalsUnwrap = goals {
            self.budgetArray = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(GoalType.BudgetGoalString, goals: goalsUnwrap)
            self.timeBucketData(.BudgetGoalString)
            
            self.timeZoneArray = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(GoalType.TimeZoneGoalString, goals: goalsUnwrap)
            self.timeBucketData(.TimeZoneGoalString)
            
            self.nogoArray = GoalsRequestManager.sharedInstance.sortGoalsIntoArray(GoalType.NoGoGoalString, goals: goalsUnwrap)
            self.timeBucketData(.NoGoGoalString)
        }
    }
    
    fileprivate func callActivityCategory() {
        #if DEBUG
        print("****** ACTIVITY CALLED ******")
        #endif
        if UserDefaults.standard.bool(forKey: YonaConstants.nsUserDefaultsKeys.isLoggedIn) {
            Loader.Show()
            ActivitiesRequestManager.sharedInstance.getActivitiesNotAddedWithTheUsersGoals{ (success, message, code, budgetactivities,timezoneactivity,nogogoalactivity, goals, error) in
                Loader.Hide()
                if success{
                    self.activityCategoriesArrayBudget = budgetactivities!
                    self.activityCategoriesArrayTimeZone = timezoneactivity!
                    self.activityCategoriesArrayNoGoGoal = nogogoalactivity!
                    
                    //                    self.addNewGoalButton.hidden = !(self.activityCategoriesArray.count > 0)
                    //                    self.callGoals(self.activityCategoriesArray, goals: goals)
                    self.callGoals( goals)
                    self.setSelectedCategory(self.selectedCategoryView)
                } else {
                    if let message = message {
                        self.displayAlertMessage(message, alertDescription: "")
                    }
                    
                }
            }
        }
        
    }
    
    fileprivate func setupUI() {
        //Nav bar Back button.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        
        self.navigationItem.leftBarButtonItem = nil
        //    Looks for single or multiple taps.
        let budgetTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.budgetView.addGestureRecognizer(budgetTap)
        
        let timezoneTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.timezoneView.addGestureRecognizer(timezoneTap)
        
        let nogoTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector.categoryTapEvent)
        self.nogoView.addGestureRecognizer(nogoTap)
        
        
        
        self.budgetBadgeLabel.isHidden = true
        self.nogoBadgeLabel.isHidden = true
        self.timezoneBadgeLabel.isHidden = true
        
        setDeselectOtherCategory()
        // setSelectedCategory(self.nogoView)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    func setHeaderTitleLabel() {
        switch categoryHeader {
        case .budgetGoal:
            headerLabel.text = NSLocalizedString("challenges.user.budgetGoalHeader", comment: "")
        case .budgetActivity:
            headerLabel.text = NSLocalizedString("challenges.user.budgetCategoryHeader", comment: "")
        case .timeZoneGoal:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneGoalHeader", comment: "")
        case .timeZoneActivity:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneCategoryHeader", comment: "")
        case .noGoGoal:
            headerLabel.text = NSLocalizedString("challenges.user.nogoGoalHeader", comment: "")
        case .noGoActivity:
            headerLabel.text = NSLocalizedString("challenges.user.nogoCategoryHeader", comment: "")
        }
    }
    
    
    // MARK: - Tapgesture category view tap events
    @objc func categoryTapEvent(_ sender: UITapGestureRecognizer? = nil) {
        setDeselectOtherCategory()
        setSelectedCategory((sender?.view)!)
    }
    
    // MARK: - Actions
    @IBAction func back(_ sender: AnyObject) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "backActionBucketChallenges", label: "Back from time bucket challenge page", value: nil).build() as! [AnyHashable: Any])
        
        self.setSelectedCategory(selectedCategoryView)
    }
    
    @IBAction func addNewGoalbuttonTapped(_ sender: UIButton) {
        weak var tracker = GAI.sharedInstance().defaultTracker
        tracker!.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: "addNewGoalbuttonTapped", label: "Add new goal pressed", value: nil).build() as! [AnyHashable: Any])
        
        sender.isHidden = true
        self.navigationItem.leftBarButtonItem = self.backButton
        if selectedCategoryView == budgetView {
            categoryHeader = .budgetActivity
            
        } else if selectedCategoryView == timezoneView {
            categoryHeader = .timeZoneActivity
        } else if selectedCategoryView == nogoView {
            categoryHeader = .noGoActivity
        }
        self.setHeaderTitleLabel()
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationViewController = segue.destination
        var isfromActivity:Bool = true
        if categoryHeader == .budgetGoal || categoryHeader == .timeZoneGoal || categoryHeader == .noGoGoal{
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
                detailView.delegate = self
            case .TimeZoneChallengeSegue:
                
                let detailView = destinationViewController as! TimeFrameTimeZoneChallengeViewController
                if let activitySelectedUnwrap = self.activitySelected {
                    detailView.activitiyToPost = activitySelectedUnwrap
                }
                if let timezoneGoalSelectedUnwrap = self.budgetGoalSelected {
                    detailView.goalCreated = timezoneGoalSelectedUnwrap
                }
                detailView.isFromActivity = isfromActivity
                detailView.delegate = self
            case .NoGoChallengeSegue:
                let detailView = destinationViewController as! TimeFrameNoGoChallengeViewController
                if let activitySelectedUnwrap = self.activitySelected {
                    detailView.activitiyToPost = activitySelectedUnwrap
                }
                if let nogoGoalSelectedUnwrap = self.budgetGoalSelected {
                    detailView.goalCreated = nogoGoalSelectedUnwrap
                }
                detailView.isFromActivity = isfromActivity
                detailView.delegate = self
            }
        }
    }
    
}

extension TimeBucketChallenges {
    // MARK: - Table view data source
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch categoryHeader {
            
        case .budgetGoal:
            return self.budgetArray.count
            
        case .timeZoneGoal:
            return self.timeZoneArray.count
            
        case .noGoGoal:
            return self.nogoArray.count
            
        case .budgetActivity:
            return self.activityCategoriesArrayBudget.count
            
        case .timeZoneActivity:
            return self.activityCategoriesArrayTimeZone.count
            
        case .noGoActivity:
            return self.activityCategoriesArrayNoGoGoal.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "challengeCell", for: indexPath)
        
        switch categoryHeader {
        case .budgetGoal:
            if let activityCategoryNameUnwrap = self.budgetArray[indexPath.row].GoalName,
                let maxDurationMinutesUnwrap = self.budgetArray[indexPath.row].maxDurationMinutes {
                let localizedString = NSLocalizedString("challenges.user.budgetGoalDescriptionText", comment: "")
                let title = NSString(format: localizedString as NSString, String(maxDurationMinutesUnwrap), String(activityCategoryNameUnwrap))
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = title as String
                cell.detailTextLabel?.numberOfLines = 0
            }
            
        case .budgetActivity:
            cell.textLabel?.text = self.activityCategoriesArrayBudget[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .timeZoneGoal:
            if let activityCategoryNameUnwrap = self.timeZoneArray[indexPath.row].GoalName {
                var andConcate = [String]()
                for time in self.timeZoneArray[indexPath.row].zones {
                    let arr = time.dashRemoval()
                    let a = arr.joined(separator: NSLocalizedString("challenges.user.TimeZoneGoalDescriptionAndText", comment: ""))
                    andConcate.append(a)
                }
                let localizedString = NSLocalizedString("challenges.user.TimeZoneGoalDescriptionText", comment: "") + andConcate.joined(separator: NSLocalizedString("challenges.user.TimeZoneGoalDescriptionBetweenText", comment: ""))
                
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = localizedString
                cell.detailTextLabel?.numberOfLines = 2
                cell.detailTextLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
                //cell.detailTextLabel?.
            }
            
        case .timeZoneActivity:
            cell.textLabel?.text = self.activityCategoriesArrayTimeZone[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .noGoGoal:
            if let activityCategoryNameUnwrap = self.nogoArray[indexPath.row].GoalName,
                let _ = self.nogoArray[indexPath.row].maxDurationMinutes {
                let localizedString = NSLocalizedString("challenges.user.nogoGoalDescriptionText", comment: "")
                let title = NSString(format: localizedString as NSString, String(activityCategoryNameUnwrap))
                cell.textLabel?.text = activityCategoryNameUnwrap
                cell.detailTextLabel?.text = title as String
                cell.detailTextLabel?.numberOfLines = 0
            }
            
        case .noGoActivity:
            cell.textLabel?.text = self.activityCategoriesArrayNoGoGoal[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if categoryHeader == .budgetGoal || categoryHeader == .budgetActivity{
            switch categoryHeader {
            case .budgetActivity:
                self.activitySelected = self.activityCategoriesArrayBudget[indexPath.row]
            case .budgetGoal:
                self.budgetGoalSelected = self.budgetArray[indexPath.row]
            default:
                break
            }
            performSegue(withIdentifier: R.segue.timeBucketChallenges.budgetChallengeSegue, sender: self)
        } else if categoryHeader == .timeZoneGoal  || categoryHeader == .timeZoneActivity {
            switch categoryHeader {
            case .timeZoneActivity:
                self.activitySelected = self.activityCategoriesArrayTimeZone[indexPath.row]
            case .timeZoneGoal:
                self.budgetGoalSelected = self.timeZoneArray[indexPath.row]
            default:
                break
            }
            performSegue(withIdentifier: R.segue.timeBucketChallenges.timezoneChallengeSegue, sender: self)
        } else if categoryHeader == .noGoGoal  || categoryHeader == .noGoActivity {
            switch categoryHeader {
            case .noGoActivity:
                self.activitySelected = self.activityCategoriesArrayNoGoGoal[indexPath.row]
            case .noGoGoal:
                self.budgetGoalSelected = self.nogoArray[indexPath.row]
            default:
                break
            }
            performSegue(withIdentifier: R.segue.timeBucketChallenges.noGoChallengeSegue, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        self.tableView.rowHeight = UITableView.automaticDimension
        
        if categoryHeader == .budgetGoal || categoryHeader == .timeZoneGoal || categoryHeader == .noGoGoal {
            tableView.rowHeight =  100.0
        } else {
            tableView.rowHeight =  60.0
        }
        
        return self.tableView.rowHeight
        
    }
    
    func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        print(tableView.estimatedRowHeight)
        print(tableView.rowHeight)
        cell.contentView.layer.configureGradientBackground(tableView.rowHeight,colors: UIColor.yiBgGradientTwoColor().cgColor, UIColor.yiBgGradientOneColor().cgColor)
    }
}


private extension Selector {
    
    static let categoryTapEvent = #selector(TimeBucketChallenges.categoryTapEvent(_:))
    
    static let back = #selector(TimeBucketChallenges.back(_:))
}

// MARK: Touch Event of Custom Segment
extension TimeBucketChallenges {
    @IBAction func unwindToTimeBucketChallenges(_ segue: UIStoryboardSegue) {
        print(segue.source)
    }
}


