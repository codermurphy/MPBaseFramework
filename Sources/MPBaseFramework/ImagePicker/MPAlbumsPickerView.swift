//
//  MPAlbumsPickerView.swift
//  BasicProject
//
//  Created by ogawa on 2022/1/14.
//

import UIKit

class MPAlbumsPickerView: UIView {
    
    
    static func show(controller: UIViewController,dataSouce: [String],currentIndex: Int) -> MPAlbumsPickerView {
        let view = MPAlbumsPickerView(dataSouce: dataSouce, currentIndex: currentIndex)
        controller.view.addSubview(view)
        
        view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
        
        if #available(iOS 11.0, *) {
            view.topAnchor.constraint(equalTo: controller.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            view.topAnchor.constraint(equalTo: controller.topLayoutGuide.bottomAnchor).isActive = true
        }
        
        view.show()
        
        return view
    }
    
    
    //MARK: - initial
    
    init(dataSouce: [String],currentIndex: Int) {
        self.dataSource = dataSouce
        self.currentIndex = currentIndex
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = true
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - property
    
    var didSelectedAlbumBlock: ((Int) -> Void)?
    
    var hideCallback: (()->Void)?
    
    private var dataSource: [String]
    
    private var currentIndex: Int
    
    //MARK: - show and hidden
    func show() {
        self.alpha = 0
        self.contenView.transform = CGAffineTransform(translationX: 0, y: -contenView.rowHeight * CGFloat(dataSource.count))
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1
            self?.contenView.transform = CGAffineTransform.identity
        }
    }
    
    func hidden() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let weakSelf = self else { return }
            self?.alpha = 0
            self?.contenView.transform = CGAffineTransform(translationX: 0, y: -weakSelf.contenView.rowHeight * CGFloat(weakSelf.dataSource.count))
        } completion: { [weak self]_ in
            self?.removeFromSuperview()
        }

    }
    
    //MARK: - UI
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.7)
        return view
    }()
    
    private let contenView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.rowHeight = 50
        tableView.bounces = false
        tableView.register(MPAlbumsPickerCell.self, forCellReuseIdentifier: "MPAlbumsPickerCell-identifier")
        tableView.separatorColor = .lightGray.withAlphaComponent(0.5)
        tableView.separatorInset = .zero
        return tableView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
        if self.bounds.height >= contenView.rowHeight * CGFloat(dataSource.count) {
            contenView.frame = CGRect(origin: .zero, size: CGSize(width: containerView.frame.width, height: contenView.rowHeight * CGFloat(dataSource.count)))
        }
        else {
            contenView.frame = containerView.bounds
        }
    }
    
    
    private func commonInit() {
        
        self.addSubview(containerView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Self.tapGestureHandle(tap:)))
        tap.delegate = self
        containerView.addGestureRecognizer(tap)
        containerView.addSubview(contenView)
        contenView.dataSource = self
        contenView.delegate = self

    }
    
    // MARK: user interactive
    
    @objc private func tapGestureHandle(tap: UIGestureRecognizer) {
        self.hideCallback?()
        self.hidden()
        
    }
}

// MARK: UIGestureRecognizerDelegate

extension MPAlbumsPickerView: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: self)
        if contenView.frame.contains(point) {
            return false
        }
        else {
            return true
        }
    }
}

//MARK: - UITableViewDataSource
extension MPAlbumsPickerView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MPAlbumsPickerCell-identifier", for: indexPath) as! MPAlbumsPickerCell
        cell.nameLabel.text = dataSource[indexPath.row]
        if currentIndex == indexPath.row {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
}

extension MPAlbumsPickerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentIndex = indexPath.row
        didSelectedAlbumBlock?(indexPath.row)
        self.hidden()
    }
    
}

class MPAlbumsPickerCell: UITableViewCell {
    
    //MARK: - initial
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.backgroundColor = .black.withAlphaComponent(0.8)
        self.selectionStyle = .none
        layout()
        
        selectedView.isSelected = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - override
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        selectedView.isHidden = !selected
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        selectedView.isSelected = false
        selectedView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.bounds
    }
    
    //MARK: - UI
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    
    let selectedView: MPTickSelectedView = MPTickSelectedView(size: CGSize(width: 18, height: 18))
    
    private func layout() {
        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -50).isActive = true
        
        self.contentView.addSubview(selectedView)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        selectedView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
    }
}
