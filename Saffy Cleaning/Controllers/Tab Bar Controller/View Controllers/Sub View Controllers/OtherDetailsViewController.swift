//
//  OtherDetailsViewController.swift
//  Saffy Cleaning
//
//  Created by Onurcan Sever on 2022-03-12.
//

import UIKit

protocol OtherDetailsViewDelegate: AnyObject {
    func addOtherDetails(pet: String, message: String, tips: String, selectedItems: [ExtraService])
}

class OtherDetailsViewController: UIViewController {
    
    private let petView = SCVerticalOrderInfoView(backgroundColor: .lightBrandLake2, height: 20)
    private var horizontalStackView: SCStackView!
    private let yesButton = SCRadioButtonView(title: "Yes")
    private let noButton = SCRadioButtonView(title: "No")
    private let quantityTextField = SCTextField(placeholder: "Describe quantity and type of pet in the place.")
    private let messageLabel = SCMainLabel(fontSize: 16, textColor: .brandDark)
    private let messageTextField = SCTextField(placeholder: "Leave a message to the cleaner...")
    private let extraServiceLabel = SCMainLabel(fontSize: 16, textColor: .brandDark)
    private lazy var serviceCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(SCExtraServiceCell.self, forCellWithReuseIdentifier: SCExtraServiceCell.identifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsMultipleSelection = true
        layout.scrollDirection = .horizontal
        
        return collectionView
    }()
    
    public weak var delegate: OtherDetailsViewDelegate?
    private var serviceArray = [ExtraService]()
    private var selectedArray = [ExtraService]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        configurePetView()
        configureHorizontalStackView()
        configureQuantityTextField()
        configureMessageLabel()
        configureMessageTextField()
        configureServiceLabel()
        configureCollectionView()
        setData()
        
        yesButton.delegate = self
        noButton.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    @objc private func okButtonTapped(_ button: UIBarButtonItem) {
        
        let pet = quantityTextField.text!
        let message = messageTextField.text!
        
        delegate?.addOtherDetails(pet: pet, message: message, tips: "USD 10", selectedItems: selectedArray)
    }
    
    private func setData() {
        
        serviceArray.append(ExtraService(image: UIImage(named: "carpet")!, name: "carpet\ncleaning"))
        serviceArray.append(ExtraService(image: UIImage(named: "carpet")!, name: "carpet\ncleaning"))
        serviceArray.append(ExtraService(image: UIImage(named: "carpet")!, name: "carpet\ncleaning"))
        
    }
    

}

extension OtherDetailsViewController: SCRadioButtonViewDelegate {
    
    func didTapRadioButton(_ button: UIButton) {
        
        if yesButton.radioButton.isSelected {
            noButton.radioButton.isSelected = false
        }
        
        if noButton.radioButton.isSelected {
            yesButton.radioButton.isSelected = false
        }
        
        switch button {
        case yesButton.radioButton:
            print("Yes Button clicked")
            yesButton.radioButton.isSelected = true
            noButton.radioButton.isSelected = false
        case noButton.radioButton:
            print("No button clicked")
            noButton.radioButton.isSelected = true
            yesButton.radioButton.isSelected = false
        default:
            break
        }
    }
    
    
}

extension OtherDetailsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SCExtraServiceCell.identifier, for: indexPath) as? SCExtraServiceCell else { return UICollectionViewCell() }
        
        cell.setData(image: serviceArray[indexPath.row].image, name: serviceArray[indexPath.row].name)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SCExtraServiceCell
        
        cell.setImageOpacity(opacity: 0.5)
        
        selectedArray.append(serviceArray[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SCExtraServiceCell
        
        cell.setImageOpacity(opacity: 1)
        
        selectedArray.remove(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension OtherDetailsViewController {
    
    private func configureViewController() {
        
        view.backgroundColor = .lightBrandLake2
        title = "Other details"
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let okButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(okButtonTapped(_:)))
        okButton.tintColor = .brandDark
        okButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.urbanistRegular(size: 18)!], for: .normal)
        navigationItem.leftBarButtonItem = okButton
    }
    
    private func configurePetView() {
        view.addSubview(petView)
        
        petView.infoLabel.text = "Pets"
        petView.infoValue.text = "Is/are there pets in the place?"
        
        NSLayoutConstraint.activate([
            petView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            petView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            petView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            petView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    
    private func configureHorizontalStackView() {
        horizontalStackView = SCStackView(arrangedSubviews: [yesButton, noButton])
        view.addSubview(horizontalStackView)
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 10
        horizontalStackView.distribution = .fillEqually
                
        NSLayoutConstraint.activate([
            yesButton.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor),
            noButton.heightAnchor.constraint(equalTo: horizontalStackView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            horizontalStackView.topAnchor.constraint(equalTo: petView.bottomAnchor, constant: 30),
            horizontalStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            horizontalStackView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func configureQuantityTextField() {
        view.addSubview(quantityTextField)
        
        NSLayoutConstraint.activate([
            quantityTextField.topAnchor.constraint(equalTo: horizontalStackView.bottomAnchor, constant: 10),
            quantityTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            quantityTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            quantityTextField.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    private func configureMessageLabel() {
        view.addSubview(messageLabel)
        messageLabel.text = "Message to cleaner"
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: quantityTextField.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            messageLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configureMessageTextField() {
        view.addSubview(messageTextField)
        
        NSLayoutConstraint.activate([
            messageTextField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            messageTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            messageTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            messageTextField.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    private func configureServiceLabel() {
        view.addSubview(extraServiceLabel)
        
        extraServiceLabel.text = "Extra services"
        
        NSLayoutConstraint.activate([
            extraServiceLabel.topAnchor.constraint(equalTo: messageTextField.bottomAnchor, constant: 15),
            extraServiceLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            extraServiceLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            extraServiceLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configureCollectionView() {
        serviceCollectionView.delegate = self
        serviceCollectionView.dataSource = self
        serviceCollectionView.clipsToBounds = false
        serviceCollectionView.backgroundColor = .lightBrandLake2
        view.addSubview(serviceCollectionView)
        
        NSLayoutConstraint.activate([
            serviceCollectionView.topAnchor.constraint(equalTo: extraServiceLabel.bottomAnchor, constant: 15),
            serviceCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            serviceCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            serviceCollectionView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
}