//
//  PublicResultsViewController .swift
//  pPoll
//
//  Created by Nath on 9/21/16.
//  Copyright © 2016 syle. All rights reserved.
//

import UIKit
import Charts

class PublicResultsViewController: ResultViewController {
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        vote = [0.0, 0.0]
        print(responsesRef)
        
        if question.answers.count == 0 {
            getAnswers({ _ in
                self.loadQuestionFields()
                self.addResponseListeners(self.responsesRef)
            })
        }
        else {
            loadQuestionFields()
            self.addResponseListeners(self.responsesRef)
        }
    }
    
    override func addResponseToView(response: Response) {
        if !question.responses.contains(response) {
            question.responses.append(response)
            
            if response.answer == question.answers[0].id {
                vote[0] = vote[0] + 1
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
            else {
                vote[1] = vote[1] + 1
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
        }
        else {
            if response.answer == question.answers[0].id {
                vote[0] = vote[0] + 1
                
                if vote[1] != 0 {
                    vote[1] = vote[1] - 1
                }
                
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
            else {
                vote[1] = vote[1] + 1
                
                if vote[0] != 0 {
                    vote[0] = vote[0] - 1
                }
                
                self.leftResultLabel.text = self.leftQuestionPercentage(self.question)
                self.rightResultLabel.text = self.rightQuestionPercentage(self.question)
                
                setChart(removedselect, values: vote)
            }
        }
    }
    
    // Add graph methods
    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = Array()
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
            
        }
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Selection")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChartView.data = pieChartData
        pieChartView.animate(xAxisDuration: 2.0)
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        
        pieChartDataSet.colors = colors
    }
    
    override func reloadResultsDisplay() {
        setChart(removedselect, values: vote)
    }
    
    override func updateResponses(response: Response) {
        firebaseModel.updatePublicpPollQuestionResponse(question, response: response)
    }
    
    override func addDataPoint() {
        removedselect.append(question.answers[0].text)
        removedselect.append(question.answers[1].text)
        
        vote = [0.0,0.0]
        
        setChart(removedselect, values: vote)
    }
    
    @IBAction func unwindToPublicResults (segue : UIStoryboardSegue) {
        
    }}
