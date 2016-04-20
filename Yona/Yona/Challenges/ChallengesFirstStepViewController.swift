
//
//  ChallengesFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class ChallengesFirstStepViewController: UIViewController,UIScrollViewDelegate {
    
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
    
    var selectedCategoryView: UIView!
    var activityCategoriesArray = [Activities]()
    var goalsArray = [Goal]()
    
    var categoryHeader = SelectedCategoryHeader.BudgetGoal
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
    }
    
    // MARK: - private functions
    private func setSelectedCategory(categoryView: UIView) {
        
        addNewGoalButton.hidden = false
        backButton.hidden = true
        
        selectedCategoryView = categoryView
        categoryView.addBottomBorderWithColor(UIColor.yiWhiteColor(), width: 4.0)
        categoryView.alpha = 1.0
        if categoryView == budgetView {
            categoryHeader = .BudgetGoal
            self.callBudgetGoal()
        } else if categoryView == timezoneView {
            categoryHeader = .TimeZoneGoal
            self.callTimeZoneGoal()
        } else if categoryView == nogoView {
            categoryHeader = .NoGoGoal
            self.callNoGoGoal()
        }
        self.setHeaderTitleLabel()
    }
    
    private func callBudgetGoal() {
        APIServiceManager.sharedInstance.getGoalsOfType(.BudgetGoalString, onCompletion: { (success, message, code, goals, err) in
            if let goalsUnwrap = goals {
                if success {
                    self.goalsArray  = goalsUnwrap
                    if self.goalsArray.count > 0 {
                        self.budgetBadgeLabel.text = String(self.goalsArray.count)
                    } else {
                        self.budgetBadgeLabel.hidden = true
                    }
                    #if DEBUG
                        for goal in goalsUnwrap {
                            print(goal.goalType)
                        }
                    #endif
                    self.tableView .reloadData()
                } else {
                    
                }
            }
        })
    }
    
    private func callTimeZoneGoal() {
        APIServiceManager.sharedInstance.getGoalsOfType(.TimeZoneGoalString, onCompletion: { (success, message, code, goals, err) in
            if let goalsUnwrap = goals {
                if success {
                    self.goalsArray  = goalsUnwrap
                    if self.goalsArray.count > 0 {
                        self.timezoneBadgeLabel.text = String(self.goalsArray.count)
                    } else {
                        self.timezoneBadgeLabel.hidden = true
                    }
                    #if DEBUG
                        for goal in goalsUnwrap {
                            print(goal.goalType)
                        }
                    #endif
                    self.tableView .reloadData()
                } else {
                    
                }
            }
        })
    }
    
    private func callNoGoGoal() {
        APIServiceManager.sharedInstance.getGoalsOfType(.NoGoGoalString, onCompletion: { (success, message, code, goals, err) in
            if let goalsUnwrap = goals {
                if success {
                    self.goalsArray  = goalsUnwrap
                    if self.goalsArray.count > 0 {
                        self.nogoBadgeLabel.text = String(self.goalsArray.count)
                    } else {
                        self.nogoBadgeLabel.hidden = true
                    }
                    #if DEBUG
                        for goal in goalsUnwrap {
                            print(goal.goalType)
                        }
                    #endif
                    self.tableView .reloadData()
                } else {
                    
                }
            }
        })
        
    }
    
    private func setDeselectOtherCategory() {
        budgetView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        timezoneView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        nogoView.addBottomBorderWithColor(UIColor.yiPeaColor(), width: 4.0)
        
        budgetView.alpha = 0.5
        timezoneView.alpha = 0.5
        nogoView.alpha = 0.5
    }
    
    private func callGoals() {
        APIServiceManager.sharedInstance.getActivitiesArray{ (success, message, server, activities, error) in
            if success {
                APIServiceManager.sharedInstance.getUserGoals(activities!){ (success, message, code, goals, error) in
                    if(success){
                        if let goals = goals {
                            self.goalsArray  = goals
                            
                            #if DEBUG
                                for goal in goals {
                                    print(goal.goalType)
                                }
                            #endif
                            self.tableView.reloadData()
                        }
                    } else {
                        print("error in goals")
                    }
                }
            }
        }
    }
    
    private func callActivityCategory() {
        
        APIServiceManager.sharedInstance.getActivityCategories{ (success, serverMessage, serverCode, activities, err) in
            if success{
                self.activityCategoriesArray = activities!
            } else {
                print("error in callActivityCategory")
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
        
        self.callActivityCategory()
        self.callNoGoGoal()
        self.callTimeZoneGoal()
        self.callBudgetGoal()
        
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
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoryHeader == .BudgetGoal || categoryHeader == .TimeZoneGoal || categoryHeader == .NoGoGoal{
            return self.goalsArray.count
        } else {
            return self.activityCategoriesArray.count
        }
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        switch categoryHeader {
        case .BudgetGoal:
            let activityCategoryNameUnwrap = self.goalsArray[indexPath.row].goalType!
            let maxDurationMinutesUnwrap = String(self.goalsArray[indexPath.row].maxDurationMinutes)
            let localizedString = NSLocalizedString("challenges.user.budgetGoalDescriptionText", comment: "")
            let title = NSString(format: localizedString, maxDurationMinutesUnwrap, String(activityCategoryNameUnwrap))
            cell.textLabel?.text = activityCategoryNameUnwrap
            cell.detailTextLabel?.text = title as String
            cell.detailTextLabel?.numberOfLines = 0
            
        case .BudgetActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .TimeZoneGoal:
            cell.textLabel?.text = self.goalsArray[indexPath.row].goalType!
            //TODO: - work in progress
            cell.detailTextLabel?.text = "TimeZoneGoal"
            cell.detailTextLabel?.numberOfLines = 0
            
        case .TimeZoneActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
            
        case .NoGoGoal:
            cell.textLabel?.text = self.goalsArray[indexPath.row].goalType!
            cell.detailTextLabel?.text = "NoGoGoal"
            
        case .NoGoActivity:
            cell.textLabel?.text = self.activityCategoriesArray[indexPath.row].activityCategoryName!
            cell.detailTextLabel?.text = ""
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index  \(indexPath)")
        if categoryHeader == .BudgetGoal {
            performSegueWithIdentifier(R.segue.challengesFirstStepViewController.budgetChallengeSegue, sender: self)
        } else if categoryHeader == .TimeZoneGoal {
        performSegueWithIdentifier(R.segue.challengesFirstStepViewController.timezoneChallengeSegue, sender: self)
        } else if categoryHeader == .NoGoGoal {
            performSegueWithIdentifier(R.segue.challengesFirstStepViewController.noGoChallengeSegue, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if categoryHeader == .BudgetGoal || categoryHeader == .TimeZoneGoal || categoryHeader == .NoGoGoal{
            return 100.0
        } else {
            return 60.0
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(categoryHeader)
        
    }
}

private extension Selector {
    
    static let categoryTapEvent = #selector(ChallengesFirstStepViewController.categoryTapEvent(_:))
    
    static let back = #selector(ChallengesFirstStepViewController.back(_:))
}



