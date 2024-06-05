//
//  MapLaboratoryViewController.swift
//  KoreaTourist
//
//  Created by 의식주컴퍼니 on 6/1/24.
//

import UIKit
import Combine

import Then
import SnapKit
import CombineCocoa

final class MapLaboratoryViewController: UIViewController {
    // 지도 컨트롤 뷰
    private let minZoomControl = SliderControlView(title: "최소 줌 레벨",
                                                   minValue: 0,
                                                   maxValue: 15,
                                                   defaultValue: 15)
    private let maxZoomControl = SliderControlView(title: "최대 줌 레벨",
                                                   minValue: 18,
                                                   maxValue: 30,
                                                   defaultValue: 18)
    private let lightnessControl = SliderControlView(title: "지도 밝기",
                                                     minValue: -1,
                                                     maxValue: 1,
                                                     defaultValue: 0)
    private let symbolScaleControl = SliderControlView(title: "심볼 크기",
                                                       minValue: 0,
                                                       maxValue: 2,
                                                       defaultValue: 1)
    
    // 마커 컨트롤 뷰
    private let captionControl = SliderControlView(title: "캡션 사이즈",
                                                   minValue: 0,
                                                   maxValue: 50,
                                                   defaultValue: Float(Constant.defaultMarkerCaptionTextSize))
    private let subCaptionControl = SliderControlView(title: "서브캡션 사이즈",
                                                      minValue: 0,
                                                      maxValue: 50,
                                                      defaultValue: Float(Constant.defaultMarkerSubCaptionTextSize))
    private let imageWidthControl = SliderControlView(title: "이미지 너비 크기 (높이는 자동 조절)",
                                                      minValue: 0,
                                                      maxValue: 50,
                                                      defaultValue: Float(Constant.defaultMarkerImageWidth))
    
    // 시스템 컨트롤 뷰
    private let minDiscoveryDistControl = SliderControlView(title: "발견 가능한 최소 거리",
                                                         minValue: 0,
                                                         maxValue: 10000,
                                                         defaultValue: Float(Constant.minimumDiscoveryDistance))
    private let searchRadiusControl = SliderControlView(title: "검색 범위 (반경)",
                                                        minValue: 0,
                                                        maxValue: 10000,
                                                        defaultValue: Float(Constant.defaultSearchRadius))

    private var cancellables = Set<AnyCancellable>()
    
    var minZoomLevel: AnyPublisher<Float, Never> {
        self.minZoomControl.valuePublisher
    }
    var maxZoomLevel: AnyPublisher<Float, Never> {
        self.maxZoomControl.valuePublisher
    }
    var lightness: AnyPublisher<Float, Never> {
        self.lightnessControl.valuePublisher
    }
    var symbolScale: AnyPublisher<Float, Never> {
        self.symbolScaleControl.valuePublisher
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureSubviews()
        self.subscribeEvent()
    }
    
    private func subscribeEvent() {
        self.captionControl.valuePublisher
            .sink {
                Constant.defaultMarkerCaptionTextSize = CGFloat($0)
            }
            .store(in: &self.cancellables)
        
        self.subCaptionControl.valuePublisher
            .sink {
                Constant.defaultMarkerSubCaptionTextSize = CGFloat($0)
            }
            .store(in: &self.cancellables)
        
        self.imageWidthControl.valuePublisher
            .sink {
                Constant.defaultMarkerImageWidth = CGFloat($0)
            }
            .store(in: &self.cancellables)
        
        self.minDiscoveryDistControl.valuePublisher
            .sink {
                Constant.minimumDiscoveryDistance = CGFloat($0)
            }
            .store(in: &self.cancellables)
        
        self.searchRadiusControl.valuePublisher
            .sink {
                Constant.defaultSearchRadius = CGFloat($0)
            }
            .store(in: &self.cancellables)
    }
}

extension MapLaboratoryViewController {
    private func configureSubviews() {
        let mapControlStackView = self.controlStackView(title: "지도 컨트롤", subviews: [self.minZoomControl,
                                                                                    self.maxZoomControl,
                                                                                    self.lightnessControl,
                                                                                    self.symbolScaleControl])
        let markerControlStackView = self.controlStackView(title: "지도 마커 컨트롤", subviews: [self.captionControl,
                                                                                          self.subCaptionControl,
                                                                                          self.imageWidthControl])
        
        let systemControlStackView = self.controlStackView(title: "시스템 컨트롤", subviews: [self.minDiscoveryDistControl,
                                                                                          self.searchRadiusControl])
        
        
        
        let stackView = UIStackView(arrangedSubviews: [mapControlStackView,
                                                       markerControlStackView,
                                                       systemControlStackView])
        stackView.axis = .vertical
        stackView.spacing = 24
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.horizontalEdges.top.equalTo(self.view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    private func controlStackView(title: String, subviews: [UIView]) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
        titleLabel.text = title
        
        let controlStackView = UIStackView(arrangedSubviews: subviews)
        controlStackView.axis = .vertical
        controlStackView.spacing = 8
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, controlStackView])
        stackView.axis = .vertical
        stackView.spacing = 12
        
        return stackView
    }
}

extension MapLaboratoryViewController {
    final class SliderControlView: UIStackView {
        private let label = UILabel().then {
            $0.font = .systemFont(ofSize: 18, weight: .medium)
        }
        
        private let slider = UISlider(frame: .zero)
        private let title: String
        
        var valuePublisher: AnyPublisher<Float, Never> {
            self.slider.valuePublisher
        }
        
        init(title: String, minValue: Float, maxValue: Float, defaultValue: Float) {
            self.title = title
            super.init(frame: .zero)
            self.configureSubviews(title: title, minValue: minValue, maxValue: maxValue, defaultValue: defaultValue)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureSubviews(title: String, minValue: Float, maxValue: Float, defaultValue: Float) {
            self.axis = .vertical
            self.spacing = 2
            self.distribution = .fill
            self.addArrangedSubview(self.label)
            self.addArrangedSubview(self.slider)
            
            self.slider.minimumValue = minValue
            self.slider.maximumValue = maxValue
            self.slider.value = defaultValue
            
            self.slider.addTarget(self, action: #selector(self.updateLabel(_:)), for: .valueChanged)
            self.label.text = title
            self.updateLabel(self.slider)
        }
        
        @objc func updateLabel(_ slider: UISlider) {
            self.label.text = "\(self.title) - \(slider.value)"
        }
    }
}
