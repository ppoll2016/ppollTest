//
//  PublicResultsViewController .swift
//  pPoll
//
//  Created by Nath on 9/21/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Charts

class PublicResultsViewController: ResultViewController, ChartViewDelegate {
    @IBOutlet weak var pieChartView: PieChartView!
    var selected = ["A", "B"]
    var removedselect:[String] = []
    var vote = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountsRef = ref.child("Accounts")
        responsesRef = ref.child("Responses").child(question.ID)
        answersRef = ref.child("Answers")
        
        vote.append(0.0)
        vote.append(0.0)
        
        pieChartView.delegate = self
        
        if !userResponsed() {
            pieChartView.noDataText = "Response to see results"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        vote = [0.0, 0.0]
        print(responsesRef)
        
        if question.answers.count == 0 {
            getAnswers({ _ in
                self.addDataPoint()
                
                self.loadQuestionFields()
                self.addResponseListeners(self.responsesRef)
            })
        }
        else {
            addDataPoint()
            
            if question.responses.count != 0 {
                reloadResponses()
            }
            
            loadQuestionFields()
            self.addResponseListeners(self.responsesRef)
        }
    }
    
    func reloadResponses() {
        for response in question.responses {
            if response.answer == question.answers[0].id {
                vote[1] = vote[1] + 1
            }
            else {
                vote[0] = vote[0] + 1
            }
        }
        
        reloadResultsDisplay()
    }
    
    func userResponsed() -> Bool {
        for response in question.responses {
            if response.owner == model.user.uid {
                return true
            }
        }
        
        return false
    }
    
    override func addResponseToView(response: Response) {
        if !question.responses.contains(response) {
            question.responses.append(response)
            
            if response.answer == question.answers[0].id {
                vote[1] = vote[1] + 1
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
            else {
                vote[0] = vote[0] + 1
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
        }
    }
    
    // Add graph methods
    func setChart(dataPoints: [String], values: [Double]) {
        if userResponsed() {
            var dataEntries: [ChartDataEntry] = Array()
            for i in 0..<dataPoints.count {
                let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
                dataEntries.append(dataEntry)
            }
            
            let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "")
            let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
            pieChartView.data = pieChartData
            pieChartView.descriptionText = ""
            pieChartView.legend.enabled = false
            pieChartView.rotationEnabled = false
            
            var colors: [UIColor] = []
            
            let redColour = UIColor.redColor()
            let greenColour = UIColor.greenColor()
            colors.append(redColour)
            colors.append(greenColour)
            
            pieChartDataSet.colors = colors
        }
        else {
            pieChartView.noDataText = "Response to see results"
        }
    }
    
    override func reloadResultsDisplay() {
        setChart(removedselect, values: vote)
    }
    
    override func updateResponses(response: Response) {
        firebaseModel.updatePublicpPollQuestionResponse(question, response: response)
    }
    
    override func updateResponseCounter(index: Int, responseCount: Double) {
        if index == 0 {
            vote[1] = responseCount
        }
        else {
            vote[0] = responseCount
        }
        setChart(removedselect, values: vote)
    }
    
    override func addDataPoint() {
        removedselect.append(question.answers[1].text)
        removedselect.append(question.answers[0].text)
    }
    
    @IBAction func unwindToPublicResults (segue : UIStoryboardSegue) {
        
    }
}
