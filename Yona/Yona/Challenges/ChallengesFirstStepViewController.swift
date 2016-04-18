
//
//  ChallengesFirstStepViewController.swift
//  Yona
//
//  Created by Chandan on 11/04/16.
//  Copyright © 2016 Yona. All rights reserved.
//

import UIKit

class ChallengesFirstStepViewController: UIViewController,UIScrollViewDelegate {
    
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
    
    var selectedCategoryView: UIView!
    var activityCategoriesArray = [Activities]()
    var goalsArray = [Goal]()
    
    var categoryHeader = YonaConstants.GoalType.BudgetGoal
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        gradientView.colors = [UIColor.yiSicklyGreenColor(), UIColor.yiSicklyGreenColor()]
    }
    
    // MARK: - private functions
    private func setSelectedCategory(categoryView: UIView) {
        selectedCategoryView = categoryView
        categoryView.addBottomBorderWithColor(UIColor.yiWhiteColor(), width: 4.0)
        categoryView.alpha = 1.0
        if categoryView == budgetView {
            categoryHeader = YonaConstants.GoalType.BudgetGoal
        } else if categoryView == timezoneView {
            categoryHeader = YonaConstants.GoalType.TimeZoneGoal
        } else if categoryView == nogoView {
            categoryHeader = YonaConstants.GoalType.NoGo
        }
        
        self.setHeaderTitleLabel()
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
        APIServiceManager.sharedInstance.getUserGoals { (success, message, code, goals, error) in
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

    private func callActivityCategory() {
        
        APIServiceManager.sharedInstance.getActivityCategories{ (success, message,json, activities,error) in
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
        
        setDeselectOtherCategory()
        setSelectedCategory(self.budgetView)
        
        
        self.callActivityCategory()
        self.callGoals()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func setHeaderTitleLabel() {
        switch categoryHeader {
            
        case YonaConstants.GoalType.BudgetGoal:
            headerLabel.text = NSLocalizedString("challenges.user.budgetGoalHeader", comment: "")
        case YonaConstants.GoalType.BudgetActivity:
            headerLabel.text = NSLocalizedString("challenges.user.budgetCategoryHeader", comment: "")
        case YonaConstants.GoalType.TimeZoneGoal:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneGoalHeader", comment: "")
        case YonaConstants.GoalType.TimezoneActivity:
            headerLabel.text = NSLocalizedString("challenges.user.timezoneCategoryHeader", comment: "")
        case YonaConstants.GoalType.NoGo:
            headerLabel.text = NSLocalizedString("challenges.user.nogoGoalHeader", comment: "")
        case YonaConstants.GoalType.NogoActivity:
            headerLabel.text = NSLocalizedString("challenges.user.nogoCategoryHeader", comment: "")
        }
        
    }
    
    
    // MARK: - Tapgesture category view tap events
    func categoryTapEvent(sender: UITapGestureRecognizer? = nil) {
        setDeselectOtherCategory()
        setSelectedCategory((sender?.view)!)
    }
    
    
    // MARK: - Actions
    @IBAction func addNewGoalbuttonTapped(sender: UIButton) {
        if selectedCategoryView == budgetView {
            categoryHeader = YonaConstants.GoalType.BudgetActivity
        } else if selectedCategoryView == timezoneView {
            categoryHeader = YonaConstants.GoalType.TimezoneActivity
        } else if selectedCategoryView == nogoView {
            categoryHeader = YonaConstants.GoalType.NogoActivity
        }
        self.setHeaderTitleLabel()
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goalsArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        
        cell.textLabel?.text = self.goalsArray[indexPath.row].activityCategoryName!
        cell.textLabel?.numberOfLines = 0
        
        cell.detailTextLabel?.text = self.goalsArray[indexPath.row].goalType!
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
}

private extension Selector {
    
    static let categoryTapEvent = #selector(ChallengesFirstStepViewController.categoryTapEvent(_:))
    
}



