//
//  OPlanGridView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 10.03.2022.
//

import UIKit

final class OPlanGridView: UIView {
    lazy var line1View = makeLineView()
    lazy var line2View = makeLineView()
    lazy var line3View = makeLineView()
    lazy var line4View = makeLineView()
    lazy var line5View = makeLineView()
    lazy var line6View = makeLineView()
    lazy var line7View = makeLineView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Make constraints
private extension OPlanGridView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            line1View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line1View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line1View.heightAnchor.constraint(equalToConstant: 1.scale),
            line1View.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            line2View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line2View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line2View.heightAnchor.constraint(equalToConstant: 1.scale),
            line2View.topAnchor.constraint(equalTo: topAnchor, constant: 38.scale)
        ])
        
        NSLayoutConstraint.activate([
            line3View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line3View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line3View.heightAnchor.constraint(equalToConstant: 1.scale),
            line3View.topAnchor.constraint(equalTo: topAnchor, constant: 75.scale)
        ])
        
        NSLayoutConstraint.activate([
            line4View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line4View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line4View.heightAnchor.constraint(equalToConstant: 1.scale),
            line4View.topAnchor.constraint(equalTo: topAnchor, constant: 112.scale)
        ])
        
        NSLayoutConstraint.activate([
            line5View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line5View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line5View.heightAnchor.constraint(equalToConstant: 1.scale),
            line5View.topAnchor.constraint(equalTo: topAnchor, constant: 149.scale)
        ])
        
        NSLayoutConstraint.activate([
            line6View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line6View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line6View.heightAnchor.constraint(equalToConstant: 1.scale),
            line6View.topAnchor.constraint(equalTo: topAnchor, constant: 186.scale)
        ])
        
        NSLayoutConstraint.activate([
            line7View.leadingAnchor.constraint(equalTo: leadingAnchor),
            line7View.trailingAnchor.constraint(equalTo: trailingAnchor),
            line7View.heightAnchor.constraint(equalToConstant: 1.scale),
            line7View.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension OPlanGridView {
    func makeLineView() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.greyColor.withAlphaComponent(0.1)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
