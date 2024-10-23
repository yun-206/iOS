//
//  HomeView.swift
//  iKREAM
//
//  Created by 김윤진 on 10/21/24.
//

import UIKit
import SnapKit
import Then

class HomeView: UIView {
    let segmentedControl = UISegmentedControl(items: ["추천", "랭킹", "발매정보", "럭셔리", "남성", "여성"]).then {
        $0.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        $0.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        $0.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        $0.setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        $0.selectedSegmentIndex = 0
        $0.setTitleTextAttributes(
            [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 15, weight: .light)
            ],
            for: .normal
        )
        $0.setTitleTextAttributes(
            [
            NSAttributedString.Key.foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 15, weight: .bold)
            ],
            for: .selected
            )
        }
    
    // 밑줄을 위한 뷰
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let recommendCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical // 수직 방향 스크롤
            $0.minimumInteritemSpacing = 9 // 좌우 간격 설정
            $0.minimumLineSpacing = 20 // 위아래 간격 설정
        }).then {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.register(HomeCollectionViewCell.self, forCellWithReuseIdentifier: HomeCollectionViewCell.identifier)
        }
    
    let emptyLable = UILabel().then {
        $0.font = .systemFont(ofSize: 13, weight: .medium)
        $0.textColor = .black
        $0.text = "휑~"
        $0.isHidden = true
    }
    
    let bannerImageView: UIImageView = {
        let bv = UIImageView()
        bv.image = UIImage(named: "banner")
        bv.contentMode = .scaleAspectFill
        return bv
    }()

    //MARK: UISegmentedControl
    let bellButton: UIButton = {
        let bll = UIButton()
        bll.setImage(UIImage(systemName: "bell"), for: .normal)
        bll.tintColor = .black
        return bll
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "브랜드,상품,프로필,태그 등" // 플레이스홀더 : 문구를 입력하기전에 보여주는 문구
        textField.font = .systemFont(ofSize: 13, weight: .regular)
        textField.layer.cornerRadius = 15 // 둥글게
        //textField.layer.borderWidth = 1
        textField.layer.backgroundColor = UIColor.systemGray6.cgColor
        textField.layer.masksToBounds = true // 콘텐츠가 레이어의 경게를 넘으면, 그 부분을 자를건지 묻는 여부 코드 (참)
        let leftview = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 16)) // 왼쪽에 공백 주는 코드
        textField.leftView = leftview
        textField.leftViewMode = .always
        
        textField.autocapitalizationType = .none // 첫 글자 대문자 (자동) 끄는 코드
        textField.autocorrectionType = .no // 추천글자 표시 끄는 코드
        textField.spellCheckingType = .no // 오타글자 표시 끄는 코드
        textField.returnKeyType = .done
        textField.clearsOnBeginEditing = false // 텍스트 필드 편집 시, 기존 값 제거 ( 기본이 false )
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // MARK: - SetupUI
    private func setupUI() {
        self.backgroundColor = .white
        self.addSubview(searchTextField)
        self.addSubview(bellButton)
        
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupView()
        setupSegmentedControlAction()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [
            segmentedControl,
            underLineView,
            emptyLable,
            bannerImageView,
            recommendCollectionView
        ].forEach{
            addSubview($0)
        }
        segmentedControl.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().inset(107)
            make.width.equalTo(325)
            make.height.equalTo(27)
        }
        // 밑줄의 초기 위치 및 크기 설정
        underLineView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.width.equalTo(28)
            make.height.equalTo(2) // 밑줄의 두께 설정
            make.leading.equalTo(segmentedControl.snp.leading) // 첫 번째 세그먼트 아래로 위치
        }
        emptyLable.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        bannerImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(134)
            make.width.equalTo(374)
            make.height.equalTo(336)
        }
        recommendCollectionView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalTo(segmentedControl.snp.bottom).offset(356)
            make.bottom.equalToSuperview().inset(138)
            make.width.equalTo(341)
            make.height.equalTo(182)
        }
    }
    
    private func setupSegmentedControlAction() {
        // 세그먼트 변경 액션 추가
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingOffset = CGFloat(sender.selectedSegmentIndex) * segmentWidth
        
        UIView.animate(withDuration: 0.3) {
            self.underLineView.snp.updateConstraints { make in
                make.leading.equalTo(self.segmentedControl.snp.leading).offset(leadingOffset)
            }
            self.layoutIfNeeded()
        }
        //각 세그먼트 별 눌렀을때
        if sender.selectedSegmentIndex == 0 {
            emptyLable.isHidden = true
            bannerImageView.isHidden = false
            recommendCollectionView.isHidden = false
        } else {
            emptyLable.isHidden = false
            bannerImageView.isHidden = true
            recommendCollectionView.isHidden = true
        }
    }
    
    
    // MARK: - SetupConstraints
    private func setupConstraints() {
        searchTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(51)
            make.width.equalTo(303)
            make.height.equalTo(40)
        }
        bellButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(334)
            make.top.equalToSuperview().inset(59)
            make.width.height.equalTo(24)

        }
        
    }



}