//
//  FooterView.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import UIKit

class FooterView: UIView {
    
    private let loadLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 161, green: 165, blue: 169, alpha: 1)
        return label
    }()
    
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupElements()
    }
    
    private func setupElements() {
        addSubview(loadLabel)
        addSubview(loader)
        
        loader.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
//        loader.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
//        loader.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        loader.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        
        loadLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        loadLabel.topAnchor.constraint(equalTo: loader.bottomAnchor, constant: 8).isActive = true
        
    }
    
    func showLoader() {
        loader.startAnimating()
        loadLabel.text = "Loading.."
    }
    
    func hideLoader() {
        loader.stopAnimating()
        loadLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
