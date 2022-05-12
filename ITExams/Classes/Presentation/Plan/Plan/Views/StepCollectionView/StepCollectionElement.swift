//
//  StepCollectionElement.swift
//  ITExams
//
//  Created by Андрей Чернышев on 04.05.2022.
//

struct StepCollectionElement {
    let step: PlanStep
    let locked: Bool
}

// MARK: Public
extension StepCollectionElement {
    static func from(steps: [PlanStep]) -> [StepCollectionElement] {
        guard !steps.isEmpty else {
            return []
        }
        
        var result = [StepCollectionElement]()
        
        var lastStepProgress: Int = 100
        
        steps.enumerated().forEach { index, step in
            let locked = lastStepProgress < 100
            let element = StepCollectionElement(step: step, locked: locked)
            result.append(element)
            
            lastStepProgress = step.progress
        }
        
        return result
    }
    
    static func currentIndex(in elements: [StepCollectionElement]) -> Int? {
        guard !elements.isEmpty else {
            return nil
        }
        
        if let index = elements.firstIndex(where: { $0.step.progress != 100 }) {
            return index
        }
        
        return elements.count - 1
    }
}
