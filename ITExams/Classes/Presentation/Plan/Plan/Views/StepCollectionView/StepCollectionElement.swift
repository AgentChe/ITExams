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
        
        // TODO
        steps.enumerated().forEach { index, step in
            let locked = lastStepProgress < 100
            let s = PlanStep(name: step.name, sort: step.sort, progress: [0, 1].contains(index) ? 100 : step.progress, tests: [])
            let element = StepCollectionElement(step: s, locked: locked)
            result.append(element)
            
            lastStepProgress = s.progress
        }
        
        return result
    }
}
