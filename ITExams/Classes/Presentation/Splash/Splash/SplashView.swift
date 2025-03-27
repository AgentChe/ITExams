//
//  SplashView.swift
//  ITExams
//
//  Created by Андрей Чернышев on 22.02.2022.
//

import UIKit

final class SplashView: UIView {
    lazy var waveView = makeWaveView()
    lazy var nameLabel = makeNameLabel()
    lazy var textLabel = makeTextLabel()
    lazy var preloader = makePreloader()
    lazy var preloaderLabel = makeLabel()
    lazy var imageView = makeImageView()
    
    private lazy var waveViewWidthConstraint = NSLayoutConstraint()
    private lazy var waveViewHeightConstraint = NSLayoutConstraint()
    
    private lazy var imageViewWidthConstraint = NSLayoutConstraint()
    private lazy var imageViewHeightConstraint = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension SplashView {
    func wave() {
        NSLayoutConstraint.deactivate([
            waveViewWidthConstraint,
            waveViewHeightConstraint
        ])
        
        waveViewWidthConstraint.constant = 1000.scale
        waveViewHeightConstraint.constant = 1000.scale
        
        NSLayoutConstraint.activate([
            waveViewWidthConstraint,
            waveViewHeightConstraint
        ])
        
        UIView.animate(withDuration: 1, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
    
    func compressImage(completion: @escaping () -> Void) {
        NSLayoutConstraint.deactivate([
            imageViewWidthConstraint,
            imageViewHeightConstraint
        ])
        
        imageViewWidthConstraint.constant = 100.scale
        imageViewHeightConstraint.constant = 100.scale
        
        NSLayoutConstraint.activate([
            imageViewWidthConstraint,
            imageViewHeightConstraint
        ])
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.waveView.backgroundColor = Appearance.main100
            self?.layoutIfNeeded()
        }, completion: { _ in
            completion()
        })
    }
}

// MARK: Private
private extension SplashView {
    func initialize() {
        backgroundColor = Appearance.custom230_231_248
    }
}

// MARK: Make constraints
private extension SplashView {
    func makeConstraints() {
        waveViewWidthConstraint = waveView.widthAnchor.constraint(equalToConstant: 0)
        waveViewHeightConstraint = waveView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            waveView.centerXAnchor.constraint(equalTo: centerXAnchor),
            waveView.centerYAnchor.constraint(equalTo: centerYAnchor),
            waveViewWidthConstraint,
            waveViewHeightConstraint
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12.scale.scale)
        ])
        
        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            textLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: centerXAnchor),
            preloader.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: 68.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloaderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            preloaderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            preloaderLabel.topAnchor.constraint(equalTo: preloader.bottomAnchor, constant: 12.scale)
        ])
        
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 500.scale)
        imageViewHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 500.scale)
        NSLayoutConstraint.activate([
            imageViewWidthConstraint,
            imageViewHeightConstraint,
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension SplashView {
    func makeWaveView() -> CircleView {
        let view = CircleView()
        view.backgroundColor = Appearance.custom230_231_248
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeNameLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono200)
            .font(Fonts.Inter.black(size: 32.scale))
            .lineHeight(38.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Splash.Name".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTextLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(Appearance.mono300)
            .font(Fonts.Inter.regular(size: 19.scale))
            .lineHeight(26.6.scale)
            .letterSpacing(-0.44.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Splash.Text".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePreloader() -> Spinner {
        let view = Spinner(size: CGSize(width: 32.scale, height: 32.scale))
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeImageView() -> UIImageView {
        let view = UIImageView()
        view.layer.cornerRadius = 20.scale
        view.layer.masksToBounds = true
        view.image = UIImage(named: "Splash.Image")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
