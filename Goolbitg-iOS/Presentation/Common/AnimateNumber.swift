//
//  AnimateNumber.swift
//  Goolbitg-iOS
//
//  Created by Jae hyung Kim on 1/27/25.
//

import SwiftUI

struct AnimateNumber: View {
    
    private let formatter = GBNumberForMatter.shared
    
    // MARK: - Text Properties
    private let font: Font
    private let numberStyle: NumberFormatter.Style
    
    @Binding
    private var value: Double
    
    @Binding
    private var textColor: Color
    
    // MARK: - Animation Properties
    @State
    private var animationRange: [TextType] = []
    
    init(
        font: Font = .body,
        value: Binding<Double>,
        textColor: Binding<Color>,
        numberStyle: NumberFormatter.Style = .currency
    ) {
        self.font = font
        self._value = value
        self._textColor = textColor
        self.numberStyle = numberStyle
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(animationRange.indices, id: \.self) { index in
                switch animationRange[index] {
                case .string(let string):
                    Text(string)
                        .font(font)
                        .foregroundColor(textColor)
                case .number:
                    Text("8")
                        .font(font)
                        .opacity(0)
                        .overlay {
                            GeometryReader { proxy in
                                let size = proxy.size
                                
                                VStack(spacing: 0) {
                                    // MARK: - Since Its Individual Value
                                    // We Need Form 0-9
                                    ForEach(0...9, id: \.self) { number in
                                        Text("\(number)")
                                            .font(font)
                                            .frame(width: size.width,
                                                   height: size.height,
                                                   alignment: .center)
                                            .foregroundColor(textColor)
                                    }
                                }
                                // MARK: - Setting Offset
                                .offset(y: settingOffset(at: index, height: size.height))
                            }
                            .clipped()
                        }
                }
            }
        }
        .onAppear {
            // MARK: - Loading Range
            let stringValue = formatter.changeFormatToString(
                number: value,
                numberStyle: numberStyle
            )
            animationRange = Array(repeating: .string(""), count: stringValue.count)
            settingAnimationRange(stringValue, isAnimate: false)
        }
        .onChange(of: value) { newValue in
            // MARK: - Handling Addition/Removal to Extra Value
            let stringValue = formatter.changeFormatToString(
                number: newValue,
                numberStyle: numberStyle
            )
            resizeAnimationRange(to: stringValue.count, duration: 0.05)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                settingAnimationRange(stringValue, isAnimate: true)
            }
        }
    }
    
    private func resizeAnimationRange(to count: Int, duration: TimeInterval){
        let extra = count - animationRange.count
        
        if extra > 0 {
            // Adding Extra Range
            for _ in 0 ..< extra {
                withAnimation(.easeIn(duration: duration)) {
                    animationRange.append(.string(""))
                }
            }
        } else {
            // Removing Extra Range
            for _ in 0 ..< (-extra) {
                withAnimation(.easeIn(duration: duration)) {
                    _ = animationRange.removeLast()
                }
            }
        }
    }
    
    private func settingAnimationRange(_ string: String, isAnimate: Bool) {
        for (index, value) in string.enumerated() {
            // IF First Value = 1
            // Then Offset will be Applied for -1
            // So the text will move up to show 1 Value
            
            if isAnimate {
                // MARK: DampingFaction based on Index Value
                var fraction = Double(index) * 0.15
                // Max = 0.5
                // Total = 1.5
                fraction = (fraction > 0.5 ? 0.5 : fraction)
                
                withAnimation(.interactiveSpring(response: 0.45,
                                                 dampingFraction: 1 + fraction,
                                                 blendDuration: 1 + fraction)) {
                    animationRange.set(value, index: index)
                }
            } else {
                animationRange.set(value, index: index)
            }
        }
    }
    
    private func settingOffset(at index: Int, height: CGFloat) -> CGFloat {
        switch animationRange[index] {
        case .string:
            return 0
            
        case .number(let number):
            return -CGFloat(number) * height
        }
    }
}


enum TextType {
    case string(String)
    case number(Int)
}

extension Array where Element == TextType {
    mutating func set(_ value: Character, index: Int) {
        if let number = Int(String(value)) {
            self[index] = .number(number)
        } else {
            self[index] = .string(String(value))
        }
    }
}
